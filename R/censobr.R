#' censobr: Download Data from Brazil's Population Census
#'
#' Download data data from Brazil's population Census.
#'
#' @section Usage:
#' Please check the vignettes and data documentation on the
#' [website](https://ipea.github.io/censobr/).
#'
#' @docType package
#' @name censobr
#' @aliases censobr-package
#'
#' @importFrom dplyr mutate select across case_when all_of
#'
#' @keywords internal
"_PACKAGE"

## quiets concerns of R CMD check:
utils::globalVariables( c('year',
                          'temp_local_file',
                          'cod_region',
                          'cod_state',
                          'cod_meso',
                          'cod_micro',
                          'cod_intermediate',
                          'cod_immediate',
                          'cod_urbanconentration',
                          'cod_muni',
                          'cod_weightingarea',
                          'code_region',
                          'name_region',
                          'code_state',
                          'abbrev_state',
                          'name_state',
                          'code_meso',
                          'code_micro',
                          'code_intermediate',
                          'code_immediate',
                          'code_urban_concentration',
                          'code_muni',
                          'code_weighting'
                          ) )

NULL
