# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


tester <- function(year = 2010,
                   columns = NULL,
                   add_labels = NULL,
                   as_data_frame = FALSE,
                   showProgress = FALSE,
                   cache = TRUE,
                   verbose = TRUE,
                   merge_households = FALSE) {
  read_population(
    year,
    columns,
    add_labels,
    as_data_frame,
    showProgress,
    cache,
    verbose,
    merge_households
    )
  }

# Reading the data -----------------------

test_that("read_population read", {


  # (default) arrow table
  test1 <- tester( )
  testthat::expect_true(is(test1, "ArrowObject"))
  # testthat::expect_true(is(test1, "Table"))
  testthat::expect_true(nrow(test1) >0 )
  rm(test1); gc(TRUE)
  gc(TRUE)

  # year 2000
  # (default) arrow table
  test2 <- tester(year = 2000)
  testthat::expect_true(is(test2, "ArrowObject"))
  # testthat::expect_true(is(test1, "Table"))
  testthat::expect_true(nrow(test2) >0 )

  # year 1991
  # (default) arrow table
  test2 <- tester(year = 1991)
  testthat::expect_true(is(test2, "ArrowObject"))
  # testthat::expect_true(is(test1, "Table"))
  testthat::expect_true(nrow(test2) >0 )

  # year 1980
  # (default) arrow table
  test2 <- tester(year = 1980)
  testthat::expect_true(is(test2, "ArrowObject"))
  # testthat::expect_true(is(test1, "Table"))
  testthat::expect_true(nrow(test2) >0 )

  # year 1970
  # (default) arrow table
  test2 <- tester(year = 1970)
  testthat::expect_true(is(test2, "ArrowObject"))
  # testthat::expect_true(is(test1, "Table"))
  testthat::expect_true(nrow(test2) >0 )

  # # data.frame
  # test2 <- tester(as_data_frame = TRUE)
  # testthat::expect_true(is(test2, "data.frame"))

  # # select columns
  # cols <- c('V0001')
  # test2 <- censobr::tester(columns = cols, as_data_frame = FALSE)
  # test2 <- test2[1:2,] |> dplyr::collect()
  # testthat::expect_true(names(test2) %in% cols)

  # add labels
  test4 <- tester(add_labels = 'pt',
                           columns = c('abbrev_state', 'V1005'),
                           showProgress = FALSE)
  test4 <- test4 |>
    dplyr::filter(abbrev_state == 'CE') |>
            dplyr::collect()

  testthat::expect_true(paste('\u00c1rea urbanizada') %in% test4$V1005)

  # 1960 labels: codes are stored as integers in this release, and the
  # labelled query must stay lazy
  testthat::expect_warning(
    test1960 <- tester(year = 1960, add_labels = 'pt',
                       columns = c('uf', 'V206', 'V215'),
                       showProgress = FALSE),
    'two different releases'
    )
  testthat::expect_s3_class(test1960, 'arrow_dplyr_query')
  test1960 <- test1960 |> dplyr::distinct(V206, V215) |> dplyr::collect()
  testthat::expect_true('Parda' %in% test1960$V206)
  testthat::expect_true('Somente casamento religioso' %in% test1960$V215)

  # 1970 labels
  test1970 <- tester(year = 1970, add_labels = 'pt',
                     columns = c('abbrev_state', 'V035', 'V040'),
                     showProgress = FALSE) |>
    dplyr::distinct(V035, V040) |>
    dplyr::collect()
  testthat::expect_true('Sim' %in% test1970$V035)
  testthat::expect_true('Casamento civil e religioso' %in% test1970$V040)

  # 1980 labels: codes are strings, except V536 which is a number. V681 is a
  # 2-wide field: 'Sem renda' is code '0', so it only resolves if the file stores
  # the code unpadded - that is the assertion guarding against leading zeros.
  test1980 <- tester(year = 1980, add_labels = 'pt',
                     columns = c('abbrev_state', 'V509', 'V536', 'V681'),
                     showProgress = FALSE) |>
    dplyr::distinct(V509, V536, V681) |>
    dplyr::collect()
  testthat::expect_true('Parda' %in% test1980$V509)
  testthat::expect_true('De 49 horas e mais' %in% test1980$V536)
  testthat::expect_true('Sem renda' %in% test1980$V681)

  # 1991 labels: codes are strings without leading zeros. 'Chefe' is code '1' of
  # a 2-wide field, so it only resolves when the code is stored unpadded - the
  # 2-character codes below pass either way and cannot detect that regression.
  test1991 <- tester(year = 1991, add_labels = 'pt',
                     columns = c('abbrev_state', 'V0302', 'V0349'),
                     showProgress = FALSE) |>
    dplyr::distinct(V0302, V0349) |>
    dplyr::collect()
  testthat::expect_true('Chefe' %in% test1991$V0302)
  testthat::expect_true('Cunhado(a)' %in% test1991$V0302)
  testthat::expect_true('Empregador' %in% test1991$V0349)

  # no message
  testthat::expect_no_message(tester(verbose = FALSE))

})



gc()

# check totals -----------------------

test_that("read_population check totals", {


  # 2010
  dfp <- tester(year = 2010)
  total_2010_p <- dplyr::summarise(dfp, total = sum(V0010)) |> dplyr::collect()
  expect_equal(total_2010_p$total, 190755799)


  # 2000
  dfp <- tester(year = 2000)
  total_2000_p <- dplyr::summarise(dfp, total = sum(P001, na.rm=T)) |> dplyr::collect()
  expect_equal(total_2000_p$total, 169872856)


  # 1991
  dfp <- tester(year = 1991)
  total_1991_p <- dplyr::summarise(dfp, total = sum(V7301, na.rm=T)) |> dplyr::collect()
  expect_equal(total_1991_p$total, 146815212)


  # 1980
  dfp <- tester(year = 1980)
  total_1980_p <- dplyr::summarise(dfp, total = sum(V604, na.rm=T)) |> dplyr::collect()
  expect_equal(total_1980_p$total, 119011052)


  # 1970
  dfp <- tester(year = 1970)
  total_1970_p <- dplyr::summarise(dfp, total = sum(V054, na.rm=T)) |> dplyr::collect()
  expect_equal(total_1970_p$total, 94461969)

})



# Merge households vars -----------------------

test_that("read_population merge_households_vars", {

  # merge_households requires columns -- for years that support it. 2022 is
  # read from the public release here, which warns once per call that the
  # controlled microdata are not imported; that warning is the subject of
  # test_import_microdata22_controlado.R, not of this test
  for (y in c(1970, 2000, 2010, 2022)) { # y = 2010

    quiet <- if (y == 2022) suppressWarnings else identity

    hou_cols <- names(quiet(censobr::read_households(year = y, showProgress = FALSE, verbose = FALSE)))
    pop_cols <- names(quiet(tester(year = y)))
    # a column that only exists in the household table for this year
    probe <- setdiff(hou_cols, pop_cols)[1]
    testthat::expect_false(is.na(probe))

    # `probe` only exists in the household table, so nrow() of the unmerged
    # population is checked via a column guaranteed to exist on both sides
    # (code_muni is absent from the 2022 public release)
    df_pop <- quiet(tester(year = y, columns = 'code_state'))
    df_merged <- quiet(tester(year = y, columns = probe, merge_households = TRUE))

    # row count is preserved by the LEFT JOIN
    testthat::expect_equal(nrow(df_merged), nrow(df_pop))

    # the requested household-only column is actually present, matches for at
    # least some rows (nrow equality alone cannot detect a broken join key --
    # it also holds at a 0% match rate), and nothing beyond the requested
    # columns (plus no leaked join keys) survives the post-merge select
    testthat::expect_true(probe %in% names(df_merged))
    # collected locally rather than summarised lazily: arrow's dplyr backend
    # does not reliably translate `.data[[probe]]` inside a lazy summarise()
    matched_n <- sum(!is.na(dplyr::collect(df_merged)[[probe]]))
    testthat::expect_gt(matched_n, 0)
    testthat::expect_equal(names(df_merged), probe)
  }

  # a columns= request spanning both tables returns exactly those columns, in
  # the requested order
  df_both <- tester(year = 2010, columns = c('V0601', 'V4001'), merge_households = TRUE)
  testthat::expect_equal(names(df_both), c('V0601', 'V4001'))

  # 2022: the household identifier is named differently on each side (P0100 in
  # the person records, D0100 in the household records), so the join runs on
  # an ON clause rather than USING. Check the key actually links the rows:
  # every person's P0100 must equal the D0100 brought in from the household
  # side, and a household-only variable must be filled for every person
  df_2022 <- suppressWarnings(
    tester(year = 2022, columns = c('P0100', 'D0100', 'D0120'), merge_households = TRUE)
    )
  testthat::expect_equal(names(df_2022), c('P0100', 'D0100', 'D0120'))
  chk_2022 <- df_2022 |>
    dplyr::summarise(
      n = dplyr::n(),
      n_key_equal = sum(P0100 == D0100, na.rm = TRUE),
      n_hou_na = sum(is.na(D0120))
      ) |>
    dplyr::collect()
  testthat::expect_equal(chk_2022$n_key_equal, chk_2022$n)
  testthat::expect_equal(chk_2022$n_hou_na, 0)

  # 1980 and 1991: the population microdata already carry every household
  # variable, so merge_households = TRUE is answered with a message and the
  # data are returned as usual, the household variable served from the
  # population file
  for (y in c(1980, 1991)) {
    hou_var <- if (y == 1980) 'V201' else 'V0201'
    testthat::expect_message(
      df_y <- tester(year = y, columns = hou_var, merge_households = TRUE),
      'already includes'
      )
    testthat::expect_equal(names(df_y), hou_var)
    # a columns= selection on an arrow Dataset is a lazy arrow_dplyr_query,
    # not an ArrowObject -- the point is that it was not collected
    testthat::expect_s3_class(df_y, "arrow_dplyr_query")
  }

  # numeric column indices are not supported under merge_households = TRUE --
  # only character names are, matching the documented `columns` contract
  pop_names_2010 <- names(tester(year = 2010))
  idx <- which(pop_names_2010 == 'V0601')
  testthat::expect_error(
    tester(year = 2010, columns = idx, merge_households = TRUE),
    'character'
    )
})


# ERRORS and messages  -----------------------
test_that("read_population ERRORs", {

  # Wrong date 4 digits
  # only one year at a time: a vector used to fail with a cryptic
  # "the condition has length > 1" from base R
  testthat::expect_error( read_population(c(2000, 2010)), 'length 1' )
  # year must be declared by the user, whether omitted or passed as NULL
  testthat::expect_error( read_population(), 'declare' )
  testthat::expect_error( read_population(year = NULL), 'declare' )
  testthat::expect_error(tester(year=999))
  testthat::expect_error(tester(year='999'))
  testthat::expect_error( tester(columns = 'banana'), 'not found' )
  # columns only accepts character (a vector of column names) -- numeric
  # indices are not supported
  testthat::expect_error( tester(columns = c(1, 3)), 'character' )
  # testthat::expect_error(tester(as_data_frame = 'banana'))
  testthat::expect_error(read_population(year = 2010, as_data_frame = 'banana'))
  testthat::expect_error(tester(showProgress = 'banana' ))
  testthat::expect_error(tester(cache = 'banana'))
  testthat::expect_error(tester(add_labels = 'banana'))
  # 'ptbr' matches the old regex check but is not a valid option
  testthat::expect_error(tester(add_labels = 'ptbr'))
  testthat::expect_error(tester(verbose='banana'))


  # labels exist for every census year; the 'only available' guard can only
  # trigger for a year that is not in the data registry, which errors earlier

  # merge_households requires columns, and only supports years 1970/2000/2010/2022
  # (1980 and 1991 are accepted and answered with a message -- see the merge test)
  testthat::expect_error(tester(merge_households = TRUE), 'columns.*required')
  testthat::expect_error(
    tester(year = 1960, columns = 'V2', merge_households = TRUE),
    '1970'
    )

  # a bad column name under merge_households = TRUE is still attributed to
  # read_population(), not to the internal merge helper
  err <- tryCatch(
    tester(columns = 'banana', merge_households = TRUE),
    error = function(e) e
    )
  testthat::expect_match(conditionMessage(err), 'not found')
  testthat::expect_match(paste(deparse(conditionCall(err)), collapse = ' '), 'read_population')

})

# # clean cache
# censobr_cache(delete_file = 'all')
