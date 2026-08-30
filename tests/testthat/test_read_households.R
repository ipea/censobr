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
                   verbose = TRUE) {
  read_households(
    year,
    columns,
    add_labels,
    as_data_frame,
    showProgress,
    cache,
    verbose
  )
}

# Reading the data -----------------------

test_that("read_households reading", {

  # (default) arrow table
  test1 <- tester()
  testthat::expect_true(is(test1, "ArrowObject"))
  # testthat::expect_true(is(test1, "Table"))
  testthat::expect_true(nrow(test1) >0 )

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

  # select columns
  cols <- c('V0001')
  test3 <- tester(columns = cols)
  testthat::expect_true(names(test3) %in% cols)

  # add labels
  test4 <- tester(year=2010, add_labels = 'pt', columns = c('abbrev_state', 'V1005'))
  test4 <- test4 |> dplyr::filter(abbrev_state == 'CE') |> as.data.frame()
  testthat::expect_true(paste('\u00c1rea urbanizada') %in% test4$V1005)

  test5 <- tester(year=2000, add_labels = 'pt', columns = c('abbrev_state', 'V1005'))
  test5 <- test5 |> dplyr::filter(abbrev_state == 'CE') |> as.data.frame()
  testthat::expect_true(paste('\u00c1rea urbanizada de vila ou cidade') %in% test5$V1005)

  # no message
  testthat::expect_no_message(tester(verbose = FALSE))

})





# check totals -----------------------

test_that("read_households totals", {


  # 2010
  dfh <- tester(year = 2010)
  total_2010_p <- dplyr::summarise(dfh, total = sum(V0010)) |> dplyr::collect()
  expect_equal(total_2010_p$total, 58051449)


  # 2000
  dfh <- tester(year = 2000)
  total_2000_p <- dplyr::summarise(dfh, total = sum(P001, na.rm=T)) |> dplyr::collect()
  expect_equal(total_2000_p$total, 45507516)


  # 1991
  dfh <- tester(year = 1991)
  total_1991_p <- dplyr::summarise(dfh, total = sum(V7300, na.rm=T)) |> dplyr::collect()
  expect_equal(total_1991_p$total, 35435725)


  # 1980
  dfh <- tester(year = 1980)
  total_1980_p <- dplyr::summarise(dfh, total = sum(V603, na.rm=T)) |> dplyr::collect()
  expect_equal(total_1980_p$total, 25210639)


  # 1970
  dfh <- tester(year = 1970)
  total_1970_p <- dplyr::summarise(dfh, total = sum(weight_household, na.rm=T)) |> dplyr::collect()
  expect_equal(total_1970_p$total, 17682112)

})




# ERRORS and messages  -----------------------
test_that("read_households errors", {

  # Wrong date 4 digits
  # only one year at a time: a vector used to fail with a cryptic
  # "the condition has length > 1" from base R
  testthat::expect_error( read_households(c(2000, 2010)), 'length 1' )
  # year must be declared by the user, whether omitted or passed as NULL
  testthat::expect_error( read_households(), 'declare' )
  testthat::expect_error( read_households(year = NULL), 'declare' )
  testthat::expect_error(tester(year=999))
  testthat::expect_error(tester(year='999'))
  testthat::expect_error( tester(columns = 'banana'), 'not found' )
  testthat::expect_error(tester(as_data_frame = 'banana'))
  testthat::expect_error(tester(showProgress = 'banana' ))
  testthat::expect_error(tester(cache = 'banana'))
  testthat::expect_error(tester(add_labels = 'banana'))
  # 'ptbr' matches the old regex check but is not a valid option
  testthat::expect_error(tester(add_labels = 'ptbr'))
  testthat::expect_error(tester(verbose='banana'))

  # missing labels


})

# # clean cache
# censobr_cache(delete_file = 'all')
