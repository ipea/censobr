# Add labels to categorical variables of family datasets
#' @keywords internal
add_labels_families <- function(arrw,
                                year = parent.frame()$year,
                                lang = 'pt'){

  # check input
  checkmate::assert_string(lang, pattern = 'pt', na.ok = TRUE)
  if (!(year %in% c(2000, 2010))) {
    cli::cli_abort("Labels for this data are only available for the years c(2000, 2010)")
    }

  if(year == 2000 & lang == 'pt'){ # nocov start
    config <- load_label_config(dataset = "families", year = year, lang = lang)
    arrw <- apply_label_config(arrw, config)
  } # nocov end

  return(arrw)
}
