context("read_tracts")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


tester <- function(year = 2010,
                   dataset = 'Basico',
                   as_data_frame = FALSE,
                   showProgress = FALSE,
                   cache = TRUE,
                   verbose = TRUE) {
  censobr::read_tracts(
    year,
    dataset,
    as_data_frame,
    showProgress,
    cache,
    verbose
  )
}


# Reading the data -----------------------

testthat::test_that("read_tracts", {

  # arrow table
  test1 <- tester(year = 2010, dataset = 'Basico')
  testthat::expect_true(is(test1, "ArrowObject"))
  # testthat::expect_true(is(test1, "Table"))
  testthat::expect_true(nrow(test1) >0 )

  # data.frame
  test2 <- tester(year = 2010, dataset = 'Basico', as_data_frame = TRUE)
  testthat::expect_true(is(test2, "data.frame"))


  # check whether cache argument is working
  # check whether cache argument is working
  testthat::expect_message(tester(year = 2010, dataset = 'Basico',
                                  cache = TRUE), regexp = 'locally')
  testthat::expect_message(tester(year = 2010, dataset = 'Basico',
                                  cache = FALSE), regexp = 'Overwriting|future')

  # no message
  testthat::expect_no_message(tester(verbose = FALSE))

})


# 2022 data sets  -----------------------

testthat::test_that("read_tracts 2022 datasets", {

  # 2022 different data sets
  ## check if file has been downloaded
  tbls <- c("Basico", "Domicilio", "Pessoas", "ResponsavelRenda",
            "Indigenas", "Quilombolas", "Entorno", "Obitos", "Preliminares")

  lapply(X=tbls, FUN = function(y){ # y = 'Preliminares'
    tmp_d <- tester(year = 2022, dataset = y)
    testthat::expect_true( nrow(tmp_d) >= 344841)
  } )

})

# 2010 data sets  -----------------------

testthat::test_that("read_tracts 2010 datasets", {

  # 2010 different data sets
  ## check if file have been downloaded
  tbls <- c('Basico', 'Domicilio', 'DomicilioRenda', 'Entorno',
            'ResponsavelRenda', 'Responsavel', 'PessoaRenda', 'Pessoa')

  lapply(
    X=tbls,
    FUN = function(y){ # y = 'Pessoa'     y = 'Basico'  y = 'Entorno'
      message(y)
      tmp_d <- tester(year = 2010, dataset = y)
      testthat::expect_true( nrow(tmp_d) >= 310114)
      }
    )

})




# 2000 data sets  -----------------------

testthat::test_that("read_tracts 2000 datasets", {

  # 2000 different data sets
  ## check if file have been downloaded
  tbls <- c("Basico", "Domicilio", "Responsavel", "Pessoa", "Instrucao", "Morador")

  lapply(X=tbls, FUN = function(y){ # y = 'Pessoa'     y = 'Basico'  y = 'Entorno'
    tmp_d <- tester(year = 2000, dataset = y)
    testthat::expect_true( nrow(tmp_d) == 215811)
  } )

})

# ERRORS and messages  -----------------------
testthat::test_that("read_tracts", {

  # Wrong date 4 digits )
  # year must be declared by the user, whether omitted or passed as NULL
  # dataset must be declared, and the error must list the options for that year
  testthat::expect_error( read_tracts(year = 2000), 'declare' )
  testthat::expect_error( read_tracts(year = 2000), 'Instrucao' )
  testthat::expect_error( read_tracts(year = 2010, dataset = NULL), 'declare' )
  testthat::expect_error( read_tracts(), 'declare' )
  testthat::expect_error( read_tracts(year = NULL), 'declare' )
  testthat::expect_error(tester(year=999, dataset='Basico'))
  testthat::expect_error(tester(year=999, dataset='Basico'))
  testthat::expect_error(tester(year=2010, dataset='banana'))
  testthat::expect_error(tester(year=2022, dataset='banana'))
  # error for 2000 must list the 2000 data sets, not the 2010 ones
  testthat::expect_error(tester(year=2000, dataset='banana'), 'Instrucao')

  testthat::expect_error(tester(cache='banana'))
  testthat::expect_error(tester(showProgress='banana'))
  testthat::expect_error(tester(verbose='banana'))

  testthat::expect_error(tester(year=2010, dataset='Basico', showProgress = 'banana' ))
  testthat::expect_error(tester(year=2010, dataset='Basico', cache = 'banana' ))
})

# # clean cache
# censobr_cache(delete_file = 'all')
