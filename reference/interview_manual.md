# Interview manual of the data collection of Brazil's censuses

Open on a browser the interview manual of the data collection of
Brazil's censuses

## Usage

``` r
interview_manual(
  year = NULL,
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
)
```

## Arguments

- year:

  Numeric. Year of reference in the format `yyyy`.

- showProgress:

  Logical. Defaults to `TRUE` display download progress bar. The
  progress bar only reflects only the downloading time, not the time to
  load the data to memory.

- cache:

  Logical. Whether the function should read the data cached locally,
  which is much faster. Defaults to `TRUE`. The first time the user runs
  the function, `censobr` will download the file and store it locally so
  that the file only needs to be download once. If `FALSE`, the function
  will download the data again and overwrite the local file.

- verbose:

  A logical. Whether the function should print informative messages.
  Defaults to `TRUE`.

## Value

Opens a `.pdf` file on the browser

## See also

Other Census documentation:
[`data_dictionary()`](https://ipeagit.github.io/censobr/reference/data_dictionary.md)

## Examples

``` r
# Open interview manual on the browser
interview_manual(
  year = 2010,
  showProgress = FALSE
  )
#> ℹ Downloading data and storing it locally for future use.
```
