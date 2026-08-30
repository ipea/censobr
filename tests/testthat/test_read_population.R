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

  # merge_households requires columns -- for years that support it
  for (y in c(1970, 2000, 2010)) { # y = 2010

    hou_cols <- names(censobr::read_households(year = y, showProgress = FALSE, verbose = FALSE))
    pop_cols <- names(tester(year = y))
    # a column that only exists in the household table for this year
    probe <- setdiff(hou_cols, pop_cols)[1]
    testthat::expect_false(is.na(probe))

    # `probe` only exists in the household table, so nrow() of the unmerged
    # population is checked via a column guaranteed to exist on both sides
    df_pop <- tester(year = y, columns = 'code_muni')
    df_merged <- tester(year = y, columns = probe, merge_households = TRUE)

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


  # missing labels
  testthat::expect_error(tester(year=2000, add_labels = 'pt'))

  # merge_households requires columns, and only supports years 1970/2000/2010
  testthat::expect_error(tester(merge_households = TRUE), 'columns.*required')
  testthat::expect_error(
    tester(year = 1980, columns = 'V201', merge_households = TRUE),
    '1970'
    )
  testthat::expect_error(
    tester(year = 1960, columns = 'V2', merge_households = TRUE),
    '1970'
    )
  testthat::expect_error(
    tester(year = 1991, columns = 'V0109', merge_households = TRUE),
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
