# Add labels to categorical variables of household datasets
#' @keywords internal
add_labels_households <- function(arrw,
                                  year = parent.frame()$year,
                                  lang = 'pt'){

  # check input
  checkmate::assert_string(lang, pattern = 'pt', na.ok = TRUE)
  if (!(year %in% c(2000, 2010))) {
    cli::cli_abort("Labels for this data are only available for the years c(2000, 2010)")
  }

  if (lang == 'pt') {
    config <- load_label_config(dataset = 'households', year = year, lang = lang)
    arrw <- apply_label_config(arrw, config)
  }

  return(arrw)
}
