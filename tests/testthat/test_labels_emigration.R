# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

test_that("add_labels_emigration", {

  # sem labels
  test1a <- read_emigration(year = 2010,
                            add_labels = NULL,
                            columns = c('abbrev_state', 'V1006'),
                            showProgress = FALSE) |>
            dplyr::filter(abbrev_state == 'RO')

  # com labels
  test1b <- censobr:::add_labels_emigration(arrw = test1a, year=2010, lang = 'pt') |>
            dplyr::filter(abbrev_state == 'RO')

  test1a <- dplyr::collect(test1a)
  test1b <- dplyr::collect(test1b)
  # add labels
  testthat::expect_true('1' %in% test1a$V1006)
  testthat::expect_true('Urbana' %in% test1b$V1006)



})

test_that("emigration YAML labels preserve mapped and unmatched values", {
  arrw <- arrow::arrow_table(data.frame(
    V1006 = c("2", "7", NA_character_),
    V0303 = c("9", "8", NA_character_),
    V1005 = c("8", "9", NA_character_),
    V3061 = c("8000710", "8000826", "8999999"),
    stringsAsFactors = FALSE
  ))

  output <- censobr:::add_labels_emigration(arrw, year = 2010, lang = "pt") |>
    dplyr::collect()

  testthat::expect_equal(output$V1006, c("Rural", NA_character_, NA_character_))
  testthat::expect_equal(output$V0303, c("Ignorado", NA_character_, NA_character_))
  testthat::expect_equal(output$V1005, c("Área rural exclusive aglomerado rural", NA_character_, NA_character_))
  testthat::expect_equal(output$V3061, c("África do SUL", "Escócia", NA_character_))
})


# ERRORS and messages  -----------------------
test_that("add_labels_emigration", {

  # missing labels
  testthat::expect_error(censobr:::add_labels_emigration(arrw = test1a, year=9999, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_emigration(arrw = test1a, year=2010, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_emigration(arrw = test1a, year=2010, lang = 'banana') )

})
