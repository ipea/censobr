#' Data dictionary of Brazil's census data
#'
#' @description
#' Open on a browser the data dictionary of Brazil's census data.
#'
#' @template year
#' @param dataset Character. The type of data dictionary to be opened. Options
#'        include `c("microdata", "tracts", "population", "households")`. In the
#'        case of `"microdata"`, the function opens a single Excel file with the
#'        data dictionary of all variables of the microdata, available for the
#'        years 2000, 2010 and 2022. For earlier censuses, use `"population"` or
#'        `"households"`, which open a separate file per data set.
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
#' # Open data dictionary
#' data_dictionary(
#'   year = 2010,
#'   dataset = 'microdata'
#'   )
#'
#' data_dictionary(
#'   year = 2022,
#'   dataset = 'tracts'
#'   )
#'
#' data_dictionary(
#'   year = 1980,
#'   dataset = 'households'
#'   )
#'
#'
#'
data_dictionary <- function(
  year,
  dataset,
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
) {
  # year = 2010
  # dataset = 'microdata'

  ### check inputs
  if (missing(year) || is.null(year)) {
    error_year_not_declared()
  }
  checkmate::assert_number(year)
  checkmate::assert_logical(verbose, null.ok = FALSE)

  # data available for data sets:
  data_sets <- c("microdata", "tracts", "population", "households")
  if (missing(dataset) || is.null(dataset)) {
    error_arg_not_declared('dataset', data_sets)
  }
  checkmate::assert_string(dataset, na.ok = FALSE)
  # data sets that censobr distributes but for which no dictionary of its own
  # was ever published: point the user to the microdata dictionary instead
  no_dictionary <- c("families", "mortality", "emigration")
  if (dataset %in% no_dictionary) {
    cli::cli_abort(
      c(
        "There is no data dictionary published for {.val {dataset}} data.",
        "i" = "The variables of {.val {dataset}} are described in the microdata dictionary, which you can open with {.code data_dictionary(year, dataset = 'microdata')} for the years 2000, 2010 and 2022."
      )
    )
  }

  if (isFALSE(dataset %in% data_sets)) {
    error_missing_datasets(data_sets)
  }

  # check year / data availability
  if (dataset == 'microdata') {
    years <- c(2000, 2010, 2022)
  }
  if (dataset == 'tracts') {
    years <- c(1970, 1980, 1991, 2000, 2010, 2022)
  }
  # the per-dataset dictionaries were superseded by the single Excel file in
  # 2000 onward, but remain the only ones available for earlier censuses
  if (dataset == 'population') {
    years <- c(1960, 1970, 1980, 1991)
  }
  if (dataset == 'households') {
    years <- c(1960, 1970, 1980, 1991)
  }

  if (isFALSE(year %in% years)) {
    # for censuses before 2000 the dictionary exists, but per data set
    if (dataset == "microdata" && year %in% c(1960, 1970, 1980, 1991)) {
      cli::cli_abort(
        c(
          "The {.val microdata} dictionary is only available for the years 2000, 2010 and 2022.",
          "i" = "For {year}, open the dictionary of a specific data set with {.code data_dictionary({year}, dataset = 'population')} or {.code dataset = 'households'}."
        )
      )
    }

    cli::cli_abort(
      "The dictionary for {.val {dataset}} data is only available for the years {years}.",
      call = rlang::caller_env()
    )
  }

  ### Get url

  # MICRODATA
  if (dataset %in% c("microdata")) {
    fname <- paste0(year, '_dictionary_', dataset, '.xlsx')
    file_url <- paste0(
      "https://github.com/ipea/censobr_prep_data/releases/download/censo_docs/",
      fname
    )
  }

  # MICRODATA, per data set (censuses before 2000)
  if (dataset %in% c("population", "households")) {
    fname <- paste0(year, '_dictionary_microdata_', dataset, '.html')
    file_url <- paste0(
      "https://github.com/ipea/censobr_prep_data/releases/download/censo_docs/",
      fname
    )
  }

  # TRACT DATA
  if (dataset == 'tracts') {
    fname <- paste0(year, '_dictionary_tracts.pdf')
    file_url <- paste0(
      "https://github.com/ipea/censobr_prep_data/releases/download/censo_docs/",
      fname
    )

    if (year == 2022) {
      file_url <- gsub(".pdf", ".xlsx", file_url)
    }
  }

  ### Download
  local_file <- download_file(
    file_url = file_url,
    showProgress = showProgress,
    cache = cache,
    verbose = verbose
  )

  # check if download worked
  if (is.null(local_file)) {
    return(NULL)
  }

  # open data dic on browser
  file_extension <- fs::path_ext(local_file)

  # open the file only when the user asked for messages and the session is
  # interactive. Otherwise simply hand back the path to the downloaded file.
  if (isTRUE(verbose) && interactive()) {
    if (file_extension %in% c('pdf', 'html')) {
      utils::browseURL(url = local_file)
    } else {
      open_file(path = local_file)
    }
    return(invisible(local_file))
  }

  return(local_file)
}


open_file <- function(path) {
  # path <- normalizePath(path, mustWork = FALSE)   # tidy up the path
  if (.Platform$OS.type == "windows") {
    shell.exec(path) # built-in Windows helper
  } else if (Sys.info()[["sysname"]] == "Darwin") {
    system2("open", shQuote(path), wait = FALSE) # macOS
  } else {
    # Linux, *BSD, etc.
    system2("xdg-open", shQuote(path), wait = FALSE)
  }

  invisible(TRUE)
}
