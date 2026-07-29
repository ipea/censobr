# Add household variables to the data set

Add household variables to the data set

## Usage

``` r
merge_household_var(
  df,
  year = parent.frame()$year,
  add_labels = parent.frame()$add_labels,
  showProgress = parent.frame()$showProgress,
  verbose = parent.frame()$verbose
)
```

## Arguments

- df:

  An arrow `Dataset` passed from function above.

- year:

  Numeric. Passed from function above.

- add_labels:

  Character. Passed from function above.

- showProgress:

  Logical. Passed from function above.

- verbose:

  Logical. Passed from function above.

## Value

An arrow `Dataset` with additional household variables.
