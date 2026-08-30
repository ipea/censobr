# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

test_that("add_labels_families", {

  # sem labels
  test1a <- read_families(year = 2000,
                          add_labels = NULL,
                          columns = c('abbrev_state', 'CODV0404_2'),
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

 })


# ERRORS and messages  -----------------------
test_that("add_labels_families", {

  # missing labels
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=9999, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=2000, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=2000, lang = 'banana') )

})
