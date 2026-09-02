


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


u <- "https://github.com/ipea/censobr/releases/download/v0.3.0/2010_emigration_v0.3.0.parquet"

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
