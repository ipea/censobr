# Add labels to categorical variables of emigration datasets
#' @keywords internal
add_labels_emigration <- function(arrw,
                                  year = parent.frame()$year,
                                  lang = 'pt'){

  # check input
  checkmate::assert_string(lang, pattern = 'pt', na.ok = TRUE)
  if (year != 2010){
    cli::cli_abort("Labels for this data are only available for the year 2010")
    }

  ### YEAR 2010
  if(year == 2010 & lang == 'pt'){ # nocov start
    config <- load_label_config(dataset = "emigration", year = year, lang = lang)
    arrw <- apply_label_config(arrw, config)
  }  # nocov end

  return(arrw)
}
