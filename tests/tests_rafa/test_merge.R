library(dplyr)
library(arrow)
library(duckdb)
library(bench)

# prep data

# df <- censobr::read_mortality(year = 2010)
df <- censobr::read_population(year = 2010) |>
  dplyr::filter(abbrev_state %in% c('SP', 'RJ', 'MG'))
df_household <- censobr::read_households(year = 2010) |>
  dplyr::filter(abbrev_state %in% c('SP', 'RJ', 'MG'))

key_vars <- c('code_muni', 'code_state', 'abbrev_state','name_state',
              'code_region', 'name_region', 'code_weighting', 'V0300')

key_key <- 'V0300'

# drop repeated vars
all_common_vars <- names(df)[names(df) %in% names(df_household)]
vars_to_drop <- setdiff(all_common_vars, key_vars)
df_household <- dplyr::select(df_household, -all_of(vars_to_drop)) |>
  dplyr::compute()



# fun merge SQL
join_sql_arrow <- function(df, df_household) {

  # create db connection
  db_path <- tempfile(pattern = 'censobr', fileext = '.duckdb')

  con <- duckdb::dbConnect(
    duckdb::duckdb(),
    dbdir = db_path
  )

  # register data to db
  duckdb::duckdb_register_arrow(con, 'df', df)
  duckdb::duckdb_register_arrow(con, 'df_household', df_household)

  # Create the JOIN condition by concatenating the key columns
  join_condition <- paste(
    glue::glue("df.{key_vars} = df_household.{key_vars}"),
    collapse = ' AND '
  )

  query_match <- glue::glue(
    "SELECT *
      FROM df
      LEFT JOIN df_household
      ON {join_condition};"
  )

  merge_query <- duckdb::dbSendQuery(con, query_match, arrow = TRUE)

  # get result of the left join as an arrow table
  df_geo <- duckdb::duckdb_fetch_arrow(merge_query)

  # remove duckdb instance
  duckdb::duckdb_unregister_arrow(con, 'df')
  duckdb::duckdb_unregister_arrow(con, 'df_household')
  duckdb::dbDisconnect(con)

  df_geo <- head(df_geo) |> dplyr::collect()
  return(df_geo)
  }

# fun merge dplyr and duckdb
join_dplyr_to_duckdb <- function(df, df_household) {

  # convert to duckdb
  df <- arrow::to_duckdb(df)
  df_household <- arrow::to_duckdb(df_household)

  # merge
  df_geo <- dplyr::left_join(df, df_household) |>
    dplyr::compute()

  # back to arrow
  df_geo <- arrow::to_arrow(df_geo)
  df_geo <- head(df_geo) |> dplyr::collect()
  return(df_geo)
}



# fun merge dplyr and SQL
join_dplyr_sql <- function(df, df_household) {

  # create db connection
  db_path <- tempfile(pattern = 'censobr', fileext = '.duckdb')

  con <- duckdb::dbConnect(
    duckdb::duckdb(),
    dbdir = db_path
  )


  # Register Arrow data as DuckDB tables
  duckdb::duckdb_register_arrow(con, "df", df)
  duckdb::duckdb_register_arrow(con, "df_household", df_household)

  # Perform the left join using dplyr syntax
  df_geo <- dplyr::left_join(tbl(con, "df"),
                             tbl(con, "df_household"),
                             by = key_vars) |>
    dplyr::compute()

  # back to arrow
  df_geo <- arrow::to_arrow(df_geo)

  df_geo <- head(df_geo) |> dplyr::collect()
  return(df_geo)
}

bench::mark(
#  dplyr_sql = join_dplyr_sql(df, df_household),                 # out of mem
  sql_arrow = join_sql_arrow(df, df_household) ,
#  dplyr_to_duckdb = join_dplyr_to_duckdb(df, df_household) ,
  iterations = 3,
  check = F
  )

# mais rapido # menos memoria

# sql_arrow
# dplyr_sql

#   expression     min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 sql_arrow    1.31s  1.33s     0.738    2.99MB   0.0738    10     1      13.5s
# 2 dplyr_to_du… 2.42s  2.53s     0.387   10.11MB   1.20      10    31      25.8s
# 3 dplyr_sql    2.29s  2.44s     0.402    1.26MB   0.402     10    10      24.8s

# 1 dplyr_to_du… 2.73s  2.84s     0.341    12.2MB    1.19     10    35      29.3s
# 2 dplyr_sql    2.76s  3.43s     0.275    1.36MB    0.330    10    12      36.4s
# 3 sql_arrow    1.53s  1.78s     0.537     822KB    0.107    10     2      18.6s

# 1 dplyr_sql    2.31s  2.38s     0.419   11.93MB    0.419    10    10      23.9s
# 2 sql_arrow    1.41s  1.54s     0.640  914.85KB    0.128    10     2      15.6s
# 3 dplyr_to_du… 2.54s  2.96s     0.328    1.54MB    0.951    10    29      30.5s







# codigo douglas --------------------------------------------------------------

# https://github.com/ipea/censobr/pull/59

# mais rapido usar duckdb pra salvar parquet e depois ler com Arrows do que
# usar factharrow

library(censobr)
library(duckdb)
library(dplyr)
library(glue)

# get original tables
year <- 2010
pop <- censobr::read_population(year = year)
hh <- censobr::read_households(year = year)

# define key columns
key_vars <- c(
  "code_muni", "code_state", "abbrev_state", "name_state",
  "code_region", "name_region", "code_weighting", "V0300"
)


# rename household weight column
hh <- dplyr::rename(hh, "V0010_household" = "V0010") |>
  dplyr::compute()

# create db connection on a temp file
db_path <- tempfile(pattern = "censobr", fileext = ".duckdb")
con <- duckdb::dbConnect(
  duckdb::duckdb(),
  dbdir = db_path
)

# configure memory limit for duckdb to use
# memory usage can still go a bit higher than this due to R processing
memory_limit <- "12GB"
query_setup <- stringr::str_glue("SET memory_limit = '{memory_limit}';")
DBI::dbExecute(con, query_setup)

# path for temp files generated by duckdb when memory exceeds limit
db_temp_dir <- tempdir()
query_setup <- stringr::str_glue("SET temp_directory = '{db_temp_dir}';")
DBI::dbExecute(con, query_setup)

# get list of cached files by censobr
cached_files <- capture.output(censobr::censobr_cache(), type = "message")

# select parquet file containing households from cached files
hh_parquet <- cached_files[
  grepl("households", cached_files) &
    grepl("parquet", cached_files) &
    grepl(as.character(year), cached_files)
]
# select parquet file containing households from cached files
pop_parquet <- cached_files[
  grepl("population", cached_files) &
    grepl("parquet", cached_files) &
    grepl(as.character(year), cached_files)
]

# import parquet files into duckdb
query_import_hh_parquet <- glue::glue(
  "CREATE TABLE hh AS SELECT * FROM '{hh_parquet}';"
)
res <- DBI::dbExecute(con, query_import_hh_parquet)

query_import_pop_parquet <- glue::glue(
  "CREATE TABLE pop AS SELECT * FROM '{pop_parquet}';"
)
res <- DBI::dbExecute(con, query_import_pop_parquet)

# drop repeated columns from households table
all_common_vars <- names(pop)[names(pop) %in% names(hh)]
vars_to_drop <- setdiff(all_common_vars, key_vars)
query_drop_vars <- glue::glue(
  "ALTER TABLE hh DROP COLUMN {vars_to_drop};"
)
rv <- DBI::dbExecute(con, query_drop_vars)

# Create the JOIN condition by concatenating the key columns
join_condition <- paste(
  glue::glue("pop.{key_vars} = hh.{key_vars}"),
  collapse = " AND "
)

# create the merged table using duckdb left join
# do it on disk to save memory
query_match <- glue::glue(
  "CREATE TABLE df_geo AS
    SELECT *
      FROM pop
      LEFT JOIN hh
      ON {join_condition};"
)
rv <- DBI::dbExecute(con, query_match)

# inspect the resulting table
df_geo <- tbl(con, "df_geo")
df_geo |> head()
# seems ok, low memory consumption (<15GB)
# but it's not an arrow table yet


# passing the table to arrow
# trying to fetch the table as arrow using duckdb package
res <- duckdb::dbSendQuery(con, "SELECT * FROM df_geo", arrow = TRUE) # memory explodes here (>100GB)
df_geo_arrow <- duckdb::duckdb_fetch_arrow(res)
head(df_geo_arrow) |> dplyr::collect()

# clean up
rm(res)
rm(df_geo_arrow)
gc()

# trying to fetch the table as arrow using arrow package
df_geo_arrow <- arrow::to_arrow(df_geo) # memory also explodes here (>90GB) but it's faster than previous
head(df_geo_arrow) |> dplyr::collect()

# clean up
rm(df_geo_arrow)
gc()

# workaround: saving the table to disk as parquet file and reading it back
# this is really slower and generate a large file in disk
# but memory usage is low (<15GB)
query_write_parquet <- glue::glue(
  "COPY
    (FROM df_geo)
    TO '{db_temp_dir}/df_geo.parquet'
    (FORMAT PARQUET);"
)
res <- DBI::dbExecute(con, query_write_parquet)
df_geo_arrow <- arrow::open_dataset(
  file.path(db_temp_dir, "df_geo.parquet")
)
df_geo_arrow |>
  head() |>
  dplyr::collect()

# clean up
rm(df_geo_arrow)
unlink(file.path(db_temp_dir, "df_geo.parquet"))
dbDisconnect(con)
unlink(db_path)
unlink(db_temp_dir, recursive = TRUE)
gc()

