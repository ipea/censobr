# Import controlled-access microdata of the 2022 census into censobr cache

Import controlled-access microdata of the sample component of Brazil's
2022 Population Census ("dados controlados") from a zip file obtained
from IBGE, convert the `csv` files it contains into Parquet, and save
them in the local `censobr` cache directory.

Unlike the microdata of previous censuses, the 2022 controlled-access
microdata are distributed by IBGE under controlled access and cannot be
redistributed by `censobr` directly. Users need to request the data
directly from IBGE at <https://microdados.ibge.gov.br/> and run this
function once on the zip file they receive from IBGE. From then on, the
data are available locally like any other data set cached by the censobr
package, and no download is attempted.

One Parquet file is written per table, following the file naming
convention used by `censobr`:

|                       |                                                     |
|-----------------------|-----------------------------------------------------|
| Table in the zip file | File written to the cache                           |
| `Domicilios`          | `2022_households.controlado_<data release>.parquet` |
| `Familia`             | `2022_families.controlado_<data release>.parquet`   |
| `Mortalidade`         | `2022_mortality.controlado_<data release>.parquet`  |
| `Pessoas`             | `2022_population.controlado_<data release>.parquet` |

After that the tables sit in the cache and are read from disk, with no
further processing. The data imported via `import_microdata22()` lives
in the cache directory even if censobr updates to a new data release.
This means you only need to import the data **once**. Nonetheless, we
strongly recommend you **store the original `.zip` from IBGE somewhere
safe** in case you need to import that data again.

## Usage

``` r
import_microdata22(zip_path, verbose = TRUE)
```

## Arguments

- zip_path:

  String. Path to the local zip file with the controlled-microdata of
  the 2022 census sample saved, as provided by IBGE. The original file
  is expected to hold one subdirectory per state, each containing the
  `csv` files of the `Domicilios`, `Familia`, `Mortalidade` and
  `Pessoas` tables.

- verbose:

  A logical. Whether the function should print informative messages.
  Defaults to `TRUE`.

## Value

Returns `NULL` invisibly and prints message. The function is called for
its side effect of writing Parquet files to the `censobr` cache
directory, whose location can be checked with
[`get_censobr_cache_dir()`](https://ipea.github.io/censobr/reference/get_censobr_cache_dir.md).

## Examples

``` r
if (FALSE) { # \dontrun{

# **pointing to a temp cache dir just so this example does not overite cache**
temp_cache_dir <- fs::path_temp("temp_example")
censobr::set_censobr_cache_dir(temp_cache_dir)

# path to fake zip file
# **the real zip file has to be requested from IBGE beforehand**
path_to_zip <- system.file(
  "extdata/microdata_2022_controlado_fake.zip",
  package = "censobr"
)

# import controlled-access microdata 2022
censobr::import_microdata22(zip_path = path_to_zip)

# check files in cache dir
censobr::censobr_cache()

# set cache back to original dir
censobr::set_censobr_cache_dir(path = NULL)
} # }
```
