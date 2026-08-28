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

  # download files
  try(silent = TRUE,
        downloaded_files <- curl::multi_download(
          urls = file_url,
          destfiles = local_file,
          progress = showProgress,
          resume = cache
        )
      )

  # if anything fails, return NULL (fail gracefully)
  if (any(!downloaded_files$success | is.na(downloaded_files$success))) {
        msg <- paste(
        "Local file seems to be corrupted. Please download it again using 'cache = FALSE'.",
        sprintf("Alternatively, you can remove the corrupted file with 'censobr::censobr_cache(delete_file = \"%s\")'", basename(local_file)),
        sep = "\n")
        cli::cli_alert_danger(msg)

        return(invisible(NULL))
        }

  # Halt function if download failed (file must exist and be larger than 200 kb)
  if (!file.exists(local_file) | file.info(local_file)$size < 5000) {
    cli::cli_alert_danger("Internet connection not working properly.")

    return(invisible(NULL))
  }

  return(local_file)
  } # nocov end


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
      msg <- paste(
        "File cached locally seems to be corrupted. Please download it again using 'cache = FALSE'.",
        sprintf("Alternatively, you can remove the corrupted file with 'censobr::censobr_cache(delete_file = \"%s\")'", basename(filename)),
        sep = "\n"
      )
      cli::cli_abort(msg)

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



