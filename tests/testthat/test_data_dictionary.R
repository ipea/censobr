# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()

tester <- function(year = 2010,
                   dataset = NULL,
                   showProgress = FALSE,
                   cache = TRUE,
                   verbose = TRUE) {
  data_dictionary(
    year,
    dataset,
    showProgress,
    cache,
    verbose
  )
}

# Reading the data -----------------------

test_that("data_dictionary", {

  # the microdata dictionary is a single Excel file, one per census since 1960
  for (y in c(1960, 1970, 1980, 1991, 2000, 2010, 2022)) {
    f <- tester(year = y, dataset = 'microdata', verbose = FALSE)
    testthat::expect_true(file.exists(f))
    testthat::expect_equal(basename(f), paste0(y, '_dictionary_microdata.xlsx'))
  }

  # the census tract dictionary starts in 1970 and is a pdf, except in 2022
  for (y in c(1970, 1980, 1991, 2000, 2010)) {
    f <- tester(year = y, dataset = 'tracts', verbose = FALSE)
    testthat::expect_true(file.exists(f))
    testthat::expect_equal(basename(f), paste0(y, '_dictionary_tracts.pdf'))
  }
  f <- tester(year = 2022, dataset = 'tracts', verbose = FALSE)
  testthat::expect_equal(basename(f), '2022_dictionary_tracts.xlsx')

  # dataset is case insensitive, as in read_tracts()
  testthat::expect_equal(
    basename(tester(year = 2010, dataset = 'MICRODATA', verbose = FALSE)),
    '2010_dictionary_microdata.xlsx'
  )
  testthat::expect_equal(
    basename(tester(year = 2010, dataset = 'Tracts', verbose = FALSE)),
    '2010_dictionary_tracts.pdf'
  )

  # with verbose = TRUE the function reports what it is doing
  testthat::expect_message( tester(year = 2010, dataset = 'tracts') )
  testthat::expect_message( tester(year = 2010, dataset = 'microdata') )

 })


# ERRORS and messages  -----------------------

test_that("data_dictionary years", {

  # each dictionary covers a different period, and a year outside it must say
  # so instead of failing on a download that can never succeed
  testthat::expect_error( tester(year = 1960, dataset = 'tracts'), 'available' )
  testthat::expect_error( tester(year = 1995, dataset = 'microdata'), 'available' )
  testthat::expect_error( tester(year = 2030, dataset = 'tracts'), 'available' )

})


test_that("data_dictionary datasets", {

  # data sets censobr distributes that never had a dictionary of their own,
  # plus the two per-data-set dictionaries retired once the microdata
  # dictionary became available for every census: the error must say so and
  # point to the microdata dictionary, not just list the valid options
  for (d in c('families', 'mortality', 'emigration', 'population', 'households')) {
    testthat::expect_error( tester(year = 2010, dataset = d), 'no data dictionary published' )
    testthat::expect_error( tester(year = 1980, dataset = d), 'microdata' )
  }

  # anything else is reported with the list of options
  testthat::expect_error( tester(year = 1991, dataset = 'banana'), 'microdata' )
  testthat::expect_error( tester(year = 1991, dataset = 'banana'), 'tracts' )

  # dataset must be declared, and the error must list the options
  testthat::expect_error( data_dictionary(year = 2010), 'declare' )
  testthat::expect_error( data_dictionary(year = 2010), 'microdata' )
  testthat::expect_error( data_dictionary(year = 2010, dataset = NULL), 'declare' )
  testthat::expect_error( data_dictionary(year = 2010, dataset = c('microdata', 'tracts')), 'length 1' )

})


test_that("data_dictionary", {

  # only one year at a time: a vector used to fail with a cryptic
  # "the condition has length > 1" from base R
  testthat::expect_error( data_dictionary(c(2000, 2010), 'microdata'), 'length 1' )
  # year must be declared by the user, whether omitted or passed as NULL
  testthat::expect_error( data_dictionary(), 'declare' )
  testthat::expect_error( data_dictionary(year = NULL), 'declare' )
  testthat::expect_error( data_dictionary(year = '2010', dataset = 'microdata'), 'number' )
  testthat::expect_error( tester(year = banana, dataset = 'microdata') )
  testthat::expect_error( tester(year = 1991, verbose = 'banana') )

  # verbose = FALSE downloads quietly and hands back the path
  testthat::expect_no_message( tester(dataset = 'microdata', verbose = FALSE) )

})
