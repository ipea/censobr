# Error when merge_households is requested for a year that does not support it

Defensive only. Since the 1960 household key was documented, the
`merge_households` entry of the year registry matches the entry of the
data set being read, so no year that clears the availability check can
reach this error. It is kept so that the two registries diverging again
fails loudly instead of silently returning an unmerged result.

## Usage

``` r
error_merge_households_years(y)
```

## Arguments

- y:

  Vector with the years for which the household merge is available

## Value

An informative error
