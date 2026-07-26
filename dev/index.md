# censobr: Download Data from Brazil’s Population Census

[![CRAN
status](https://www.r-pkg.org/badges/version/censobr)](https://CRAN.R-project.org/package=censobr)
[![CRAN/METACRAN Total
downloads](https://cranlogs.r-pkg.org/badges/grand-total/censobr?color=blue)](https://CRAN.R-project.org/package=censobr)
[![Codecov test
coverage](https://codecov.io/gh/ipea/censobr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ipea/censobr?branch=main)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-yellow.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![R-CMD-check](https://github.com/ipea/censobr/actions/workflows/R-CMD-check.yaml/badge.svg?branch=main)](https://github.com/ipea/censobr/actions?query=branch%3Amain)
[![Paper](https://img.shields.io/badge/DOI-10.1590%2Fdados--2026--69--1--006-blue)](https://doi.org/10.1590/dados.2026.69.1.006)

**{censobr}** is an R package to download data from Brazil’s Population
Census. It provides a very simple and efficient way to download and read
the data sets and documentation of all the population censuses taken in
and after 1960 in the country. The package is built on top of the [Arrow
platform](https://arrow.apache.org/docs/r/), which allows users to work
with larger-than-memory census data using [{dplyr} familiar
functions](https://arrow.apache.org/docs/r/articles/arrow.html#analyzing-arrow-data-with-dplyr).

## Installation

``` r

# install from CRAN
install.packages("censobr")

# or use the development version with latest features
utils::remove.packages('censobr')
remotes::install_github("ipea/censobr", ref="dev")
library(censobr)
```

## Basic usage

The package currently includes 6 main functions to download & read
census data:

1.  [`read_population()`](https://ipeagit.github.io/censobr/dev/reference/read_population.md)
2.  [`read_households()`](https://ipeagit.github.io/censobr/dev/reference/read_households.md)
3.  [`read_mortality()`](https://ipeagit.github.io/censobr/dev/reference/read_mortality.md)
4.  [`read_families()`](https://ipeagit.github.io/censobr/dev/reference/read_families.md)
5.  [`read_emigration()`](https://ipeagit.github.io/censobr/dev/reference/read_emigration.md)
6.  [`read_tracts()`](https://ipeagit.github.io/censobr/dev/reference/read_tracts.md)

**{censobr}** also includes a few support functions to help users
navigate the documentation Brazilian censuses, providing convenient
information on data variables and methodology:

7.  [`data_dictionary()`](https://ipeagit.github.io/censobr/dev/reference/data_dictionary.md)
8.  [`questionnaire()`](https://ipeagit.github.io/censobr/dev/reference/questionnaire.md)
9.  [`interview_manual()`](https://ipeagit.github.io/censobr/dev/reference/interview_manual.md)

Finally, the package includes three functions to help users manage the
data cached locally.

10. [`censobr_cache()`](https://ipeagit.github.io/censobr/dev/reference/censobr_cache.md)
11. [`set_censobr_cache_dir()`](https://ipeagit.github.io/censobr/dev/reference/set_censobr_cache_dir.md)
12. [`get_censobr_cache_dir()`](https://ipeagit.github.io/censobr/dev/reference/get_censobr_cache_dir.md)

The syntax of all **{censobr}** functions to read data operate on the
same logic so it becomes intuitive to download any data set using a
single line of code. Like this:

    read_households(
      year,          # year of reference
      columns,       # select columns to read
      add_labels,    # add labels to categorical variables
      as_data_frame, # return an Arrow DataSet or a data.frame
      showProgress,  # show download progress bar
      cache,         # cache data for faster access later
      verbose        # whether to print informative messages
      )

***Note:*** all data sets in **{censobr}** are enriched with geography
columns following the name standards of the [{geobr}
package](https://github.com/ipea/geobr/) to help data manipulation and
integration with spatial data from {geobr}. The added columns are:
`c(‘code_muni’, ‘code_state’, ‘abbrev_state’, ‘name_state’, ‘code_region’, ‘name_region’, ‘code_weighting’)`.

### Data cache

The first time the user runs a function, **{censobr}** will download the
file and store it locally. This way, the data only needs to be
downloaded once. When the `cache` parameter is set to `TRUE` (Default),
the function will read the cached data, which is much faster.

- [`censobr_cache()`](https://ipeagit.github.io/censobr/dev/reference/censobr_cache.md):
  can be used to list and/or delete data files cached locally
- [`set_censobr_cache_dir()`](https://ipeagit.github.io/censobr/dev/reference/set_censobr_cache_dir.md):
  can be used to set custom cache directory for **{censobr}** files
- [`get_censobr_cache_dir()`](https://ipeagit.github.io/censobr/dev/reference/get_censobr_cache_dir.md):
  returns the path of the cache directory in use

## Larger-than-memory Data

Microdata of Brazilian census are often be too big to load in users’ RAM
memory. To avoid this problem, **{censobr}** will by default return an
[Arrow
table](https://arrow.apache.org/docs/r/articles/arrow.html#tabular-data-in-arrow),
which can be analyzed like a regular `data.frame` using the `dplyr`
package without loading the full data to memory.

More info in the package [vignette](https://ipea.github.io/censobr/).

## Contributing to censobr

If you would like to contribute to **{censobr}**, you’re welcome to open
an issue to explain the proposed a contribution.

------------------------------------------------------------------------

#### **Related projects**

As far as we know, **{censobr}** is the only R package that provides
fast and convenient access to the complete data sets and documentation
of Brazilian censuses. The
[microdadosBrasil](https://github.com/lucasmation/microdadosBrasil)
package used to provide access to microdata of several public data sets,
but unfortunately, it has been discontinued.

#### **Similar packages for other countries**

- Bolivia: [censosbo](https://lab-tecnosocial.github.io/censosbo/)
- Canada: [cancensus](https://mountainmath.github.io/cancensus/)
- Chile: [censo2017](https://docs.ropensci.org/censo2017/)
- US: [tidycensus](https://walker-data.com/tidycensus/)
- World: [ipumsr](https://tech.popdata.org/ipumsr/)

## Credits [![IPEA](reference/figures/ipea_logo.png)](https://www.ipea.gov.br)

Original Census data is collected by the Brazilian Institute of
Geography and Statistics (IBGE). The **{censobr}** package is developed
by a team at the Institute for Applied Economic Research (Ipea), Brazil.
If you want to cite this package, you can cite it as:

- Pereira, R. H., & Barbosa, R. J. (2026). {censobr}: Fácil Acesso aos
  Dados dos Censos Demográficos Brasileiros. Dados, 69(1), e20240150.
  <https://doi.org/10.1590/dados.2026.69.1.006>

&nbsp;


    @article{pereira2026censobr,
      title={$\{$censobr$\}$: F{\'a}cil Acesso aos Dados dos Censos Demogr{\'a}ficos Brasileiros},
      author={Pereira, Rafael HM and Barbosa, Rog{\'e}rio Jer{\^o}nimo},
      journal={Dados},
      volume={69},
      number={1},
      pages={e20240150},
      year={2026},
      url = "https://doi.org/10.1590/dados.2026.69.1.006",
      publisher={SciELO Brasil}
    }
