# censobr v0.6.0

* Minor changes
  * The function `data_dictionary()` now does not open the file when 
  `verbose = FALSE`. Closes [72](https://github.com/ipea/censobr/issues/72) 

* Data fixes included in this version:
  * The census tract aggregate table of Pessoa02 from the state of Goias has been fixed. Closes [68](https://github.com/ipea/censobr/issues/68)

* New data set and files included in this version:
  * Data dictionary of microdata now includes a single Excel file with info for
  all variables, including auxiliary documentation. For now, available for the years
  2000 and 2010.

# censobr v0.5.0

* Major changes
  * New function `get_censobr_cache_dir()`
  * The function `set_censobr_cache_dir()` now sets cache directories that persist across R sessions. Closes [#55](https://github.com/ipea/censobr/issues/55). The data is saved in versioned directory inside the cache directory.
  * The `year` parameter no longer defaults to `2010`.
  * New parameter `verbose` (logical) indicating whether functions should print messsages

* Minor changes
  * Improved internal code of `merge_households = TRUE` to avoid duplicated columns 
  * Improved package info and error messages with {cli}
  * {censobr} now imports {cli} and {rlang}

* New data set and files included in this version:
  * 2022 census. Closes [#64](https://github.com/ipea/censobr/issues/64)
    * Census-tract level data
    * Census-tract level data dictionary
  * 2000 census. Closes [#43](https://github.com/ipea/censobr/issues/43)
    * Census-tract level data
  * All data sets are save in `.parquet` compressed using `compression='zstd'` and `compression_level = 22`. This has almost halved the size of data files, making downloads much more efficient at minimal cost of reading time.
  * All data sets are now sorted by key columns to speed up join operations. Closes #60.
  * Fixed annoying message about arrow metadata. closed #56.


# censobr v0.4.1

* Minor changes
  * Removed {duckplyr} from package dependency

* bug fixes
  * Passing parameter `merge_households = TRUE` now returns the expected result.


# censobr v0.4.0

* Major changes
  * Some functions (`read_mortality`, `read_emigration`) now include a new parameter `merge_households` (logical) to indicate whether the function should merge household variables to the output data. Partially closes [#31](https://github.com/ipea/censobr/issues/31)
  * {censobr} now imports the {duckplyr} package, which is used for merging household data. Closes issue [#31](https://github.com/ipea/censobr/issues/31).
  * New vignette showing how to work with larger-than-memory data. Closes [#42](https://github.com/ipea/censobr/issues/42). The vignette still needs to be expanded with more examples, though.

* Minor changes
  * Updated Vignettes Closes issue [#51](https://github.com/ipea/censobr/issues/51)
  * Removed dependency on the {httr} package
  * Now using `curl::multi_download()` to download files in parallel. This brings the advantage that the package now automatically detects whether the data/documentation file has been updated and should be downloaded again.

* Changes to data sets and files included in this version:
  * Population microdata for the year 2000 now include a few columns that were not included before. Closes [#44](https://github.com/ipea/censobr/issues/44)
  * Included additional columns and fixed minor errors in data dictionary of 2010 microdata. Closes [#45](https://github.com/ipea/censobr/issues/45) 

* New data set and files included in this version:
  * 1960 census Closes [#32](https://github.com/ipea/censobr/issues/32)
    * Interview manual 
    * Data dictionary for microdata of population and households
    * Microdata of population and households
  * 1970: fixed geography columns. Closes [#52](https://github.com/ipea/censobr/issues/52)
  * 1991 census: Data dictionary for microdata of population and households. Closes [#28](https://github.com/ipea/censobr/issues/28)




# censobr v0.3.2

* Minor changes
  * Moved {arrow} package back to `Imports`

* New data set and files included in this version:
  * 2022 census
    * Preliminary aggregate results of census tracts


# censobr v0.3.1

* Minor changes
  * Moved {arrow} package from `Imports` to `Suggests` while the {arrow} team fixes their conflict with CRAN policies related to downloading binary software. [See here](https://github.com/apache/arrow/issues/39806).
* New package contributors:
  * Diego Rabatone Oliveira
  * Neal Richardson


# censobr v0.3.0

* Major changes
  * The `questionnaire()` function now accepts questionnaires of `type`: `"long"` or `"short"`.
  * Updated census tract data following latest update by IBGE on Oct/2023. Closed [#38](https://github.com/ipea/censobr/issues/38). As a result, the package moved to data release v0.3.0.

* Minor changes
  * Replaced `.onAttach` by `.onLoad` so that the package works with `censobr::function()`
  * Fixed documentation of various functions.
  * Fixed issue to make sure censobr uses suggested packages conditionally on CRAN
  * Fixed message when user requests a data set / file for a year that is not available

* New data set and files included in this version:
  * 2022 census [*New*]
    * Questionnaires and interview manuals 
  * Short questionnaires for every census between 1960 and 2022.
  * Long questionnaire for the 1960 and 2022 censuses.


# censobr v0.2.0

* Major changes
  * New function `read_tracts()` to read  Census tract-level aggregate data.
  * New function `data_dictionary()` opens on a browser the data dictionary of Brazil's census data.
  * New function `questionnaire()` opens on a browser the questionnaire used in the data collection of Brazil's censuses.
  * New function `interview_manual()` opens on a browser the interview manual of the data collection of Brazil's censuses.
    * New function `set_censobr_cache_dir()` that allows users to set custom directory for caching files from the censobr package.
  * New data sets of 1970, 1980 and 1991 censuses: microdata of population and households PLUS Census tract-level aggregate data for 2010. Closes [#6](https://github.com/ipea/censobr/issues/6), [#7](https://github.com/ipea/censobr/issues/7), [#8](https://github.com/ipea/censobr/issues/8) and [1#8](https://github.com/ipea/censobr/issues/18) 
  * New vignette on Census tract-level aggregate data for 2010.
  * New vignette covering functions about census documentation and dictionary of variables. Closes [#2](https://github.com/ipea/censobr/issues/2).

* Minor changes
  * Running `censobr_cache(delete_file = 'all')` now removes all data and directories related from censobr.
  * censobr now uses suggested package {geobr} conditionally

* Data included in this version:
  * 1970 census [*New*]
    * Microdata of population, households 
  * 1980 census [*New*]
    * Microdata of population, households 
  * 1991 census [*New*]
    * Microdata of population, households 
  * 2000 Census
    * Microdata of population, households and families.
  * 2010 Census
    * Microdata of population, households, deaths and emigration.
    * Census tract-level aggregate data  [*New*]



# censobr v0.1.1

* Minor changes
  * Using cache_dir and data_release as global variables. Closes [#13](https://github.com/ipea/censobr/issues/13)
  * Running `censobr_cache(delete_file = 'all')`now also remove data from old data releases. Closes [#14](https://github.com/ipea/censobr/issues/14).
  * Large improvement in code coverage 

* Changes requested by CRAN team
  * Changed location of cached data to directory inside tools::R_user_dir("censobr", which = "cache"). 
  * The package now automatically deletes cached data from previous data releases that might exist from previous versions of the package
  * Clean cache after intro vignette and testhat checks

# censobr v0.1.0

* Launch of **censobr** v0.1.0 on CRAN https://cran.r-project.org/package=censobr
* All data sets are now enriched with geography columns following {geobr} name standards. This should help data manipulation and integration with spatial data from the [{geobr}](https://github.com/ipea/geobr) package. The added columns are: c('code_muni', 'code_state', 'abbrev_state', 'name_state', 'code_region', 'name_region', 'code_weighting'). Closes #5.
* Data included in this version:
  * 2000 Census
    * Microdata of population, households and families.
  * 2010 Census
    * Microdata of population, households, deaths and emigration.
