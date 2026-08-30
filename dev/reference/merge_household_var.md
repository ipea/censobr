# Add household variables to the data set

Streams the main table through DuckDB's native parquet reader and joins
it to the (already downloaded, already labelled) household table,
writing the result to a temporary parquet file so a wide main table
never round-trips through memory. See
`quality_reports/plans/2026-08-30_merge-households-read-population.md`
for the design rationale and the memory measurements behind it.

## Usage

``` r
merge_household_var(
  df,
  year = parent.frame()$year,
  columns = NULL,
  add_labels = parent.frame()$add_labels,
  showProgress = parent.frame()$showProgress,
  cache = TRUE,
  verbose = parent.frame()$verbose
)
```

## Arguments

- df:

  An arrow `Dataset` passed from function above. Must be a plain
  `FileSystemDataset` backed by a single local parquet file, i.e. called
  before any
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
  or labelling step.

- year:

  Numeric. Passed from function above.

- columns:

  Character vector of column names, or `NULL` (the `columns` argument on
  the functions above is character-only, enforced by
  [`checkmate::assert_character()`](https://mllg.github.io/checkmate/reference/checkCharacter.html)
  before this function is ever reached). When character, pushed down
  into the join so only the requested columns (plus the join keys) are
  read and written – this is the difference between a multi-minute,
  multi-GB operation and a sub-second one. `NULL` reads the main table
  at full width.

- add_labels:

  Character. Passed from function above.

- showProgress:

  Logical. Passed from function above.

- cache:

  Logical. Passed from function above.

- verbose:

  Logical. Passed from function above.

## Value

An arrow `Dataset` with additional household variables, or
`invisible(NULL)` if the household data could not be downloaded or the
merge failed.
