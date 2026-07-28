# Working with larger-than-memory data

## Larger-than-memory Data

Many data sets of Brazilian censuses are too big to load in users’ RAM
memory. To avoid this problem, **{censobr}** works with files saved in
`.parquet` format and, by default, the functions in **{censobr}**
returns an [Arrow
table](https://arrow.apache.org/docs/r/articles/arrow.html#tabular-data-in-arrow)
rather than a `data.frame`. There are a few really simple alternative
ways to work with Arrow tables in R without loading the full data to
memory. We cover four alternative approaches in this vignette.

First, let’s read the 2010 mortality data, which we’ll use throughout
vignette for illustration purposes.

``` r

library(censobr)

# read 2010 mortality data
df <- censobr::read_mortality(
  year = 2010,
  add_labels = 'pt',
  showProgress = FALSE
  )
```

### 1. `{dplyr}`

Because of the seamless integration between
[arrow](https://github.com/apache/arrow/) and
[dplyr](https://dplyr.tidyverse.org), Arrow tables can be analyzed
pretty much like a regular `data.frame` using the
[dplyr](https://dplyr.tidyverse.org)syntax. There is a small but
important difference, though. When using {dplyr} with an Arrow table,
the operations are not executed immediately. Instead, {dplyr} builds a
lazy query plan that is only evaluated when you explicitly ask for the
results. To retrieve the actual results, you need to call either:

- [`collect()`](https://dplyr.tidyverse.org/reference/compute.html):
  This brings the results into memory as a regular `data.frame`.
- [`compute()`](https://dplyr.tidyverse.org/reference/compute.html):
  This materializes the result in the Arrow format (e.g., as a new Arrow
  table).

Without calling one of these, the query is just prepared but not
executed, which is useful for delaying heavy computations until needed.

In the example below, we create a new Arrow table that only includes the
deaths records of men in the state of Rio de Janeiro without loading the
data to memory. Note that we only piece of data we
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html)
(i.e. load to memory) here are the first observations of the data.

``` r

library(dplyr)

# Filter deaths of men in the state of Rio de Janeiro
rio <- df |>
      filter(V0704 == 'Masculino' & abbrev_state == 'RJ')

head(rio) |> 
  collect()
#> # A tibble: 6 × 26
#>   code_muni code_state abbrev_state name_state     code_region name_region
#> *     <dbl>      <dbl> <chr>        <chr>                <dbl> <chr>      
#> 1   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 2   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 3   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 4   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 5   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 6   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> # ℹ 20 more variables: code_weighting <dbl>, V0001 <chr>, V0002 <chr>,
#> #   V0011 <chr>, V0300 <dbl>, V0010 <dbl>, V1001 <chr>, V1002 <chr>,
#> #   V1003 <chr>, V1004 <chr>, V1006 <chr>, V0703 <chr>, V0704 <chr>,
#> #   V7051 <dbl>, V7052 <dbl>, M0703 <chr>, M0704 <chr>, M7051 <chr>,
#> #   M7052 <chr>, V1005 <chr>
```

### 2. `{duckdb}`

[duckdb](https://r.duckdb.org/) is another powerful library to work with
larger-than-memory data in R through database interface. There are
different ways to use [duckdb](https://r.duckdb.org/), but here cover
three alternatives

#### 2.1 Combining `{duckdb}` & `{dbplyr}`

One easy option is to combine [duckdb](https://r.duckdb.org/) &
[dbplyr](https://dbplyr.tidyverse.org/). Note here that first you need
to convert the Arrow table into a DuckDB table with
[`arrow::to_duckdb()`](https://arrow.apache.org/docs/r/reference/to_duckdb.html).
Also note that the you need to use a bit of `SQL` syntax inside the
dplyr call. Using the same example as above:

``` r

library(duckdb)
library(dbplyr)
library(arrow)

# Filter deaths of men in the state of Rio de Janeiro
rio1 <- df |>
        arrow::to_duckdb() |>
        filter(sql("V0704 LIKE '%Masculino%' AND abbrev_state = 'RJ'"))

head(rio1) |> 
  collect()
#> # A tibble: 6 × 26
#>   code_muni code_state abbrev_state name_state     code_region name_region
#>       <dbl>      <dbl> <chr>        <chr>                <dbl> <chr>      
#> 1   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 2   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 3   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 4   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 5   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> 6   3300100         33 RJ           Rio de Janeiro           3 Sudeste    
#> # ℹ 20 more variables: code_weighting <dbl>, V0001 <chr>, V0002 <chr>,
#> #   V0011 <chr>, V0300 <dbl>, V0010 <dbl>, V1001 <chr>, V1002 <chr>,
#> #   V1003 <chr>, V1004 <chr>, V1006 <chr>, V0703 <chr>, V0704 <chr>,
#> #   V7051 <dbl>, V7052 <dbl>, M0703 <chr>, M0704 <chr>, M7051 <chr>,
#> #   M7052 <chr>, V1005 <chr>
```

#### 2.2 Using `{duckdb}` with `SQL`

Another alternative is to combine [duckdb](https://r.duckdb.org/) with
[DBI](https://dbi.r-dbi.org) using database interface and `SQL` syntax.

``` r

library(duckdb)
library(DBI)

# create databse connection
con <- duckdb::dbConnect(duckdb::duckdb())
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpqC7zAe/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

# register the data in the data base
duckdb::duckdb_register_arrow(con, 'mortality_2010_tbl', df)

# Filter deaths of men in the state of Rio de Janeiro
query <- glue::glue("SELECT * FROM 'mortality_2010_tbl' 
         WHERE V0704 LIKE '%Masculino%' AND abbrev_state = 'RJ';")

rio2 <- DBI::dbGetQuery(con, query)

head(rio2)
#>   code_muni code_state abbrev_state     name_state code_region name_region
#> 1   3300100         33           RJ Rio de Janeiro           3     Sudeste
#> 2   3300100         33           RJ Rio de Janeiro           3     Sudeste
#> 3   3300100         33           RJ Rio de Janeiro           3     Sudeste
#> 4   3300100         33           RJ Rio de Janeiro           3     Sudeste
#> 5   3300100         33           RJ Rio de Janeiro           3     Sudeste
#> 6   3300100         33           RJ Rio de Janeiro           3     Sudeste
#>   code_weighting V0001 V0002         V0011   V0300    V0010 V1001 V1002 V1003
#> 1     3.3001e+12    33 00100 3300100003001 1285657 13.51819     3    05   013
#> 2     3.3001e+12    33 00100 3300100003001 6084726 12.76395     3    05   013
#> 3     3.3001e+12    33 00100 3300100003002  898500 10.68108     3    05   013
#> 4     3.3001e+12    33 00100 3300100003002 2581116 11.61204     3    05   013
#> 5     3.3001e+12    33 00100 3300100003002 3768175 12.93833     3    05   013
#> 6     3.3001e+12    33 00100 3300100003002 4125020 10.66262     3    05   013
#>   V1004  V1006             V0703     V0704 V7051 V7052 M0703 M0704 M7051 M7052
#> 1    00 Urbana     Março de 2010 Masculino    69    NA     2     2     2     2
#> 2    00 Urbana Fevereiro de 2010 Masculino    84    NA     2     2     2     2
#> 3    00 Urbana     Abril de 2010 Masculino    38    NA     2     2     2     2
#> 4    00 Urbana      Maio de 2010 Masculino    54    NA     2     2     2     2
#> 5    00  Rural    Agosto de 2009 Masculino    31    NA     2     2     2     2
#> 6    00 Urbana  Setembro de 2009 Masculino    28    NA     2     2     2     2
#>                                   V1005
#> 1                       Área urbanizada
#> 2                   Área não urbanizada
#> 3                       Área urbanizada
#> 4                       Área urbanizada
#> 5 Área rural exclusive aglomerado rural
#> 6                       Área urbanizada
```
