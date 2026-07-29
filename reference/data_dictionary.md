# Data dictionary of Brazil's census data

Open on a browser the data dictionary of Brazil's census data.

## Usage

``` r
data_dictionary(
  year,
  dataset,
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
)
```

## Arguments

- year:

  Numeric. Year of reference in the format `yyyy`.

- dataset:

  Character. The type of data dictionary to be opened. Options include
  `c("microdata", "tracts", "population", "households", "families", "mortality", "emigration")`.
  In the case of `"microdata"`, the function opens an Excel file with
  the data dictionary of all variables, including auxiliary
  documentation.

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

Returns `NULL` and opens an .html, .pdf or excel file

## See also

Other Census documentation:
[`interview_manual()`](https://ipeagit.github.io/censobr/reference/interview_manual.md)

## Examples

``` r
# Open data dictionary
data_dictionary(
  year = 2010,
  dataset = 'microdata'
  )
#> ℹ Downloading data and storing it locally for future use.
#> NULL

data_dictionary(
  year = 2022,
  dataset = 'tracts'
  )
#> ℹ Downloading data and storing it locally for future use.
#> NULL

data_dictionary(
  year = 1980,
  dataset = 'households'
  )
#> ℹ Downloading data and storing it locally for future use.
#> NULL
```
