#' Download microdata of emigration records from Brazil's census
#'
#' @description
#' Download microdata of emigration records from Brazil's census. Data collected in
#' the sample component of the questionnaire.
#'
#' @template year
#' @template columns
#' @template add_labels
#' @template merge_households
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
#' df <- read_emigration(
#'   year = 2010,
#'   showProgress = FALSE
#'   )
#'
#' # return data as data.frame
#' df <- read_emigration(
#'   year = 2010,
#'   as_data_frame = TRUE,
#'   showProgress = FALSE
#'   )
#'
#'
read_emigration <- function(year,
                            columns = NULL,
                            add_labels = NULL,
                            merge_households = FALSE,
                            as_data_frame = FALSE,
                            showProgress = TRUE,
                            cache = TRUE,
                            verbose = TRUE){

  ### check inputs
  if (missing(year) || is.null(year)) { error_year_not_declared() }
  checkmate::assert_number(year)
  checkmate::assert_character(columns, null.ok = TRUE)
  checkmate::assert_logical(as_data_frame, null.ok = FALSE)
  checkmate::assert_logical(merge_households, null.ok = FALSE)
  checkmate::assert_logical(verbose, null.ok = FALSE)
  checkmate::assert_choice(add_labels, choices = 'pt', null.ok = TRUE)

  # data available for the years:
  years <- c(2010)
  if (isFALSE(year %in% years)) {
    error_missing_years(years)
    }

  ### download and open
  df <- open_censobr_data(dataset = 'emigration',
                          year = year,
                          showProgress = showProgress,
                          cache = cache,
                          verbose = verbose)

  # NULL if the download failed or the cached file is corrupted
  if (is.null(df)) { return(invisible(NULL)) }

  ### merge household data
  if (isTRUE(merge_households)) {
    df <- merge_household_var(df,
                              year = year,
                              columns = columns,
                              add_labels = add_labels,
                              showProgress = showProgress,
                              cache = cache,
                              verbose = verbose)
    # merge_household_var() returns a lazy Dataset; read_emigration() has
    # always returned an in-memory Table for this path, so compute() it back
    if (!is.null(df)) { df <- dplyr::compute(df) }
  }

  # merge_household_var() returns NULL if the household data could not be downloaded
  if (isTRUE(merge_households) && is.null(df)) { return(invisible(NULL)) }

  ### Select
  if (!is.null(columns)) { # columns <- c('V0002','V0011')
    absent <- setdiff(columns, names(df))
    if (length(absent) > 0) { error_columns_absent(absent) }
    df <- dplyr::select(df, dplyr::all_of(columns))
  }

  ### Add labels
  if (!is.null(add_labels)) { # add_labels = 'pt'
    df <- add_labels_emigration(arrw = df,
                                 year = year,
                                 lang = add_labels)
  }

  ### output format
  if (isTRUE(as_data_frame)) { return( dplyr::collect(df) )
  } else {
    return(df)
  }

}

