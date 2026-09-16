# Plan — Unify the microdata data dictionary across all census years

**Date:** 2026-09-14 · **Status:** DRAFT · **Branch:** dev

---

## Context

`data_dictionary()` was written when the single-Excel microdata dictionary existed only for
2000, 2010 and 2022. Earlier censuses had two separate HTML codebooks each
(`{year}_dictionary_microdata_population.html`, `..._households.html`), exposed as
`dataset = "population"` / `"households"`.

The user has now uploaded `{year}_dictionary_microdata.xlsx` for **1960, 1970, 1980 and 1991**
to the `censo_docs` release. Verified live — all seven years return HTTP 200:

```
1960 ✓  1970 ✓  1980 ✓  1991 ✓  2000 ✓  2010 ✓  2022 ✓
```

So the per-dataset split no longer exists for any year. `R/availability.R:20` already
anticipates this (`dictionary_microdata = c(1960, 1970, 1980, 1991, 2000, 2010, 2022)`), but
`R/data_dictionary.R` still routes `population`/`households` to the HTML files, and its
year-availability check is commented out (`R/data_dictionary.R:82-102`, marked
`# CLAUDE, DELETE ?`) — so today an out-of-range year gets no validation at all and fails with
a generic download error.

**Outcome:** one dictionary file per census year for microdata; `"population"` and
`"households"` become permanent back-compatible aliases that warn and return that same file.

### Decisions taken (user, this session)

1. **Redirect for all years** — the legacy HTML branch is deleted outright, even though the
   HTML files still exist on the release for 1960–1991. One behaviour, one return type.
2. **`families` / `mortality` / `emigration` keep erroring** — they are distinct datasets the
   user named, not aliases. Only the stale "for the years 2000, 2010 and 2022" clause is fixed.
3. **Permanent alias, no lifecycle deprecation** — warns on every call, no removal timeline,
   no new {lifecycle} dependency.

---

## Changes

### 1. `R/data_dictionary.R` — the core

**a. Split the accepted values.** `data_sets` becomes the two real dictionaries; the aliases
live in their own vector:

```r
data_sets    <- c("microdata", "tracts")
legacy_micro <- c("population", "households")
```

`error_arg_not_declared('dataset', data_sets)` (`R/utils.R:299`) then lists only the two real
options — it still contains `"microdata"`, which the existing test asserts.

**b. Fix the `no_dictionary` abort message.** Drop the now-false "for the years 2000, 2010 and
2022" clause; the microdata dictionary covers every year.

**c. Insert the alias redirect**, after the `no_dictionary` check and *before* the
`dataset %in% data_sets` validation — so the warning fires early, regardless of whether the
download later succeeds:

```r
if (dataset %in% legacy_micro) {
  warning_dictionary_unified(dataset = dataset, year = year)
  dataset <- "microdata"
}
```

**d. Restore the year check** that is currently commented out, now as a plain lookup — there is
no longer a pre-2000 special case to branch on. Mirror the wording style of
`R/docs_questionnaire.R:42-49`:

```r
years <- censobr_years(paste0("dictionary_", dataset))
if (isFALSE(year %in% years)) {
  years_available <- paste(years, collapse = " ")
  cli::cli_abort(
    "The dictionary of {.val {dataset}} data is currently only available for the years {years_available}.",
    call = rlang::caller_env()
  )
}
```

Note the lookup happens *after* the redirect, so an alias is validated against
`dictionary_microdata`, not a key that no longer exists.

**e. Delete the HTML URL branch** (`R/data_dictionary.R:113-121`). The `microdata` and `tracts`
branches are unchanged; `open_file()` / `browseURL()` dispatch on extension and needs no edit
(the `'html'` case stays — harmless, and `tracts` still yields `.pdf` pre-2022).

**f. Update the roxygen `@param dataset`** — two real options plus a sentence naming the two
aliases and what they now return.

### 2. `R/utils.R` — new warning helper

Add `warning_dictionary_unified(dataset, year, call = rlang::caller_env())` alongside the
existing helpers, following the shape of `warning_microdata22_not_imported()` (`R/utils.R:401`):
`cli::cli_warn()`, `call =` for correct attribution, `#' @keywords internal`, wrapped in
`# nocov start/end`. Message: the `population`/`households` dictionaries are now unified into a
single microdata Excel file per census year, and this call is returning that file.

### 3. `R/availability.R` — drop two dead keys

Remove `dictionary_population` and `dictionary_households` (`R/availability.R:21-22`). Nothing
else reads them (grep-verified: only `R/data_dictionary.R:80` builds a `dictionary_*` key, and
after the redirect it can only produce `microdata` or `tracts`).

### 4. `tests/testthat/test_data_dictionary.R`

- **Remove the duplicated block** — the `households`/`population` error asserts and the
  `families`/`mortality`/`emigration` loop currently appear **twice**, verbatim.
- **Microdata, all seven years:** `expect_message()` for 1960, 1970, 1980, 1991, 2000, 2010,
  2022. This replaces `expect_error(tester(1991, 'microdata'))`, which now inverts.
- **Alias behaviour** (replaces the four `expect_error` asserts on `population`/`households`):
  - `expect_warning(tester(1960, 'population'), 'unified')`
  - `expect_warning(tester(2010, 'households'), 'unified')`
  - path identity: `suppressWarnings(tester(1980, 'households'))` is `identical()` to
    `tester(1980, 'microdata')` — the strongest assertion that the redirect really lands on the
    same file, and it reuses an already-cached download.
- **`families`/`mortality`/`emigration`** keep their `expect_error(..., 'no data dictionary
  published')` loop, kept once.
- **New year-range asserts**, covering the restored check:
  `expect_error(tester(1950, 'microdata'), 'only available')` and
  `expect_error(tester(1960, 'tracts'), 'only available')` (tracts start at 1970).
- Existing asserts on the `year`/`dataset` contract (`'declare'`, `'length 1'`, `'banana'`,
  `expect_no_message(verbose = FALSE)`) are unaffected.

### 5. `tests/testthat/test_availability.R`

`dictionary_keys` at `:46-47` enumerates all four `dictionary_*` keys; narrow it to
`c("microdata", "tracts")` or the "every key used in R/ resolves" test fails on the two removed
entries.

### 6. Documentation

- **`NEWS.md`** — replace the bullet at `:48-50` ("The `population` and `households`
  dictionaries remain available for the 1960, 1970, 1980 and 1991 censuses…"), which this change
  makes false, with the new behaviour: a microdata dictionary now exists for every census since
  1960, and `dataset = "population"`/`"households"` warn and return it.
- **`vignettes/documentation.Rmd`** — in the availability table (`:44-62`), the
  `data_dictionary()` / Microdata row: 1960 from italic `<i>X</i>` to `X`, 2022 from
  `<i>soon</i>` to `X`. In the prose at `:99`, fix the `19960` typo, add 1991/2022 to the year
  list, and state the unification.
- **`CLAUDE.md`** — the availability table lists
  `data_dictionary(dataset = "microdata") | 2000, 2010, 2022` and the docs-functions table
  describes the "5 microdata types→`.html`" branch. Both are now wrong; update to match.
- **`man/data_dictionary.Rd`** — regenerated, never hand-edited (`devtools::document()`).

---

## Order of work

1. `R/availability.R` → `R/utils.R` (helper) → `R/data_dictionary.R`
2. `devtools::document()`
3. Tests (both files)
4. Docs: `NEWS.md`, `vignettes/documentation.Rmd`, `CLAUDE.md`

---

## Verification

Network-dependent — confirm connectivity first (every example and test hits GitHub Releases).

```r
devtools::document()
devtools::check(pkg = ".", cran = FALSE, env_vars = c(NOT_CRAN = "true"))
```

Per [MEMORY.md](../../MEMORY.md), run tests through `devtools::check(cran = FALSE)`, not plain
`devtools::test()`.

Manual smoke test of the three paths:

```r
data_dictionary(1960, 'microdata')                 # new file, no warning
data_dictionary(1960, 'population')                # same path + 'unified' warning
identical(suppressWarnings(data_dictionary(1980, 'households')),
          data_dictionary(1980, 'microdata'))      # TRUE
data_dictionary(1950, 'microdata')                 # errors, lists the 7 years
data_dictionary(2010, 'families')                  # errors, no stale year clause
```

**Gate:** `R CMD check --as-cran` stays at the v0.6.0 baseline of 0 errors / 0 warnings /
0 notes. Run `/r-package-check` before merge.

---

## Out of scope

- Deleting the legacy `*_dictionary_microdata_{population,households}.html` assets from the
  `censo_docs` release — that is a `censobr_prep_data` decision, and leaving them costs nothing.
- `Config/testthat/edition: 3` (a separate deferred commit, per CLAUDE.md).
- The `vignettes/census_tracts_data.Rmd:90` prose/output drift (known follow-up #1, unrelated).
