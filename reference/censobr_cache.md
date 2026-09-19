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
  `NULL`, so that no file is deleted. Two values are read as keywords
  rather than as patterns: `delete_file = "all"` deletes all of the
  cached files, and `delete_file = "old"` deletes only the files cached
  from previous data releases.

- verbose:

  A logical. Whether the function should print informative messages.
  Defaults to `TRUE`.

## Value

A message indicating which file exist and/or which ones have been
deleted from the local cache directory.

## Details

censobr caches data in a directory versioned by data release, so a new
data release does not read files downloaded from the previous one. Files
from previous releases are deleted automatically the first time data is
downloaded in a session, and can be deleted at any time with
`delete_file = "old"`. Set `options(censobr.keep_old_cache = TRUE)` to
keep them, for example to go on working with an older data release.
Microdata imported with
[`import_microdata22()`](https://ipea.github.io/censobr/reference/import_microdata22.md)
are never deleted automatically, because censobr cannot download them
again.

## See also

Other Cache data:
[`get_censobr_cache_dir()`](https://ipea.github.io/censobr/reference/get_censobr_cache_dir.md),
[`set_censobr_cache_dir()`](https://ipea.github.io/censobr/reference/set_censobr_cache_dir.md)

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
