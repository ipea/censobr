# Working with 2022 microdata

## Why the 2022 census is different

For every census up to 2010, the microdata are openly available, and
**{censobr}** downloads them for you already processed. The sample
microdata of the 2022 census are not: IBGE releases them as *dados
controlados*, under controlled access. **{censobr}** is therefore not
allowed to redistribute them, and there is no file for the package to
download on your behalf.

What the package can do is read the file **you** obtained from IBGE and
store it in the local **{censobr}** cache, in the same format and under
the same naming convention as every other census year. That is what
[`import_microdata22_controlado()`](https://ipeagit.github.io/censobr/dev/reference/import_microdata22_controlado.md)
is for.

## Step 1. Get the data from IBGE

Request and download the 2022 sample microdata from IBGE at
<https://microdados.ibge.gov.br/>. Download the version of the data
saved in **`.csv`** format.

The file you receive is a single `.zip` holding one subdirectory per
state, each with four tables:

| File in the zip | Content    |
|-----------------|------------|
| `Domicilios`    | households |
| `Familia`       | families   |
| `Mortalidade`   | mortality  |
| `Pessoas`       | population |

## Step 2. Import it, once

Once you have downloaded the original zip file with the data, you only
need to pass the path to the zip file to
[`import_microdata22_controlado()`](https://ipeagit.github.io/censobr/dev/reference/import_microdata22_controlado.md).

Here’s an example using a tiny **fake** data set with the same structure
as the IBGE file.

``` r

library(censobr)

# path to the zip file with the raw data 
fake_zip <- system.file(
  "extdata/microdata_2022_controlado_fake.zip",
  package = "censobr"
  )

censobr::import_microdata22_controlado(zip_path = fake_zip)
```

The function unzips the file, converts each of the four tables to
Parquet, and saves them in the **{censobr}** cache directory. Depending
on your machine this takes a few minutes, most of it spent on the
`Pessoas` table.

And the data can be read back with
[censobr](https://github.com/ipea/censobr) using the familiar verbs:

``` r

pop <- censobr::read_population(year = 2022)

fam <- censobr::read_families(year = 2022)

hou <- censobr::read_households(year = 2022)

mor <- censobr::read_mortality(year = 2022)
```

## Keep the original zip file

You only need to import the data **once**. After that the tables sit in
the cache and are read from disk, with no further processing.

There is one case where you have to import them again. The **{censobr}**
cache is versioned by data release, and each release lives in its own
subdirectory. When a new version of the package points to a newer data
release, it will not find the files you imported under the previous one.

So **store the original `.zip` from IBGE somewhere safe**. It is the
only copy you have, the package cannot download it for you, and you will
need it if you upgrade **{censobr}** or move to another machine.
Deleting your cache with `censobr_cache(delete_file = "all")` has the
same consequence.
