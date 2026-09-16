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

  # 1960 labels: codes are stored as integers in this release, and the
  # labelled query must stay lazy
  testthat::expect_warning(
    test1960 <- tester(year = 1960, add_labels = 'pt',
                       columns = c('uf', 'V102', 'V105')),
    'two different releases'
    )
  testthat::expect_s3_class(test1960, 'arrow_dplyr_query')
  test1960 <- test1960 |> dplyr::distinct(V102, V105) |> dplyr::collect()
  testthat::expect_true('R\u00fastico' %in% test1960$V102)
  testthat::expect_true('Rede geral com canaliza\u00e7\u00e3o interna' %in% test1960$V105)

  # 1970 labels
  test1970 <- tester(year = 1970, add_labels = 'pt',
                     columns = c('abbrev_state', 'V009', 'V019')) |>
    dplyr::distinct(V009, V019) |>
    dplyr::collect()
  testthat::expect_true('Pr\u00f3prio j\u00e1 pago' %in% test1970$V009)
  testthat::expect_true('N\u00e3o tem' %in% test1970$V019)

  # 1980 labels: codes are strings
  test1980 <- tester(year = 1980, add_labels = 'pt',
                     columns = c('abbrev_state', 'V203', 'V220')) |>
    dplyr::distinct(V203, V220) |>
    dplyr::collect()
  testthat::expect_true('Alvenaria' %in% test1980$V203)
  testthat::expect_true('Preto e branco' %in% test1980$V220)

  # 1991 labels: codes are strings without leading zeros
  test1991 <- tester(year = 1991, add_labels = 'pt',
                     columns = c('abbrev_state', 'V0206', 'V2013')) |>
    dplyr::distinct(V0206, V2013) |>
    dplyr::collect()
  testthat::expect_true('Vala negra' %in% test1991$V0206)
  testthat::expect_true('Mais de 20 a 30 salários mínimos' %in% test1991$V2013)

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
  # since the v0.7.0 data release weight_household is stored as an integer,
  # which moves this total down from the 17682112 of earlier releases
  total_1970_p <- dplyr::summarise(dfh, total = sum(weight_household, na.rm=T)) |> dplyr::collect()
  expect_equal(total_1970_p$total, 17643387)

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
  # columns only accepts character (a vector of column names) -- numeric
  # indices are not supported
  testthat::expect_error( tester(columns = c(1, 3)), 'character' )
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
