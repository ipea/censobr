# Plan — `.censobr_availability`: one source of truth for census year availability

**Status:** DRAFT (rev. 2, post-adversarial-review) · **Date:** 2026-09-04 · **Branch:** feature branch off `main`

## Context

Census year availability is hardcoded as `years <- c(...)` in **9 files** with no shared constant
(CLAUDE.md: *"There is no single constant — all copies must move together"*). That duplication
produced the originating bug: `a0bc4aa` added 2022 to `data_dictionary()`'s microdata list but left
the error strings saying "2000 and 2010". Those strings were repaired in `bf2959f`, which is now
`HEAD`; this plan removes the *conditions* that let them drift.

Behaviour-preserving: every registered value is transcribed verbatim from the literal it replaces,
and every year guard keeps its existing shape and message.

## The file — `R/availability.R` (new)

Plain comments, **no roxygen** — a roxygen block over a `list` emits a useless
`man/dot-censobr_availability.Rd` carrying a `\format{... of length N}` line that re-diffs on every
key added.

A top-level object, **not** `censobr_env$...`: `censobr_env` (`R/onLoad.R:1-9`) is mutable runtime
state populated inside `.onLoad()` and wrapped in `# nocov start/end`. A constant belongs in the
locked package namespace, where it is immutable and needs no load hook.

```r
# Single source of truth for which census years each public function serves.
# A new census release is added here, not in nine files.
# Values transcribed verbatim from the literals they replace -- behaviour-preserving.
.censobr_availability <- list(
  population            = c(1960, 1970, 1980, 1991, 2000, 2010, 2022),
  households            = c(1960, 1970, 1980, 1991, 2000, 2010, 2022),
  families              = c(2000, 2022),
  mortality             = c(2010, 2022),
  emigration            = c(2010),
  tracts                = c(2000, 2010, 2022),
  questionnaire         = c(1960, 1970, 1980, 1991, 2000, 2010, 2022),
  interview_manual      = c(1960, 1970, 1980, 1991, 2000, 2010, 2022),
  dictionary_microdata  = c(2000, 2010, 2022),
  dictionary_tracts     = c(1970, 1980, 1991, 2000, 2010, 2022),
  dictionary_population = c(1960, 1970, 1980, 1991),
  dictionary_households = c(1960, 1970, 1980, 1991)
)

# Internal accessor. Aborts loudly on an unregistered key.
censobr_years <- function(key) {
  out <- .censobr_availability[[key]]
  if (is.null(out)) cli::cli_abort("Internal error: no year list registered for {.val {key}}.")
  out
}
```

**Why an accessor.** Eight call sites pass a string literal, where inline `[[` would be equally safe
(`[[` is exact by default; only `$` partial-matches). The ninth, `data_dictionary()`, passes a
**computed** key — and there a miss returns `NULL`, making `year %in% NULL` always `FALSE` and firing
the year error with an empty list instead of failing. The `is.null()` check turns that into a loud
abort. Do **not** add `# nocov` — test 2 below covers it. Neither identifier appears in `R/`,
`tests/`, or `NAMESPACE` today.

## Call sites — verified against the working tree at `bf2959f`

| File:line | Becomes |
|---|---|
| `R/read_population.R:60` | `years <- censobr_years("population")` |
| `R/read_households.R:46` | `years <- censobr_years("households")` |
| `R/read_families.R:44` | `years <- censobr_years("families")` |
| `R/read_mortality.R:53` | `years <- censobr_years("mortality")` |
| `R/read_emigration.R:53` | `years <- censobr_years("emigration")` |
| `R/read_tracts.R:71` | `years <- censobr_years("tracts")` |
| `R/docs_questionnaire.R:42` | `years <- censobr_years("questionnaire")` |
| `R/docs_interview_manual.R:36` | `years <- censobr_years("interview_manual")` |
| `R/data_dictionary.R:81-94` | `years <- censobr_years(paste0("dictionary_", dataset))` — replaces four `if` blocks |

**Only the right-hand side of each `years <-` assignment changes.** Every guard below it is left
byte-for-byte alone — which matters, because the guards are *not* uniform: six sites call
`error_missing_years(years)`; `docs_questionnaire.R:43-47` and `docs_interview_manual.R:37-41` build
their own `cli_abort` from `paste(years, collapse = " ")`; `data_dictionary.R:96-111` has a bespoke
`cli_abort` plus a pre-2000 redirect branch.

The computed key is safe: by `data_dictionary.R:81`, `dataset` has passed `assert_string` (`:63`),
the `no_dictionary` abort (`:67`) and `isFALSE(dataset %in% data_sets)` (`:76`), so it is exactly one
of `microdata`, `tracts`, `population`, `households` — all four registered.

## Also: fix CLAUDE.md's availability table

Verified stale in **four rows** — it omits 2022 from `read_population()`, `read_households()`,
`read_families()` and `read_mortality()`, all of which now serve it (`R/read_population.R:60`,
`R/read_households.R:46`, `R/read_families.R:44`, `R/read_mortality.R:53`). CLAUDE.md loads into
every session's context, so a wrong table actively misinforms future work. Correct the four rows and
cite `R/availability.R` as the authority.

## Deliberately excluded

- **Labeller years** (`R/add_labels_*.R:9`) and **`merge_households` years**
  (`R/merge_household.R:43`, `R/read_population.R:66`, `:75`). Narrower than their readers, and one is
  inconsistent — `add_labels_families` covers `c(2000, 2010)` while `read_families` serves
  `c(2000, 2022)`. Registering them would smuggle an availability *decision* into a
  transcription-only refactor.
- **`R/data_dictionary.R:98`** — `year %in% c(1960, 1970, 1980, 1991)` means "pre-2000 censuses" and
  equals `dictionary_population` only by coincidence. Leave literal; add a one-line comment. (So the
  pre-2000 vector still appears three times: two identical registry keys plus `:98`. Deliberate.)
- **`read_tracts()` per-census dataset lists** (`R/read_tracts.R:77-86`) — a year×dataset matrix of a
  different shape.
- **A combined `censobr_check_year(year, key)`** — the guards are not uniform, so there is nothing to
  unify; and `error_missing_years()` aborts with `call = rlang::caller_env()`, so an extra frame would
  re-attribute year errors away from the public function.

## Test — `tests/testthat/test_availability.R` (new)

Structural and offline. **No `skip_on_cran()`** — this is the guard rail the refactor exists for.
(`test_zz_graceful_failure.R` is already un-gated, so this is not a new pattern.)

1. Every registry element is a numeric vector: sorted, no duplicates, all values `>= 1960`.
2. `censobr_years("nope")` aborts; `censobr_years("population")` returns the expected vector.
3. Every key actually used in `R/` resolves — loop the nine key strings, including the four
   `paste0("dictionary_", d)` forms, through `censobr_years()`.

Test 3 deliberately replaces "the nine functions still reject an out-of-range year": that is already
covered at `test_read_population.R:194`, `test_read_households.R:138`, `test_read_families.R:80`,
`test_read_mortality.R:95`, `test_read_emigration.R:84`, `test_read_tracts.R:120`,
`test_docs_questionnaire.R:96`, `test_docs_interview_manual.R:44`, `test_data_dictionary.R:34`.
Re-testing the call sites adds nothing; testing the *keys* is what the existing suite cannot do.

## Verification

1. **Transcription check (the one that matters).** Capture `grep -rnE "years *<-" R/` before the
   refactor; diff those year sets against `R/availability.R`. Must be identical.
2. `devtools::document()` — `git status` clean; **no new man page**, `NAMESPACE` unchanged. Confirm
   (do not assume) that the non-exported `.`-prefixed object raises no undocumented-object NOTE.
3. `devtools::test()` with `NOT_CRAN=true`; `test_availability.R` must also pass **offline**.
4. Spot-check the collapsed branch offline (the year guard precedes any download):
   `data_dictionary(1800, "microdata")` aborts listing 2000 2010 2022; `read_families(1960)` aborts
   listing 2000 2022.
5. `/r-package-check` — **both modes**, per CLAUDE.md's standing rule that the gate is
   `cran=TRUE`/`NOT_CRAN=false` *and* `cran=FALSE`/`NOT_CRAN=true`, since this touches `R/` and
   `tests/`. Bar: 0 errors, 0 warnings, every NOTE justified in `cran-comments.md`. Baseline 0/0/0.

## Commit

Single commit: `refactor: single source of truth for census year availability`.
No `NEWS.md` entry — no user-facing behaviour changes.

## Follow-ups

- `data_dictionary(2022, "microdata")` has no test — `test_data_dictionary.R:24` covers only
  `2022, "tracts"`. Left over from `bf2959f`.
- `read_population.R:75-76` repeats `c(1970, 2000, 2010)` in the guard and the error argument; bind to
  a local. Note the parallel `:66` `c(2010)` duplication — do both or neither.
- `add_labels_families()` covers 2010 but `read_families()` does not serve it — unreachable branch.
- `read_tracts()` per-census dataset lists still duplicated (`R/read_tracts.R:77-86` + roxygen).
