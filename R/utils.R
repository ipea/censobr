#' Is a downloaded file incomplete?
#'
#' @param actual Numeric. Size of the file on disk, or NA if it does not exist.
#' @param expected String. The `content-length` reported by the server, or NULL.
#' @param encoding String. The `content-encoding` reported by the server, or NULL.
#'
#' @return Logical.
#'
#' @keywords internal
download_is_incomplete <- function(actual, expected, encoding) {

  # no file, or a body too small to be a real data set
  if (is.na(actual) || actual < 5000) { return(TRUE) }

  # the server size can only be compared with the bytes on disk when the
  # response was not compressed: curl decompresses on the fly, so the two
  # would legitimately differ
  if (is.null(encoding) && !is.null(expected)) {
    expected <- suppressWarnings(as.numeric(expected))
    if (!is.na(expected)) { return(actual != expected) }
  }

  return(FALSE)
}

#' Download file from url
#'
#' @param file_url String. A url.
#' @param showProgress Logical.
#' @param cache Logical.
#' @param verbose Logical.

#' @return A string to the address of the file
#'
#' @keywords internal
download_file <- function(file_url = parent.frame()$file_url,
                          showProgress = parent.frame()$showProgress,
                          cache = parent.frame()$cache,
                          verbose = parent.frame()$verbose){ # nocov start

  # check input
  checkmate::assert_logical(showProgress)
  checkmate::assert_logical(cache)

  # create local dir / cache dir is versioned
  cache_dir <- get_censobr_cache_dir()
  cache_dir <- glue::glue("{cache_dir}/data_release_{censobr_env$data_release}")
  if (!dir.exists(cache_dir)) { dir.create(cache_dir, recursive=TRUE) }

  # path to local file
  file_name <- basename(file_url)
  local_file <- fs::path(cache_dir, file_name)

  # cache message
  cache_message(local_file, cache, verbose)

  # this is necessary to silence download message when reading local file
  if (file.exists(local_file) & isTRUE(cache)) {
    return(local_file)
  }

  # download file
  req <- httr2::request(file_url)
  if (isTRUE(showProgress)) { req <- httr2::req_progress(req) }

  resp <- tryCatch(httr2::req_perform(req, path = local_file), error = function(e) e)

  # a failed download must not be left behind: download_file() treats an
  # existing file as a valid cache hit on the next call
  if (inherits(resp, 'error')) {
    unlink(local_file)
    if (inherits(resp, 'httr2_http')) {
      cli::cli_alert_danger("The file is not available at the source. Please try again later.")
    } else {
      cli::cli_alert_danger("Download failed. Please check your internet connection and try again.")
    }
    return(invisible(NULL))
  }

  # verify the download is complete. The size reported by the server can only be
  # compared with the bytes on disk when the response was not compressed, since
  # curl decompresses on the fly and the two would legitimately differ.
  actual <- if (file.exists(local_file)) file.info(local_file)$size else NA_real_
  encoding <- httr2::resp_header(resp, "content-encoding")
  expected <- httr2::resp_header(resp, "content-length")

  if (isTRUE(download_is_incomplete(actual, expected, encoding))) {
    unlink(local_file)
    cli::cli_alert_danger("The downloaded file is incomplete. Please try again.")
    return(invisible(NULL))
  }

  return(local_file)
  } # nocov end


#' Build the release URL, download it, and open it as an arrow Dataset
#'
#' Contains no input validation, so that errors raised by the calling function
#' keep being attributed to that function rather than to this helper.
#'
#' @param dataset String. Name used in the file, e.g. "population" or "tracts_basico".
#' @param year Numeric. Year of reference.
#' @param showProgress Logical.
#' @param cache Logical.
#' @param verbose Logical.
#'
#' @return An arrow `Dataset`, or `NULL` if the download or the file failed.
#'
#' @keywords internal
open_censobr_data <- function(dataset, year, showProgress, cache, verbose) {

  file_url <- paste0("https://github.com/ipea/censobr_prep_data/releases/download/",
                     censobr_env$data_release, "/", year, "_", dataset, "_",
                     censobr_env$data_release, ".parquet")

  local_file <- download_file(file_url = file_url,
                              showProgress = showProgress,
                              cache = cache,
                              verbose = verbose)

  if (is.null(local_file)) { return(invisible(NULL)) }

  # returns NULL if the cached file is corrupted
  arrow_open_dataset(local_file)
}

#' Safely use arrow to open a Parquet file
#'
#' This function handles some failure modes, including if the Parquet file is
#' corrupted.
#'
#' @param filename A local Parquet file
#' @return An `arrow::Dataset`
#'
#' @keywords internal
arrow_open_dataset <- function(filename){ # nocov start

  tryCatch(
    arrow::open_dataset(filename),
    error = function(e){
      # remove the corrupted file so the next call downloads it again, and
      # fail gracefully instead of throwing (CRAN policy)
      unlink(filename)
      msg <- paste(
        "The file cached locally seems to be corrupted, and has been removed.",
        "Please run the function again to download it.",
        sep = "\n"
      )
      cli::cli_alert_danger(msg)

      return(invisible(NULL))
    }
  )
} # nocov end

#' Message when caching file
#'
#' @param local_file The address of a file passed from the download_file function
#' @param cache Logical. Whether the cached data should be used
#' @param verbose Logical. Whether the message should be printed
#'
#' @return A message
#'
#' @keywords internal
cache_message <- function(local_file = parent.frame()$local_file,
                          cache = parent.frame()$cache,
                          verbose = parent.frame()$verbose){ # nocov start

#  local_file <- 'C:\\Users\\user\\AppData\\Local/R/cache/R/censobr_v0.1/2010_deaths.parquet'

  # name of local file
  file_name <- basename(local_file[1])
  dir_name <- dirname(local_file[1])

  if (isTRUE(verbose)) {
    ## if file already exists
      # YES cache
      if (file.exists(local_file) & isTRUE(cache)) {
         cli::cli_alert_info('Reading data cached locally.')
         }

      # NO cache
      if (file.exists(local_file) & isFALSE(cache)) {
          cli::cli_alert_info('Overwriting data cached locally.')
         }

    ## if file does not exist yet
    # YES cache
    if (!file.exists(local_file) & isTRUE(cache)) {
      cli::cli_alert_info('Downloading data and storing it locally for future use.')
    }

    # NO cache
    if (!file.exists(local_file) & isFALSE(cache)) {
      cli::cli_alert_info("Downloading data. Setting 'cache = TRUE' is strongly recommended to speed up future use. File will be stored locally at: {dir_name}")
      }
    }
  } # nocov end




#' Error when requested columns are absent from the data
#'
#' @param absent Character. Column names not found in the data set.
#' @return An informative error
#'
#' @keywords internal
error_columns_absent <- function(absent) {

  cli::cli_abort(
    c("Column{?s} {.val {absent}} not found in this data set.",
      "i" = "Use {.code data_dictionary()} to see the variables available."),
    call = rlang::caller_env()
  )
}

#' Error when a required argument is not declared
#'
#' @param arg String. Name of the argument.
#' @param options Vector. The values the argument accepts.
#' @return An informative error
#'
#' @keywords internal
error_arg_not_declared <- function(arg, options) { # nocov start

  cli::cli_abort(
    c("Please declare the {.arg {arg}}.",
      "i" = "Options: {options}."),
    call = rlang::caller_env()
  )
} # nocov end

#' Error when the year is not declared
#'
#' @return An informative error
#'
#' @keywords internal
error_year_not_declared <- function() { # nocov start

  cli::cli_abort(
    "Please declare the {.arg year} of the census.",
    call = rlang::caller_env()
  )
} # nocov end

#' Error missing years
#'
#' @param y Vector with the years available
#' @return An informative error
#'
#' @keywords internal
error_missing_years <- function(y) { # nocov start

  years_available <- paste(y, collapse = " ")
  cli::cli_abort(
    "Data currently available only for the years {years_available}.",
    call = rlang::caller_env()
  )
} # nocov end

#' Error missing data sets
#'
#' @param d Vector with the data sets available
#' @return An informative error
#'
#' @keywords internal
error_missing_datasets <- function(d) { # nocov start

  datasets_available <- paste(d, collapse = ", ")
  cli::cli_abort(
    "Only the following data sets are currently available: {datasets_available}.",
    call = rlang::caller_env()
  )
} # nocov end



