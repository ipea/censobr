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
                          'temp_local_file') )

NULL
