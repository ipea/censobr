# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

################################################################### 2010
test_that("2010 add_labels_population", {
  # sem labels
  test1a <- read_population(
    year = 2010,
    add_labels = NULL,
    columns = c('abbrev_state', 'V1006'),
    showProgress = FALSE
  ) |>
    dplyr::filter(abbrev_state == 'RO')

  # com labels
  test1b <- censobr:::add_labels_population(
    arrw = test1a,
    year = 2010,
    lang = 'pt'
  ) |>
    dplyr::filter(abbrev_state == 'RO')

  test1a <- dplyr::collect(test1a)
  test1b <- dplyr::collect(test1b)

  # add labels
  testthat::expect_true('1' %in% test1a$V1006)
  testthat::expect_true('Urbana' %in% test1b$V1006)
})

test_that("2010 add_labels_population keeps every observed code", {
  # variables whose 2010 microdata carry an 'Ignorado' (9) or 'Nao determinado'
  # (5) code on top of the regular ones, and V6920 whose code 2 means
  # 'Nao ocupadas' (not 'Desocupadas', which is V6910)
  vars <- c('V0617', 'V0656', 'V0614', 'V0670', 'V0604', 'V6400', 'V6920')
  test4a <- read_population(
    year = 2010,
    add_labels = NULL,
    columns = c('abbrev_state', vars),
    showProgress = FALSE
  ) |>
    dplyr::filter(abbrev_state == 'RO')

  test4b <- censobr:::add_labels_population(
    arrw = test4a,
    year = 2010,
    lang = 'pt'
  ) |>
    dplyr::filter(abbrev_state == 'RO')

  test4a <- dplyr::collect(test4a)
  test4b <- dplyr::collect(test4b)

  # every observed code must be mapped to a label
  for (v in vars) {
    testthat::expect_equal(sum(is.na(test4b[[v]])), sum(is.na(test4a[[v]])))
  }

  # code 9 is 'Ignorado', not 'Nao'
  testthat::expect_true('9' %in% test4a$V0617)
  testthat::expect_true('Ignorado' %in% test4b$V0617)
  testthat::expect_equal(sum(test4b$V0617 == 'Ignorado', na.rm = TRUE),
                         sum(test4a$V0617 == '9', na.rm = TRUE))
  testthat::expect_true('9' %in% test4a$V0656)
  testthat::expect_true('Ignorado' %in% test4b$V0656)
  testthat::expect_equal(sum(test4b$V0656 == 'Não', na.rm = TRUE),
                         sum(test4a$V0656 == '0', na.rm = TRUE))

  # V6920 code 2 is 'Nao ocupadas'
  testthat::expect_true('Não ocupadas' %in% test4b$V6920)
  testthat::expect_false('Desocupadas' %in% test4b$V6920)
})


################################################################### 2022
test_that("2022 add_labels_population", {
  # sem labels
  test1a <- read_population(
    year = 2022,
    add_labels = NULL,
    columns = c('abbrev_state', 'P0120'),
    showProgress = FALSE
  ) |>
    dplyr::filter(abbrev_state == 'RO')

  # com labels
  test1b <- censobr:::add_labels_population(
    arrw = test1a,
    year = 2022,
    lang = 'pt'
  ) |>
    dplyr::filter(abbrev_state == 'RO')

  test1a <- dplyr::collect(test1a)
  test1b <- dplyr::collect(test1b)

  # add labels
  testthat::expect_true(5 %in% test1a$P0120)
  testthat::expect_true('Povoado' %in% test1b$P0120)
})
################################################################### 2000
test_that("2000 add_labels_population", {
  # sem labels
  test3a <- read_population(
    year = 2000,
    add_labels = NULL,
    columns = c('abbrev_state', 'V0408', 'V0402', 'V4300', 'V0415', 'V0411'),
    showProgress = FALSE
  ) |>
    dplyr::filter(abbrev_state == 'RO')

  # com labels
  test3b <- censobr:::add_labels_population(
    arrw = test3a,
    year = 2000,
    lang = 'pt'
  ) |>
    dplyr::filter(abbrev_state == 'RO')

  test3a <- dplyr::collect(test3a)
  test3b <- dplyr::collect(test3b)

  # add labels
  testthat::expect_true('1' %in% test3a$V0408)
  testthat::expect_true('Branca' %in% test3b$V0408)

  # variables labelled through dplyr::across()
  testthat::expect_true('Pessoa responsável' %in% test3b$V0402)
  testthat::expect_true('Sim' %in% test3b$V0415)
  testthat::expect_true('Nenhuma dificuldade' %in% test3b$V0411)

  # every observed code must be mapped to a label
  for (v in c('V0408', 'V0402', 'V4300', 'V0415', 'V0411')) {
    testthat::expect_equal(sum(is.na(test3b[[v]])), sum(is.na(test3a[[v]])))
  }
})

test_that("2000 labels are reachable through read_population()", {
  # the public API used to reject add_labels = 'pt' for 2000 before downloading
  test3c <- read_population(
    year = 2000,
    add_labels = 'pt',
    columns = c('abbrev_state', 'V0408'),
    showProgress = FALSE
  ) |>
    dplyr::filter(abbrev_state == 'RO') |>
    dplyr::collect()

  testthat::expect_true('Branca' %in% test3c$V0408)
})

# ERRORS and messages  -----------------------
test_that("add_labels_population", {
  # missing labels
  testthat::expect_error(censobr:::add_labels_population(
    arrw = test1a,
    year = 9999,
    lang = 'pt'
  ))
  testthat::expect_error(censobr:::add_labels_population(
    arrw = test1a,
    year = 2022,
    lang = 9999
  ))
  testthat::expect_error(censobr:::add_labels_population(
    arrw = test1a,
    year = 2022,
    lang = 'banana'
  ))

  testthat::expect_error(censobr:::add_labels_population(
    arrw = test1a,
    year = 2010,
    lang = 9999
  ))
  testthat::expect_error(censobr:::add_labels_population(
    arrw = test1a,
    year = 2010,
    lang = 'banana'
  ))

  testthat::expect_error(censobr:::add_labels_population(
    arrw = test1a,
    year = 2000,
    lang = 9999
  ))
  testthat::expect_error(censobr:::add_labels_population(
    arrw = test1a,
    year = 2000,
    lang = 'banana'
  ))
})
