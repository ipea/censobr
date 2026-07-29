# Manage cached files from the censobr package

Manage cached files from the censobr package

## Usage

``` r
censobr_cache(
  list_files = TRUE,
  print_tree = FALSE,
  delete_file = NULL,
  verbose = TRUE
)
```

## Arguments

- list_files:

  Logical. Whether to print a message with the address of all censobr
  data sets cached locally. Defaults to `TRUE`.

- print_tree:

  Logical. Whether the cache files should be printed in a tree-like
  format. This parameter only works if `list_files = TRUE`. Defaults to
  `FALSE`.

- delete_file:

  String. The file name or a string pattern that matches the file path
  of a file cached locally and which should be deleted. Defaults to
  `NULL`, so that no file is deleted. If `delete_file = "all"`, then all
  of the cached files are deleted.

- verbose:

  A logical. Whether the function should print informative messages.
  Defaults to `TRUE`.

## Value

A message indicating which file exist and/or which ones have been
deleted from the local cache directory.

## See also

Other Cache data:
[`get_censobr_cache_dir()`](https://ipeagit.github.io/censobr/reference/get_censobr_cache_dir.md),
[`set_censobr_cache_dir()`](https://ipeagit.github.io/censobr/reference/set_censobr_cache_dir.md)

## Examples

``` r
# list all files cached
censobr_cache(list_files = TRUE)
#> ℹ Cache directory is currently empty.
#> character(0)

# delete particular file
censobr_cache(delete_file = '2010_deaths')
#> ℹ Cache directory is currently empty.
#> character(0)
```
