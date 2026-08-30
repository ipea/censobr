# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


tester <- function(year = 2000,
                   columns = NULL,
                   add_labels = NULL,
                   # merge_households = FALSE,
                   as_data_frame = FALSE,
                   showProgress = FALSE,
                   cache = TRUE,
                   verbose = TRUE) {
  read_families(
    year,
    columns,
    add_labels,
    # merge_households,
    as_data_frame,
    showProgress,
    cache,
    verbose
  )
}

# Reading the data -----------------------

test_that("read_families read", {

  # (default) arrow table
  test1 <- tester()
  testthat::expect_true(is(test1, "ArrowObject"))
  # testthat::expect_true(is(test1, "Table"))
  testthat::expect_true(nrow(test1) >0 )

  # # data.frame
  # test2 <- tester(as_data_frame = TRUE)
  # testthat::expect_true(is(test2, "data.frame"))

  # select columns
  cols <- c('V0102')
  test3 <- tester(columns = cols)
  testthat::expect_true(names(test3) %in% cols)

  # add labels
  test4 <- tester(add_labels = 'pt', columns = c('abbrev_state', 'V1004'))
  test4 <- test4 |> dplyr::filter(abbrev_state == 'CE') |> as.data.frame()
  testthat::expect_true('Fortaleza' %in% test4$V1004)

  # no message
  testthat::expect_no_message(tester(verbose = FALSE))

})


# Merge households vars -----------------------

# test_that("families merge_households_vars", {
#
#   for(y in c(2000)){ # y = 2000
#     message(y)
#     df_hou <- read_households(year = y)
#     df_test <- tester(year = y, merge_households = TRUE)
#     testthat::expect_true( all(names(df_hou) %in% names(df_test)) )
#   }
# })


# ERRORS and messages  -----------------------
test_that("read_families errors", {

  # Wrong date 4 digits
  # only one year at a time: a vector used to fail with a cryptic
  # "the condition has length > 1" from base R
  testthat::expect_error( read_families(c(2000, 2010)), 'length 1' )
  # year must be declared by the user, whether omitted or passed as NULL
  testthat::expect_error( read_families(), 'declare' )
  testthat::expect_error( read_families(year = NULL), 'declare' )
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
  testthat::expect_error(tester(year=2010, add_labels = 'pt'))

})

# # clean cache
# censobr_cache(delete_file = 'all')
