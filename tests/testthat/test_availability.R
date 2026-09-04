# Structural tests for the year-availability registry. Offline and free of
# skip_on_cran(): this is the guard rail the registry exists for, so gating it
# on CRAN would defeat the purpose.

test_that("every registry entry is a well formed year vector", {

  for (key in names(.censobr_availability)) {
    y <- .censobr_availability[[key]]

    testthat::expect_true(is.numeric(y), info = key)
    testthat::expect_gt(length(y), 0)
    testthat::expect_false(any(is.na(y)), info = key)
    testthat::expect_identical(y, sort(y), info = key)
    testthat::expect_identical(anyDuplicated(y), 0L, info = key)
    testthat::expect_true(all(y >= 1960), info = key)
  }

})


test_that("censobr_years() returns registered keys and aborts on unknown ones", {

  testthat::expect_identical(
    censobr_years("population"),
    c(1960, 1970, 1980, 1991, 2000, 2010, 2022)
  )
  testthat::expect_identical(censobr_years("emigration"), 2010)

  testthat::expect_error(censobr_years("nope"), "no year list registered")
  testthat::expect_error(censobr_years("populatio"), "no year list registered")

})


test_that("every key used in R/ resolves", {

  # the eight literal keys passed by the read_* and documentation functions
  literal_keys <- c("population", "households", "families", "mortality",
                    "emigration", "tracts", "questionnaire", "interview_manual")

  # data_dictionary() builds its key at run time from `dataset`, which is one of
  # these four by the time the lookup happens
  dictionary_keys <- paste0("dictionary_",
                            c("microdata", "tracts", "population", "households"))

  for (key in c(literal_keys, dictionary_keys)) {
    testthat::expect_no_error(censobr_years(key))
  }

})
