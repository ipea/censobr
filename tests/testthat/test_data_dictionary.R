context("data_dictionary")

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

  # tracts
  testthat::expect_message( tester(year = 2022, dataset = 'tracts') )
  testthat::expect_message( tester(year = 2010, dataset = 'tracts') )
  testthat::expect_message( tester(year = 2000, dataset = 'tracts') )
  testthat::expect_message( tester(year = 1991, dataset = 'tracts') )
  testthat::expect_message( tester(year = 1980, dataset = 'tracts') )
  testthat::expect_message( tester(year = 1970, dataset = 'tracts') )

  # population
  testthat::expect_message( tester(year = 2010, dataset = 'population') )
  testthat::expect_message( tester(year = 2000, dataset = 'population') )
  testthat::expect_message( tester(year = 1991, dataset = 'population') )
  testthat::expect_message( tester(year = 1980, dataset = 'population') )
  testthat::expect_message( tester(year = 1970, dataset = 'population') )

  # households
  testthat::expect_message( tester(year = 2010, dataset = 'households') )
  testthat::expect_message( tester(year = 2000, dataset = 'households') )
  testthat::expect_message( tester(year = 1991, dataset = 'population') )
  testthat::expect_message( tester(year = 1980, dataset = 'households') )
  testthat::expect_message( tester(year = 1970, dataset = 'households') )

  # families
  testthat::expect_message( tester(year = 2000, dataset = 'families') )
  # year must be declared by the user, whether omitted or passed as NULL
  testthat::expect_error( data_dictionary(), 'declare' )
  testthat::expect_error( data_dictionary(year = NULL), 'declare' )
  testthat::expect_error( tester(year = 1991, dataset = 'families') )

  # mortality
  testthat::expect_message( tester(year = 2010, dataset = 'mortality') )
  testthat::expect_error( tester(year = 1991, dataset = 'mortality') )

  # emigration
  testthat::expect_message( tester(year = 2010, dataset = 'emigration') )
  testthat::expect_error( tester(year = 1991, dataset = 'emigration') )

 })


# ERRORS and messages  -----------------------
test_that("data_dictionary", {

  testthat::expect_error( tester(year = 1991, dataset = 'banana') )
  testthat::expect_error( tester(year = banana, dataset = 'population') )
  testthat::expect_error( tester(year = 1991, verbose = 'banana') )

  testthat::expect_no_message( tester(dataset = 'population',verbose = FALSE) )

})


