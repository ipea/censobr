#' Questionnaires used in the data collection of Brazil's censuses
#'
#' @description
#' Open on a browser the questionnaire used in the data collection of Brazil's
#' censuses
#'
#' @template year
#' @param type Character. The type of questionnaire used in the survey, whether
#'        the `"long"` one used in the sample component of the census, or the
#'        `"short"` one, which is answered by more households. Options include
#'        `c("long", "short")`.
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return Opens a `.pdf` file on the browser
#' @export
#' @family Questionnaire
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' library(censobr)
#'
#' # Open questionnaire on browser
#' questionnaire(year = 2010, type = 'long', showProgress = FALSE)
#'
questionnaire <- function(year,
                          type,
                          showProgress = TRUE,
                          cache = TRUE,
                          verbose = TRUE){
  # year = 2000
  # type = 'short'
  # type = 'long'

  ### check inputs
  if (missing(year) || is.null(year)) { error_year_not_declared() }
  checkmate::assert_numeric(year)
  checkmate::assert_logical(verbose, null.ok = FALSE)

  # data available for the years:
  years <- c(1960, 1970, 1980, 1991, 2000, 2010, 2022)
  if (isFALSE(year %in% years)) {
    years_available <- paste(years, collapse = " ")
    cli::cli_abort(
      "Questionnaire currently only available for the years {years_available}.",
      call = rlang::caller_env()
    )
  }

  # data available for data sets:
  data_sets <- c('long', 'short')
  if (missing(type) || is.null(type)) { error_arg_not_declared('type', data_sets) }
  checkmate::assert_string(type)
  if (isFALSE(type %in% data_sets)) {
    datasets_available <- paste(data_sets, collapse = ", ")
    cli::cli_abort(
      "Questionnaire currently only available for the types: {data_sets}.",
      call = rlang::caller_env()
    )
  }

  ### Get url
  fname <- paste0(year, '_questionnaire_', type, '.pdf')
  file_url <- paste0("https://github.com/ipea/censobr_prep_data/releases/download/censo_docs/", fname)

  ### Download
  local_file <- download_file(file_url = file_url,
                              showProgress = showProgress,
                              cache = cache,
                              verbose = verbose)
  # check if download worked
  if(is.null(local_file)) { return(NULL) }

  # open data dic on browser
  utils::browseURL(url = local_file)
}
