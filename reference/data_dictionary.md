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

  Character (case insensitive). The type of data dictionary to be
  opened, either `"microdata"` or `"tracts"`. With `"microdata"`, the
  function opens a single Excel file with the data dictionary of all
  variables of the microdata, available for every census since 1960.
  With `"tracts"`, it opens the data dictionary of the census
  tract-level aggregate data, available since 1970.

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

Returns the path to the downloaded file. When `verbose = TRUE` and the
session is interactive, the file is also opened and the path is returned
invisibly.

## See also

Other Census documentation:
[`interview_manual()`](https://ipea.github.io/censobr/reference/interview_manual.md)

## Examples

``` r
# Open data dictionary
data_dictionary(
  year = 2022,
  dataset = 'microdata'
  )
#> ℹ Downloading data and storing it locally for future use.
#> /home/runner/.cache/R/censobr/data_release_v1.0.0/2022_dictionary_microdata.xlsx

data_dictionary(
  year = 2022,
  dataset = 'tracts'
  )
#> ℹ Downloading data and storing it locally for future use.
#> /home/runner/.cache/R/censobr/data_release_v1.0.0/2022_dictionary_tracts.xlsx
```
