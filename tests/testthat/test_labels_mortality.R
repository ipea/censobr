# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

################################################################### 2010
test_that("add_labels_mortality", {

  # sem labels
  test1a <- read_mortality(year = 2010,
                           add_labels = NULL,
                           columns = c('abbrev_state', 'V0704'),
                           showProgress = FALSE) |>
            dplyr::filter(abbrev_state == 'RO')

  # com labels
  test1b <- censobr:::add_labels_mortality(arrw = test1a,
                                           year=2010,
                                           lang = 'pt') |>
            dplyr::filter(abbrev_state == 'RO')

  test1a <- dplyr::collect(test1a)
  test1b <- dplyr::collect(test1b)

  # add labels
  testthat::expect_true(1 %in% test1a$V0704)
  testthat::expect_true('Feminino' %in% test1b$V0704)



 })


################################################################### 2022
test_that("2022 add_labels_mortality", {

  # sem labels
  test2a <- read_mortality(year = 2022,
                           add_labels = NULL,
                           columns = c('abbrev_state', 'M0160', 'M0170'),
                           showProgress = FALSE) |>
            dplyr::filter(abbrev_state == 'RO')

  # com labels
  test2b <- censobr:::add_labels_mortality(arrw = test2a,
                                           year = 2022,
                                           lang = 'pt') |>
            dplyr::filter(abbrev_state == 'RO')

  test2a <- dplyr::collect(test2a)
  test2b <- dplyr::collect(test2b)

  # add labels
  testthat::expect_true(2 %in% test2a$M0160)
  testthat::expect_true('Feminino' %in% test2b$M0160)
  testthat::expect_true('80 anos ou mais' %in% test2b$M0170)

  # every observed code must be mapped to a label
  testthat::expect_equal(sum(is.na(test2b$M0160)), 0L)
  testthat::expect_equal(sum(is.na(test2b$M0170)), 0L)

})


# ERRORS and messages  -----------------------
test_that("add_labels_mortality", {

  # missing labels
  testthat::expect_error(censobr:::add_labels_mortality(arrw = test1a, year=9999, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_mortality(arrw = test1a, year=2010, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_mortality(arrw = test1a, year=2010, lang = 'banana') )

})
