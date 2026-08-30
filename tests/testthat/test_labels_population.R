# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

test_that("add_labels_population", {

  ################################################################### 2010
  # sem labels
  test1a <- read_population(year = 2010,
                            add_labels = NULL,
                            columns = c('abbrev_state', 'V1006'),
                            showProgress = FALSE) |>
            dplyr::filter(abbrev_state == 'RO')

  # com labels
  test1b <- censobr:::add_labels_population(arrw = test1a, year=2010, lang = 'pt') |>
            dplyr::filter(abbrev_state == 'RO')

  test1a <- dplyr::collect(test1a)
  test1b <- dplyr::collect(test1b)

  # add labels
  testthat::expect_true('1' %in% test1a$V1006)
  testthat::expect_true('Urbana' %in% test1b$V1006)



  # ################################################################### 2000
  # # sem labels
  # test2a <- read_population(year = 2000, add_labels = NULL) |>
  #   filter(abbrev_state == 'RO')
  #
  # # com labels
  # test2b <- censobr:::add_labels_population(arrw = test2a, year=2000, lang = 'pt') |>
  #   filter(abbrev_state == 'RO')
  #
  # test2a <- as.data.frame(test2a)
  # test2b <- as.data.frame(test2b)
  #
  # # add labels
  # testthat::expect_true('1' %in% test2a$V1006)
  # testthat::expect_true('Urbana' %in% test2b$V1006)


 })


# ERRORS and messages  -----------------------
test_that("add_labels_population", {

  # missing labels
  testthat::expect_error(censobr:::add_labels_population(arrw = test1a, year=9999, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_population(arrw = test1a, year=2010, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_population(arrw = test1a, year=2010, lang = 'banana') )

  testthat::expect_error(censobr:::add_labels_population(arrw = test1a, year=2000, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_population(arrw = test1a, year=2000, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_population(arrw = test1a, year=2000, lang = 'banana') )

})
