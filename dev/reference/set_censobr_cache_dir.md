# Set custom cache directory for censobr files

Set custom directory for caching files from the censobr package. The
user only needs to run this function once. This set directory is
persistent across R sessions.

## Usage

``` r
set_censobr_cache_dir(path, verbose = TRUE)
```

## Arguments

- path:

  String. The path to an existing directory. It defaults to
  `path = NULL`, to use the default directory

- verbose:

  A logical. Whether the function should print informative messages.
  Defaults to `TRUE`.

## Value

A message pointing to the directory where censobr files are cached.

## See also

Other Cache data:
[`censobr_cache()`](https://ipeagit.github.io/censobr/dev/reference/censobr_cache.md),
[`get_censobr_cache_dir()`](https://ipeagit.github.io/censobr/dev/reference/get_censobr_cache_dir.md)

## Examples

``` r

# Set custom cache directory
tempd <- tempdir()
set_censobr_cache_dir(path = tempd)
#> ℹ censobr files will be cached at /tmp/RtmpCQeIlH.

# back to default path
set_censobr_cache_dir(path = NULL)
#> ℹ censobr files will be cached at /home/runner/.cache/R/censobr.
```
