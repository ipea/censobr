# censobr dev

* New data release [v1.0.0](https://github.com/ipea/censobr_prep_data/releases/tag/v1.0.0), 
which includes the following news files or edits:
  * Census 2022 
    * Data dictionary of microdata
    * Public microdata. Closes [#65](https://github.com/ipea/censobr/issues/65)
    * New function `import_microdata22()`, which brings the controlled-access
    microdata of the **2022** Population Census into censobr. See the new 
    vignette [Working with 2022 microdata](https://ipea.github.io/censobr/articles/microdata_2022.html).

* New features

  * New function `import_microdata22_controlado()` to import to censobr the
  controlled-access microdata of 2022. Once the `.zip` file with the original data
  is imported `read_(year = 2022)` functions always read the controlled-access 
  microdata. If the controlled-access microdata have not  been imported yet, 
  these functions return an informative warning  and download the public 
  microdata set, which has fewer variables. See the new vignette [Working with 2022 microdata](https://ipea.github.io/censobr/articles/microdata_2022.html). Closes [#79](https://github.com/ipea/censobr/issues/79).
  * `add_labels = "pt"` now works for all years and tables since 1960.
  * `merge_households` parameter now works for all years since 1970. Because 
  merging all ~300 population + househols columns can require more than 20GB 
  of memory, `read_population(merge_households = TRUE)` **requires `columns` to 
  be set** -- naming the columns you need keeps the operation to a few seconds 
  and a few dozen MB.

* Major changes

* `data_dictionary()` now takes only two values in `dataset`: `"microdata"`,
  which opens a single Excel file covering every variable of the microdata and
  is now available for **all** censuses since 1960, and `"tracts"`, available
  since 1970.
* The argument `dataset` in `data_dictionary()` is also case insensitive now,
as in `read_tracts()`.


* Breaking changes

  * All functions that take a `year` now require the user to declare it. 
  Previously `questionnaire()` silently assumed `year = 2010`.
  * The arguments `questionnaire(type)`, `read_tracts(dataset)` and
  `data_dictionary(dataset)` are now explicitly required, and the error message
  lists the values accepted.
  * `data_dictionary()` now takes only two values in `dataset`: `"microdata"`,
  which opens a single Excel file covering every variable of the microdata. The 
  per-data-set dictionaries opened with `dataset = "population"` and 
  `dataset = "households"` were retired, since the microdata dictionary now covers 
  the pre-2000 censuses too. 
  * Data fixes 
    * 2022: census tract, table "preliminares" 
    * 2010: census tract of table "pessoas", state of Sao Paulo
    * 1980: code_muni values of Tocantins e Fernando de Noronha
    * 1970: variables `weight_household` and `hh_income` are stored as integers. 
    Totals weighted by `weight_household` therefore differ slightly from earlier 
    releases -- `sum(weight_household)` goes from 17,682,112 to 17,643,387 (-0.22%).
    * All year: the codes of categorical variables of the microdata are stored 
    as integers rather than text, in every census year. Code that filtered on 
    the text form needs to drop the quotes, e.g. `filter(V0601 == "1")` becomes 
    `filter(V0601 == 1)`. Zero-padded codes lose the padding as well: `V0402 == "01"` 
    becomes `V0402 == 1`. Values that used to be recorded as `"."` are now `NA`.


* Minor changes

  * censobr now uses {httr2} to download files, replacing {curl}.
  * `data_dictionary()`, `questionnaire()` and `interview_manual()` now return the
  path to the downloaded file. The file is only opened when `verbose = TRUE` and
  the session is interactive, so scripted runs no longer launch a viewer.
  * `columns` now only accepts a character vector of column names, in all five microdata
  readers (`read_population()`, `read_households()`, `read_families()`, `read_mortality()`,
  `read_emigration()`), matching its documented type. It previously also silently accepted
  numeric column indices.

* bug fixes

  * Several bug fixes and a few label corrections when `add_labels = "pt"` in
  multiple read_ functions.
  * `add_labels = "pt"` now compares the codes of every census year as numbers,
  matching how the microdata are stored since the v0.7.0 data release.
  * Requesting a column that does not exist now returns an informative error
  naming the column, instead of an internal {dplyr} message.
  * Passing more than one `year` now returns an informative error. Previously a
  vector such as `year = c(2000, 2010)` failed with a cryptic "the condition has
  length > 1" message from base R.
  * An incomplete download is now detected by comparing the size of the file
  with the size reported by the server, and is removed instead of being cached.
  * A corrupted file in the local cache no longer throws an error. The file is
  removed and the function returns `NULL`, so that running it again downloads a
  fresh copy instead of failing on every call.
  * Passing `cache = FALSE` no longer fails when the cache directory does not
  exist yet, for example on a fresh installation.
  * Download error messages now match their cause. A failed transfer no longer
  reports the local file as corrupted, and an incomplete download no longer
  reports the internet connection as faulty.
  * The temporary DuckDB database file created by `merge_households = TRUE` is 
  now removed when the merge finishes. Previously it was left behind in the 
  session's temp directory.
  * Data cached from previous data releases is deleted again. The cache
  directory is versioned by data release, so a new release leaves the files of
  the previous one behind. censobr used to delete them when the package was
  loaded, but that stopped working in v0.6.0, when the cache directory became a
  setting the user can change. The check now runs once per session, the first
  time data is downloaded, and can also be run on demand with
  `censobr_cache(delete_file = 'old')`. Set `options(censobr.keep_old_cache = TRUE)`
  to keep those files, for example to go on working with an older data release.
  Microdata imported with `import_microdata22_controlado()` are never deleted,
  because censobr cannot download them again.



# censobr v0.6.0

* Minor changes
  * The function `data_dictionary()` now does not open the file when 
  `verbose = FALSE`. Closes [72](https://github.com/ipea/censobr/issues/72) 
  * All data, documentation files and pipeline to generate the data sets shared
  through the censobr package have been migrated repository to https://github.com/ipea/censobr_prep_data.

* Data fixes included in this version:
  * The census tract aggregate table of Pessoa02 from the state of Goias has been 
  fixed. Closes [68](https://github.com/ipea/censobr/issues/68), [70](https://github.com/ipea/censobr/issues/70)
  and [71](https://github.com/ipea/censobr/issues/71).
  * All `code_` columns now have class `numeric` to keep the consistency across 
  {geobr} and other sister packages in the brverse.

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
