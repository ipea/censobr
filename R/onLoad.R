# package global variables
censobr_env <- new.env(parent = emptyenv()) # nocov start

.onLoad <- function(libname, pkgname) {
  # data release
  censobr_env$data_release <- 'v0.7.0'
} # nocov end
