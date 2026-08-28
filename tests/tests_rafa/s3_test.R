

# duckdbfs ---------------------------------------------------------------------------------

library(arrow)
library(dplyr)

minio <- arrow::S3FileSystem$create(
  access_key = "CC10HvyOMmynA1bG12CD",
  secret_key = "vKpyxfbKFDiR9aV23hHD832thlFDJXzYiobKwHdl",
  scheme = "https",
#  endpoint_override = "minioapi-teste.ipea.gov.br:443",  # Or public DNS
 endpoint_override = "minio.ipea.gov.br:443",  # Or public DNS
)


Sys.setenv(
  AWS_REGION = "us-east-1",
  AWS_EC2_METADATA_DISABLED = "TRUE"
)

df <- arrow::open_dataset(
  'censobr/2010_tracts_Pessoa_v0.5.0.parquet',
  filesystem=minio, format="parquet"
)

nrow(df)

# carrega pra memoria a base completa (310,114 observacoes)
# pico de 66% de rede
df2 <- df|> collect()

# carrega pra memoria soh estado do acre (2,346 observacoes)
# pico de 34% de rede
df3 <- df |>
  filter(code_state=='11') |>
  collect()

head(df3)

a <- "http://minio.ipea.gov.br/censobr/2010_tracts_Pessoa_v0.5.0.parquet"


df4 <- arrow::open_dataset(a) |>
  filter(code_state=='11') |>
  collect()


# minioclient -------------------------------------------------------------

# https://github.com/cboettig/minioclient
library(minioclient)

mc_alias_set("censobr", "minioapi-teste.ipea.gov.br:443",
             access_key = "CC10HvyOMmynA1bG12CD",
             secret_key = "vKpyxfbKFDiR9aV23hHD832thlFDJXzYiobKwHdl"
             )



# duckdbfs ---------------------------------------------------------------------------------
# https://cboettig.github.io/duckdbfs/

a <- "https://github.com/ipea/censobr/releases/download/v0.5.0/1960_households_v0.5.0.parquet"

a <- "http://minio.ipea.gov.br/censobr/2010_tracts_Pessoa_v0.5.0.parquet"

library(duckdbfs)

ds <- duckdbfs::open_dataset(a)
nrow(ds)

ds2 <- duckdbfs::open_dataset(a, mode = "TABLE")
class(ds2)
nrow(ds2)
ds2

url <- "https://github.com/ipea/geobr/releases/download/v1.7.0/amazonia_legal.gpkg"

countries_meta <- duckdbfs::st_read_meta(url )
countries_meta

g <- duckdbfs::open_dataset(url,format = "sf")
in_mem <- g |> to_sf(crs = countries_meta$wkt)






# pins tests -------

#' https://pins.rstudio.com/
library(pins)

web_board <-pins::board_url("https://minio.ipea.gov.br/censobr/")

a <- "http://minio.ipea.gov.br/censobr/2010_tracts_Pessoa_v0.5.0.parquet"


pins::pin_reactive_download()

# another tests -------


get_nbm_bl <- function(geoid_co, release = "latest") {

  con <- DBI::dbConnect(duckdb::duckdb(read_only = TRUE))


  DBI::dbExecute(con, sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")
  statement <- sprintf(
    paste0("select *
 		  from read_parquet('s3://cori.data.fcc/nbm_block", release_target, "/*/*.parquet')
    where geoid_co = '%s';"), geoid_co)
  DBI::dbGetQuery(con, statement)
}

nbm_bl <- get_nbm_bl(geoid_co = "47051")


library(aebdata)

# List all series
df_series <- "https://www.ipea.gov.br/atlasestado/api/v1/series" |>
  httr2::request() |>
  httr2::req_perform() |>
  httr2::resp_body_json() |>
  # Select only the title and id to avoid problems with subthemes
  lapply(`[`, c("titulo", "id")) |>
   do.call(rbind.data.frame, args = _)
  # data.table::rbindlist()

names(df_series) <- c("series_title", "series_id")
head(df_series)




library(geobr)
 library(geoarrow)
library(arrow)
library(sf)
library(dplyr)

df <- geobr::read_state()
# geoarrow::geoarrow_schema_parse()

arrow::write_parquet(df, 'states.parquet')


a <- arrow::open_dataset('states.parquet') |>
  filter(code_state==11) |>
  st_as_sf()
plot(a)

geoarrow::infer_geoarrow_schema(a)


