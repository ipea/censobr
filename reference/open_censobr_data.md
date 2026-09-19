# Build the release URL, download it, and open it as an arrow Dataset

Contains no input validation, so that errors raised by the calling
function keep being attributed to that function rather than to this
helper.

## Usage

``` r
open_censobr_data(dataset, year, showProgress, cache, verbose)
```

## Arguments

- dataset:

  String. Name used in the file, e.g. "population" or "tracts_basico".

- year:

  Numeric. Year of reference.

- showProgress:

  Logical.

- cache:

  Logical.

- verbose:

  Logical.

## Value

An arrow `Dataset`, or `NULL` if the download or the file failed.
