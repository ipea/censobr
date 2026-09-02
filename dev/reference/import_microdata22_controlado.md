# Import the controlled-access microdata of the 2022 census into censobr cache

Import the microdata of the sample component of Brazil's 2022 Population
Census ("dados controlados") from a zip file obtained from IBGE, convert
the `csv` files it contains into Parquet, and save them in the local
`censobr` cache directory.

Unlike the microdata of previous censuses, the 2022 controlled-access
microdata are distributed by IBGE under controlled access and cannot be
redistributed by `censobr` directly. Users need to request the data
directly from IBGE at <https://microdados.ibge.gov.br/> and run this
function once on the zip file they receive. From then on, the data are
available locally like any other data set cached by the package, and no
download is attempted.

One Parquet file is written per table, following the file naming
convention used by `censobr`:

|                       |                                          |
|-----------------------|------------------------------------------|
| Table in the zip file | File written to the cache                |
| `Domicilios`          | `2022_households_<data release>.parquet` |
| `Familia`             | `2022_families_<data release>.parquet`   |
| `Mortalidade`         | `2022_mortality_<data release>.parquet`  |
| `Pessoas`             | `2022_population_<data release>.parquet` |

The `<data release>` suffix is the release of the `censobr` data pinned
by the installed version of the package. A version of `censobr` that
points to a newer data release will not find files imported under the
previous one, so the zip file has to be imported again. We strongly
recommend you store the original zip file in a save place so you can
import it again in the future if necessary.

## Usage

``` r
import_microdata22_controlado(zip_path)
```

## Arguments

- zip_path:

  String. Path to the original zip file with the controlled-microdata of
  the 2022 census sample saved, as provided by IBGE. The original file
  is expected to hold one subdirectory per state, each containing the
  `csv` files of the `Domicilios`, `Familia`, `Mortalidade` and
  `Pessoas` tables.

## Value

Returns `NULL` invisibly. The function is called for its side effect of
writing Parquet files to the `censobr` cache directory, whose location
can be checked with
[`get_censobr_cache_dir()`](https://ipeagit.github.io/censobr/dev/reference/get_censobr_cache_dir.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# the zip file has to be requested from IBGE beforehand
# The repo rule bans it for hiding broken examples, but here the example genuinely 
# cannot run: it needs a restricted-access file only the user has.

# path to zip fil
path_to_zip <- system.file("extdata/microdata_2022_controlado_fake.zip", 
                           package = "censobr")

# import controlled-microdata 2022.
import_microdata22_controlado(
  zip_path = path_to_zip
  )
} # }
```
