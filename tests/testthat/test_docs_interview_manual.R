context("interview_manual")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("interview_manual", {

  # download files
  testthat::expect_message( interview_manual(year = 2022, showProgress = FALSE) )
  testthat::expect_message( interview_manual(year = 2010, showProgress = FALSE) )
  testthat::expect_message( interview_manual(year = 2000, showProgress = FALSE) )
  testthat::expect_message( interview_manual(year = 1991, showProgress = FALSE) )
  testthat::expect_message( interview_manual(year = 1980, showProgress = FALSE) )
  testthat::expect_message( interview_manual(year = 1970, showProgress = FALSE) )
  testthat::expect_no_message( interview_manual(year = 1970, verbose = FALSE) )

  # cache dir
  pkgv <- paste0('data_release_', censobr_env$data_release)
  cache_dir <- fs::path(get_censobr_cache_dir(), pkgv)

  ## check if file have been downloaded
  years <- c(1970, 1980, 1991, 2000, 2010, 2022)

  lapply(X=years, FUN = function(y){
    f_address <- paste0(cache_dir,'/',y, '_interview_manual.pdf')
    testthat::expect_true(file.exists(f_address))
    } )

 })


# ERRORS and messages  -----------------------
test_that("interview_manual", {

  # Wrong date 4 digits
  # year must be declared by the user, whether omitted or passed as NULL
  testthat::expect_error( interview_manual(), 'declare' )
  testthat::expect_error( interview_manual(year = NULL), 'declare' )
  testthat::expect_error(interview_manual(year = 9999))
  testthat::expect_error(interview_manual(year = 2000, showProgress = 'banana'))
  testthat::expect_error(interview_manual(year = 2000, cache = 'banana'))
  testthat::expect_error(interview_manual(year = 2000, verbose = 'banana'))

})


