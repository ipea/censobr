# Regression guard for the STORAGE TYPE of the microdata codes.
#
# The v0.7.0 data release re-typed nearly every categorical column of the
# microdata from `string` to `int32`. Until then the label blocks compared
# codes as quoted strings (`V0601 == '1'`), which Arrow cannot evaluate
# against an integer column: on an arrow Dataset -- what every read_*()
# returns by default -- it aborts with "Expression not supported in Arrow",
# and on an in-memory Table it silently pulls the whole dataset into R,
# which is the opposite of what this package promises.
#
# Every other label test needs the network, so the breakage only showed up
# once the new data were downloaded. These tests run each add_labels_*() year
# block over a one-row integer Dataset built in memory, so an unevaluable
# comparison fails here with no network at all.

# chaining ~80 arrow mutate() calls per year block costs a couple of minutes
# in total, so this file follows the other label tests and steps aside on CRAN
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")

# Column names a labeller mutates for one census year. Every string constant
# of the year's block that is not the right-hand side of a `~` and is shaped
# like a column name: that is the `'V0601' %in% cols` guards plus the vectors
# handed to dplyr::across(). The Portuguese labels all sit on the right of a
# `~`, so they are skipped. Blocks for the other years are dropped so the
# dummy table stays narrow -- arrow's mutate() cost grows with the width of
# the query.
labelled_vars <- function(fn, year) {
  stmts <- as.list(body(fn))[-1]
  mine <- vapply(stmts, function(s) {
    if (!is.call(s) || !identical(as.character(s[[1]]), "if")) return(TRUE)
    cond <- paste(deparse(s[[2]]), collapse = " ")
    !grepl("year ==", cond, fixed = TRUE) ||
      grepl(paste0("year == ", year), cond, fixed = TRUE)
  }, logical(1))
  block <- as.call(c(as.name("{"), stmts[mine]))

  walk <- function(x) {
    if (is.character(x)) return(x)
    if (!is.call(x)) return(NULL)
    two_sided <- identical(as.character(x[[1]])[1], "~") && length(x) == 3L
    parts <- if (two_sided) list(x[[2]]) else as.list(x)[-1]
    unlist(lapply(parts, walk))
  }
  strs <- unique(walk(block))
  setdiff(strs[grepl("^[A-Za-z][A-Za-z0-9_.]*$", strs)], "pt")
}

# A one-row arrow Dataset with every column stored as int32. A Dataset (not
# a Table) on purpose: a Table would fall back to R instead of erroring.
int_dataset <- function(vars) {
  df <- as.data.frame(stats::setNames(rep(list(1L), length(vars)), vars))
  arrow::InMemoryDataset$create(arrow::arrow_table(df))
}

fleet <- list(
  population = list(fn = censobr:::add_labels_population,
                    years = c(1960, 1970, 1980, 1991, 2000, 2010, 2022)),
  households = list(fn = censobr:::add_labels_households,
                    years = c(1960, 1970, 1980, 1991, 2000, 2010, 2022)),
  families   = list(fn = censobr:::add_labels_families,  years = c(2000, 2022)),
  mortality  = list(fn = censobr:::add_labels_mortality, years = c(2010, 2022)),
  emigration = list(fn = censobr:::add_labels_emigration, years = 2010)
)


test_that("every label block is evaluable inside Arrow on integer codes", {
  for (nm in names(fleet)) {
    for (y in fleet[[nm]]$years) {
      vars <- labelled_vars(fleet[[nm]]$fn, y)
      testthat::expect_true(length(vars) > 0)
      ds <- int_dataset(vars)

      # no error => every comparison has an Arrow kernel for int32 columns
      out <- NULL
      testthat::expect_error(
        out <- dplyr::collect(fleet[[nm]]$fn(arrw = ds, year = y, lang = 'pt')),
        NA
      )

      # and labels are actually applied, not silently dropped
      testthat::expect_true(any(vapply(out, is.character, logical(1))))
    }
  }
})


test_that("codes that used to be zero-padded are labelled", {
  # these three were '01' in the pre-v0.7.0 character data and are 1 now
  h <- int_dataset(labelled_vars(fleet$households$fn, 2010))
  h <- dplyr::collect(censobr:::add_labels_households(h, year = 2010, lang = 'pt'))
  testthat::expect_equal(h$V4001, 'Domicílio particular permanente ocupado')

  p <- int_dataset(labelled_vars(fleet$population$fn, 2000))
  p <- dplyr::collect(censobr:::add_labels_population(p, year = 2000, lang = 'pt'))
  testthat::expect_equal(p$V0402, 'Pessoa responsável')

  f <- int_dataset(labelled_vars(fleet$families$fn, 2000))
  f <- dplyr::collect(censobr:::add_labels_families(f, year = 2000, lang = 'pt'))
  testthat::expect_equal(f$CODV0404_2, 'Casal sem filhos')

  # and the block shared by every year
  e <- int_dataset(labelled_vars(fleet$emigration$fn, 2010))
  e <- dplyr::collect(censobr:::add_labels_emigration(e, year = 2010, lang = 'pt'))
  testthat::expect_equal(e$V1006, 'Urbana')
})
