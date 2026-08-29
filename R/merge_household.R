#' Add household variables to the data set
#'
#' @param df An arrow `Dataset` passed from function above.
#' @param year Numeric. Passed from function above.
#' @param add_labels Character. Passed from function above.
#' @param showProgress Logical. Passed from function above.
#' @param verbose Logical. Passed from function above.
#'
#' @return An arrow `Dataset` with additional household variables.
#'
#' @keywords internal
merge_household_var <- function(df,
                                year = parent.frame()$year,
                                add_labels = parent.frame()$add_labels,
                                showProgress = parent.frame()$showProgress,
                                verbose = parent.frame()$verbose){

  # download household data
  df_household <- censobr::read_households(
    year = year,
    add_labels = add_labels,
    as_data_frame = FALSE,
    showProgress = showProgress,
    verbose = verbose
    )

  # fail gracefully if the household data could not be downloaded
  if (is.null(df_household)) { return(invisible(NULL)) }

  # set vars to merge
  # if (year == 1960) {
  #   key_vars <- c('code_state', 'code_muni', 'id_household')
  #   key_key <- 'id_household'
  # }

  if (year == 1970) {
    key_vars <- c('code_state', 'code_muni', 'id_household')
    key_key <- 'id_household'
    }

  if (year == 1980) {
    key_vars <- c('code_state', 'code_muni', 'V6', 'V601')
    key_key <- 'V601'
    }

  if (year == 1991) {
    key_vars <- c('code_state', 'code_muni', 'V0109')
    key_key <- 'V0109'
    }

  if (year == 2000) {
    key_vars <- c('code_state', 'code_muni', 'V0300')
    key_key <- 'V0300'
  }

  if (year == 2010) {
    key_vars <- c('code_state', 'code_muni', 'V0300')
    key_key <- 'V0300'
  }


  # drop repeated vars
  all_common_vars <- names(df)[names(df) %in% names(df_household)]
  vars_to_drop <- setdiff(all_common_vars, key_vars)
  df_household <- dplyr::select(df_household, -all_of(vars_to_drop))

  # # pre-filter right-hand table that matches key values in left-hand table
  # this improves performance a bit but only for migration and death data sets
  if (nrow(df) < nrow(df_household)) {

    key_values <- df |> dplyr::select(key_key) |> unique() |> dplyr::collect()
    key_values <- key_values[[1]]
    df_household <- dplyr::filter(df_household, get(key_key) %in% key_values)
  }

  df_household <- df_household |> dplyr::compute()


  # create db connection
  db_path <- tempfile(pattern = 'censobr', fileext = '.duckdb')

  con <- duckdb::dbConnect(
    duckdb::duckdb(),
    dbdir = db_path
    )

  # register data to db
  duckdb::duckdb_register_arrow(con, 'df', df)
  duckdb::duckdb_register_arrow(con, 'df_household', df_household)

  # Create the JOIN condition by concatenating the key columns
  join_condition <- paste0(
    'USING (',
    paste0(key_vars, collapse = ', '),
    ");"
    )

  query_match <- glue::glue(
    "SELECT *
      FROM df
      LEFT JOIN df_household
      {join_condition}"
  )

  merge_query <- duckdb::dbSendQuery(con, query_match, arrow = TRUE)

  # get result of the left join as an arrow table
  df_geo <- duckdb::duckdb_fetch_arrow(merge_query)

  # remove duckdb instance
  duckdb::duckdb_unregister_arrow(con, 'df')
  duckdb::duckdb_unregister_arrow(con, 'df_household')
  duckdb::dbDisconnect(con)

  return(df_geo)
}
