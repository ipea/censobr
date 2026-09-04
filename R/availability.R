# Single source of truth for which census years each public function serves.
# A new census release is added here, not in nine files.
# Values transcribed verbatim from the literals they replace -- behaviour-preserving.
.censobr_availability <- list(
  population            = c(1960, 1970, 1980, 1991, 2000, 2010, 2022),
  households            = c(1960, 1970, 1980, 1991, 2000, 2010, 2022),
  families              = c(2000, 2022),
  mortality             = c(2010, 2022),
  emigration            = c(2010),
  tracts                = c(2000, 2010, 2022),
  questionnaire         = c(1960, 1970, 1980, 1991, 2000, 2010, 2022),
  interview_manual      = c(1960, 1970, 1980, 1991, 2000, 2010, 2022),
  dictionary_microdata  = c(2000, 2010, 2022),
  dictionary_tracts     = c(1970, 1980, 1991, 2000, 2010, 2022),
  dictionary_population = c(1960, 1970, 1980, 1991),
  dictionary_households = c(1960, 1970, 1980, 1991)
)

# Internal accessor. Aborts loudly on an unregistered key: `data_dictionary()`
# builds its key at run time, and a silent NULL there would make `year %in% NULL`
# always FALSE and report an empty list of available years.
censobr_years <- function(key) {
  out <- .censobr_availability[[key]]
  if (is.null(out)) cli::cli_abort("Internal error: no year list registered for {.val {key}}.")
  out
}
