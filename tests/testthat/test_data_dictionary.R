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

  # microdata (single Excel file, years 2000 and 2010 only)
  testthat::expect_message( tester(year = 2010, dataset = 'microdata') )
  testthat::expect_message( tester(year = 2000, dataset = 'microdata') )
  testthat::expect_error( tester(year = 1991, dataset = 'microdata') )

  # per-dataset dictionaries: the only ones available for censuses before 2000
  testthat::expect_message( tester(year = 1980, dataset = 'households') )
  testthat::expect_message( tester(year = 1960, dataset = 'population') )
  testthat::expect_message( tester(year = 1991, dataset = 'households') )

  # in 2000 and 2010 they were superseded by the single Excel file
  testthat::expect_error( tester(year = 2010, dataset = 'households') )
  testthat::expect_error( tester(year = 2000, dataset = 'population') )

  # these were never published, for any year: the error must say so and point
  # to the microdata dictionary, not just list the valid options
  for (d in c('families', 'mortality', 'emigration')) {
    testthat::expect_error( tester(year = 2010, dataset = d), 'no data dictionary published' )
    testthat::expect_error( tester(year = 1980, dataset = d), 'microdata' )
  }

  # year must be declared by the user, whether omitted or passed as NULL
  # dataset must be declared, and the error must list the options
  testthat::expect_error( data_dictionary(year = 2010), 'declare' )
  testthat::expect_error( data_dictionary(year = 2010), 'microdata' )
  testthat::expect_error( data_dictionary(year = 2010, dataset = NULL), 'declare' )
  testthat::expect_error( data_dictionary(), 'declare' )
  testthat::expect_error( data_dictionary(year = NULL), 'declare' )

 })


# ERRORS and messages  -----------------------
test_that("data_dictionary", {

  testthat::expect_error( tester(year = 1991, dataset = 'banana') )
  testthat::expect_error( tester(year = banana, dataset = 'microdata') )
  testthat::expect_error( tester(year = 1991, verbose = 'banana') )

  testthat::expect_no_message( tester(dataset = 'microdata', verbose = FALSE) )

})


