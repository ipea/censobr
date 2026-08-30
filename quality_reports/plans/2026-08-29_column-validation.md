# Plan — Informative error for unknown `columns`

**Status:** COMPLETED 2026-08-29 — review cut roughly half. DROPPED: `utils::adist` near-matches (`utils` is not in Imports = undeclared dependency; and on the real 251-column schema `"V0602"` yields 85 suggestions, so edit-distance is noise on 5-char census codes) and the `assert_character` tightening (**numeric `columns` works today** — `c(1L,2L)` returns code_muni/code_state — so it was a live regression). ADDED: an `is.character(columns)` guard, because `setdiff` coerces numerics and would have falsely errored. Call sites = 5, not 6.
**Date:** 2026-08-29
**Scope:** One new internal helper in `R/utils.R`, six one-line call sites in the `read_*()` readers.

---

## Context

Issue 2 from the `read_*()` diagnostic. A mistyped column leaks dplyr/tidyselect internals:

```r
read_families(2000, columns = "NOT_A_COLUMN")
#> Error: ℹ In argument: `dplyr::all_of(columns)`.
#>   Caused by error in `dplyr::all_of()`...
```

`columns` is validated only as `assert_vector(columns, null.ok = TRUE)` — never against the
schema — so the failure happens inside `dplyr::select(df, dplyr::all_of(columns))` and the user sees
tidyselect internals instead of a censobr message.

The schema is already available at that point and cheap to read: `add_labels_population.R:14`
already does `cols <- names(arrw)` on the open Dataset (metadata only, no data read).

---

## The change

### 1. Helper in `R/utils.R`, alongside the existing `error_*` family

```r
#' Error when requested columns are not in the data
#'
#' @param df An arrow `Dataset`.
#' @param columns Character. Columns requested by the user.
#' @return An informative error, or TRUE invisibly.
#'
#' @keywords internal
check_columns <- function(df, columns) {

  available <- names(df)
  absent    <- setdiff(columns, available)
  if (length(absent) == 0) { return(invisible(TRUE)) }

  # suggest near matches for likely typos
  near <- available[utils::adist(tolower(absent[1]), tolower(available)) <= 2]

  msg <- c("Column{?s} {.val {absent}} not found in this data set.")
  if (length(near) > 0) {
    msg <- c(msg, "i" = "Did you mean {.val {near}}?")
  } else {
    msg <- c(msg, "i" = "Use {.code data_dictionary()} to see the variables available.")
  }

  cli::cli_abort(msg, call = rlang::caller_env())
}
```

### 2. Six call sites — `read_population`, `read_households`, `read_families`, `read_mortality`,
`read_emigration`, `read_tracts`

```diff
  if (!is.null(columns)) {
+   check_columns(df, columns)
    df <- dplyr::select(df, dplyr::all_of(columns))
  }
```

> `read_tracts()` has no `columns` parameter (its block is commented out), so it is **five** call
> sites, not six — to be confirmed by the reviewer.

### 3. Tighten the `columns` assert (same six files)

```diff
- checkmate::assert_vector(columns, null.ok = TRUE)
+ checkmate::assert_character(columns, null.ok = TRUE, any.missing = FALSE)
```

Catches `columns = 1:3` and `NA` before the schema check.

---

## Design decisions

- **Error, do not return `NULL`.** Fail-gracefully covers *internet* problems. A mistyped column is
  user input; returning `NULL` would hide the mistake. Same reasoning as the `year` / `dataset`
  validation already in place.
- **Do not print the full column list.** Census microdata has hundreds of variables. Near-match
  suggestion via `utils::adist` (base R, no new dependency), falling back to pointing at
  `data_dictionary()`.
- **Known limitation, to be stated not hidden:** validation runs *after* the download, because the
  schema comes from the file. A first-time typo on an 800 MB file still costs the download. Fixing
  that needs a schema cache and is out of scope.

## Questions for the reviewer

1. Is `utils::adist` worth it, or is the fallback message enough on its own? `utils` is already in
   Imports. Note `adist` on hundreds of columns × several absent names — is the cost trivial?
2. Should the check cover **all** absent columns' near matches, or only the first? The draft only
   suggests for `absent[1]`, which is arguably inconsistent.
3. Is `assert_character(any.missing = FALSE)` a behaviour change that could break a working call
   (e.g. someone passing a factor)?
4. Is a helper justified at all, or is `tryCatch` around the existing `select()` a smaller change?

## Verification

- `expect_error(read_families(2000, columns = "V0011x"), "not found")`, plus a near-match assertion.
  Needs the file cached → `skip_on_cran()`.
- `devtools::check(pkg = ".", cran = FALSE, env_vars = c(NOT_CRAN = "true"))` — the executing mode.
  Per `MEMORY.md`: a reduced check is not a check.
