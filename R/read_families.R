#' Download microdata of family records from Brazil's census
#'
#' @description
#' Download microdata of family records from Brazil's census. Data collected in
#' the sample component of the questionnaire.
#'
#' @template year
#' @template columns
#' @template add_labels
#' @template as_data_frame
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An arrow `Dataset` or a `"data.frame"` object.
#' @export
#' @family Microdata
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # return data as arrow Dataset
#' df <- read_families(
#'   year = 2000,
#'   showProgress = FALSE
#'   )
#'
#'
read_families <- function(year,
                          columns = NULL,
                          add_labels = NULL,
                          as_data_frame = FALSE,
                          showProgress = TRUE,
                          cache = TRUE,
                          verbose = TRUE){

  ### check inputs
  if (missing(year) || is.null(year)) { error_year_not_declared() }
  checkmate::assert_number(year)
  checkmate::assert_character(columns, null.ok = TRUE)
  checkmate::assert_logical(as_data_frame, null.ok = FALSE)
  checkmate::assert_logical(verbose, null.ok = FALSE)
  # checkmate::assert_logical(merge_households)
  checkmate::assert_choice(add_labels, choices = 'pt', null.ok = TRUE)

  # data available for the years:
  years <- c(2000)
  if (isFALSE(year %in% years)) {
    error_missing_years(years)
    }

  ### download and open
  df <- open_censobr_data(dataset = 'families',
                          year = year,
                          showProgress = showProgress,
                          cache = cache,
                          verbose = verbose)

  # NULL if the download failed or the cached file is corrupted
  if (is.null(df)) { return(invisible(NULL)) }

  # ### merge household data
  # if (isTRUE(merge_households)) {
  #   df <- merge_household_var(df,
  #                             year = year,
  #                             add_labels = add_labels,
  #                             showProgress)
  # }

  ### Select
  if (!is.null(columns)) { # columns <- c('V0002','V0011')
    absent <- setdiff(columns, names(df))
    if (length(absent) > 0) { error_columns_absent(absent) }
    df <- dplyr::select(df, dplyr::all_of(columns))
  }

  ### Add labels
  if (!is.null(add_labels)) { # add_labels = 'pt'
    df <- add_labels_families(arrw = df,
                               year = year,
                               lang = add_labels)
  }

  ### output format
  if (isTRUE(as_data_frame)) { return( dplyr::collect(df) )
  } else {
    return(df)
  }

}

