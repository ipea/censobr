# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

test_that("add_labels_households", {

  ################################################################### 2010
  # sem labels
  test1a <- read_households(year = 2010,
                            add_labels = NULL,
                            columns = c('abbrev_state', 'V1006'),
                            showProgress = FALSE) |>
            dplyr::filter(abbrev_state == 'RO')

  # com labels
  test1b <- censobr:::add_labels_households(arrw = test1a, year=2010, lang = 'pt') |>
            dplyr::filter(abbrev_state == 'RO')

  test1a <- dplyr::collect(test1a)
  test1b <- dplyr::collect(test1b)

  # add labels
  testthat::expect_true('1' %in% test1a$V1006)
  testthat::expect_true('Urbana' %in% test1b$V1006)



  ################################################################### 2000
  # sem labels
  test2a <- read_households(year = 2000,
                            add_labels = NULL,
                            columns = c('abbrev_state', 'V1006'),
                            showProgress = FALSE) |>
    dplyr::filter(abbrev_state == 'RO')

  # com labels
  test2b <- censobr:::add_labels_households(arrw = test2a,
                                            year=2000,
                                            lang = 'pt') |>
    dplyr::filter(abbrev_state == 'RO')

  test2a <- dplyr::collect(test2a)
  test2b <- dplyr::collect(test2b)

  # add labels
  testthat::expect_true('1' %in% test2a$V1006)
  testthat::expect_true('Urbana' %in% test2b$V1006)


 })


test_that("household yes/no mappings preserve legacy defaults", {
  input_2000 <- arrow::arrow_table(data.frame(
    V0210 = c("1", "2", NA_character_),
    V1112 = c("1", "9", NA_character_)
  ))
  output_2000 <- censobr:::add_labels_households(input_2000, year = 2000, lang = "pt") |>
    dplyr::collect()

  input_2010 <- arrow::arrow_table(data.frame(
    V0206 = c("1", "2", NA_character_),
    V0701 = c("1", "9", NA_character_)
  ))
  output_2010 <- censobr:::add_labels_households(input_2010, year = 2010, lang = "pt") |>
    dplyr::collect()

  testthat::expect_identical(output_2000$V0210, c("Sim", "Não", NA_character_))
  testthat::expect_identical(output_2000$V1112, c("Sim", "Não", NA_character_))
  testthat::expect_identical(output_2010$V0206, c("Sim", "Não", NA_character_))
  testthat::expect_identical(output_2010$V0701, c("Sim", "Não", NA_character_))
})


# ERRORS and messages  -----------------------
test_that("add_labels_households", {

  # missing labels
  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=9999, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2010, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2010, lang = 'banana') )

  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2000, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2000, lang = 'banana') )

})
