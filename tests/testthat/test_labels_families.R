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


test_that("add_labels_families preserves mapped and unmatched values", {

  input <- arrow::arrow_table(data.frame(
    V1004 = c("01", "99", NA_character_),
    CODV0404 = c("0", "8", NA_character_),
    CODV0404_2 = c("01", "99", NA_character_),
    stringsAsFactors = FALSE
  ))

  output <- censobr:::add_labels_families(input, year = 2000, lang = "pt") |>
    dplyr::collect()

  testthat::expect_identical(output$V1004, c("Belém", NA_character_, NA_character_))
  testthat::expect_identical(output$CODV0404, c(
    "Única (uma só família vive no domicílio)", NA_character_, NA_character_
  ))
  testthat::expect_identical(output$CODV0404_2, c(
    "Casal sem filhos", NA_character_, NA_character_
  ))
})


# ERRORS and messages  -----------------------
test_that("add_labels_families", {

  # missing labels
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=9999, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=2000, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_families(arrw = test1a, year=2000, lang = 'banana') )

})
