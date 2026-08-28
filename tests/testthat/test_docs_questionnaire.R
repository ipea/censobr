context("questionnaire")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


tester <- function(year = 2010,
                   type = NULL,
                   showProgress = FALSE,
                   cache = TRUE,
                   verbose = TRUE) {
  questionnaire(
    year,
    type,
    showProgress,
    cache,
    verbose
  )
}

# Reading long questionnaire -----------------------

test_that("questionnaire", {

  # download files
  for (y in c(1960, 1970, 1980, 1991, 2000, 2010, 2022)) {

    for (t in c('long', 'short')) {
      testthat::expect_message(tester(year = y, type = t))
      }

    }

  testthat::expect_no_message(tester(year = 2022, type = 'short', verbose = FALSE) )


  # cache dir
  pkgv <- paste0('data_release_', censobr_env$data_release)
  cache_dir <- fs::path(get_censobr_cache_dir(), pkgv)

  ## check if file have been downloaded
  years <- c(1960, 1970, 1980, 1991, 2000, 2010, 2022)

  lapply(X=years, FUN = function(y){
    f_address <- paste0(cache_dir,'/',y, '_questionnaire_long.pdf')
    testthat::expect_true(file.exists(f_address))
    } )

 })





# # Reading short questionnaire -----------------------
#
# test_that("questionnaire", {
#
#   # download files
#   testthat::expect_message( tester(year = 2022, type = 'short') )
#   testthat::expect_message( tester(year = 2010, type = 'short') )
#   testthat::expect_message( tester(year = 2000, type = 'short') )
#   testthat::expect_message( tester(year = 1991, type = 'short') )
#   testthat::expect_message( tester(year = 1980, type = 'short') )
#   testthat::expect_message( tester(year = 1970, type = 'short') )
#
#   # cache dir
#   pkgv <- paste0('censobr/data_release_', data_release)
#   cache_dir <- tools::R_user_dir(pkgv, which = 'cache')
#
#   ## check if file have been downloaded
#   years <- c(1970, 1980, 1991, 2000, 2010, 2022)
#
#   lapply(X=years, FUN = function(y){
#     f_address <- paste0(cache_dir,'/',y, '_questionnaire_short.pdf')
#     testthat::expect_true(file.exists(f_address))
#   } )
#
# })


# ERRORS and messages  -----------------------
test_that("questionnaire", {

  # Wrong date 4 digits
  # year must be declared by the user, whether omitted or passed as NULL
  # type must be declared, and the error must list the options
  testthat::expect_error( questionnaire(year = 2010), 'declare' )
  testthat::expect_error( questionnaire(year = 2010), 'long' )
  testthat::expect_error( questionnaire(year = 2010, type = NULL), 'declare' )
  testthat::expect_error( questionnaire(), 'declare' )
  testthat::expect_error( questionnaire(year = NULL), 'declare' )
  testthat::expect_error( questionnaire(type = 'long'), 'declare' )
  testthat::expect_error(questionnaire(year = 9999))
  testthat::expect_error(questionnaire(year = 2000, showProgress = 'banana'))
  testthat::expect_error(questionnaire(year = 2000, cache = 'banana'))
  testthat::expect_error(questionnaire(year = 2000, type = 'banana'))
  testthat::expect_error(questionnaire(year = 2000, verbose = 'banana'))

})


