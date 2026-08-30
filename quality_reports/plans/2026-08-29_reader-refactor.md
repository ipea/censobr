# Plan — Reduce duplication across the microdata readers

**Status:** COMPLETED 2026-08-29 — full refactor **DROPPED** on review. `checkmate` asserts have no `call` argument (formals: x, na.ok, lower, upper, finite, null.ok, .var.name, add), so routing through a helper would permanently leak the internal name: `read_families(c(2000,2010))` would report `read_microdata(year = year)` instead of `read_families()`. That is ~30 asserts across 5 readers - the most common user-facing errors - and no existing test would catch it, since every `expect_error` matches message text only. Two of the three motivations also failed inspection: assert 'drift' was cosmetic (`assert_logical`'s `null.ok` already defaults FALSE) and both live merge guards were already correct. Implemented instead: `open_censobr_data()`, a validation-free URL+download+open helper - 20 lines to 9 in each of 5 readers, with zero error surface.
**Date:** 2026-08-29
**Scope:** `R/read_population.R`, `read_households.R`, `read_families.R`, `read_mortality.R`,
`read_emigration.R`, plus one new internal in `R/utils.R`. `read_tracts()` is **not** included.

---

## Context

Issue 3 from the `read_*()` diagnostic. Five readers of 59–67 lines each repeat the same body:

```
guard year declared -> assert inputs -> check year in `years` -> build URL ->
download_file() -> null-guard -> arrow_open_dataset() -> null-guard ->
[merge_households] -> check columns -> select -> add_labels -> [1960 warning] ->
collect or return
```

**This duplication is not cosmetic — it is the cause of most defects fixed this session.** Every
fix had to be applied 5–9 times, and the record shows what that costs:

- `merge_households` was guarded in two files but not the third
- `add_labels` asserts drifted apart between readers
- `read_tracts()` reported the 2010 dataset list for year 2000 (a copy-paste that was never fixed)
- I misplaced the `is.null(df)` merge guard **twice** while applying it by hand
- The `year` contract, the `columns` check, and `assert_number()` each needed 5–9 identical edits

The differences between the five are small and enumerable:

| reader | years | `merge_households` | labeller | 1960 warning |
|---|---|---|---|---|
| `read_population` | 1960–2010 | not exposed | `add_labels_population` | yes |
| `read_households` | 1960–2010 | not exposed | `add_labels_households` | yes |
| `read_families` | 2000 | not exposed | `add_labels_families` | no |
| `read_mortality` | 2010 | **live** | `add_labels_mortality` | no |
| `read_emigration` | 2010 | **live** | `add_labels_emigration` | no |

---

## Proposed change

One internal in `R/utils.R`; each exported reader becomes a thin wrapper that stays the documented,
roxygen'd public surface.

```r
#' @keywords internal
read_microdata <- function(dataset, year, years, columns, add_labels, merge_households,
                           as_data_frame, showProgress, cache, verbose, labeller) {

  if (missing(year) || is.null(year)) { error_year_not_declared() }
  checkmate::assert_number(year)
  checkmate::assert_vector(columns, null.ok = TRUE)
  checkmate::assert_logical(as_data_frame, null.ok = FALSE)
  checkmate::assert_logical(verbose, null.ok = FALSE)
  checkmate::assert_logical(merge_households, null.ok = FALSE)
  checkmate::assert_choice(add_labels, choices = 'pt', null.ok = TRUE)

  if (isFALSE(year %in% years)) { error_missing_years(years) }

  file_url <- paste0("https://github.com/ipea/censobr_prep_data/releases/download/",
                     censobr_env$data_release, "/", year, "_", dataset, "_",
                     censobr_env$data_release, ".parquet")

  local_file <- download_file(file_url, showProgress, cache, verbose)
  if (is.null(local_file)) { return(invisible(NULL)) }

  df <- arrow_open_dataset(local_file)
  if (is.null(df)) { return(invisible(NULL)) }

  if (isTRUE(merge_households)) {
    df <- merge_household_var(df, year = year, add_labels = add_labels,
                              showProgress = showProgress, verbose = verbose)
    if (is.null(df)) { return(invisible(NULL)) }
  }

  if (!is.null(columns)) {
    if (is.character(columns)) {
      absent <- setdiff(columns, names(df))
      if (length(absent) > 0) { error_columns_absent(absent) }
    }
    df <- dplyr::select(df, dplyr::all_of(columns))
  }

  if (!is.null(add_labels)) { df <- labeller(arrw = df, year = year, lang = add_labels) }

  if (year == 1960) { warning(msg_1960) }

  if (isTRUE(as_data_frame)) { return(dplyr::collect(df)) }
  return(df)
}
```

Each exported reader keeps its roxygen block and signature, e.g.:

```r
read_families <- function(year, columns = NULL, add_labels = NULL,
                          as_data_frame = FALSE, showProgress = TRUE,
                          cache = TRUE, verbose = TRUE) {
  read_microdata(dataset = "families", year = year, years = c(2000),
                 columns = columns, add_labels = add_labels, merge_households = FALSE,
                 as_data_frame = as_data_frame, showProgress = showProgress,
                 cache = cache, verbose = verbose, labeller = add_labels_families)
}
```

Rough effect: ~320 lines of body across five files collapse to one ~45-line helper plus five
~10-line wrappers.

---

## Constraints that must not break

1. **Public signatures unchanged.** `read_population()` and `read_households()` must NOT gain a
   `merge_households` argument; `read_mortality()` / `read_emigration()` must keep theirs. Argument
   **order** must not change — positional calls exist in tests and vignettes.
2. **`error_*()` helpers use `call = rlang::caller_env()`.** Routing through an extra frame will
   change error attribution from `read_families()` to `read_microdata()` unless the call frame is
   passed through. **This is the single highest-risk part of the plan.**
3. **`parent.frame()` lookups.** `download_file()` and `merge_household_var()` default several
   arguments to `parent.frame()$x`. All call sites here pass explicitly, but the reviewer must
   confirm nothing else relies on the frame.
4. **The 1960 warning** appears only in population/households.
5. `read_tracts()` stays as-is — different parameters (`dataset`, no `columns`/`add_labels`).

## Questions for the reviewer

1. **Is this refactor worth it at all**, given every reader is currently green and CRAN-clean?
   Argue the case for DROP. Churn on working code has its own risk.
2. Does passing a **labeller function** as an argument create an `R CMD check` problem
   (undefined global, or a `@keywords internal` doc requirement)?
3. Is the `caller_env()` attribution actually broken by the extra frame? **Test it**, do not reason.
4. Is a smaller intermediate better — e.g. extract only the download+open+null-guard block
   (~8 lines × 6 files) and leave the rest alone?

## Verification

- Error attribution unchanged: `read_families()` errors must still say ``Error in `read_families()` ``.
- Signatures byte-identical: compare `formals()` before/after for all five.
- `devtools::check(pkg = ".", cran = FALSE, env_vars = c(NOT_CRAN = "true"))` — the executing mode.
- Then `cran = TRUE, NOT_CRAN = "false"`.
