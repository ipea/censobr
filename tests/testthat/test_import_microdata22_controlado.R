# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
# the test moves the cache directory, and set_censobr_cache_dir() records the
# path in a config file outside tempdir(), which CRAN does not allow
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


fake_zip <- system.file("extdata", "microdata_2022_controlado_fake.zip",
                        package = "censobr")

tables <- data.frame(
  ibge   = c("Domicilios", "Familia", "Mortalidade", "Pessoas"),
  censo  = c("households", "families", "mortality", "population"),
  prefix = c("D", "F", "M", "P"),
  ncol   = c(64L, 31L, 25L, 210L),
  stringsAsFactors = FALSE
)

# set_censobr_cache_dir() records the path in a config file that persists across
# sessions, so every test that moves the cache has to put the user's own
# configuration back, whether it passes or not
cache_config_restorer <- function() {
  config_file <- get_config_cache_file()
  had_config  <- file.exists(config_file)
  old_config  <- if (had_config) readLines(config_file) else NULL
  function() {
    if (had_config) writeLines(old_config, config_file) else unlink(config_file)
  }
}

# Import once, into a temporary cache directory.
release_dir <- (function() {

  restore <- cache_config_restorer()
  on.exit(restore(), add = TRUE)

  cache <- tempfile("censobr_cache_")
  dir.create(cache, recursive = TRUE)
  set_censobr_cache_dir(path = cache, verbose = FALSE)

  import_microdata22_controlado(zip_path = fake_zip)

  file.path(cache, paste0("data_release_", censobr_env$data_release))
})()

imported <- function(censo_name) {
  arrow::open_dataset(
    file.path(release_dir,
              paste0("2022_", censo_name, "_", censobr_env$data_release, ".parquet"))
  )
}

col_type <- function(dataset, column) {
  dataset$schema$GetFieldByName(column)$type$ToString()
}


# Writing the files -----------------------

test_that("import_microdata22_controlado writes the four tables to the cache", {

  # the files have to land in the versioned subdirectory, because that is where
  # download_file() looks for a file that is already cached
  testthat::expect_true(dir.exists(release_dir))

  testthat::expect_setequal(
    list.files(release_dir),
    paste0("2022_", tables$censo, "_", censobr_env$data_release, ".parquet")
  )

  for (censo_name in tables$censo) {
    testthat::expect_true(nrow(imported(censo_name)) > 0)
  }
})


test_that("import_microdata22_controlado keeps every column of every table", {

  schemas <- list(households = schema_households(),
                  families   = schema_families(),
                  mortality  = schema_mortality(),
                  population = schema_population())

  for (i in seq_len(nrow(tables))) {
    df  <- imported(tables$censo[i])
    sch <- schemas[[tables$censo[i]]]

    # every census variable of the layout file survives the import
    testthat::expect_true(all(sch$names %in% names(df)))
    # plus the geography columns that censobr adds
    testthat::expect_gt(length(names(df)), tables$ncol[i])
  }
})


# Column types -----------------------

test_that("import_microdata22_controlado types the columns from the layout file", {

  for (i in seq_len(nrow(tables))) {
    df <- imported(tables$censo[i])
    prefix <- tables$prefix[i]

    # 10 digit codes: the "area de ponderacao" goes above 2147483647 from state
    # 22 onwards, so a 32 bit integer overflows. The fixture carries Sao Paulo
    # so the values really do exceed the ceiling, and not only the declaration
    testthat::expect_equal(col_type(df, paste0(prefix, "0090")), "int64")
    weighting <- df |>
      dplyr::select(dplyr::all_of(paste0(prefix, "0090"))) |>
      dplyr::collect()
    testthat::expect_gt(max(as.numeric(weighting[[1]])), 2147483647)

    # the sample weight carries 13 decimal places, which needs a double
    testthat::expect_equal(col_type(df, paste0(prefix, "0111")), "double")

    # 2 digit codes fit the smallest integer
    testthat::expect_equal(col_type(df, paste0(prefix, "0120")), "int8")
  }

  # F0101 and M0101 carry a letter prefix, "F001" and "M001"
  testthat::expect_equal(col_type(imported("families"), "F0101"), "string")
  testthat::expect_equal(col_type(imported("mortality"), "M0101"), "string")

  # P0101 looks like them but is a plain count, so it stays an integer
  testthat::expect_false(col_type(imported("population"), "P0101") == "string")

  # income carries 2 decimals over 9 digits
  testthat::expect_equal(col_type(imported("families"), "F0260"), "double")
})


test_that("the schemas cover every column of their table", {

  schemas <- list(households = schema_households(),
                  families   = schema_families(),
                  mortality  = schema_mortality(),
                  population = schema_population())

  for (i in seq_len(nrow(tables))) {
    sch <- schemas[[tables$censo[i]]]
    testthat::expect_s3_class(sch, "Schema")
    testthat::expect_equal(length(sch$names), tables$ncol[i])
    # no column may be left untyped
    testthat::expect_false(any(duplicated(sch$names)))
  }
})


# Geography columns -----------------------

test_that("import_microdata22_controlado adds the censobr geography columns", {

  geo <- c("code_region", "name_region", "code_state", "abbrev_state",
           "name_state", "code_meso", "code_micro", "code_intermediate",
           "code_immediate", "code_urban_concentration", "code_muni",
           "code_weighting")

  for (censo_name in tables$censo) {
    df <- imported(censo_name)

    testthat::expect_true(all(geo %in% names(df)))
    # they are moved to the front of the table
    testthat::expect_equal(names(df)[seq_along(geo)], geo)

    states <- df |>
      dplyr::select(dplyr::all_of(c("code_state", "abbrev_state", "name_state",
                                    "code_region", "name_region"))) |>
      dplyr::distinct() |>
      dplyr::collect() |>
      as.data.frame()

    # the fixture holds Rondonia, Acre and Sao Paulo
    testthat::expect_setequal(states$code_state, c(11, 12, 35))
    testthat::expect_setequal(states$abbrev_state, c("RO", "AC", "SP"))
    testthat::expect_setequal(states$name_state,
                              c("Rondônia", "Acre", "São Paulo"))
    testthat::expect_setequal(states$name_region, c("Norte", "Sudeste"))
    # a code with no match would come back as NA
    testthat::expect_false(anyNA(states))
  }
})


test_that("add_geography_cols does not read the data into memory", {

  arrw <- arrow::open_delim_dataset(
    utils::unzip(fake_zip, files = "11/Familia_11_controlado.csv",
                 exdir = tempfile("fixture")),
    delim = ";",
    col_types = schema_families(),
    na = ""
  )

  out <- add_geography_cols(arrw, "families")

  # a materialised Table would defeat the larger-than-memory contract of the
  # package, and Pessoas alone would take several GB
  testthat::expect_s3_class(out, "arrow_dplyr_query")
  testthat::expect_false(inherits(out, "Table"))
})


# The schema is what makes the files readable -----------------------

test_that("the tables cannot be read without declaring the schema", {

  files <- utils::unzip(fake_zip, exdir = tempfile("fixture"))
  familia <- grep("Familia", files, value = TRUE)

  # F0070 is blank in every row of the first state file, so arrow infers `null`
  # for the whole dataset and fails on the first file that has a value
  testthat::expect_error(
    arrow::write_parquet(
      arrow::open_delim_dataset(familia, delim = ";"),
      tempfile(fileext = ".parquet")
    )
  )

  # declaring the schema is what avoids it
  testthat::expect_no_error(
    arrow::write_parquet(
      arrow::open_delim_dataset(familia, delim = ";",
                                col_types = schema_families(), na = ""),
      tempfile(fileext = ".parquet")
    )
  )
})


# ERRORS and messages  -----------------------

test_that("import_microdata22_controlado errors", {

  testthat::expect_error(
    import_microdata22_controlado(zip_path = "banana.zip"), "does not exist"
  )
  testthat::expect_error(import_microdata22_controlado())
})


# The read_ functions point users to the import -----------------------

test_that("read_ functions ask for the 2022 microdata to be imported", {

  restore <- cache_config_restorer()
  on.exit(restore(), add = TRUE)

  empty_cache <- tempfile("censobr_empty_")
  dir.create(empty_cache, recursive = TRUE)
  set_censobr_cache_dir(path = empty_cache, verbose = FALSE)

  # IBGE does not let censobr redistribute these files, so an empty cache is not
  # something a download can fix. The error has to say so, and say what to do.
  for (f in list(read_population, read_households, read_families, read_mortality)) {
    testthat::expect_error(f(year = 2022), "not distributed")
    testthat::expect_error(f(year = 2022), "import")
    testthat::expect_error(f(year = 2022), "microdados.ibge.gov.br")
  }

  # the error belongs to the function the user called, not to the internal
  # helper that raises it
  err <- rlang::catch_cnd(read_population(year = 2022))
  testthat::expect_match(deparse(conditionCall(err))[1], "read_population")

  # a year that censobr does distribute must not take this path
  testthat::expect_error(read_population(year = 1999), "currently available")
})


test_that("read_ functions find the 2022 microdata once imported", {

  restore <- cache_config_restorer()
  on.exit(restore(), add = TRUE)

  set_censobr_cache_dir(path = dirname(release_dir), verbose = FALSE)

  readers <- list(population = read_population, households = read_households,
                  families   = read_families,   mortality  = read_mortality)

  for (nm in names(readers)) {
    df <- readers[[nm]](year = 2022, verbose = FALSE)
    testthat::expect_s3_class(df, "Dataset")
    testthat::expect_gt(nrow(df), 0)
    testthat::expect_true("name_state" %in% names(df))
  }

  # nothing is downloaded for 2022, so cache = FALSE must not try to
  testthat::expect_s3_class(
    read_population(year = 2022, cache = FALSE, verbose = FALSE), "Dataset"
  )
})
