# package global variables
censobr_env <- new.env(parent = emptyenv()) # nocov start

.onLoad <- function(libname, pkgname) {
  # data release
  censobr_env$data_release <- 'v1.0.0'

  # cache dir already checked for files from previous data releases. The check
  # runs at download time and not here, because the cache dir is only known
  # once set_censobr_cache_dir() has had its chance to run
  censobr_env$old_cache_checked <- NULL
} # nocov end
