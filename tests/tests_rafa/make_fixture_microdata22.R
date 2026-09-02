# Build inst/extdata/microdata_2022_controlado_fake.zip
#
# The fixture mimics the structure of the zip file that IBGE distributes with
# the controlled-access microdata of the 2022 census: one subdirectory per
# state, four `;` delimited csv files in each, and the real variable names.
#
# It holds NO census data. Every value is made up, and deliberately round, so
# that nobody can mistake the file for the real thing:
#
#   int8   ->  10, 20, 30, 40, 50
#   int16  ->  100, 200, 300, 400, 500
#   int32  ->  1000, 2000, 3000, 4000, 5000
#   int64  ->  3000000001 ... (above the 32 bit ceiling, on purpose)
#   double ->  1.5, 2.5, 3.5, 4.5, 5.5
#   string ->  "F001" ... (a letter prefix, as F0101 and M0101 have)
#
# The geography variables (X0010 to X0090) are the exception: they carry codes
# that really exist, because add_geography_cols() has to resolve them into
# state and region names.
#
# Run with:  Rscript tests/tests_rafa/make_fixture_microdata22.R

devtools::load_all(".", quiet = TRUE)

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
ufs   <- c(11L, 12L, 35L)
nrows <- 5L

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

bld <- tempfile("fixture22"); dir.create(bld, recursive = TRUE)

for (k in seq_len(nrow(tables))) {

  sch    <- schemas[[tables$ibge[k]]]
  prefix <- tables$prefix[k]
  cols   <- sch$names
  types  <- vapply(sch$fields, function(f) f$type$ToString(), character(1))

  for (uf in ufs) {

    m <- matrix("", nrow = nrows, ncol = length(cols),
                dimnames = list(NULL, cols))

    for (i in seq_len(nrows)) {
      v <- vapply(seq_along(cols), function(j) fake_value(types[j], i, prefix),
                  character(1))
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

cat("wrote", zp, "-", file.size(zp), "bytes\n")
print(utils::unzip(zp, list = TRUE))
