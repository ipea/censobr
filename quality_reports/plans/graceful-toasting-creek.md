# Plan — fix `data_dictionary(2022, "microdata")` + the drift that caused it

**Status:** DRAFT · **Date:** 2026-09-03 · **Branch:** feature branch off `main`

## Context

The reported error — `data_dictionary(2022, "microdata")` aborting with *"only available for the
years 2000 and 2010"* — **is not a source bug.** It reproduces against the *installed* package,
built from SHA `6f9d451`, one commit behind `a0bc4aa` ("Add 2022 to available years"). The asset
exists (`2022_dictionary_microdata.xlsx`, ~1.7 MB, `censo_docs` release) and the current working
tree downloads and opens it end-to-end. **The fix for the symptom is a reinstall** — blocked on this
machine by a gutted `curl` install whose DLL is held by a running `Rterm`; that is a user-side
action, tracked in the session log, not here.

Diagnosis surfaced three real code defects:

| # | Defect | Impact |
|---|---|---|
| A | Message strings said "2000 and 2010" next to `years <- c(2000, 2010, 2022)` | Users told 2022 is unavailable while it works |
| B | `vignettes/censobr.Rmd` cache section overrides the file's `NOT_CRAN` guard with `eval=TRUE` and calls `set_censobr_cache_dir()` | Writes a config file **outside `tempdir()`** — CRAN policy. Already left this machine's cache pointing at a dead temp dir, hiding 945 MB of downloaded parquet |
| C | No test for `data_dictionary(2022, "microdata")`; year lists duplicated across 9 files | The regression the user hit was untested and structurally invited |

**Outcome:** 2022 works and stays working; the vignette stops writing outside `tempdir()`; public
year availability lives in one place.

**Already in the working tree** (uncommitted, pre-planning): the three string fixes in
`R/data_dictionary.R`, regenerated `man/data_dictionary.Rd`, a NEWS bullet, one CLAUDE.md table row,
a first-pass vignette save/restore, and the user's cache config reset. Part 2 **revises** the
vignette edit; the rest is kept.

**Binding decisions:** (1) vignette — drop `eval=TRUE` *and* keep save/restore; (2) do introduce a
single source of truth for year availability.

---

## Part 1 — Finish the 2022 dictionary fix

- **`tests/testthat/test_data_dictionary.R`** — add `expect_message(tester(year = 2022, dataset =
  'microdata'))`; fix the stale comment at **line 31** ("years 2000 and 2010 only"); delete the
  **verbatim duplicate at lines 52-61** (repeats 41-50).
- **`vignettes/documentation.Rmd:99`** — year list omits 2022, and has a typo: `19960` → `1960`.
- **`MEMORY.md`** (`[LEARN:api]`, httr2 section) — asserts the microdata dictionary is *"published
  only for 2000 and 2010"*. Now false; would mislead future sessions. Correct in place.
- **`CLAUDE.md`** — refresh the availability table against source, and fix the export count:
  `NAMESPACE` exports **13**; the header says 12, omitting `import_microdata22_controlado()`.
  **Scope stops there.** The "Pipeline of each function" section has separate drift — verified:
  `merge_households` is live in `read_population()` (`:56` assert, `:90` merge), not "commented
  out"; `assert_choice(add_labels, choices = 'pt')` (`:57`) replaced the `assert_string(pattern=)`
  whose "ptbr passes silently" gotcha is documented; `open_censobr_data()` (`:81`) replaced the
  direct `download_file()` / `arrow_open_dataset()` calls. Deferred to its own commit rather than
  half-refreshed here — a half-true CLAUDE.md is worse than an obviously stale one.

## Part 2 — Vignette cache-dir leak

`vignettes/censobr.Rmd`, cache section. **Delete `eval=TRUE` from all four chunks: lines 390, 397,
405, 418.** All then inherit the global guard at line 17
(`eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true")`). Edit is delete-only; keep the
existing save/restore comments and calls.

All four matters. The working tree's save/restore pair (390, 418) currently carries `eval=TRUE`
itself, so fixing only the setter chunk would leave **line 418 calling `set_censobr_cache_dir()` on
CRAN** — the restore becoming the very violation being fixed. Precedent for the guard:
`tests/testthat/test_import_microdata22_controlado.R:3-5` skips the same call on CRAN because it
writes "outside tempdir(), which CRAN does not allow".

Trade-off accepted: `pkgdown::build_site()` needs `NOT_CRAN=true` for live output in that section.
NEWS bullet: building the vignettes no longer leaves the cache directory in a temp folder.

## Part 3 — Single source of truth for year availability

### New file `R/availability.R` — plain comments, **no roxygen**

A roxygen'd `list` generates `man/dot-censobr_availability.Rd` carrying a `\format{... of length N}`
line that re-diffs on every key added — a man page nobody reads that changes on every edit. No
`censobr_env` / `.onLoad` coupling either: a top-level literal has no load-order risk.

```r
# Single source of truth for which census years each public function serves.
# A new census release is added here, not in nine files.
# Values transcribed verbatim from the previous literals -- behaviour-preserving.
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

### Call sites

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
| `R/data_dictionary.R:82-93` | `years <- censobr_years(paste0("dictionary_", dataset))` — collapses four `if` branches |

The `paste0()` key is safe: by line 82 `dataset` has passed `assert_string` (`:63`), the
`no_dictionary` abort (`:67`) and `isFALSE(dataset %in% data_sets)` (`:76`), so it is one of exactly
four values, all four registered — and an unregistered key aborts loudly anyway.

### Local de-duplication (no registry expansion)

Two literals appear **twice each — in the guard and again in the error argument**, the exact drift
that produced defect A:

```r
R/read_population.R:66-67   year %in% c(2010)            + "...only available for the year c(2010)"
R/read_population.R:75-76   year %in% c(1970,2000,2010)  + error_merge_households_years(c(1970,2000,2010))
```

Bind each to a local variable used in both places. Purely local, no availability decision.

### Deliberately NOT registered — each a follow-up, not a rename

- **Labeller years** (`R/add_labels_*.R:9`) and **`merge_households` years**
  (`R/merge_household.R:43`). These are narrower than their readers and one is *inconsistent*:
  `add_labels_families` covers `c(2000, 2010)` while `read_families` serves `c(2000, 2022)`, so its
  2010 branch is unreachable. Registering them would smuggle an availability *decision* into a
  behaviour-preserving refactor.
- **`R/data_dictionary.R:98`** — `year %in% c(1960, 1970, 1980, 1991)` there means "pre-2000
  censuses" for a redirect message; it equals `dictionary_population` only by coincidence. Leave
  literal, with a comment saying why.
- **`read_tracts()` per-census dataset lists** (`R/read_tracts.R:77-86`) — a year×dataset matrix of
  a different shape.

### New test `tests/testthat/test_availability.R`

Structural only, offline, **no `skip_on_cran()`** — unlike every other file in the suite. This is
the guard rail the refactor exists for; gating it on CRAN defeats it.

- Every key returns a numeric vector: sorted, no duplicates, all values in `1960:2030`.
- `censobr_years("nope")` aborts.
- The nine reader/doc functions still reject an out-of-range year (`expect_error`), offline — the
  year guard runs before any download.

**No `labels ⊆ reader` subset invariant.** It fails today on `families` (above) and would go red on
the commit that introduces it, forcing an availability decision at the worst moment.

---

## Verification

Run against the scratch library that has a working curl:
`.libPaths(c("<scratchpad>/rlib", .libPaths()))`

1. **Behaviour preservation (Part 3)** — `grep -rnE "years *<-|%in% c\(" R/` before the refactor;
   diff against `R/availability.R`. Sets must be identical. *(Pre-verified twice during planning:
   all 12 registered values match source.)*
2. `devtools::test()` with `NOT_CRAN=true`. `test_availability.R` must pass **offline**.
3. **The reported case, end-to-end:**
   ```r
   p <- data_dictionary(2022, "microdata", verbose = FALSE)
   file.exists(p) && file.info(p)$size > 1e6   # not an exact byte count -- the asset may be republished
   ```
4. **Vignette restore** — record `get_censobr_cache_dir()`; `rmarkdown::render("vignettes/censobr.Rmd")`
   with `NOT_CRAN=true`; confirm unchanged. Then render with `NOT_CRAN` **unset** and confirm all
   four chunks are skipped and **no config file is written**.
5. **Release gate:** `/r-package-check` — `R CMD check --as-cran` in both modes (`cran=TRUE`/
   `NOT_CRAN=false` and `cran=FALSE`/`NOT_CRAN=true`). Bar: 0 errors, 0 warnings, every NOTE
   justified in `cran-comments.md`; baseline is 0/0/0. `devtools::document()` must leave `git status`
   clean apart from intended `man/` changes — **no new man page for `.censobr_availability`**.

## Commits

1. `fix: data_dictionary() year lists and messages for 2022 microdata` — Part 1.
2. `fix: vignettes no longer write a cache config outside tempdir()` — Part 2.
3. `refactor: single source of truth for census year availability` — Part 3.

Part 3 last: the behaviour-preserving refactor sits on a green tree and reverts alone if
`R CMD check` disagrees. Parts 1 and 2 are the user-visible fixes and ship independently.

## Follow-ups

- `add_labels_families()` covers 2010 but `read_families()` does not serve it — the branch is
  unreachable. Decide: extend the reader, or shrink the labeller.
- Labeller / `merge_households` year lists still outside the registry.
- `read_tracts()` per-census dataset lists still duplicated (`R/read_tracts.R:77-86` + roxygen).
- CLAUDE.md "Pipeline of each function" section stale in four verified places (see Part 1).
- `questionnaire()` / `interview_manual()` still call `browseURL()` unconditionally, without the
  `verbose` gate applied to `data_dictionary()` in v0.6.0 (issue #72).
- `import_microdata22_controlado()` uses `@examples \dontrun{}`; `@examplesIf` + the bundled fake zip
  in `inst/extdata` would make it runnable.
