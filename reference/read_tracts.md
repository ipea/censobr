# Download census tract-level data from Brazil's censuses

Download census tract-level aggregate data from Brazil's censuses.

## Usage

``` r
read_tracts(
  year,
  dataset,
  as_data_frame = FALSE,
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
)
```

## Arguments

- year:

  Numeric. Year of reference in the format `yyyy`.

- dataset:

  Character. The dataset to be opened. The following options are
  available for each edition of the census:

  **2000 Census**

  - `c("Basico", "Domicilio", "Responsavel", "Pessoa", "Instrucao", "Morador")`.

  **2010 Census**

  - `c("Basico", "Domicilio", "DomicilioRenda", "Responsavel", "ResponsavelRenda", "Pessoa", "PessoaRenda", "Entorno")`.

  **2022 Census**

  - `c("Basico", "Domicilio", "ResponsavelRenda", "Pessoas", "Indigenas", "Quilombolas", "Entorno", "Obitos", "Preliminares")`.

  The `censobr` package exposes all original IBGE census tracts
  datasets, regrouping them into broader themes and appending geographic
  identifiers so that they align seamlessly with `geobr` shapefiles.

  For a complete description of the datasets, themes, and variables,
  check

  - `data_dictionary(year = 2000, dataset = "tracts")`,

  - `data_dictionary(year = 2010, dataset = "tracts")`,

  - `data_dictionary(year = 2022, dataset = "tracts")`.

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

## Examples

``` r
library(censobr)

# return data as arrow Dataset
df <- read_tracts(
  year = 2022,
  dataset = 'Domicilio',
  showProgress = FALSE
  )
#> ℹ Downloading data and storing it locally for future use.

# return data as data.frame
df <- read_tracts(
  year = 2010,
  dataset = 'Basico',
  as_data_frame = TRUE,
  showProgress = FALSE
  )
#> ℹ Downloading data and storing it locally for future use.
```
