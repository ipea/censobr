# Delete files cached from previous data releases

The cache directory is versioned by data release
(`{cache_dir}/data_release_{tag}`), so bumping the data release leaves
the files of the previous one behind. This deletes them.

## Usage

``` r
delete_old_cache_dirs(verbose = TRUE)
```

## Arguments

- verbose:

  A logical. Whether the function should print informative messages.
  Defaults to `TRUE`.

## Value

The paths deleted, invisibly.

## Details

Only directories named `data_release_*` are considered, and the current
release is matched by equality rather than by pattern: the cache
directory can be any directory the user chose with
[`set_censobr_cache_dir()`](https://ipea.github.io/censobr/reference/set_censobr_cache_dir.md),
so anything else living there is none of the package's business.

Microdata imported with
[`import_microdata22()`](https://ipea.github.io/censobr/reference/import_microdata22.md)
are never deleted. They come from a zip file IBGE distributes under
controlled access, so censobr cannot download them again. A release
directory that still holds those files is kept.

Set `options(censobr.keep_old_cache = TRUE)` to disable this entirely,
for example to keep working with an older data release.
