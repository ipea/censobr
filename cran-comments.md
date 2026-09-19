## R CMD check results

── R CMD check results ────────────────────────────────────────────────────────────────────────── censobr 1.0.0 ────
Duration: 26m 20s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔



# censobr v1.0.0

* New data release [v1.0.0](https://github.com/ipea/censobr_prep_data/releases/tag/v1.0.0), 
which includes the following news files or edits:
  * Census 2022. Closes [#65](https://github.com/ipea/censobr/issues/65)
    * Data dictionary of microdata
    * Public microdata.
    * New function `import_microdata22()`, which brings the controlled-access
    microdata of the **2022** Population Census into censobr. See *new features* below.
  * Data fixes 
    * 2022: census tract, table "preliminares" 
    * 2010: census tract, table "pessoas", state of Sao Paulo
    * 1980: code_muni values of Tocantins and Fernando de Noronha
    * 1970: variables `weight_household` and `hh_income` are stored as integers. 
    Totals weighted by `weight_household` therefore differ slightly from earlier 
    releases -- `sum(weight_household)` goes from 17,682,112 to 17,643,387 (-0.22%).
    * 1960. Major updates. See details in [v1.0.0](https://github.com/ipea/censobr_prep_data/releases/tag/v1.0.0).
    * All year: the codes of categorical variables of the microdata are stored 
    as integers rather than text, in every census year. Code that filtered on 
    the text form needs to drop the quotes, e.g. `filter(V0601 == "1")` becomes 
    `filter(V0601 == 1)`. Zero-padded codes lose the padding as well: `V0402 == "01"` 
    becomes `V0402 == 1`. Values that used to be recorded as `"."` are now `NA`.

* New features

  * New function `import_microdata22()` to import to censobr the
  controlled-access microdata of 2022. Once the `.zip` file with the original data
  is imported `read_(year = 2022)` functions always read the controlled-access 
  microdata. If the controlled-access microdata have not  been imported yet, 
  these functions return an informative warning  and download the public 
  microdata set, which has fewer variables. See the new vignette [Working with 2022 microdata](https://ipea.github.io/censobr/articles/microdata_2022.html). Closes [#79](https://github.com/ipea/censobr/issues/79).
  * `add_labels = "pt"` now works for all years and tables since 1960. Closes [#25](https://github.com/ipea/censobr/issues/25), [#26](https://github.com/ipea/censobr/issues/26), and [#27](https://github.com/ipea/censobr/issues/27).
  * `merge_households` parameter now works for all census years since 1960. Because 
  merging all ~300 population + househols columns can require more than 20GB 
  of memory, `read_population(merge_households = TRUE)` **requires `columns` to 
  be set** -- naming the columns you need keeps the operation to a few seconds 
  and a few dozen MB. Closes [#31](https://github.com/ipea/censobr/issues/31).

* Major changes

  * `data_dictionary()` now takes only two values in `dataset`: `"microdata"`,
    which opens a single Excel file covering every variable of the microdata and
    is now available for **all** censuses since 1960, and `"tracts"`, available
    since 1970.
  * Microdata dictionary now includes in a single file all supplementary dictionaries 
  of variable codes (e.g. occupation, religion, education categories etc). Closes 
  [53](https://github.com/ipea/censobr/issues/53).

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

* Minor changes

  * censobr now uses {httr2} to download files, replacing {curl}.
  * `data_dictionary()`, `questionnaire()` and `interview_manual()` now return the
  path to the downloaded file. The file is only opened when `verbose = TRUE` and
  the session is interactive, so scripted runs no longer launch a viewer.
  * `columns` now only accepts a character vector of column names, in all five microdata
  readers (`read_population()`, `read_households()`, `read_families()`, `read_mortality()`,
  `read_emigration()`), matching its documented type. It previously also silently accepted
  numeric column indices.
  * The argument `dataset` in `data_dictionary()` is also case insensitive now,
  as in `read_tracts()`.

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
  Microdata imported with `import_microdata22()` are never deleted,
  because censobr cannot download them again.

