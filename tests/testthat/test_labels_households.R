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

  # V4001 carries zero-padded codes ('01', '05', '06'); V4002 has code 65
  test1c <- read_households(year = 2010,
                            add_labels = NULL,
                            columns = c('abbrev_state', 'V4001', 'V4002'),
                            showProgress = FALSE) |>
            dplyr::filter(abbrev_state == 'RO')
  test1d <- censobr:::add_labels_households(arrw = test1c, year=2010, lang = 'pt')
  test1c <- dplyr::collect(test1c)
  test1d <- dplyr::collect(test1d)
  testthat::expect_true('01' %in% test1c$V4001)
  testthat::expect_true('Domicílio particular permanente ocupado' %in% test1d$V4001)
  for (v in c('V4001', 'V4002')) {
    testthat::expect_equal(sum(is.na(test1d[[v]])), sum(is.na(test1c[[v]])))
  }



  ################################################################### 2000
  # sem labels
  test2a <- read_households(year = 2000,
                            add_labels = NULL,
                            columns = c('abbrev_state', 'V1006', 'V0222',
                                        'V0223', 'v1111', 'v1112', 'v1113'),
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

  # number of cars / air conditioners
  testthat::expect_true('Não tem' %in% test2b$V0222)
  testthat::expect_true('1 automóvel' %in% test2b$V0222)
  testthat::expect_true('Não tem' %in% test2b$V0223)
  testthat::expect_true('1 aparelho' %in% test2b$V0223)

  # characteristics of the surroundings, stored in lower case in the 2000 file
  testthat::expect_true('Sim' %in% test2b$v1111)
  testthat::expect_true('Ignorado' %in% test2b$v1112)
  testthat::expect_true('Parcial' %in% test2b$v1113)
  testthat::expect_true('Ignorado' %in% test2b$v1113)

  # every observed code must be mapped to a label. v1111/v1112/v1113 carry a
  # '.' for the households the question does not apply to, which stays NA
  for (v in c('V1006', 'V0222', 'V0223')) {
    testthat::expect_equal(sum(is.na(test2b[[v]])), sum(is.na(test2a[[v]])))
  }
  for (v in c('v1111', 'v1112', 'v1113')) {
    testthat::expect_equal(sum(is.na(test2b[[v]])), sum(test2a[[v]] == '.', na.rm = TRUE))
  }

 })


################################################################### 2022
test_that("2022 add_labels_households", {

  # sem labels
  test3a <- read_households(year = 2022,
                            add_labels = NULL,
                            columns = c('abbrev_state', 'D0120'),
                            showProgress = FALSE) |>
            dplyr::filter(abbrev_state == 'RO')

  # com labels
  test3b <- censobr:::add_labels_households(arrw = test3a,
                                            year = 2022,
                                            lang = 'pt') |>
            dplyr::filter(abbrev_state == 'RO')

  test3a <- dplyr::collect(test3a)
  test3b <- dplyr::collect(test3b)

  # add labels
  testthat::expect_true(5 %in% test3a$D0120)
  testthat::expect_true('Povoado' %in% test3b$D0120)

})


# ERRORS and messages  -----------------------
test_that("add_labels_households", {

  # missing labels
  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=9999, lang = 'pt') )
  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2010, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2010, lang = 'banana') )

  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2000, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2000, lang = 'banana') )

  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2022, lang = 9999) )
  testthat::expect_error(censobr:::add_labels_households(arrw = test1a, year=2022, lang = 'banana') )

})
