# Deleting files cached from previous data releases.
#
# These tests are offline: they build a fake cache directory and never download
# anything, so they also give coverage to code that is otherwise `nocov`.

testthat::skip_on_cran()

# builds a cache dir holding one current and one previous data release
setup_fake_cache <- function(files_old = "1960_households_v0.6.0.parquet") {
  cache_dir <- file.path(tempfile("censobr_cache"))

  old_dir <- file.path(cache_dir, "data_release_v0.6.0")
  new_dir <- file.path(
    cache_dir,
    paste0("data_release_", censobr_env$data_release)
  )

  dir.create(old_dir, recursive = TRUE)
  dir.create(new_dir, recursive = TRUE)

  for (f in files_old) {
    writeLines("old", file.path(old_dir, f))
  }
  writeLines("current", file.path(new_dir, "1960_households_current.parquet"))

  list(cache_dir = cache_dir, old_dir = old_dir, new_dir = new_dir)
}

# points censobr at a fake cache dir for the duration of the calling test, and
# resets the once-per-session guard
use_fake_cache <- function(fake, env = parent.frame()) {
  original <- get_censobr_cache_dir()
  censobr::set_censobr_cache_dir(path = fake$cache_dir, verbose = FALSE)
  censobr_env$old_cache_checked <- NULL

  withr::defer(
    {
      censobr::set_censobr_cache_dir(path = original, verbose = FALSE)
      censobr_env$old_cache_checked <- NULL
    },
    envir = env
  )
}


test_that("delete_old_cache_dirs removes previous releases only", {
  fake <- setup_fake_cache()
  use_fake_cache(fake)

  # a directory of the user's that censobr did not create must not be touched
  other_dir <- file.path(fake$cache_dir, "my_own_data")
  dir.create(other_dir)
  writeLines("mine", file.path(other_dir, "important.csv"))

  deleted <- delete_old_cache_dirs(verbose = FALSE)

  testthat::expect_length(deleted, 1)
  testthat::expect_false(dir.exists(fake$old_dir))
  testthat::expect_true(dir.exists(fake$new_dir))
  testthat::expect_true(
    file.exists(file.path(fake$new_dir, "1960_households_current.parquet"))
  )
  testthat::expect_true(file.exists(file.path(other_dir, "important.csv")))
})


test_that("delete_old_cache_dirs is a no-op when there is nothing to delete", {
  fake <- setup_fake_cache()
  use_fake_cache(fake)

  delete_old_cache_dirs(verbose = FALSE)

  testthat::expect_length(delete_old_cache_dirs(verbose = FALSE), 0)
  testthat::expect_true(dir.exists(fake$new_dir))
})


test_that("delete_old_cache_dirs reports what it deleted, and only if verbose", {
  fake <- setup_fake_cache()
  use_fake_cache(fake)

  testthat::expect_message(
    delete_old_cache_dirs(verbose = TRUE),
    "previous"
  )

  fake2 <- setup_fake_cache()
  use_fake_cache(fake2)

  testthat::expect_silent(delete_old_cache_dirs(verbose = FALSE))
  testthat::expect_false(dir.exists(fake2$old_dir))
})


test_that("controlled-access microdata are never deleted", {
  fake <- setup_fake_cache(files_old = c(
    "1960_households_v0.6.0.parquet",
    "2022_population.controlado_v0.6.0.parquet"
  ))
  use_fake_cache(fake)

  deleted <- delete_old_cache_dirs(verbose = FALSE)

  testthat::expect_length(deleted, 1)
  testthat::expect_true(dir.exists(fake$old_dir))
  testthat::expect_true(file.exists(
    file.path(fake$old_dir, "2022_population.controlado_v0.6.0.parquet")
  ))
  testthat::expect_false(file.exists(
    file.path(fake$old_dir, "1960_households_v0.6.0.parquet")
  ))
})


test_that("options(censobr.keep_old_cache = TRUE) disables the deletion", {
  fake <- setup_fake_cache()
  use_fake_cache(fake)

  withr::local_options(censobr.keep_old_cache = TRUE)

  testthat::expect_length(delete_old_cache_dirs(verbose = FALSE), 0)
  testthat::expect_true(dir.exists(fake$old_dir))
})


test_that("prune_old_cache_once runs once per cache dir", {
  fake <- setup_fake_cache()
  use_fake_cache(fake)

  testthat::expect_length(prune_old_cache_once(verbose = FALSE), 1)

  # a second old release appearing in the same session is not deleted again,
  # the check having already run for this cache dir
  dir.create(file.path(fake$cache_dir, "data_release_v0.5.0"))
  writeLines("old", file.path(fake$cache_dir, "data_release_v0.5.0", "x.parquet"))

  testthat::expect_length(prune_old_cache_once(verbose = FALSE), 0)
  testthat::expect_true(dir.exists(file.path(fake$cache_dir, "data_release_v0.5.0")))

  # but a different cache dir is checked
  fake2 <- setup_fake_cache()
  censobr::set_censobr_cache_dir(path = fake2$cache_dir, verbose = FALSE)

  testthat::expect_length(prune_old_cache_once(verbose = FALSE), 1)
  testthat::expect_false(dir.exists(fake2$old_dir))
})


test_that("censobr_cache(delete_file = 'old') deletes previous releases", {
  fake <- setup_fake_cache()
  use_fake_cache(fake)

  testthat::expect_message(
    censobr_cache(delete_file = "old", list_files = FALSE, verbose = TRUE),
    "previous"
  )

  testthat::expect_false(dir.exists(fake$old_dir))
  testthat::expect_true(dir.exists(fake$new_dir))
})


test_that("'old' is a keyword, not a file pattern", {
  # a cache path containing the word "old" must not be matched as a file
  fake <- setup_fake_cache(files_old = "1960_households_v0.6.0.parquet")
  use_fake_cache(fake)

  writeLines("keep", file.path(fake$new_dir, "old_looking_file.parquet"))

  censobr_cache(delete_file = "old", list_files = FALSE, verbose = FALSE)

  testthat::expect_true(
    file.exists(file.path(fake$new_dir, "old_looking_file.parquet"))
  )
})
