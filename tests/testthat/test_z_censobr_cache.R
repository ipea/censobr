context("censobr_cache")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

test_that("censobr_cache", {

  # clean cache
  censobr_cache(delete_file = 'all')

  # simply list files
  testthat::expect_message( censobr_cache(list_files = TRUE) )

  # default cache dir
  censobr::set_censobr_cache_dir(path = NULL)
  cache_dir <- censobr::get_censobr_cache_dir()

  # download
  censobr::read_emigration(year = 2010, showProgress = FALSE, cache = TRUE)

  # list cached files
  files <- list.files(cache_dir, full.names = TRUE, recursive = TRUE)
  fname <- paste0('2010_emigration_',censobr_env$data_release, '.parquet')
  fname_full <- files[grepl(fname, files)]

  testthat::expect_true( file.exists(fname_full) )
  testthat::expect_message( censobr_cache(delete_file = fname) )
  testthat::expect_false( file.exists(fname_full) )

  ## delete ALL
  censobr::read_emigration(year = 2010, showProgress = FALSE, cache = TRUE)
  files <- list.files(cache_dir, full.names = TRUE, recursive = TRUE)
  fname <- paste0('2010_emigration_',censobr_env$data_release, '.parquet')
  fname_full <- files[grepl(fname, files)]
  testthat::expect_true( file.exists(fname_full) )
  testthat::expect_message( censobr_cache(delete_file = 'all') )
  censobr_cache(delete_file = 'all')
  testthat::expect_true(
    length(list.files(cache_dir, recursive = TRUE, full.names = TRUE)) ==0
  )

  # cache dir is created even when cache = FALSE (regression: fresh-install failure)
  # the cache dir was just deleted above, so this exercises the empty-cache path
  testthat::expect_null( download_file(file_url = "http://127.0.0.1:1/x.parquet",
                                       showProgress = FALSE,
                                       cache = FALSE,
                                       verbose = FALSE) )
  testthat::expect_true( dir.exists(
    file.path(cache_dir, paste0("data_release_", censobr_env$data_release))
    ) )
  # a failed download must not be left behind, or it becomes a poisoned cache hit
  testthat::expect_false( file.exists(file.path(cache_dir,
    paste0("data_release_", censobr_env$data_release), "x.parquet")) )

  # if file does not exist, simply print message
  testthat::expect_message( censobr_cache(delete_file ='aaa') )


  # check is output is "fs_path" when print_tree = TRUE
  censobr::read_emigration(year = 2010, showProgress = FALSE, cache = TRUE)
  testthat::expect_message(censobr_cache(list_files = TRUE, print_tree = TRUE))
  temp <- censobr_cache(list_files = TRUE, print_tree = TRUE)
  testthat::expect_is(temp, "character")

  # deleting everything while print_tree = TRUE must not error on the missing dir
  testthat::expect_no_error( censobr_cache(delete_file = 'all', print_tree = TRUE) )

  # an empty cache must not error when verbose = FALSE (the early return used to
  # sit inside the verbose guard, so execution fell through to fs::dir_delete)
  testthat::expect_no_error( censobr_cache(delete_file = 'all', verbose = FALSE) )

  # get current cache dir
  testthat::expect_true(is.character(get_censobr_cache_dir()))

 })


# ERRORS and messages  -----------------------
test_that("censobr_cache", {

  # Wrong date 4 digits
  testthat::expect_error(censobr_cache(list_files= 999))
  testthat::expect_error(censobr_cache(print_tree = 999))
  testthat::expect_error(censobr_cache(delete_file = 999))

  # check is output is "fs_path" when print_tree = TRUE
  testthat::expect_error(censobr_cache(list_files = FALSE, print_tree = TRUE))

  # no messages
  testthat::expect_no_message(censobr_cache(list_files = FALSE, verbose = FALSE))

  })


# clean cache
censobr_cache(delete_file = 'all')
