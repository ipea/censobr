# package global variables
censobr_env <- new.env(parent = emptyenv()) # nocov start

.onLoad <- function(libname, pkgname){

  # data release
  censobr_env$data_release <- 'v0.6.0'
  censobr_env$label_config_cache <- new.env(parent = emptyenv())

} # nocov end
