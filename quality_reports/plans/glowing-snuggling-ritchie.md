# Plan — `merge_households = TRUE` for 1980 and 1991: inform, don't merge

**Status:** DRAFT (awaiting approval)
**Date:** 2026-09-13
**Request:** plan the changes so `merge_household_var()` works with 1980 and 1991, with
adversarial agents checking (a) the key columns against the IBGE data dictionaries and
(b) the minimality of the function changes. **User decision (2026-09-13):** when
`merge_households = TRUE` and `year` is 1980 or 1991, the `read_*()` function should throw
a message saying the population data set of those years already includes all variables
of the household data set.

---

## Context

`merge_household_var()` (`R/merge_household.R`) joins the person table to the household
table and is reachable with 1980/1991 only through `read_population()`
(`read_mortality()` / `read_emigration()` serve 2010/2022 and 2010). Both years currently
abort via `error_merge_households_years()`. Phase 0 (below) shows that a merge is
possible in both years but pointless: the population files already carry every household
variable. So the right change is not a new key branch but a clear, non-fatal notice, and
`merge_household_var()` itself changes only in a comment.

## Phase 0 — evidence (v0.7.0 release files via DuckDB `httpfs`; IBGE dictionaries)

| | 1980 | 1991 |
|---|---|---|
| Household variables also in the population file | all 38 (V2–V6, V198, V201–V221, V601–V603) | all 58 IBGE columns (V0109, V0111–V0112, V0201–V0227, V1061, V2012–V2122, V7001–V7003, V7300); only the pipeline id `iddomicilio` is household-only |
| Populated on person rows | `count(V201)` = 29,378,753 = n | `count(V0201)` = 17,045,653 = n |
| Equal to the household file's value | — | 200k-row sample join: V0201 100 %, V2012 99.99 % |
| A working key exists | `(code_state, code_muni, V601)` unique (6,716,885/6,716,885), LEFT JOIN keeps 29,378,753 rows, 100 % matched | `V0102` "Identificação do Questionário" unique nationally (4,024,543/4,024,543), LEFT JOIN keeps 17,045,653 rows, 100 % matched — even on the exact arrow-registered path, despite `V0102` being VARCHAR (population) vs DOUBLE (households) |
| The old 1991 key `(code_state, code_muni, V0109)` | — | 1,285,449 distinct: confirms the 74× row explosion of 2026-08-30 |

**Adversarial dictionary check** (fresh agent, four IBGE HTML dictionaries, windows-1252):
2 claims SUPPORTED, 3 PARTIALLY, 1 UNVERIFIABLE, 0 REFUTED. `V0102` is the only documented
identifier in 1991 (corroborated by `V0098` "00 para os registros de domicílio"); the
dictionary is silent on `V0109`'s numbering scope, so "numbered within a sector" must not
appear in user-facing text. In 1980, `V601` = "Número do Domicílio" (7 digits, positions
14–20), `V6` = "Distrito", `V603` = household weight. **Documentation gap found:** the 1980
and 1991 *population* dictionaries do not list the household variables that the population
parquet carries — a `data_dictionary()` follow-up, out of scope here.

**Adversarial minimality review** (fresh agent, on the earlier "add a 1991 branch" draft):
0 CRITICAL, 1 MAJOR, 4 MINOR. The MAJOR was that enabling 1980 as a no-op join is far more
than 3 lines (the merge test's probe column is NA, the whole 29M-row main table is still
copied through DuckDB) — this plan drops the branch idea entirely, which resolves it.
Retained from that review: edit the stale reason clauses in place (function comment,
`error_merge_households_years()`, NEWS, `@details`) rather than adding text; no new bullet
in NEWS because `read_population(merge_households)` is itself unreleased.

## Changes

### 1. `R/read_population.R` — the guard (the only behavioural change)

Replace the current `if (isTRUE(merge_households)) { ... }` block:

```r
  if (isTRUE(merge_households)) {
    # 1980 and 1991: the population microdata already carry every variable of
    # the household data set (verified on data release v0.7.0), so there is
    # nothing to merge. Say so and read the data as usual
    if (year %in% c(1980, 1991)) {
      message_households_in_population(year)
      merge_households <- FALSE
    } else {
      if (is.null(columns)) {
        error_merge_households_needs_columns()
      }
      merge_years <- censobr_years("merge_households")
      if (isFALSE(year %in% merge_years)) {
        error_merge_households_years(merge_years)
      }
    }
  }
```

The `columns` requirement is skipped for 1980/1991 on purpose: it exists to bound the
memory of a join that will not run. The rest of the function is untouched; with
`merge_households` now `FALSE`, the download, select and label steps run exactly as for
`merge_households = FALSE`, and the household file is never downloaded.

`@details`: "`merge_households = TRUE` is only available for years 1970, 2000, 2010 and
2022, and requires `columns` to be set. For 1980 and 1991 the population microdata
already include all variables of the household data set, so `merge_households = TRUE`
has no effect and a message says so."

### 2. `R/utils.R` — one new helper next to the two `error_merge_households_*()` helpers

```r
#' Message when merge_households is requested for a year whose population
#' microdata already include the household variables
#'
#' @param year Numeric. The census year.
#' @return An informative message
#' @keywords internal
message_households_in_population <- function(year) {
  # nocov start
  cli::cli_inform(
    c(
      "The {year} population microdata already include all variables of the household
      data set, so {.arg merge_households = TRUE} has no effect.",
      "i" = "Select household variables directly with {.arg columns}."
    )
  )
} # nocov end
```

Not gated on `verbose`: it reports an argument being ignored, like the 1960 `warning()`.
`cli_inform()` is a `message()`, so `suppressMessages()` silences it.

In `error_merge_households_years()` (`R/utils.R:351-353`) reword the reasons in place:
"1960 has no documented household key; the 1980 and 1991 population microdata already
include all variables of the household data set." (drops the now-wrong "1991's household
key is not unique" clause — true of the old `V0109`, but not the reason anymore).

### 3. `R/merge_household.R` — comment only

Lines 40-42: end the reasons after 1980 and add 1991 to it, mirroring the error helper.
No code line changes; `.censobr_availability$merge_households` stays
`c(1970, 2000, 2010, 2022)`, so a direct internal call with 1980/1991 still aborts.

### 4. Tests — `tests/testthat/test_read_population.R`

- In the ERRORs block, replace the two `expect_error(tester(year = 1980 / 1991, ..., merge_households = TRUE), '1970')`
  cases with, in the merge test:
  ```r
  # 1980 and 1991: nothing to merge -- a message, then the data as usual,
  # with the requested household variable served from the population file
  for (y in c(1980, 1991)) {
    hou_var <- if (y == 1980) 'V201' else 'V0201'
    testthat::expect_message(
      df_y <- tester(year = y, columns = hou_var, merge_households = TRUE),
      'already include'
      )
    testthat::expect_equal(names(df_y), hou_var)
    testthat::expect_true(is(df_y, "ArrowObject"))
  }
  # columns is not required when there is nothing to merge
  testthat::expect_message(tester(year = 1991, merge_households = TRUE), 'already include')
  ```
- Update the comment "only supports years 1970/2000/2010/2022" to mention that 1980/1991
  message instead of erroring. (1960 keeps its `expect_error(..., '1970')`.)

### 5. `NEWS.md` — edit the existing sentence in place (dev section, `merge_households` bullet)

"It is only available for census years 1970, 2000, 2010 and 2022 -- 1960 has no documented
household join key, and the 1980 and 1991 population microdata already include all
variables of the household data set, so for those years `merge_households = TRUE` has no
effect and says so with a message."

### 6. `devtools::document()` → `man/read_population.Rd`, `man/message_households_in_population.Rd`

Files touched: `R/read_population.R`, `R/utils.R`, `R/merge_household.R` (comment),
`tests/testthat/test_read_population.R`, `NEWS.md`, generated `man/`. Nothing in
`availability.R`, `test_availability.R`, or the SQL / push-down / pre-filter code.

## Verification

1. `read_population(1991, columns = 'V0201', merge_households = TRUE)` and the 1980 twin:
   one message, an arrow Dataset with exactly the requested column, no household file
   downloaded (check `censobr_cache()` shows no `1991_households` file on a clean cache).
2. `read_population(1991, merge_households = TRUE)` (no `columns`): message, full Dataset,
   no error. `read_population(1960, columns = 'V2', merge_households = TRUE)`: still errors
   listing 1970.
3. 2010 / 2022 merge behaviour unchanged (existing loop test).
4. `devtools::check(pkg = ".", cran = FALSE, env_vars = c(NOT_CRAN = "true"))` → 0 errors;
   then `cran = TRUE, NOT_CRAN = "false"` → 0/0.
5. Post-implementation adversarial pass: a fresh `verifier` fork reads the diff and checks
   it contains nothing beyond sections 1-6 above, and re-runs step 1.

## Follow-ups (not in this change)

- Report upstream to `ipea/censobr_prep_data`: `V0102` typed VARCHAR in `1991_population`
  and DOUBLE in `1991_households`.
- `data_dictionary(1980 / 1991, "population")` does not document the household variables
  the population parquet carries; consider pointing users to the households dictionary.
