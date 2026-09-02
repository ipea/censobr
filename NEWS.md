# censobr dev


* New features

  * New function `import_microdata22_controlado()`, which brings the microdata of
  the **2022** Population Census into censobr. IBGE releases the sample microdata
  of 2022 under controlled access, so censobr is not allowed to redistribute them
  and has nothing to download on the user's behalf. Users request the data in
  `.csv` format at https://microdados.ibge.gov.br/ and pass the zip file to this
  function once. It converts the four tables (`Domicilios`, `Familia`,
  `Mortalidade` and `Pessoas`) to Parquet, adds the same geography columns
  provided for the other censuses, and stores them in the censobr cache, where
  they are read like any other census year. The zip file should be kept, because
  the cache is versioned by data release and a censobr version that points to a
  newer release will not find files imported under the previous one. See the new
  vignette [Working with 2022 microdata](https://ipea.github.io/censobr/articles/microdata_2022.html).
  Closes [#79](https://github.com/ipea/censobr/issues/79).
  * `read_population()`, `read_households()`, `read_families()` and
  `read_mortality()` now accept `year = 2022`, reading the data imported with
  `import_microdata22_controlado()`. When the data have not been imported yet,
  these functions return an informative error explaining how to obtain them
  instead of attempting a download that cannot succeed.
  * `read_population()` now accepts a `merge_households` parameter, bringing in
  household-level variables from `read_households()` -- previously only `read_mortality()`
  and `read_emigration()` supported this. Because merging all ~300 population + household
  columns can require more than 20GB of memory, `read_population(merge_households = TRUE)`
  **requires `columns` to be set** -- naming the columns you need keeps the operation to a few
  seconds and a few dozen MB. It is only available for census years 1970, 2000 and 2010 -- 1960
  has no documented household join key, 1980's household variables are already present in the
  population microdata, and 1991's household key is not unique in the source data and would
  multiply rows.

* Major changes

  * All functions that take a `year` now require the user to declare it, and say
  so with an informative message when it is missing or `NULL`. Previously
  `questionnaire()` silently assumed `year = 2010` and `interview_manual()`
  defaulted to `NULL`.
  * The arguments `questionnaire(type)`, `read_tracts(dataset)` and
  `data_dictionary(dataset)` are now explicitly required, and the error message
  lists the values accepted. For `read_tracts()`, the options listed are the ones
  available for the requested year.
  * censobr now uses {httr2} to download files, replacing {curl}.

* Minor changes

  * `data_dictionary()` now returns an informative error for
  `dataset = "families"`, `"mortality"` and `"emigration"`, explaining that no
  dictionary was published for those data sets and pointing to the microdata
  dictionary instead. The `"population"` and `"households"`
  dictionaries remain available for the 1960, 1970, 1980 and 1991 censuses; for
  2000 and 2010 they were superseded by the single Excel file opened with
  `dataset = "microdata"`.
  * `data_dictionary()`, `questionnaire()` and `interview_manual()` now return the
  path to the downloaded file. The file is only opened when `verbose = TRUE` and
  the session is interactive, so scripted runs no longer launch a viewer.

* bug fixes
  * Requesting a column that does not exist now returns an informative error
  naming the column, instead of an internal {dplyr} message.
  * Passing more than one `year` now returns an informative error. Previously a
  vector such as `year = c(2000, 2010)` failed with a cryptic "the condition has
  length > 1" message from base R.
  * An incomplete download is now detected by comparing the size of the file
  with the size reported by the server, and is removed instead of being cached.
  Previously a partial download of a large file passed the size check and was
  stored, only to fail later as a corrupted file.
  * A corrupted file in the local cache no longer throws an error. The file is
  removed and the function returns `NULL`, so that running it again downloads a
  fresh copy instead of failing on every call.
  * `read_mortality()` and `read_emigration()` with `merge_households = TRUE` no
  longer throw an error when the household data cannot be downloaded. Following
  CRAN policy, they now fail gracefully and return `NULL`.
  * A failed or incomplete download is now removed instead of being left in the
  cache, where it would be picked up as a valid file on the next call. This is
  what made a partial download surface later as a corrupted file, and what left
  the 404 responses of the retired data dictionaries silently cached.
  * Passing `cache = FALSE` no longer fails when the cache directory does not
  exist yet, for example on a fresh installation.
  * The `add_labels` parameter now only accepts `"pt"`. Values such as `"ptbr"`
  previously passed the input check and returned data with labels partially
  applied or missing, with no error.
  * `read_tracts()` now lists the data sets available in 2000 when an invalid
  `dataset` is passed for that year. It previously listed the 2010 data sets.
  * `censobr_cache(delete_file = "all", print_tree = TRUE)` no longer throws an
  error after deleting the cache directory.
  * `censobr_cache()` no longer throws an error when the cache directory is
  empty or absent and `verbose = FALSE`.
  * Download error messages now match their cause. A failed transfer no longer
  reports the local file as corrupted, and an incomplete download no longer
  reports the internet connection as faulty.
  * `read_mortality()` and `read_emigration()` with `merge_households = TRUE` now honor
  `cache = FALSE` for the household data too. Previously the household file was always
  cached regardless of the `cache` argument.
  * The temporary DuckDB database file created by `merge_households = TRUE` is now removed
  when the merge finishes. Previously it was left behind in the session's temp directory.
  * `columns` now only accepts a character vector of column names, in all five microdata
  readers (`read_population()`, `read_households()`, `read_families()`, `read_mortality()`,
  `read_emigration()`), matching its documented type. It previously also silently accepted
  numeric column indices.

* Notes

  * The output of `read_mortality()` and `read_emigration()` with `merge_households = TRUE`
  no longer preserves DuckDB's row insertion order (it never guaranteed one). If your code
  relies on row order from this specific combination of arguments, sort explicitly.


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
