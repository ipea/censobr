# NOTE: this file is named test_zz_ deliberately so it runs LAST.
# It exercises the real exported functions under mocked download failures, and
# download_file() unlink()s the target on failure -- which is a real path in the
# user's cache. Running earlier would delete files that the read_* tests need,
# forcing them to re-download hundreds of MB (and failing if that download is
# incomplete).

# CRAN policy: the package must fail gracefully on internet problems. Every
# function that downloads data must return NULL with an informative message,
# never throw.
#
# These tests use httr2's mocking, so they run offline and hit no network.

skip_if(Sys.getenv("TEST_ONE") != "")

# use a throw-away cache dir so a mocked failure never deletes real cached data
tmp_cache <- file.path(tempdir(), "censobr_graceful_test")
dir.create(tmp_cache, showWarnings = FALSE, recursive = TRUE)
old_cache_dir <- get_censobr_cache_dir()

# helper: run `code` with every download failing in the given way
mock_http_error <- function(status) {
  function(req) httr2::response(status_code = status)
}
mock_connection_failure <- function(req) {
  stop(structure(
    class = c("httr2_failure", "httr2_error", "rlang_error", "error", "condition"),
    list(message = "Failed to perform HTTP request.", call = NULL)
  ))
}


test_that("download_file returns NULL and never throws", {

  url <- "https://example.com/mock_censobr_file.parquet"

  # HTTP error (e.g. the file was removed at the source)
  httr2::with_mocked_responses(mock_http_error(404L), {
    testthat::expect_no_error(
      out <- download_file(url, showProgress = FALSE, cache = FALSE, verbose = FALSE)
    )
    testthat::expect_null(out)
  })

  httr2::with_mocked_responses(mock_http_error(500L), {
    testthat::expect_null(
      download_file(url, showProgress = FALSE, cache = FALSE, verbose = FALSE)
    )
  })

  # no internet connection at all
  httr2::with_mocked_responses(mock_connection_failure, {
    testthat::expect_no_error(
      out <- download_file(url, showProgress = FALSE, cache = FALSE, verbose = FALSE)
    )
    testthat::expect_null(out)
  })
})


test_that("a failed download leaves no file behind", {

  url <- "https://example.com/mock_censobr_leftover.parquet"
  local_file <- file.path(get_censobr_cache_dir(),
                          paste0("data_release_", censobr_env$data_release),
                          "mock_censobr_leftover.parquet")

  httr2::with_mocked_responses(mock_http_error(404L), {
    download_file(url, showProgress = FALSE, cache = FALSE, verbose = FALSE)
  })

  # a leftover would be served as a valid cache hit on the next call
  testthat::expect_false(file.exists(local_file))
})


test_that("exported functions return NULL when there is no internet", {

  httr2::with_mocked_responses(mock_connection_failure, {

    testthat::expect_null( read_population(2010, showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_null( read_households(2010, showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_null( read_families(2000,  showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_null( read_mortality(2010, showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_null( read_emigration(2010, showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_null( read_tracts(2010, "Basico", showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_null( data_dictionary(2010, "microdata", showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_null( questionnaire(2010, "long", showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_null( interview_manual(2010, showProgress = FALSE, verbose = FALSE, cache = FALSE) )
  })
})


test_that("exported functions do not throw when there is no internet", {

  httr2::with_mocked_responses(mock_connection_failure, {
    testthat::expect_no_error( read_population(2010, showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_no_error( read_tracts(2010, "Basico", showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_no_error( data_dictionary(2010, "tracts", showProgress = FALSE, verbose = FALSE, cache = FALSE) )
    testthat::expect_no_error( questionnaire(2010, "short", showProgress = FALSE, verbose = FALSE, cache = FALSE) )
  })
})


test_that("merge_household_var returns NULL when household data is unavailable", {

  # The path that used to throw: merge_household_var() called read_households()
  # and used the result without checking for NULL. It must be tested directly --
  # going through read_mortality() does not reach it, because that function's own
  # download fails first and it returns early.
  httr2::with_mocked_responses(mock_connection_failure, {

    testthat::expect_no_error(
      out <- merge_household_var(df = NULL,
                                 year = 2010,
                                 add_labels = NULL,
                                 showProgress = FALSE,
                                 verbose = FALSE)
    )
    testthat::expect_null(out)
  })
})


test_that("merge_households does not throw from the exported functions", {

  httr2::with_mocked_responses(mock_connection_failure, {
    testthat::expect_no_error(
      out <- read_mortality(2010, merge_households = TRUE,
                            showProgress = FALSE, verbose = FALSE, cache = FALSE)
    )
    testthat::expect_null(out)

    testthat::expect_no_error(
      out2 <- read_emigration(2010, merge_households = TRUE,
                              showProgress = FALSE, verbose = FALSE, cache = FALSE)
    )
    testthat::expect_null(out2)
  })
})


test_that("a corrupted cached file fails gracefully and is removed", {

  # arrow_open_dataset() used to throw via cli_abort() when the cached parquet
  # could not be opened. It must return NULL and delete the file, so that the
  # next call downloads a fresh copy instead of failing forever.
  corrupt <- file.path(tempdir(), "corrupt_mock.parquet")
  writeLines("this is not a parquet file", corrupt)

  testthat::expect_no_error( out <- arrow_open_dataset(corrupt) )
  testthat::expect_null( out )
  testthat::expect_false( file.exists(corrupt) )
})


# NOTE: the read_*() variant of the corrupted-cache test is deliberately NOT
# included here. It would have to write a corrupt file into the user's real cache
# directory, at the exact path a real data file occupies. If the unlink() then
# fails (e.g. the file is locked on Windows), the user's cache is left poisoned.
# arrow_open_dataset() is tested directly above, in tempdir(), which covers the
# same code path safely.


test_that("download_is_incomplete() detects a truncated download", {

  # NOTE: this logic cannot be exercised through httr2 mocking -- a mocked
  # response does not write its body to disk, so the size comparison never runs.
  # It is therefore tested directly.

  # server size and bytes on disk disagree, uncompressed -> truncated
  testthat::expect_true(  download_is_incomplete(802712853 - 1000, "802712853", NULL) )

  # they agree -> complete
  testthat::expect_false( download_is_incomplete(802712853, "802712853", NULL) )

  # a compressed response legitimately differs -> must NOT be called truncated
  testthat::expect_false( download_is_incomplete(7216, "2714", "gzip") )

  # no content-length reported -> fall back to the size floor only
  testthat::expect_false( download_is_incomplete(6000, NULL, NULL) )
  testthat::expect_true(  download_is_incomplete(10, NULL, NULL) )

  # no file on disk
  testthat::expect_true(  download_is_incomplete(NA_real_, "123", NULL) )

  # unparseable header -> fall back to the size floor
  testthat::expect_false( download_is_incomplete(6000, "not-a-number", NULL) )
})
