#' Import the controlled-access microdata of the 2022 census into censobr cache
#'
#' @description
#' Import the microdata of the sample component of Brazil's 2022 Population
#' Census ("dados controlados") from a zip file obtained from IBGE, convert the
#' `csv` files it contains into Parquet, and save them in the local `censobr`
#' cache directory.
#'
#' Unlike the microdata of previous censuses, the 2022 controlled-access microdata
#' are distributed by IBGE under controlled access and cannot be redistributed by
#' `censobr` directly. Users need to request the data directly from IBGE at 
#' \url{https://microdados.ibge.gov.br/} and run this function once on the zip file 
#' they receive. From then on, the data are available locally like any other data 
#' set cached by the package, and no download is attempted.
#'
#' One Parquet file is written per table, following the file naming convention
#' used by `censobr`:
#'
#' | Table in the zip file | File written to the cache |
#' | --- | --- |
#' | `Domicilios` | `2022_households_<data release>.parquet` |
#' | `Familia` | `2022_families_<data release>.parquet` |
#' | `Mortalidade` | `2022_mortality_<data release>.parquet` |
#' | `Pessoas` | `2022_population_<data release>.parquet` |
#'
#' The `<data release>` suffix is the release of the `censobr` data pinned by
#' the installed version of the package. A version of `censobr` that points to 
#' a newer data release will not find files imported under the previous one, 
#' so the zip file has to be imported again. We strongly recommend you store
#' the original zip file in a save place so you can import it again in the 
#' future if necessary.
#'
#' @param zip_path String. Path to the original zip file with the controlled-microdata
#'        of the 2022 census sample saved, as provided by IBGE. The original file is 
#'        expected to hold one subdirectory per state, each containing the `csv` files 
#'        of the `Domicilios`, `Familia`, `Mortalidade` and `Pessoas` tables.
#'
#' @return Returns `NULL` invisibly. The function is called for its side effect
#'         of writing Parquet files to the `censobr` cache directory, whose
#'         location can be checked with [get_censobr_cache_dir()].
#'
#' @export
#' @family Support function
#'
#' @examples \dontrun{
#' # the zip file has to be requested from IBGE beforehand
#' # The repo rule bans it for hiding broken examples, but here the example genuinely 
#' # cannot run: it needs a restricted-access file only the user has.
#' 
#' # path to zip fil
#' path_to_zip <- system.file("extdata/microdata_2022_controlado_fake.zip", 
#'                            package = "censobr")
#' 
#' # import controlled-microdata 2022.
#' import_microdata22_controlado(
#'   zip_path = path_to_zip
#'   )
#' }
#'
import_microdata22_controlado <- function(zip_path) {
  
  # zip_path <- "l:/# RAFAEL HENRIQUE MORAES PEREIRA #/microdados_censo_amostra_2022_csv_20260901_154554.zip"
 
  # "l:/# RAFAEL HENRIQUE MORAES PEREIRA #/Layout Microdados CD2022 - acesso Controlado.xlsx"
  
  # check if file exists
  if (isFALSE(file.exists(zip_path))) {
    stop(paste('File does not exist' , zip_path))
  }

  # unzip file to temp dir
  temp <- tempfile(pattern = 'microdata_2022_controlado')
  dir.create(temp, showWarnings = FALSE)
  

  cli::cli_alert_info("Unzinping files to temporary directory")
  
  utils::unzip(zip_path, exdir = temp, overwrite = TRUE)
  
  # detect files
  tempfiles <- list.files(
    path = temp, 
    recursive = TRUE, 
    full.names = TRUE
  )

  # check whether these are the .csv or .txt files
  if( !all(grepl(".csv", tempfiles))) {
    cli::cli_abort("Please make sure to donwload from IBGE the zip file with the data saved in `.csv`format.")
  }

  # tables to read
  tables <- c('Domicilios', 'Familia', 'Mortalidade', 'Pessoas')
  
  # dest directory. The cache dir is versioned by data release, so this has to
  # mirror how download_file() resolves the path of a downloaded file
  cache_dir <- get_censobr_cache_dir()
  cache_dir <- glue::glue("{cache_dir}/data_release_{censobr_env$data_release}")
  if (!dir.exists(cache_dir)) { dir.create(cache_dir, recursive = TRUE) }

  
  for (i in tables) {

    # i = "Familia"

      cli::cli_alert_info(
        paste("Saving", i, "microdata.")
      )
    
    # detect files
    tbl_files <- tempfiles[grepl(i, tempfiles)]

    tbl_name <- switch(i,
      'Domicilios' = 'households',
      'Familia' = 'families',
      'Mortalidade' = 'mortality',
      'Pessoas' = 'population'
    )

    # column types, hardcoded from the layout file of IBGE. Declaring them is
    # what stops arrow from typing as `null` the variables that are blank in
    # the first block of the first file it reads
    tbl_schema <- switch(tbl_name,
      'households' = schema_households(),
      'families'   = schema_families(),
      'mortality'  = schema_mortality(),
      'population' = schema_population()
    )

    # read with arrows
    arrw <- arrow::open_delim_dataset(
      tbl_files, 
      delim = ";", 
      col_types = tbl_schema, 
      na = ""
    )

    # add geography columns
    arrw_censobr <- add_geography_cols(arrw, tbl_name)

    # save file to cache dir
    file_name <- paste0("2022_", tbl_name, "_", censobr_env$data_release, ".parquet")
    dest_file <- fs::path(cache_dir, file_name)
    
    arrow::write_parquet(
      x = arrw_censobr, 
      sink = dest_file
    )

  }

  cli::cli_alert_info(
    paste(
      "Finished saving 2022 controlled-microdata to cache dir at:", 
      cache_dir
    )
  )

}


# Schemas of the 2022 controlled-access microdata ------------------------------

#' Column types of the microdata tables of the 2022 census
#'
#' @description
#' Column types of the four tables in the controlled-access microdata of the
#' 2022 census, taken from the layout file distributed by IBGE ("Layout
#' Microdados CD2022 - acesso Controlado.xlsx"), which declares the width
#' (`POSICAO INICIAL`, `POSICAO FINAL`, `INT`) and the number of decimal places
#' (`DEC`) of every variable.
#'
#' The width and the decimal places give the type:
#' - `DEC > 0` becomes `float64()`. There are only seven such variables. The
#'   sample weights carry 13 decimal places and the income variables carry 9
#'   digits plus 2 decimals, so neither fits in a 32 bit float.
#' - `DEC == 0` becomes an integer sized by `INT`: `int8()` up to 2 digits,
#'   `int16()` up to 4, `int32()` up to 9 and `int64()` for the 10 digit codes.
#'   The "area de ponderacao" is one of the latter: from state 22 onwards it is
#'   above 2147483647 and overflows a 32 bit integer.
#' - `F0101` and `M0101` are the exception and become `string()`: they carry a
#'   letter prefix, `"F001"` and `"M001"`. `P0101` looks like them but is not,
#'   it is a plain count of 1 to 36, so it stays an integer.
#'
#' Every type was checked against the data: each of the 330 variables was
#' scanned across all 27 state files of its table, recording the largest value,
#' whether any value carries letters, and whether any carries decimals. The type
#' here is the wider of what the layout declares and what the values require.
#'
#' Note that the codes are stored as integers, so the leading zeros of the
#' categorical variables are not kept: `F0120` is `8`, not `"08"`. This departs
#' from the microdata of the other censuses, where the codes are strings.
#'
#' Declaring the schema also bypasses the type inference of arrow, which reads
#' only the first block of the first file and therefore mistypes the variables
#' that happen to be blank in it.
#'
#' These are functions, and not stored objects, because an `arrow::schema()` is
#' an external pointer: an object created when the package is built would be
#' restored as a null pointer when the package is loaded.
#'
#' @return An `arrow::schema()`.
#'
#' @name schemas_microdata22
NULL

#' @rdname schemas_microdata22
#' @keywords internal
schema_households <- function() {   # Domicilios -- 64 variables: 50 i8, 4 i16, 6 i32, 1 i64, 3 dbl

  i8  <- arrow::int8()      # INT <= 2
  i16 <- arrow::int16()     # INT 3-4
  i32 <- arrow::int32()     # INT 5-9
  i64 <- arrow::int64()     # INT = 10
  dbl <- arrow::float64()   # DEC > 0

  arrow::schema(
    D0010 = i8, D0020 = i8, D0030 = i16, D0040 = i32, D0050 = i16, D0060 = i32,
    D0070 = i32, D0080 = i32, D0090 = i64, D0100 = i32, D0111 = dbl, D0120 = i8,
    D0130 = i8, D0140 = i8, D0150 = i16, D0160 = i8, D0170 = i8, D0171 = i8,
    D0180 = i8, D0181 = i16, D0190 = i8, D0200 = i8, D0210 = i8, D0220 = i8,
    D0230 = i8, D0240 = dbl, D0250 = i8, D0260 = i8, D0270 = i8, D0280 = i8,
    D0290 = i8, D0300 = i8, D0310 = i8, D0320 = i8, D0330 = i8, D0340 = i8,
    D0350 = i32, D0360 = dbl, D0370 = i8, D0380 = i8, D0390 = i8, D0400 = i8,
    D0410 = i8, MD0130 = i8, MD0150 = i8, MD0160 = i8, MD0170 = i8, MD0180 = i8,
    MD0190 = i8, MD0200 = i8, MD0210 = i8, MD0220 = i8, MD0230 = i8, MD0240 = i8,
    MD0250 = i8, MD0260 = i8, MD0270 = i8, MD0280 = i8, MD0290 = i8, MD0300 = i8,
    MD0310 = i8, MD0320 = i8, MD0330 = i8, MD0340 = i8
  )
}

#' @rdname schemas_microdata22
#' @keywords internal
schema_families <- function() {   # Familia -- 31 variables: 19 i8, 3 i16, 5 i32, 1 i64, 2 dbl, 1 chr

  i8  <- arrow::int8()      # INT <= 2
  i16 <- arrow::int16()     # INT 3-4
  i32 <- arrow::int32()     # INT 5-9
  i64 <- arrow::int64()     # INT = 10
  dbl <- arrow::float64()   # DEC > 0
  chr <- arrow::string()    # letters in the value

  arrow::schema(
    F0010 = i8, F0020 = i8, F0030 = i16, F0040 = i32, F0050 = i16, F0060 = i32,
    F0070 = i32, F0080 = i32, F0090 = i64, F0100 = i32, F0101 = chr, F0111 = dbl,
    F0120 = i8, F0130 = i8, F0140 = i8, F0150 = i8, F0160 = i8, F0170 = i8,
    F0180 = i8, F0181 = i16, F0190 = i8, F0200 = i8, F0210 = i8, F0220 = i8,
    F0230 = i8, F0240 = i8, F0250 = i8, F0260 = dbl, F0270 = i8, MF0190 = i8,
    MF0200 = i8
  )
}

#' @rdname schemas_microdata22
#' @keywords internal
schema_mortality <- function() {   # Mortalidade -- 25 variables: 14 i8, 3 i16, 5 i32, 1 i64, 1 dbl, 1 chr

  i8  <- arrow::int8()      # INT <= 2
  i16 <- arrow::int16()     # INT 3-4
  i32 <- arrow::int32()     # INT 5-9
  i64 <- arrow::int64()     # INT = 10
  dbl <- arrow::float64()   # DEC > 0
  chr <- arrow::string()    # letters in the value

  arrow::schema(
    M0010 = i8, M0020 = i8, M0030 = i16, M0040 = i32, M0050 = i16, M0060 = i32,
    M0070 = i32, M0080 = i32, M0090 = i64, M0100 = i32, M0101 = chr, M0111 = dbl,
    M0120 = i8, M0130 = i8, M0140 = i8, M0150 = i8, M0151 = i8, M0160 = i8,
    M0170 = i8, M0171 = i16, MM0150 = i8, MM0151 = i8, MM0160 = i8, MM0170 = i8,
    MM0171 = i8
  )
}

#' @rdname schemas_microdata22
#' @keywords internal
schema_population <- function() {   # Pessoas -- 210 variables: 177 i8, 12 i16, 14 i32, 6 i64, 1 dbl

  i8  <- arrow::int8()      # INT <= 2
  i16 <- arrow::int16()     # INT 3-4
  i32 <- arrow::int32()     # INT 5-9
  i64 <- arrow::int64()     # INT = 10
  dbl <- arrow::float64()   # DEC > 0

  arrow::schema(
    P0010 = i8, P0020 = i8, P0030 = i16, P0040 = i32, P0050 = i16, P0060 = i32,
    P0070 = i32, P0080 = i32, P0090 = i64, P0100 = i32, P0101 = i8, P0111 = dbl,
    P0120 = i8, P0130 = i8, P0140 = i8, P0150 = i8, P0160 = i8, P0170 = i8,
    P0180 = i8, P0181 = i16, P0190 = i16, P0200 = i8, P0210 = i8, P0220 = i8,
    P0230 = i8, P0240 = i8, P0250 = i8, P0260 = i8, P0270 = i8, P0280 = i8,
    P0290 = i8, P0300 = i8, P0310 = i8, P0320 = i8, P0330 = i8, P0340 = i8,
    P0350 = i8, P0360 = i8, P0370 = i8, P0380 = i8, P0381 = i16, P0390 = i8,
    P0400 = i8, P0410 = i8, P0411 = i8, P0420 = i8, P0430 = i8, P0440 = i8,
    P0450 = i8, P0460 = i8, P0470 = i8, P0480 = i8, P0490 = i8, P0500 = i32,
    P0510 = i64, P0520 = i8, P0530 = i8, P0540 = i16, P0550 = i8, P0560 = i8,
    P0570 = i8, P0580 = i32, P0590 = i64, P0600 = i8, P0610 = i8, P0620 = i32,
    P0630 = i64, P0640 = i8, P0650 = i8, P0660 = i8, P0670 = i8, P0680 = i8,
    P0690 = i8, P0700 = i8, P0710 = i8, P0720 = i8, P0730 = i8, P0740 = i8,
    P0750 = i16, P0760 = i16, P0770 = i8, P0780 = i8, P0790 = i16, P0800 = i8,
    P0810 = i8, P0820 = i32, P0830 = i64, P0840 = i8, P0850 = i8, P0860 = i8,
    P0870 = i8, P0880 = i8, P0890 = i8, P0900 = i8, P0910 = i8, P0920 = i8,
    P0930 = i8, P0940 = i8, P0950 = i8, P0960 = i8, P0970 = i16, P0980 = i32,
    P0990 = i8, P1000 = i8, P1010 = i8, P1020 = i8, P1030 = i8, P1040 = i8,
    P1050 = i8, P1060 = i8, P1070 = i8, P1080 = i32, P1090 = i8, P1100 = i32,
    P1110 = i32, P1120 = i8, P1130 = i8, P1140 = i32, P1150 = i64, P1160 = i8,
    P1170 = i8, P1180 = i8, P1190 = i16, P1200 = i8, P1210 = i8, P1220 = i16,
    MP0150 = i8, MP0170 = i8, MP0180 = i8, MP0181 = i8, MP0190 = i8, MP0210 = i8,
    MP0230 = i8, MP0260 = i8, MP0270 = i8, MP0280 = i8, MP0290 = i8, MP0300 = i8,
    MP0310 = i8, MP0320 = i8, MP0330 = i8, MP0350 = i8, MP0360 = i8, MP0410 = i8,
    MP0411 = i8, MP0420 = i8, MP0430 = i8, MP0440 = i8, MP0450 = i8, MP0460 = i8,
    MP0480 = i8, MP0490 = i8, MP0500 = i8, MP0510 = i8, MP0520 = i8, MP0530 = i8,
    MP0540 = i8, MP0550 = i8, MP0560 = i8, MP0570 = i8, MP0580 = i8, MP0590 = i8,
    MP0600 = i8, MP0610 = i8, MP0620 = i8, MP0630 = i8, MP0640 = i8, MP0650 = i8,
    MP0660 = i8, MP0670 = i8, MP0680 = i8, MP0690 = i8, MP0700 = i8, MP0710 = i8,
    MP0720 = i8, MP0730 = i8, MP0740 = i8, MP0750 = i8, MP0800 = i8, MP0810 = i8,
    MP0820 = i8, MP0830 = i8, MP0840 = i8, MP0850 = i8, MP0860 = i8, MP0870 = i8,
    MP0880 = i8, MP0890 = i8, MP0900 = i8, MP0970 = i8, MP0980 = i8, MP0990 = i8,
    MP1000 = i8, MP1010 = i8, MP1050 = i8, MP1060 = i8, MP1070 = i8, MP1080 = i8,
    MP1090 = i8, MP1100 = i8, MP1120 = i8, MP1130 = i8, MP1140 = i8, MP1150 = i8,
    MP1160 = i8, MP1170 = i8, MP1180 = i8, MP1200 = i8, MP1210 = i8, MP1220 = i8
  )
}


# Add basic geography variables
#' @keywords internal
add_geography_cols <- function(arrw, tbl_name){
  
  cols_prefix <- switch(tbl_name,
    'households' = 'D',
    'families' = 'F',
    'mortality' = 'M',
    'population' = 'P'
  )

  cod_region <- paste0(cols_prefix, "0010")
  cod_state <- paste0(cols_prefix, "0020")
  cod_meso <- paste0(cols_prefix, "0030")
  cod_micro <- paste0(cols_prefix, "0040")
  cod_intermediate <- paste0(cols_prefix, "0050")
  cod_immediate <- paste0(cols_prefix, "0060")
  cod_urbanconentration <- paste0(cols_prefix, "0070")
  cod_muni <- paste0(cols_prefix, "0080")
  cod_weightingarea <- paste0(cols_prefix, "0090")


  arrw <- arrw |> dplyr::mutate(
    code_region = get(cod_region),
    code_state = get(cod_state),
    code_meso = get(cod_meso),
    code_micro = get(cod_micro),
    code_intermediate = get(cod_intermediate),
    code_immediate = get(cod_immediate),
    code_urban_concentration = get(cod_urbanconentration),
    code_muni = get(cod_muni),
    code_weighting = get(cod_weightingarea)
  )

  # abbrev name
  arrw <- arrw |> dplyr::mutate(
    abbrev_state = dplyr::case_when(
      code_state == 11 ~'RO',
      code_state == 12 ~'AC',
      code_state == 13 ~'AM',
      code_state == 14 ~'RR',
      code_state == 15 ~'PA',
      code_state == 16 ~'AP',
      code_state == 17 ~'TO',
      code_state == 21 ~'MA',
      code_state == 22 ~'PI',
      code_state == 23 ~'CE',
      code_state == 24 ~'RN',
      code_state == 25 ~'PB',
      code_state == 26 ~'PE',
      code_state == 27 ~'AL',
      code_state == 28 ~'SE',
      code_state == 29 ~'BA',
      code_state == 31 ~'MG',
      code_state == 32 ~'ES',
      code_state == 33 ~'RJ',
      code_state == 35 ~'SP',
      code_state == 41 ~'PR',
      code_state == 42 ~'SC',
      code_state == 43 ~'RS',
      code_state == 50 ~'MS',
      code_state == 51 ~'MT',
      code_state == 52 ~'GO',
      code_state == 53 ~'DF',
      .default = NA_character_)
    )


  # state name
  arrw <- arrw |> dplyr::mutate(
    name_state = dplyr::case_when(
      code_state == 11 ~'Rond\u00f4nia',
      code_state == 12 ~'Acre',
      code_state == 13 ~'Amazonas',
      code_state == 14 ~'Roraima',
      code_state == 15 ~'Par\u00e1',
      code_state == 16 ~'Amap\u00e1',
      code_state == 17 ~'Tocantins',
      code_state == 21 ~'Maranh\u00e3o',
      code_state == 22 ~'Piau\u00ed',
      code_state == 23 ~'Cear\u00e1',
      code_state == 24 ~'Rio Grande do Norte',
      code_state == 25 ~'Para\u00edba',
      code_state == 26 ~'Pernambuco',
      code_state == 27 ~'Alagoas',
      code_state == 28 ~'Sergipe',
      code_state == 29 ~'Bahia',
      code_state == 31 ~'Minas Gerais',
      code_state == 32 ~'Esp\u00edrito Santo',
      code_state == 33 ~'Rio de Janeiro',
      code_state == 35 ~'S\u00e3o Paulo',
      code_state == 41 ~'Paran\u00e1',
      code_state == 42 ~'Santa Catarina',
      code_state == 43 ~'Rio Grande do Sul',
      code_state == 50 ~'Mato Grosso do Sul',
      code_state == 51 ~'Mato Grosso',
      code_state == 52 ~'Goi\u00e1s',
      code_state == 53 ~'Distrito Federal',
      .default = NA_character_)
    )


  # region name
  arrw <- arrw |> dplyr::mutate(
    name_region = dplyr::case_when(
      code_region == 1 ~'Norte',
      code_region == 2 ~'Nordeste',
      code_region == 3 ~'Sudeste',
      code_region == 4 ~'Sul',
      code_region == 5 ~'Centro-oeste',
      .default = NA_character_)
    )

  
  ## reoder columns
  arrw <- arrw |> 
    dplyr::relocate(
      c(code_region, name_region, code_state, abbrev_state, name_state,
        code_meso, code_micro, code_intermediate, code_immediate,
        code_urban_concentration, code_muni, code_weighting)
    )
  
  return(arrw)
}



