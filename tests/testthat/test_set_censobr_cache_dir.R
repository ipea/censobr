# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

test_that("set_censobr_cache_dir", {

  # default
  testthat::expect_message( set_censobr_cache_dir(path = NULL) )
  testthat::expect_no_message( set_censobr_cache_dir(path = NULL, verbose = FALSE) )

  # Set custom cache directory
  tempd <- tempdir()
  testthat::expect_message( set_censobr_cache_dir(path = tempd) )

  current_dir <- get_censobr_cache_dir()
  testthat::expect_true(identical(basename(current_dir), basename(tempd)))

  # download
  read_emigration(year = 2010, showProgress = FALSE)

  # check if file exists in custom dir
  files <- list.files(tempd, full.names = TRUE, recursive = TRUE)
  fname <- paste0('2010_emigration_',censobr_env$data_release, '.parquet')
  fname_full <- files[grepl(fname, files)]
  testthat::expect_true( file.exists(fname_full) )

  # back to default path
  set_censobr_cache_dir(path = NULL)


 })


# ERRORS and messages  -----------------------
test_that("set_censobr_cache_dir", {

  testthat::expect_error(set_censobr_cache_dir(path = 999))

})

