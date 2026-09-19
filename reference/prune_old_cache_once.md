# Delete files from previous data releases once per session

Wraps
[`delete_old_cache_dirs()`](https://ipea.github.io/censobr/reference/delete_old_cache_dirs.md)
so that the check runs only the first time a versioned cache directory
is resolved in a session. The cache directory already checked is
recorded, rather than a flag, so that a user who switches directories
with
[`set_censobr_cache_dir()`](https://ipea.github.io/censobr/reference/set_censobr_cache_dir.md)
gets the new one checked too.

## Usage

``` r
prune_old_cache_once(verbose = TRUE)
```

## Arguments

- verbose:

  A logical. Whether the function should print informative messages.
  Defaults to `TRUE`.

## Value

The paths deleted, invisibly.
