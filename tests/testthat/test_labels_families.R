# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

################################################################### 2000
test_that("add_labels_families", {

  # sem labels
  test1a <- read_families(year = 2000,
                          add_labels = NULL,
                          columns = c('abbrev_state', 'CODV0404_2',
                                      'CODV7400', 'CODV7400A', 'CODV7400B'),
                          showProgress = FALSE) |>
            dplyr::filter(abbrev_state == 'RO')

  # com labels
  test1b <- censobr:::add_labels_families(arrw = test1a, year=2000, lang = 'pt') |>
            dplyr::filter(abbrev_state == 'RO')

  test1a <- dplyr::collect(test1a)
  test1b <- dplyr::collect(test1b)

  # add labels
  testthat::expect_true('01' %in% test1a$CODV0404_2)
  testthat::expect_true('Casal sem filhos' %in% test1b$CODV0404_2)

  testthat::expect_true('3 pessoas' %in% test1b$CODV7400)
  testthat::expect_true('15 ou mais pessoas' %in% test1b$CODV7400)
  testthat::expect_true('nenhum' %in% test1b$CODV7400A)
  testthat::expect_true('1 mulher' %in% test1b$CODV7400B)

  # every observed code must be mapped to a label
  testthat::expect_equal(sum(is.na(test1b$CODV7400)), 0L)
  testthat::expect_equal(sum(is.na(test1b$CODV7400A)), 0L)
  testthat::expect_equal(sum(is.na(test1b$CODV7400B)), 0L)

 })


################################################################### 2022
test_that("2022 add_labels_families", {

  # sem labels
  test2a <- read_families(year = 2022,
                          add_labels = NULL,
                          columns = c('abbrev_state', 'F0120'),
                          showProgress = FALSE) |>
            dplyr::filter(abbrev_state == 'RO')

  # com labels
  test2b <- censobr:::add_labels_families(arrw = test2a,
                                          year = 2022,
                                          lang = 'pt') |>
            dplyr::filter(abbrev_state == 'RO')

  test2a <- dplyr::collect(test2a)
  test2b <- dplyr::collect(test2b)

  # add labels
  testthat::expect_true(5 %in% test2a$F0120)
  testthat::expect_true('Povoado' %in% test2b$F0120)

})


# ERRORS and messages  -----------------------
test_that("add_labels_families", {

  # missing labels
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=9999, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=2000, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=2000, lang = 'banana') )

  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=2022, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=2022, lang = 'banana') )

})
