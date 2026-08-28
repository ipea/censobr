# Questionnaires used in the data collection of Brazil's censuses

Open on a browser the questionnaire used in the data collection of
Brazil's censuses

## Usage

``` r
questionnaire(year, type, showProgress = TRUE, cache = TRUE, verbose = TRUE)
```

## Arguments

- year:

  Numeric. Year of reference in the format `yyyy`.

- type:

  Character. The type of questionnaire used in the survey, whether the
  `"long"` one used in the sample component of the census, or the
  `"short"` one, which is answered by more households. Options include
  `c("long", "short")`.

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

## Examples

``` r
library(censobr)

# Open questionnaire on browser
questionnaire(year = 2010, type = 'long', showProgress = FALSE)
#> ℹ Downloading data and storing it locally for future use.
#> /home/runner/.cache/R/censobr/data_release_v0.6.0/2010_questionnaire_long.pdf
```
