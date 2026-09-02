#' Download microdata of population records from Brazil's census
#'
#' @description
#' Download microdata of population records from Brazil's census. Data collected
#' in the sample component of the questionnaire.
#'
#' @template year
#' @template columns
#' @template add_labels
#' @param merge_households Logical. Indicate whether the function should merge
#'        household variables to the output data. Defaults to `FALSE`. When
#'        `merge_households = TRUE`, it is mandatory to pass the `columns`
#'        argument to select which columns should be kept. See the Details
#'        section.
#' @template as_data_frame
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An arrow `Dataset` or a `"data.frame"` object.
#'
#' @template 1960_census_section
#'
#' @details
#' `merge_households = TRUE` is only available for years 1970, 2000 and 2010, and
#' requires `columns` to be set. Merging household variables into the full
#' population microdata produces about 300 columns and can require more than
#' 20GB of memory; naming the columns you need keeps the operation fast and
#' light, typically a few seconds. The merge writes a temporary parquet file
#' that is removed when the R session ends.
#'
#' @export
#' @family Microdata
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # return data as arrow Dataset
#' df <- read_population(
#'   year = 2010,
#'   showProgress = FALSE
#'   )
#'
read_population <- function(year,
                            columns = NULL,
                            add_labels = NULL,
                            as_data_frame = FALSE,
                            showProgress = TRUE,
                            cache = TRUE,
                            verbose = TRUE,
                            merge_households = FALSE){

  ### check inputs
  if (missing(year) || is.null(year)) { error_year_not_declared() }
  checkmate::assert_number(year)
  checkmate::assert_character(columns, null.ok = TRUE)
  checkmate::assert_logical(as_data_frame, null.ok = FALSE)
  checkmate::assert_logical(verbose, null.ok = FALSE)
  checkmate::assert_flag(merge_households)
  checkmate::assert_choice(add_labels, choices = 'pt', null.ok = TRUE)

  # data available for the years:
  years <- c(1960, 1970, 1980, 1991, 2000, 2010, 2022)
  if (isFALSE(year %in% years)) {
    error_missing_years(years)
    }

  # add_labels() aborts on unsupported years -- check before downloading
  if (!is.null(add_labels) && isFALSE(year %in% c(2010))) {
    cli::cli_abort("Labels for this data are only available for the year c(2010)",
                   call = rlang::caller_env())
  }

  # merge_households requires columns, and is only available for some years --
  # check both before downloading anything
  if (isTRUE(merge_households)) {
    if (is.null(columns)) { error_merge_households_needs_columns() }
    if (isFALSE(year %in% c(1970, 2000, 2010))) {
      error_merge_households_years(c(1970, 2000, 2010))
      }
  }

  ### download and open
  df <- open_censobr_data(dataset = 'population',
                          year = year,
                          showProgress = showProgress,
                          cache = cache,
                          verbose = verbose)

  # NULL if the download failed or the cached file is corrupted
  if (is.null(df)) { return(invisible(NULL)) }

  ### merge household data
  if (isTRUE(merge_households)) {
    if (isTRUE(verbose)) {
      cli::cli_alert_info('Merging household variables. This can take a moment.')
      }
    df <- merge_household_var(df,
                              year = year,
                              columns = columns,
                              add_labels = add_labels,
                              showProgress = showProgress,
                              cache = cache,
                              verbose = verbose)
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
    df <- add_labels_population(arrw = df,
                                year = year,
                                lang = add_labels)
  }

  # 1960 warning
  if(year==1960){
    warning("This version of the 1960 microdata was compiled by {censobr} from two different releases elaborated by IBGE. The data was processed to ensure consistency and new variables added. See the documentation.")
  }

  ### output format
  if (isTRUE(as_data_frame)) { return( dplyr::collect(df) )
  } else {
    return(df)
  }

}
