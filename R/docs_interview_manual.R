#' Interview manual of the data collection of Brazil's censuses
#'
#' @description
#' Open on a browser the interview manual of the data collection of Brazil's
#' censuses
#'
#' @template year
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return Returns the path to the downloaded file. When `verbose = TRUE` and the
#'         session is interactive, the file is also opened and the path is
#'         returned invisibly.
#' @export
#' @family Census documentation
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Open interview manual on the browser
#' interview_manual(
#'   year = 2010,
#'   showProgress = FALSE
#'   )
#'
interview_manual <- function(year,
                             showProgress = TRUE,
                             cache = TRUE,
                             verbose = TRUE){
  # year = 2000

  ### check inputs
  if (missing(year) || is.null(year)) { error_year_not_declared() }
  checkmate::assert_number(year)
  checkmate::assert_logical(verbose)

  # data available for the years:
  years <- censobr_years("interview_manual")
  if (isFALSE(year %in% years)) {
    years_available <- paste(years, collapse = " ")
    cli::cli_abort(
      "Interview manual currently only available for the years {years_available}.",
      call = rlang::caller_env()
    )
  }

  ### Get url
  fname <- paste0(year, '_interview_manual.pdf')
  file_url <- paste0("https://github.com/ipea/censobr_prep_data/releases/download/censo_docs/", fname)

  ### Download
  local_file <- download_file(file_url = file_url,
                              showProgress = showProgress,
                              cache = cache,
                              verbose = verbose)

  # check if download worked
  if(is.null(local_file)) { return(NULL) }

  # open the file only when the user asked for messages and the session is
  # interactive. Otherwise simply hand back the path to the downloaded file.
  if (isTRUE(verbose) && interactive()) {
    utils::browseURL(url = local_file)
    return(invisible(local_file))
  }

  return(local_file)
}
