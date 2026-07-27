library(tictoc)
library(dplyr)

# clean slate
censobr::censobr_cache( print_tree = T)
censobr::censobr_cache(delete_file = 'all')

# download
tic()
df <- read_population(year=2010, showProgress = T)
toc()
# v5  9.89 sec elapsed ipea
# v3 26.12 sec elapsed ipea

# v3 15.97 sec elapsed servidor
# v5 17.65 sec elapsed elapsed servidor

# v3 33.03 sec elapsed casa
# v5 27.03 sec elapsed casa


# cache
tic()
df <- read_population(year=2010)
toc()
# v5 0.03 sec elapsed
# v3 0.04 sec elapsed


# head
test <- function(y){
  df <- read_population(year=y)
  temp <- collect(head(df))
  return(temp)
}
bench::mark(test(y = 2010), iterations = 10)

# expression   min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time result memory
#         v3 41.5s  41.5s    0.0241      11MB   0.0482     1     2      41.5s <dt>   <Rprofmem>
#         v5 46.4s  52.6s    0.0190    10.9MB   0.0760     2     8      1.75m <tibble>
#    serv v3 28.7s  28.9s    0.0346    5.24MB    0.138     2     8      57.8s <dt>
#    serv v5 28.8s  28.8s    0.0347    5.18MB    0.312     1     9      28.8s <tibble>


#    casa v3 42.5s  43.8s    0.0229    4.77MB   0.0229    10    10      7.28m
#    casa v5 50.7s  54.3s    0.0183    4.94MB   0.0183    10    10      9.09m

#### cache tests

system.time(
  df <- read_families(year = 2000,
                      showProgress = T,
                      cache = T)
)

censobr_cache(delete_file = '2000_families')




############3
# dici cenus tract 1970
# arquivo dos 80


# devtools::install_github("ipeaGIT/r5r", subdir = "r-package", force=T)
library(censobr)
library(dplyr)
library(arrow)
library(data.table)



df <- read_population(year = 2010, add_labels = 'pt') |>
      filter(code_state == 11) |>
      collect()


library(censobr)
library(dplyr)
library(arrow)

df <- censobr::read_population(year = 2010, add_labels = 'pt') |>
      group_by(code_muni, V0601) |>
      summarise(pop = sum(V0010)) |>
      collect() |>
      tidyr::pivot_wider(id_cols = code_muni,
                         names_from = V0601,
                         values_from = pop)
head(df)
#> code_muni  Masculino Feminino
#>     <chr>      <dbl>    <dbl>
#> 1 1100015      12656.   11736.
#> 2 1100023      45543.   44810.
#> 3 1100031       3266.    3047
#> 4 1100049      39124.   39450.
#> 5 1100056       8551.    8478.
#> 6 1100064       9330.    9261.




# read
# https://stackoverflow.com/questions/58439966/read-partitioned-parquet-directory-all-files-in-one-r-dataframe-with-apache-ar

# data dictionary  ----------------


data_dic(year)

utils::browseURL('./data_prep/data_raw/layout_2010.html')

temp.f <- tempfile(fileext = '.html')

knitr::knit2html('./data_prep/data_raw/layout_2010_dom.md',
                 output = temp.f)

rstudioapi::viewer(temp.f)
utils::browseURL(temp.f)

utils::browseURL(url = "./data_prep/data_raw/test.html")


# data_dictionary <- function(year, table){
#   year = '2010'
#   table = 'microdata'
#   # load all dictionary files currenlty available
#   data_path <- system.file("extdata", package = "censobr")
#   all_dic <- list.files(data_path, full.names = TRUE, pattern = '.html')
#
#   temp_dic <- all_dic[grepl(year, all_dic)]
#   temp_dic <- temp_dic[grepl(table, temp_dic)]
#
#   utils::browseURL(url = temp_dic)
#
#
# }




###### etag -----------------------

#A) etag salvo no arquivo
  a) se atualiza arquivo >>> nada (pacote automatic atualizar local file do usuario)
  b) arquivo novo >>> nada
  c) update minor do pacote >>> nada

  * tem que ficar consultando HEAD e etag a cada chamada
  * funciona offline, mas dai nao checa updates

#B) etag numa tabela de metadado
  # metadado no pacote
  a) se atualiza arquivo >>> nova versao de pacote e tabela
  b) arquivo novo >>> nova versao de pacote e tabela
  c) update minor do pacote >>> nada

  * funciona offline, mas dai nao checa updates

  # metadado no temp cache
  a) se atualiza arquivo >>> atualiza tabela
  b) arquivo novo >>> atualiza tabela
  c) update minor do pacote >>> nada

  * NAO funciona offline


u <- "https://github.com/ipeaGIT/censobr/releases/download/v0.3.0/2010_emigration_v0.3.0.parquet"

aaa <- httr::HEAD(u)$headers$etag

aaa
"\"0x8DC087CDE6C2378\""

tb <- censobr::read_emigration(as_data_frame = F)
tb1 <- censobr::read_emigration(as_data_frame = F)

tb <- tb |> mutate(year=1)
tb1 <- tb1 |> mutate(year=2)

df <- rbind(tb, tb1)
df2 <- tb |> dplyr::collect()

tb <- arrow_table(dff)

schema(tb)$metadata

tb$metadata$etag <- aaa

arrow::write_parquet(tb, 'tb.parquet')


test <- read_parquet('tb.parquet', as_data_frame = F)
schema(test)$metadata



# add labels  ----------------

parametro
codigo
test

pop

# population
df <- censobr::read_population(year = 2010) |>
  filter(abbrev_state == 'CE')

df2 <- add_labels_population(df, year=2010, lang = 'pt')
head(df2) |> collect()


# households
df <- censobr::read_households(year = 2010) |>
  filter(abbrev_state == 'CE')

df2 <- add_labels_households(df, year=2010, lang = 'pt')
head(df2) |> collect()


df <- censobr::read_households(year = 2000) |>
  filter(abbrev_state == 'CE')

df2 <- add_labels_households(df, year=2000, lang = 'pt')
head(df2) |> collect()



# mortality
df <- censobr::read_mortality(year = 2010) |>
  filter(abbrev_state == 'CE')

df2 <- add_labels_mortality(df, year=2010, lang = 'pt')

df <- censobr::read_mortality(year = 2010, add_labels = 'pt') |>
  filter(abbrev_state == 'CE')

df2 <- as.data.frame(df)
table(df2$V1005)


# families
df <- censobr::read_families(year = 2000, add_labels = 'pt') |>
  filter(abbrev_state == 'CE')
df2 <- as.data.frame(df)
table(df2$CODV0404)


# emmigration
df <- censobr::read_emmigration(year = 2010, add_labels = 'pt') |>
  filter(abbrev_state == 'CE')

df2 <- as.data.frame(df)
table(df2$V1006)











##### downloads ------------------------
library(ggplot2)
library(dlstats)
library(data.table)
library(ggplot2)


x <- dlstats::cran_stats(c('censobr', 'geobr', 'flightsbr'))

if (!is.null(x)) {
  head(x)
  ggplot(x, aes(end, downloads, group=package, color=package)) +
    geom_line() + geom_point(aes(shape=package))
}

setDT(x)

x[, .(total = sum(downloads)) , by=package][order(total)]

x[ start > as.Date('2023-01-01'), .(total = sum(downloads)) , by=package][order(total)]

xx <- x[package=='censobr',]

ggplot() +
  geom_line(data=xx, aes(x=end, y=downloads, color=package))


library(cranlogs)

a <- cranlogs::cran_downloads( package = c("censobr"), from = "2020-01-01", to = "last-day")

a
ggplot() +
  geom_line(data=a, aes(x=date, y=count, color=package))




# Coverage ------------------------
# usethis::use_coverage()
# usethis::use_github_action("test-coverage")

library(testthat)
library(covr)
Sys.setenv(NOT_CRAN = "true")



# each function separately
t1 <- covr::function_coverage(fun=read_mortality, test_file("tests/testthat/test_read_mortality.R"))
t1 <- covr::function_coverage(fun=censobr_cache, test_file("tests/testthat/test_censobr_cache.R"))
t1 <- covr::function_coverage(fun=censobr:::add_labels_emigration, test_file("tests/testthat/test_labels_emigration.R"))
t1 <- covr::function_coverage(fun=censobr:::add_labels_mortality, test_file("tests/testthat/test_labels_mortality.R"))
t1 <- covr::function_coverage(fun=censobr:::add_labels_households, test_file("tests/testthat/test_labels_households.R"))
t1 <- covr::function_coverage(fun=censobr::read_households, test_file("tests/testthat/test_read_households.R"))
t1 <- covr::function_coverage(fun=censobr::censobr_cache, test_file("./tests/testthat/test_censobr_cache.R"))
t1 <- covr::function_coverage(fun=censobr::censobr_cache)
t1



# nocov start

# nocov end

# the whole package
Sys.setenv(NOT_CRAN = "true")
cov <- covr::package_coverage(path = ".", type = "tests", clean = FALSE)
cov

rep <- covr::report()

x <- as.data.frame(cov)
covr::codecov( coverage = cov, token ='aaaaa' )




# fix non-ASCII characters  ----------------

gtools::ASCIIfy('é')
gtools::ASCIIfy('ú')
gtools::ASCIIfy('í')
gtools::ASCIIfy('ã')
gtools::ASCIIfy('ô')
gtools::ASCIIfy('ó')
gtools::ASCIIfy('õ')

gtools::ASCIIfy('â')
gtools::ASCIIfy('á')
gtools::ASCIIfy('ç')


gtools::ASCIIfy('º')
gtools::ASCIIfy('ª')

gtools::ASCIIfy('Ú')
gtools::ASCIIfy('Á')
gtools::ASCIIfy('Ê')


gtools::ASCIIfy('Belém')
gtools::ASCIIfy('São Paulo')
gtools::ASCIIfy('Rondônia')

stringi::stri_encode('S\u00e3o Paulo', to="UTF-8")
stringi::stri_encode("/u00c1rea de", to="UTF-8")

stringi::stri_escape_unicode("São Paulo")
stringi::stri_escape_unicode("Área")


stringi::stri_trans_general(str = 'S\u00e3o Paulo', "latin-ascii")





# checks spelling ----------------
library(spelling)
devtools::spell_check(pkg = ".", vignettes = TRUE, use_wordlist = TRUE)


### Check URL's ----------------

urlchecker::url_update()





# CMD Check --------------------------------
# Check package errors

# run only the tests
Sys.setenv(NOT_CRAN = "true")
testthat::test_local()


# LOCAL
Sys.setenv(NOT_CRAN = "true")
devtools::check(pkg = ".",  cran = FALSE, env_vars = c(NOT_CRAN = "true"))

# Run all diagnostics on the current package
library(checktor)
results <- checktor()

# CRAN
Sys.setenv(NOT_CRAN = "false")
devtools::check(pkg = ".",  cran = TRUE, env_vars = c(NOT_CRAN = "false"))


# extrachecks -----------------
#' https://github.com/JosiahParry/extrachecks
#' remotes::install_github("JosiahParry/extrachecks")

library(extrachecks)
extrachecks::extrachecks()


# submit to CRAN -----------------
# usethis::use_cran_comments()


devtools::submit_cran()


# build binary -----------------
system("R CMD build . --resave-data") # build tar.gz




###
library(pkgdown)
library(usethis)
# usethis::use_pkgdown_github_pages() # only once
## coverage
usethis::use_coverage()
usethis::use_github_action("test-coverage")

pkgdown::build_site()
#
#
# ### cache
# tigris
# https://github.com/walkerke/tigris/blob/0f0d7992e0208b4c55a9fe8ac6c52f9e438a3b0c/R/helpers.R#L78
#
# https://github.com/walkerke/tigris/blob/0f0d7992e0208b4c55a9fe8ac6c52f9e438a3b0c/R/helpers.R#L78
#
# tidycensus
# https://github.com/walkerke/tidycensus/blob/master/R/search_variables.R



library(geobr)
library(censobr)
library(dplyr)
library(ggplot2)

fort_df <- geobr::lookup_muni(name_muni = 'Sao Paulo')
fort_code <- fort_df$code_muni
fort_wa <- read_weighting_area(code_weighting = fort_code,
                               year = 2010,
                               simplified = FALSE)



ggplot() +
  geom_sf(data=fort_wa)


# download household data
hs <- read_households(year = 2010,
                      showProgress = FALSE)


rent <- hs |>
  mutate( V0011 = as.character(V0011)) |>
  filter(V0011 %in% fort_wa$code_weighting) |>
  collect() |>
  group_by(V0011) |>                                                 # (a)
  summarize(avgrent=weighted.mean(x=V2011, w=V0010, na.rm=TRUE)) |>  # (b)
  collect()                                                          # (c)

head(rent)


for_sf <- left_join(fort_wa, rent, by = c('code_weighting'='V0011'))


ggplot() +
  geom_sf(data=for_sf, aes(fill = avgrent), color=NA)












Caused by error:
  ! rapi_execute: Failed to run query
Error: Out of Memory Error: failed to offload data block of size 256.0 KiB (1.1 GiB/1.1 GiB used).
This limit was set by the 'max_temp_directory_size' setting.
By default, this setting utilizes the available disk space on the drive where the 'temp_directory' is located.
You can adjust this setting, by using (for example) PRAGMA max_temp_directory_size='10GiB'


[ FAIL 2 | WARN 81 | SKIP 0 | PASS 234 ]
Error: Test failures
Execution halted
Warning messages:
  1: Connection is garbage-collected, use dbDisconnect() to avoid this.
2: Connection is garbage-collected, use dbDisconnect() to avoid this.



══ Warnings ════════════════════════════════════════════════════════════════════
── Warning ('test_labels_emigration.R:14:3'): add_labels_emigration ────────────
Potentially unsafe or invalid elements have been discarded from R metadata.
ℹ Type: "externalptr"
→ If you trust the source, you can set `options(arrow.unsafe_metadata = TRUE)` to preserve them.
Backtrace:


  ── Warning ('test_read_emigration.R:85:3'): read_emigration errors ─────────────
Potentially unsafe or invalid elements have been discarded from R metadata.
ℹ Type: "externalptr"
→ If you trust the source, you can set `options(arrow.unsafe_metadata = TRUE)` to preserve them.
Backtrace:





  ══ Failed tests ════════════════════════════════════════════════════════════════
── Error ('test_read_families.R:61:5'): families merge_households_vars ─────────
Error in `db_compute(x$src$con, name, sql, temporary = temporary, unique_indexes = unique_indexes,
                     indexes = indexes, analyze = analyze, ...)`: Can't copy query to table dbplyr_fxdf6cQfeM.
Caused by error in `db_save_query.DBIConnection()`:
! Can't save query to table dbplyr_fxdf6cQfeM.
ℹ Using SQL: CREATE TEMPORARY TABLE dbplyr_fxdf6cQfeM AS SELECT df.*, V0400,
V1005, V1006, V1007, V0110, V0111, V0201, M0201, V0202, M0202, V0203, M0203,
V0204, M0204, V0205, M0205, V0206, M0206, V0207, M0207, V0208, M0208, V0209,
M0209, V0210, M0210, V0211, M0211, V0212, M0212, V0213, M0213, V0214, M0214,
V0215, M0215, V0216, M0216, V0217, M0217, V0218, M0218, V0219, M0219, V0220,
M0220, V0221, M0221, V0222, M0222, V0223, M0223, V7100, V7203, V7204, V7401,
V7402, V7403, V7404, V7405, V7406, V7407, V7408, V7409, V7616, V7617, v1111,
v1112, v1113 FROM df LEFT JOIN df_household ON ( df.code_muni =
                                                   df_household.code_muni AND df.code_state = df_household.code_state AND
                                                 df.abbrev_state = df_household.abbrev_state AND df.name_state =
                                                   df_household.name_state AND df.code_region = df_household.code_region AND
                                                 df.name_region = df_household.name_region AND df.code_weighting =
                                                   df_household.code_weighting AND df.V0300 = df_household.V0300 )
Caused by error:
  ! rapi_execute: Failed to run query
Error: Error: Out of Memory Error: failed to offload data block of size 256.0 KiB (4.6 GiB/4.6 GiB used).
This limit was set by the 'max_temp_directory_size' setting.
By default, this setting utilizes the available disk space on the drive where the 'temp_directory' is located.
You can adjust this setting, by using (for example) PRAGMA max_temp_directory_size='10GiB'


families
pop

