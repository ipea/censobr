#' Add household variables to the data set
#'
#' Streams the main table through DuckDB's native parquet reader and joins it to
#' the (already downloaded, already labelled) household table, writing the result
#' to a temporary parquet file so a wide main table never round-trips through
#' memory.
#'
#' @param df An arrow `Dataset` passed from function above. Must be a plain
#'        `FileSystemDataset` backed by a single local parquet file, i.e. called
#'        before any `dplyr::select()` or labelling step.
#' @param year Numeric. Passed from function above.
#' @param columns Character vector of column names, or `NULL` (the `columns`
#'        argument on the functions above is character-only, enforced by
#'        `checkmate::assert_character()` before this function is ever
#'        reached). When character, pushed down into the join so only the
#'        requested columns (plus the join keys) are read and written -- this
#'        is the difference between a multi-minute, multi-GB operation and a
#'        sub-second one. `NULL` reads the main table at full width.
#' @param add_labels Character. Passed from function above.
#' @param showProgress Logical. Passed from function above.
#' @param cache Logical. Passed from function above.
#' @param verbose Logical. Passed from function above.
#'
#' @return An arrow `Dataset` with additional household variables, or
#'        `invisible(NULL)` if the household data could not be downloaded or the
#'        merge failed.
#'
#' @keywords internal
merge_household_var <- function(
  df,
  year = parent.frame()$year,
  columns = NULL,
  add_labels = parent.frame()$add_labels,
  showProgress = parent.frame()$showProgress,
  cache = TRUE,
  verbose = parent.frame()$verbose
) {
  # no need to merge household variables in 1991 and 1980
  if (year %in% c(1980, 1991)) {
    cli::cli_inform(
      "The population data set of 1980 and 1991 already includes all variables from the household data set."
    )
    return(df)
  }

  # years for which the household join key is documented, present in both
  # tables, unique, and adds variables not already in the main table -- see
  # Phase 0 of the plan referenced above. 1960 has no documented key.
  merge_years <- censobr_years("merge_households")
  if (isFALSE(year %in% merge_years)) {
    error_merge_households_years(merge_years)
  }

  # local path of the main table, for duckdb's native parquet reader
  main_path <- df$files[1]

  # download household data (labelled here, before duckdb is involved at all,
  # so labels applied by add_labels_households() are preserved in the output)
  read_hou <- function() {
    censobr::read_households(
      year = year,
      add_labels = add_labels,
      as_data_frame = FALSE,
      showProgress = showProgress,
      cache = cache,
      verbose = verbose
    )
  }

  # 2022: when the main table is the public release, the reader that called us
  # has already warned once that the controlled microdata are not imported.
  # read_households() would repeat the same warning for the household table,
  # attributed to itself, so that copy is muffled here. If only the household
  # file is public, nothing is muffled and its own warning goes through.
  main_is_public <- year == 2022 &&
    grepl('.publico', basename(main_path), fixed = TRUE)
  df_household <- if (isTRUE(main_is_public)) {
    withCallingHandlers(
      read_hou(),
      warning = function(w) {
        if (grepl('public version', conditionMessage(w), fixed = TRUE)) {
          invokeRestart('muffleWarning')
        }
      }
    )
  } else {
    read_hou()
  }

  # fail gracefully if the household data could not be downloaded
  if (is.null(df_household)) {
    return(invisible(NULL))
  }

  # set vars to merge. `key_main` / `key_hou` name the household identifier on
  # each side of the join; `key_geo` are the extra (identically named) columns
  # the join is qualified on, where the identifier is only unique within them
  if (year == 1960) {
    key_geo <- c('code_state', 'code_muni')
    key_main <- key_hou <- 'censobr_idhousehold'
  }


  if (year == 1970) {
    key_geo <- c('code_state', 'code_muni')
    key_main <- key_hou <- 'id_household'
  }

  if (year %in% c(2000, 2010)) {
    key_geo <- c('code_state', 'code_muni')
    key_main <- key_hou <- 'V0300'
  }

  if (year == 2022) {
    # the household identifier carries each table's own prefix: D0100 in the
    # household records, P0100 / M0100 / F0100 in the person / death / family
    # records. It is unique nationally (7,689,914 distinct values in 7,689,914
    # household records, data release v0.7.0), so no geography is needed to
    # qualify the join
    key_geo <- character(0)
    key_hou <- 'D0100'
    key_main <- grep('^[PMF]0100$', names(df), value = TRUE)[1]
    if (is.na(key_main)) {
      cli::cli_abort(
        "Internal error: no household identifier ({.val P0100}, {.val M0100} or
        {.val F0100}) found in the main table.",
        call = rlang::caller_env()
      )
    }
  }

  keys_main <- c(key_geo, key_main)
  keys_hou <- c(key_geo, key_hou)

  # drop repeated vars (present in both tables) from the household side, kept
  # only in the main table -- keys excepted, they are needed for the join
  all_common_vars <- names(df)[names(df) %in% names(df_household)]
  vars_to_drop <- setdiff(all_common_vars, keys_hou)

  # column push-down: restrict the household side to what the caller asked for.
  # this is the main memory/time mitigation for read_population() (see plan
  # section 2) -- a 300-column join can need >20GB of RAM, a narrow one is
  # sub-second and a few dozen MB
  if (is.character(columns)) {
    hou_keep <- union(intersect(columns, names(df_household)), keys_hou)
    df_household <- dplyr::select(df_household, dplyr::all_of(hou_keep))
    vars_to_drop <- intersect(vars_to_drop, names(df_household))
  }

  if (length(vars_to_drop) > 0) {
    df_household <- dplyr::select(df_household, -dplyr::all_of(vars_to_drop))
  }

  # pre-filter right-hand table that matches key values in left-hand table
  # this improves performance a bit but only for migration and death data sets
  if (nrow(df) < nrow(df_household)) {
    key_values <- df |>
      dplyr::select(dplyr::all_of(key_main)) |>
      unique() |>
      dplyr::collect()
    key_values <- key_values[[1]]
    df_household <- dplyr::filter(df_household, get(key_hou) %in% key_values)
  }

  df_household <- df_household |> dplyr::compute()

  # main-table side: restrict to what the caller asked for too. When columns
  # is NULL (only possible for the small mortality/emigration tables -- see
  # error_merge_households_needs_columns()), read the main table at full width
  main_keep <- if (is.character(columns)) {
    union(intersect(columns, names(df)), keys_main)
  } else {
    names(df)
  }

  # create db connection. dbdir is a scratch instance for the join itself, not
  # where the result is written -- see the COPY statement below
  db_path <- tempfile(pattern = 'censobr', fileext = '.duckdb')
  # suppressMessages(): silences duckdb's one-time driver notice about where it
  # stores extensions/secrets, which is unconditional and ignores `verbose`
  con <- suppressMessages(duckdb::dbConnect(duckdb::duckdb(), dbdir = db_path))
  on.exit(
    {
      try(duckdb::dbDisconnect(con), silent = TRUE)
      unlink(db_path)
    },
    add = TRUE
  )

  # duckdb does not export dbExecute()/dbGetQuery() (they are DBI generics, and
  # DBI is only a transitive dependency via duckdb, not a direct Imports of
  # this package) -- dbSendQuery() + dbClearResult() are what duckdb exports
  duckdb_exec <- function(sql) {
    duckdb::dbClearResult(duckdb::dbSendQuery(con, sql))
  }

  duckdb_exec("SET preserve_insertion_order = false;")
  # duckdb_exec("SET memory_limit = '4GB';")
  # CRAN allows at most 2 cores during R CMD check; never let duckdb detect
  # and use every core on the check farm
  if (Sys.getenv('_R_CHECK_LIMIT_CORES_') != '') {
    duckdb_exec("SET threads = 2;")
  }
  duckdb_exec(paste0(
    "SET temp_directory = ",
    duckdb::dbQuoteLiteral(con, normalizePath(tempdir(), winslash = '/')),
    ";"
  ))

  duckdb::duckdb_register_arrow(con, 'df_household', df_household)
  on.exit(
    try(duckdb::duckdb_unregister_arrow(con, 'df_household'), silent = TRUE),
    add = TRUE
  )

  # the main-table projection is pushed down inside its own subquery; the
  # outer SELECT * then picks up both sides' (already narrowed) columns after
  # the join -- listing main_keep in the outer SELECT would silently drop any
  # requested column that only exists on the household side
  main_cols_sql <- paste(
    duckdb::dbQuoteIdentifier(con, main_keep),
    collapse = ', '
  )
  main_path_sql <- duckdb::dbQuoteLiteral(
    con,
    normalizePath(main_path, winslash = '/')
  )
  main_sql <- sprintf(
    '(SELECT %s FROM read_parquet(%s)) AS main',
    main_cols_sql,
    main_path_sql
  )

  # USING when the keys share their names (one copy of each key in the output);
  # ON when they differ (2022), in which case both identifiers survive in the
  # output -- e.g. P0100 and D0100 -- and the caller's post-merge select drops
  # whichever was not requested
  join_condition <- if (identical(keys_main, keys_hou)) {
    paste0(
      'USING (',
      paste(duckdb::dbQuoteIdentifier(con, keys_main), collapse = ', '),
      ')'
    )
  } else {
    paste0(
      'ON ',
      paste(
        sprintf(
          'main.%s = df_household.%s',
          duckdb::dbQuoteIdentifier(con, keys_main),
          duckdb::dbQuoteIdentifier(con, keys_hou)
        ),
        collapse = ' AND '
      )
    )
  }

  out_path <- tempfile(pattern = 'censobr_merged', fileext = '.parquet')
  out_path_sql <- duckdb::dbQuoteLiteral(
    con,
    normalizePath(out_path, winslash = '/', mustWork = FALSE)
  )

  query_match <- sprintf(
    "COPY (SELECT * FROM %s LEFT JOIN df_household %s) TO %s (FORMAT PARQUET, COMPRESSION ZSTD);",
    main_sql,
    join_condition,
    out_path_sql
  )

  ok <- tryCatch(
    {
      duckdb_exec(query_match)
      TRUE
    },
    error = function(e) FALSE
  )

  if (isFALSE(ok)) {
    unlink(out_path)
    if (isTRUE(verbose)) {
      cli::cli_alert_danger(
        "Merging household variables failed, possibly due to insufficient
                            memory. Try again with a narrower {.arg columns} selection."
      )
    }
    return(invisible(NULL))
  }

  # open the merged parquet directly -- not through arrow_open_dataset(), whose
  # failure path unlinks the file and tells the user to re-download it, which
  # for a freshly written merge result would mean re-running the whole join
  df_out <- tryCatch(arrow::open_dataset(out_path), error = function(e) NULL)

  if (is.null(df_out)) {
    unlink(out_path)
    if (isTRUE(verbose)) {
      cli::cli_alert_danger(
        "The merged data set could not be opened. Please try again."
      )
    }
    return(invisible(NULL))
  }

  return(df_out)
}
