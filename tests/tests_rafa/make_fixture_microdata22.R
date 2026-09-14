# Build inst/extdata/microdata_2022_controlado_fake.zip
#
# The fixture mimics the structure of the zip file that IBGE distributes with
# the controlled-access microdata of the 2022 census: one subdirectory per
# state, four `;` delimited csv files in each, and the real variable names.
#
# It holds NO census data. Every value is made up.
#
# Categorical variables of the Pessoas table carry the codes that
# add_labels_population() actually recognises for 2022, so that
# read_population(2022, add_labels = "pt") produces real labels and the
# fixture exercises the labelling code. The code sets are read straight out of
# the function body (see codes_2022() below), so they cannot drift out of sync
# with the labeller.
#
# Every other variable keeps a deliberately round value, so that nobody can
# mistake the file for the real thing:
#
#   int8   ->  10, 20, 30, 40, 50 ...
#   int16  ->  100, 200, 300, 400, 500 ...
#   int32  ->  1000, 2000, 3000, 4000, 5000 ...
#   int64  ->  3000000001 ... (above the 32 bit ceiling, on purpose)
#   double ->  1.5, 2.5, 3.5, 4.5, 5.5 ...
#   string ->  "F001" ... (a letter prefix, as F0101 and M0101 have)
#
# The Domicilios, Familia and Mortalidade tables are round values throughout:
# add_labels_households(), add_labels_families() and add_labels_mortality()
# have no 2022 branch, so there are no 2022 codes for them to be consistent
# with. Add one here when a 2022 branch is written for those labellers.
#
# The geography variables (X0010 to X0090) are the exception: they carry codes
# that really exist, because add_geography_cols() has to resolve them into
# state and region names.
#
# Run with:  Rscript tests/tests_rafa/make_fixture_microdata22.R

devtools::load_all(".", quiet = TRUE)

# ---- the 2022 codes that add_labels_population() recognises -----------------
#
# Walks the 2022 block of the labeller and collects, per variable, every
# integer it compares against. Reading them out of the AST rather than
# hardcoding them here is what keeps the fixture honest: add a code to the
# labeller and the next run of this script puts it in the fixture.

codes_2022 <- function() {

  blk <- NULL
  for (s in as.list(body(censobr:::add_labels_population))) {
    if (is.call(s) && identical(s[[1]], as.name("if"))) {
      cond <- paste(deparse(s[[2]]), collapse = "")
      if (grepl("2022", cond) && grepl("lang", cond)) { blk <- s[[3]]; break }
    }
  }
  if (is.null(blk)) stop("could not find the 2022 block of add_labels_population()")

  # every `<x> == <number>` inside an expression
  eqs <- function(x, acc = list()) {
    if (is.call(x)) {
      if (identical(x[[1]], as.name("==")) && is.numeric(x[[3]])) {
        acc[[length(acc) + 1]] <- list(lhs = paste(deparse(x[[2]]), collapse = ""),
                                       val = as.numeric(x[[3]]))
      }
      for (i in seq_along(x)) if (!is.null(x[[i]])) acc <- eqs(x[[i]], acc)
    }
    acc
  }
  calls_mutate <- function(x) {
    if (!is.call(x)) return(FALSE)
    if (grepl("mutate", paste(deparse(x[[1]]), collapse = ""))) return(TRUE)
    any(vapply(as.list(x)[-1],
               function(y) !is.null(y) && calls_mutate(y), logical(1)))
  }

  # the across() blocks name their columns through a vars_* vector defined a
  # couple of statements earlier, so those assignments have to be evaluated
  e <- new.env(); e$cols <- schema_population()$names

  map <- list()
  for (st in as.list(blk)[-1]) {

    if (is.call(st) && identical(st[[1]], as.name("<-")) && !calls_mutate(st)) {
      try(eval(st, e), silent = TRUE)
      next
    }

    ll <- eqs(st)
    if (!length(ll)) next
    lhs  <- unique(vapply(ll, function(z) z$lhs, character(1)))
    vals <- sort(unique(vapply(ll, function(z) z$val, numeric(1))))

    if (all(lhs == ".x")) {              # dplyr::across(all_of(<vars>), ...)
      tgt <- NULL
      f <- function(x) {
        if (is.call(x)) {
          if (identical(x[[1]], as.name("all_of"))) tgt <<- eval(x[[2]], e)
          for (i in seq_along(x)) if (!is.null(x[[i]])) f(x[[i]])
        }
      }
      f(st)
      for (v in tgt) map[[v]] <- vals
    } else {
      for (v in setdiff(lhs, ".x")) map[[v]] <- vals
    }
  }
  map
}

pop_codes <- codes_2022()
message("labelled 2022 variables found: ", length(pop_codes))

# the geography columns are written separately below, so the labeller must not
# also claim them
geo_cols <- paste0("P", sprintf("%04d", c(10, 20, 30, 40, 50, 60, 70, 80, 90)))
stopifnot(!any(geo_cols %in% names(pop_codes)))

# every code of every variable has to appear at least once
nrows <- max(lengths(pop_codes))

tables <- data.frame(
  ibge   = c("Domicilios", "Familia", "Mortalidade", "Pessoas"),
  prefix = c("D", "F", "M", "P"),
  stringsAsFactors = FALSE
)
schemas <- list(Domicilios  = schema_households(),
                Familia     = schema_families(),
                Mortalidade = schema_mortality(),
                Pessoas     = schema_population())

# Rondonia and Acre are in the North region, Sao Paulo in the Southeast. Sao
# Paulo is here so that the "area de ponderacao" of one state goes above
# 2147483647, which is what a 32 bit integer cannot hold.
ufs <- c(11L, 12L, 35L)

# one round value per row, chosen so it fits the type the schema declares
fake_value <- function(type, i, prefix) {
  switch(type,
    "int8"   = as.character(i * 10L),
    "int16"  = as.character(i * 100L),
    "int32"  = as.character(i * 1000L),
    "int64"  = format(3000000000 + i, scientific = FALSE),
    "double" = sprintf("%.1f", i + 0.5),
    "string" = sprintf("%s%03d", prefix, i),
    stop("unhandled type: ", type)
  )
}

# int8 tops out at 127, so a round i*10 runs off the end well before row 33
cap <- function(v, type) {
  lim <- switch(type, "int8" = 127, "int16" = 32767, "int32" = 2147483647, NA)
  if (is.na(lim)) return(v)
  n <- suppressWarnings(as.numeric(v))
  if (is.na(n) || n <= lim) v else as.character(n %% (lim + 1L))
}

bld <- tempfile("fixture22"); dir.create(bld, recursive = TRUE)

for (k in seq_len(nrow(tables))) {

  sch    <- schemas[[tables$ibge[k]]]
  prefix <- tables$prefix[k]
  cols   <- sch$names
  types  <- vapply(sch$fields, function(f) f$type$ToString(), character(1))

  # only the Pessoas table has a 2022 labeller to be consistent with
  codes <- if (prefix == "P") pop_codes else list()

  for (uf in ufs) {

    m <- matrix("", nrow = nrows, ncol = length(cols),
                dimnames = list(NULL, cols))

    for (i in seq_len(nrows)) {
      v <- vapply(seq_along(cols), function(j) {
        cd <- codes[[cols[j]]]
        if (!is.null(cd)) {
          # cycle through the codes the labeller knows, so each one appears
          as.character(cd[((i - 1L) %% length(cd)) + 1L])
        } else {
          cap(fake_value(types[j], i, prefix), types[j])
        }
      }, character(1))
      names(v) <- cols

      # geography, so that the codes resolve to real states and regions
      muni <- uf * 100000L + i
      v[paste0(prefix, "0010")] <- substr(uf, 1, 1)          # region
      v[paste0(prefix, "0020")] <- uf                        # state
      v[paste0(prefix, "0030")] <- uf * 100L + 1L            # meso region
      v[paste0(prefix, "0040")] <- uf * 1000L + 1L           # micro region
      v[paste0(prefix, "0050")] <- uf * 100L + 2L            # intermediate
      v[paste0(prefix, "0060")] <- uf * 10000L + 1L          # immediate
      # blank for every row of the first state, which is what makes arrow infer
      # `null` for the whole column when the schema is not declared
      v[paste0(prefix, "0070")] <- if (uf == ufs[1]) "" else muni
      v[paste0(prefix, "0080")] <- muni                      # municipality
      v[paste0(prefix, "0090")] <- format(as.numeric(muni) * 1000 + i,
                                          scientific = FALSE)  # weighting area

      m[i, ] <- v
    }

    d <- file.path(bld, uf)
    dir.create(d, showWarnings = FALSE)
    writeLines(
      c(paste(cols, collapse = ";"), apply(m, 1, paste, collapse = ";")),
      file.path(d, paste0(tables$ibge[k], "_", uf, "_controlado.csv"))
    )
  }
}

zp <- file.path(normalizePath("inst/extdata", mustWork = TRUE),
                "microdata_2022_controlado_fake.zip")
unlink(zp)
owd <- setwd(bld)
utils::zip(zp, list.files(".", recursive = TRUE), flags = "-q")
setwd(owd)
unlink(bld, recursive = TRUE)

cat("wrote", zp, "-", file.size(zp), "bytes -", nrows, "rows per state\n")
print(utils::unzip(zp, list = TRUE))
