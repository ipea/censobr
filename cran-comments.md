## R CMD check results

── R CMD check results ────────────────────────────────── censobr 0.6.0 ────
Duration: 12m 14s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

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
