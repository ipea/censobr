# Download microdata of death records from Brazil's census

Download microdata of death records from Brazil's census. Data collected
in the sample component of the questionnaire.

## Usage

``` r
read_mortality(
  year,
  columns = NULL,
  add_labels = NULL,
  merge_households = FALSE,
  as_data_frame = FALSE,
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
)
```

## Arguments

- year:

  Numeric. Year of reference in the format `yyyy`.

- columns:

  String. A vector of column names to keep. The rest of the columns are
  not read. Defaults to `NULL` and read all columns.

- add_labels:

  Character. Whether the function should add labels to the responses of
  categorical variables. When `add_labels = "pt"`, the function adds
  labels in Portuguese. Defaults to `NULL`.

- merge_households:

  Logical. Indicate whether the function should merge household
  variables to the output data. Defaults to `FALSE`.

- as_data_frame:

  Logical. When `FALSE` (Default), the function returns an Arrow
  Dataset, which allows users to work with larger-than-memory data. If
  `TRUE`, the function returns `data.frame`.

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

An arrow `Dataset` or a `"data.frame"` object.

## See also

Other Microdata:
[`read_emigration()`](https://ipeagit.github.io/censobr/reference/read_emigration.md),
[`read_families()`](https://ipeagit.github.io/censobr/reference/read_families.md),
[`read_households()`](https://ipeagit.github.io/censobr/reference/read_households.md),
[`read_population()`](https://ipeagit.github.io/censobr/reference/read_population.md)

## Examples

``` r

# return data as arrow Dataset
df <- read_mortality(
  year = 2010,
  showProgress = FALSE
  )
#> ℹ Downloading data and storing it locally for future use.

# return data as data.frame
df <- read_mortality(
  year = 2010,
  as_data_frame = TRUE,
  showProgress = FALSE
  )
#> ℹ Reading data cached locally.
```
