# Add labels to categorical variables of mortality datasets
#' @keywords internal
add_labels_mortality <- function(arrw,
                                 year = parent.frame()$year,
                                 lang = 'pt'){

  # check input
  checkmate::assert_string(lang, pattern = 'pt', na.ok = TRUE)
  if (!(year %in% c(2010, 2022))) {
    cli::cli_abort("Labels for this data are only available for the year c(2010, 2022)")
    }


  # names of columns present in the data
  cols <- names(arrw)

  # YEAR 2022 ------------------------------------------------------------------
  if (year == 2022 & lang == 'pt') {
    # NOTE: variable names follow the CD2022 MORT layout (Controlled Access).
    # Every block below checks var %in% cols first, so this same function
    # works on the Public Access layout too -- variables that only exist in
    # the Controlled Access version (e.g. M0080 municipio, M0111 peso amostral,
    # M0151 mes e ano do obito, M0171 idade em numero) are simply skipped when
    # absent. As in add_labels_population(), the imputation flags (MM0150,
    # MM0151, MM0160, MM0170, MM0171) are left unlabelled.

    # SITUACAO DO SETOR
    if ('M0120' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        M0120 = dplyr::case_when(
          M0120 ==
            1 ~ '\u00c1rea urbana de alta densidade de edifica\u00e7\u00f5es',
          M0120 ==
            2 ~ '\u00c1rea urbana de baixa densidade de edifica\u00e7\u00f5es',
          M0120 == 3 ~ 'N\u00facleo urbano',
          M0120 == 5 ~ 'Povoado',
          M0120 == 6 ~ 'N\u00facleo rural',
          M0120 == 7 ~ 'Lugarejo',
          M0120 == 8 ~ '\u00c1rea rural (exclusive aglomerados)'
        )
      )
    }

    # ESPECIE DA UNIDADE VISITADA
    if ('M0130' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        M0130 = dplyr::case_when(
          M0130 == 1 ~ 'Domic\u00edlio particular permanente ocupado',
          M0130 == 5 ~ 'Domic\u00edlio particular improvisado ocupado',
          M0130 == 6 ~ 'Domic\u00edlio coletivo com morador'
        )
      )
    }

    # SITUACAO DO DOMICILIO
    if ('M0140' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        M0140 = dplyr::case_when(
          M0140 == 1 ~ 'Urbana',
          M0140 == 2 ~ 'Rural'
        )
      )
    }

    # ANO DE OCORRENCIA DO OBITO, CATEGORIA
    if ('M0150' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        M0150 = dplyr::case_when(
          M0150 == 1 ~ '2019',
          M0150 == 2 ~ '2020',
          M0150 == 3 ~ '2021',
          M0150 == 4 ~ '2022',
          M0150 == 9 ~ 'Ignorado'
        )
      )
    }

    # MES E ANO DE OCORRENCIA DO OBITO, CATEGORIA
    if ('M0151' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        M0151 = dplyr::case_when(
          M0151 == 1 ~ 'Janeiro de 2019',
          M0151 == 2 ~ 'Fevereiro de 2019',
          M0151 == 3 ~ 'Mar\u00e7o de 2019',
          M0151 == 4 ~ 'Abril de 2019',
          M0151 == 5 ~ 'Maio de 2019',
          M0151 == 6 ~ 'Junho de 2019',
          M0151 == 7 ~ 'Julho de 2019',
          M0151 == 8 ~ 'Agosto de 2019',
          M0151 == 9 ~ 'Setembro de 2019',
          M0151 == 10 ~ 'Outubro de 2019',
          M0151 == 11 ~ 'Novembro de 2019',
          M0151 == 12 ~ 'Dezembro de 2019',
          M0151 == 13 ~ 'Janeiro de 2020',
          M0151 == 14 ~ 'Fevereiro de 2020',
          M0151 == 15 ~ 'Mar\u00e7o de 2020',
          M0151 == 16 ~ 'Abril de 2020',
          M0151 == 17 ~ 'Maio de 2020',
          M0151 == 18 ~ 'Junho de 2020',
          M0151 == 19 ~ 'Julho de 2020',
          M0151 == 20 ~ 'Agosto de 2020',
          M0151 == 21 ~ 'Setembro de 2020',
          M0151 == 22 ~ 'Outubro de 2020',
          M0151 == 23 ~ 'Novembro de 2020',
          M0151 == 24 ~ 'Dezembro de 2020',
          M0151 == 25 ~ 'Janeiro de 2021',
          M0151 == 26 ~ 'Fevereiro de 2021',
          M0151 == 27 ~ 'Mar\u00e7o de 2021',
          M0151 == 28 ~ 'Abril de 2021',
          M0151 == 29 ~ 'Maio de 2021',
          M0151 == 30 ~ 'Junho de 2021',
          M0151 == 31 ~ 'Julho de 2021',
          M0151 == 32 ~ 'Agosto de 2021',
          M0151 == 33 ~ 'Setembro de 2021',
          M0151 == 34 ~ 'Outubro de 2021',
          M0151 == 35 ~ 'Novembro de 2021',
          M0151 == 36 ~ 'Dezembro de 2021',
          M0151 == 37 ~ 'Janeiro de 2022',
          M0151 == 38 ~ 'Fevereiro de 2022',
          M0151 == 39 ~ 'Mar\u00e7o de 2022',
          M0151 == 40 ~ 'Abril de 2022',
          M0151 == 41 ~ 'Maio de 2022',
          M0151 == 42 ~ 'Junho de 2022',
          M0151 == 43 ~ 'Julho de 2022',
          M0151 == 99 ~ 'Ignorado'
        )
      )
    }

    # SEXO DA PESSOA FALECIDA
    if ('M0160' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        M0160 = dplyr::case_when(
          M0160 == 1 ~ 'Masculino',
          M0160 == 2 ~ 'Feminino',
          M0160 == 9 ~ 'Ignorado'
        )
      )
    }

    # IDADE CALCULADA DA PESSOA FALECIDA, CATEGORIA
    if ('M0170' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        M0170 = dplyr::case_when(
          M0170 == 1 ~ '0 a 4 anos',
          M0170 == 2 ~ '5 a 9 anos',
          M0170 == 3 ~ '10 a 14 anos',
          M0170 == 4 ~ '15 a 19 anos',
          M0170 == 5 ~ '20 a 24 anos',
          M0170 == 6 ~ '25 a 29 anos',
          M0170 == 7 ~ '30 a 34 anos',
          M0170 == 8 ~ '35 a 39 anos',
          M0170 == 9 ~ '40 a 44 anos',
          M0170 == 10 ~ '45 a 49 anos',
          M0170 == 11 ~ '50 a 54 anos',
          M0170 == 12 ~ '55 a 59 anos',
          M0170 == 13 ~ '60 a 64 anos',
          M0170 == 14 ~ '65 a 69 anos',
          M0170 == 15 ~ '70 a 74 anos',
          M0170 == 16 ~ '75 a 79 anos',
          M0170 == 17 ~ '80 anos ou mais',
          M0170 == 99 ~ 'Idade ao falecer ignorada'
        )
      )
    }
  }

  ### YEAR 2010
  if(year == 2010 & lang == 'pt'){ # nocov start
    # urban vs rural
    if ('V1006' %in% cols) {
      arrw <- arrw |> mutate(V1006 = case_when(
        V1006 == '1' ~'Urbana',
        V1006 == '2' ~'Rural'))
    }

    # sex of deceased person
    if ('V0704' %in% cols) {
      arrw <- arrw |> mutate(V0704 = case_when(
        V0704 == '1' ~ 'Masculino',
        V0704 == '2' ~ 'Feminino',
        V0704==  '9' ~ 'Ignorado'))
    }

    # month and year of death
    if ('V0703' %in% cols) {
      arrw <- arrw |> mutate(V0703 = case_when(
        V0703 == '01' ~ 'Agosto de 2009',
        V0703 == '02' ~ 'Setembro de 2009',
        V0703 == '03' ~ 'Outubro de 2009',
        V0703 == '04' ~ 'Novembro de 2009',
        V0703 == '05' ~ 'Dezembro de 2009',
        V0703 == '06' ~ 'Janeiro de 2010',
        V0703 == '07' ~ 'Fevereiro de 2010',
        V0703 == '08' ~ 'Mar\u00e7o de 2010',
        V0703 == '09' ~ 'Abril de 2010',
        V0703 == '10' ~ 'Maio de 2010',
        V0703 == '11' ~ 'Junho de 2010',
        V0703 == '12' ~ 'Julho de 2010',
        V0703 == '99' ~ 'Ignorado'))
      }

    # census tract type
    if ('V1005' %in% cols) {
      arrw <- arrw |> mutate(V1005 = case_when(
        V1005 == '1' ~ paste0('\u00c1rea urbanizada'),
        V1005 == '2' ~ paste0('\u00c1rea n\u00e3o urbanizada'),
        V1005 == '3' ~ paste0('\u00c1rea urbanizada isolada'),
        V1005 == '4' ~ paste0('\u00c1rea rural de extens\u00e3o urbana'),
        V1005 == '5' ~ 'Aglomerado rural (povoado)',
        V1005 == '6' ~ paste0('Aglomerado rural (n\u00facleo)'),
        V1005 == '7' ~ 'Aglomerado rural (outros)',
        V1005 == '8' ~ paste0('\u00c1rea rural exclusive aglomerado rural')))
    }
  } # nocov end

  return(arrw)
}
