# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

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
  testthat::expect_true('1' %in% test1a$V0704)
  testthat::expect_true('Feminino' %in% test1b$V0704)



})

test_that("mortality YAML labels preserve mapped and unmatched values", {
  arrw <- arrow::arrow_table(data.frame(
    V1006 = c("1", "7", NA_character_),
    V0704 = c("2", "8", NA_character_),
    V0703 = c("08", "00", NA_character_),
    V1005 = c("1", "9", NA_character_),
    stringsAsFactors = FALSE
  ))

  output <- censobr:::add_labels_mortality(arrw, year = 2010, lang = "pt") |>
    dplyr::collect()

  testthat::expect_equal(output$V1006, c("Urbana", NA_character_, NA_character_))
  testthat::expect_equal(output$V0704, c("Feminino", NA_character_, NA_character_))
  testthat::expect_equal(output$V0703, c("Março de 2010", NA_character_, NA_character_))
  testthat::expect_equal(output$V1005, c("Área urbanizada", NA_character_, NA_character_))
})


# ERRORS and messages  -----------------------
test_that("add_labels_mortality", {

  # missing labels
  testthat::expect_error(censobr:::add_labels_mortality(arrw = test1a, year=9999, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_mortality(arrw = test1a, year=2010, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_mortality(arrw = test1a, year=2010, lang = 'banana') )

})
