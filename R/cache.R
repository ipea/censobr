get_default_cache_dir <- function() { # nocov start
  fs::path(
    tools::R_user_dir("censobr", which = "cache")
  )
} # nocov end

get_config_cache_file <- function() { # nocov start
  fs::path(
    tools::R_user_dir("censobr", which = "config"),
    "cache_dir"
  )
} # nocov end

#' Set custom cache directory for censobr files
#'
#' Set custom directory for caching files from the censobr package. The user
#' only needs to run this function once. This set directory is persistent across
#' R sessions.
#'
#' @param path String. The path to an existing directory. It defaults to
#'        `path = NULL`, to use the default directory
#' @template verbose
#'
#' @return A message pointing to the directory where censobr files are cached.
#'
#' @export
#'
#' @family Cache data
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#'
#' # Set custom cache directory
#' tempd <- tempdir()
#' set_censobr_cache_dir(path = tempd)
#'
#' # back to default path
#' set_censobr_cache_dir(path = NULL)
#'
set_censobr_cache_dir <- function(path,
                                  verbose = TRUE) {

  checkmate::assert_string(path, null.ok = TRUE)
  checkmate::assert_logical(verbose, null.ok = FALSE)

  if (is.null(path)) {
    cache_dir <- get_default_cache_dir()
  } else {
    cache_dir <- fs::path_norm(path)
  }

  if (isTRUE(verbose)) {
    cli::cli_inform(
      c("i" = "censobr files will be cached at {.file {cache_dir}}."),
      class = "censobr_cache_dir"
    )
  }

  config_file <- get_config_cache_file()

  if (!fs::file_exists(config_file)) {
    fs::dir_create(fs::path_dir(config_file))
    fs::file_create(config_file)
  }

  cache_dir <- as.character(cache_dir)

  writeLines(cache_dir, con = config_file)

  return(invisible(cache_dir))
}

#' Get path to cache directory for censobr files
#'
#' Get the path to the cache directory currently being used for for the censobr
#' files
#'
#' @return Path to cache dir
#'
#' @export
#'
#' @family Cache data
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # get path to cache directory
#' get_censobr_cache_dir()
#'
get_censobr_cache_dir <- function() {
  config_file <- get_config_cache_file()

  if (fs::file_exists(config_file)) {
    cache_dir <- readLines(config_file)
    cache_dir <- fs::path_norm(cache_dir)
  } else {
    cache_dir <- get_default_cache_dir()
  }

  cache_dir <- as.character(cache_dir)

  return(cache_dir)
}

#' Check if user is using the default cache dir of censobr
#'
#' @return TRUE or FALSE
#' @keywords internal
using_default_censobr_cache_dir <- function(){ # nocov start

  # default dir
  deafault_dir <- get_default_cache_dir()

  # current cache cir
  config_file <- get_config_cache_file()
  if (fs::file_exists(config_file)) {
    cache_dir <- readLines(config_file)
    cache_dir <- fs::path_norm(cache_dir)
  }

  check <- dirname(deafault_dir) == cache_dir
  return(check)
} # nocov end

#' Manage cached files from the censobr package
#'
#' @param list_files Logical. Whether to print a message with the address of all
#'        censobr data sets cached locally. Defaults to `TRUE`.
#' @param print_tree Logical. Whether the cache files should be printed in a
#'        tree-like format. This parameter only works if `list_files = TRUE`.
#'        Defaults to `FALSE`.
#' @param delete_file String. The file name or a string pattern that matches the
#'        file path of a file cached locally and which should be deleted.
#'        Defaults to `NULL`, so that no file is deleted. If `delete_file = "all"`,
#'        then all of the cached files are deleted.
#' @template verbose
#'
#' @return A message indicating which file exist and/or which ones have been
#'         deleted from the local cache directory.
#' @export
#' @family Cache data
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # list all files cached
#' censobr_cache(list_files = TRUE)
#'
#' # delete particular file
#' censobr_cache(delete_file = '2010_deaths')
#'
censobr_cache <- function(list_files = TRUE,
                          print_tree = FALSE,
                          delete_file = NULL,
                          verbose = TRUE){

  # check inputs
  checkmate::assert_logical(list_files, any.missing = FALSE, len = 1)
  checkmate::assert_logical(print_tree, any.missing = FALSE, len = 1)
  checkmate::assert_character(delete_file, null.ok = TRUE)
  checkmate::assert_logical(verbose, null.ok = FALSE)

  if(isFALSE(list_files) & isTRUE(print_tree)) {
    cli::cli_abort("The parameter 'print_tree' can only be TRUE if list_files = TRUE")
  }

  cache_dir <- get_censobr_cache_dir()
  # cache_dir <- glue::glue("{cache_dir}/data_release_{censobr_env$data_release}")

  # list cached files
  files <- list.files(cache_dir, recursive = TRUE, full.names = TRUE)

  # if (!fs::dir_exists(cache_dir)) return(character(0))

  if (length(files)==0) {
    if (isTRUE(verbose)) { cli::cli_alert_info("Cache directory is currently empty.") }
    return(character(0))
  }

  # if wants to dele file
  # delete_file = "2_families.parquet"
  if (!is.null(delete_file)) {

    # IF file does not exist, print message
    if (!any(grepl(delete_file, files)) & delete_file != "all") {
      if (isTRUE(verbose)){
        cli::cli_alert_warning("The file {delete_file} is not cached.")
        }
    }

    # IF file exists, delete file
    if (any(grepl(delete_file, files))) {
      f <- files[grepl(delete_file, files)]
      unlink(f, recursive = TRUE)
      if (isTRUE(verbose)) {
        cli::cli_alert_success("The file {delete_file} has been removed.")
        }
    }

    # Delete ALL file
    if (delete_file=='all') {

      # arrow memory-maps the Parquet files it has open, and Windows refuses to
      # remove a file that is still mapped. Collecting the datasets the user no
      # longer references releases those handles first.
      invisible(gc(verbose = FALSE))

      # delete any files from censobr, current and old data releases.
      # unlink() reports failure instead of throwing, which matters because a
      # file still open in the session is not an error the user can act on here
      unlink(cache_dir, recursive = TRUE, force = TRUE)

      locked <- list.files(cache_dir, recursive = TRUE, full.names = TRUE)

      if (length(locked) == 0) {
        if (isTRUE(verbose)) {
          cli::cli_alert_success("The following cache directory has been deleted: {cache_dir}")
          }
      } else {
        n <- length(locked)
        cli::cli_alert_warning(
          "{n} file{?s} could not be removed because {?it is/they are} still open in this R session. Restart R and run the function again to delete {?it/them}."
        )
      }
    }
  }

  # update list of cached files
  files <- list.files(cache_dir, recursive = TRUE, full.names = TRUE)

  # print file names
  if (isTRUE(list_files)) {

    if (isTRUE(verbose)) {
      cli::cli_alert_info("Files currently cached:")
      }

    # print files as a message
    if (isFALSE(print_tree)) {
      message(paste0(fs::path(files), collapse = '\n'))
    }

    # print dir as a tree
    if(isTRUE(print_tree) & dir.exists(cache_dir)){
      fs::dir_tree(cache_dir)
    }
  }
}

