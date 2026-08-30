# Download microdata of population records from Brazil's census

Download microdata of population records from Brazil's census. Data
collected in the sample component of the questionnaire.

## Usage

``` r
read_population(
  year,
  columns = NULL,
  add_labels = NULL,
  as_data_frame = FALSE,
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE,
  merge_households = FALSE
)
```

## Arguments

- year:

  Numeric. Year of reference in the format `yyyy`.

- columns:

  String. A vector of column names to keep. The rest of the columns are
  not read. Defaults to `NULL` and read all columns. If the user passes
  `merge_households = TRUE`, then the `columns` vector can also include
  the names of the households data set that should be kept.

- add_labels:

  Character. Whether the function should add labels to the responses of
  categorical variables. When `add_labels = "pt"`, the function adds
  labels in Portuguese. Defaults to `NULL`.

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

- merge_households:

  Logical. Indicate whether the function should merge household
  variables to the output data. Defaults to `FALSE`. When
  `merge_households = TRUE`, it is mandatory to pass the `columns`
  argument to select which columns should be kept. See the Details
  section.

## Value

An arrow `Dataset` or a `"data.frame"` object.

## Details

`merge_households = TRUE` is only available for years 1970, 2000 and
2010, and requires `columns` to be set. Merging household variables into
the full population microdata produces about 300 columns and can require
more than 20GB of memory; naming the columns you need keeps the
operation fast and light, typically a few seconds. The merge writes a
temporary parquet file that is removed when the R session ends.

## 1960 Census

The 1960 microdata version available in **censobr** is a combination of
two versions of the Demographic Census sample. The 25% sample data from
the 1960 Census was never fully processed by IBGE - several states did
not have their questionnaires digitized. Currently, this dataset only
has data from 16 states of the Federation (and from a contested border
region between Minas Gerais and Espirito Santo called Serra dos
Aimores). Information is missing for the states of the former Northern
Region, Maranhão, Piaui, Guanabara, Santa Catarina, and Espírito Santo.
In 1965, IBGE decided to draw a probabilistic sub-sample of
approximately 1.27% of the population, including all units of the
federation. With this data, IBGE produced several official reports at
the time. The data from **censobr** is the combination of these two
datasets.

We pre-processed the 1.27% sample data to ensured data consistency,
given the original data was partially corrupted. We also created a
sample weight variable to correct for unbalanced data and to expand te
sample to the total population. For the data from the 25% sample, the
weights expand to the municipal totals. Meanwhile, for the data from the
1.27% sample, the weights expand to the state totals. Additionally, we
constructed a few variables that allow for the approximate incorporation
of the complex sample design, enabling the proper calculation of
standard errors and confidence intervals.

You can read more about the 1960 Census and find a thorough
documentation of how this dataset was processed on this link
<https://github.com/antrologos/ConsistenciaCenso1960Br>.

## See also

Other Microdata:
[`read_emigration()`](https://ipeagit.github.io/censobr/dev/reference/read_emigration.md),
[`read_families()`](https://ipeagit.github.io/censobr/dev/reference/read_families.md),
[`read_households()`](https://ipeagit.github.io/censobr/dev/reference/read_households.md),
[`read_mortality()`](https://ipeagit.github.io/censobr/dev/reference/read_mortality.md)

## Examples

``` r
# return data as arrow Dataset
df <- read_population(
  year = 2010,
  showProgress = FALSE
  )
#> ℹ Downloading data and storing it locally for future use.
```
