# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


tester <- function(year = 2010,
                   columns = NULL,
                   add_labels = NULL,
                   # merge_households = FALSE,
                   as_data_frame = FALSE,
                   showProgress = FALSE,
                   cache = TRUE,
                   verbose = TRUE) {
  read_population(
    year,
    columns,
    add_labels,
    # merge_households,
    as_data_frame,
    showProgress,
    cache,
    verbose
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

# test_that("population merge_households_vars", {
#
#   for(y in c(1970, 1980, 1991, 2000, 2010)){ # y = 2010
#     message(y)
#     df_hou <- censobr::read_households(year = y)
#     df_test <- tester(year = y,
#                       merge_households = TRUE,
#                       showProgress = FALSE)
#     testthat::expect_true( all(names(df_hou) %in% names(df_test)) )
#   }
# })


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

})

# # clean cache
# censobr_cache(delete_file = 'all')
