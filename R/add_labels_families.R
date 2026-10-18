# Add labels to categorical variables of family datasets
#' @keywords internal
add_labels_families <- function(arrw,
                                year = parent.frame()$year,
                                lang = 'pt'){

  # check input
  checkmate::assert_string(lang, pattern = 'pt', na.ok = TRUE)
  if (!(year %in% c(2000, 2010, 2022))) {
    cli::cli_abort("Labels for this data are only available for the years c(2000, 2010, 2022)")
    }

  # names of columns present in the data
  cols <- names(arrw)

  # YEAR 2022 ------------------------------------------------------------------
  if (year == 2022 & lang == 'pt') {
    # NOTE: variable names follow the CD2022 FAMI layout (Controlled Access).
    # Every block below checks var %in% cols first, so this same function
    # works on the Public Access layout too -- variables that only exist in
    # the Controlled Access version (F0030-F0090 geography codes, F0111 peso
    # amostral, F0181 idade do responsavel em numero) are simply skipped when
    # absent. As in add_labels_population(), the imputation flags (MF0190,
    # MF0200) are left unlabelled.

    # SITUACAO DO SETOR
    if ('F0120' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0120 = dplyr::case_when(
          F0120 == 1 ~ '\u00c1rea urbana de alta densidade de edifica\u00e7\u00f5es',
          F0120 == 2 ~ '\u00c1rea urbana de baixa densidade de edifica\u00e7\u00f5es',
          F0120 == 3 ~ 'N\u00facleo urbano',
          F0120 == 5 ~ 'Povoado',
          F0120 == 6 ~ 'N\u00facleo rural',
          F0120 == 7 ~ 'Lugarejo',
          F0120 == 8 ~ '\u00c1rea rural (exclusive aglomerados)'
        )
      )
    }

    # ESPECIE DA UNIDADE VISITADA
    if ('F0130' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0130 = dplyr::case_when(
          F0130 == 1 ~ 'Domic\u00edlio particular permanente ocupado',
          F0130 == 5 ~ 'Domic\u00edlio particular improvisado ocupado',
          F0130 == 6 ~ 'Domic\u00edlio coletivo com morador'
        )
      )
    }

    # SITUACAO DO DOMICILIO
    if ('F0140' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0140 = dplyr::case_when(
          F0140 == 1 ~ 'Urbana',
          F0140 == 2 ~ 'Rural'
        )
      )
    }

    # FAMILIA, IDENTIFICACAO
    # NOTE: the dictionary stops at 10 ('Convivente - nona'), but the data also
    # contain a code 11 (1 record in the Public Access file). It is left
    # unlabelled because IBGE does not document it.
    if ('F0150' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0150 = dplyr::case_when(
          F0150 == 1 ~ '\u00danica',
          F0150 == 2 ~ 'Convivente - principal',
          F0150 == 3 ~ 'Convivente - segunda',
          F0150 == 4 ~ 'Convivente - terceira',
          F0150 == 5 ~ 'Convivente - quarta',
          F0150 == 6 ~ 'Convivente - quinta',
          F0150 == 7 ~ 'Convivente - sexta',
          F0150 == 8 ~ 'Convivente - s\u00e9tima',
          F0150 == 9 ~ 'Convivente - oitava',
          F0150 == 10 ~ 'Convivente - nona'
        )
      )
    }

    # SEXO DO RESPONSAVEL PELA FAMILIA UNICA OU CONVIVENTE PRINCIPAL
    if ('F0170' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0170 = dplyr::case_when(
          F0170 == 1 ~ 'Masculino',
          F0170 == 2 ~ 'Feminino'
        )
      )
    }

    # IDADE EM ANOS DO RESPONSAVEL PELA FAMILIA UNICA OU CONVIVENTE PRINCIPAL, CATEGORIA
    if ('F0180' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0180 = dplyr::case_when(
          F0180 == 1 ~ '0 a 4 anos',
          F0180 == 2 ~ '5 a 9 anos',
          F0180 == 3 ~ '10 a 14 anos',
          F0180 == 4 ~ '15 a 19 anos',
          F0180 == 5 ~ '20 a 24 anos',
          F0180 == 6 ~ '25 a 29 anos',
          F0180 == 7 ~ '30 a 34 anos',
          F0180 == 8 ~ '35 a 39 anos',
          F0180 == 9 ~ '40 a 44 anos',
          F0180 == 10 ~ '45 a 49 anos',
          F0180 == 11 ~ '50 a 54 anos',
          F0180 == 12 ~ '55 a 59 anos',
          F0180 == 13 ~ '60 a 64 anos',
          F0180 == 14 ~ '65 a 69 anos',
          F0180 == 15 ~ '70 a 74 anos',
          F0180 == 16 ~ '75 a 79 anos',
          F0180 == 17 ~ '80 anos ou mais',
          F0180 == 99 ~ 'Ignorado'
        )
      )
    }

    # NIVEL DE INSTRUCAO DO RESPONSAVEL PELA FAMILIA UNICA OU CONVIVENTE PRINCIPAL
    if ('F0190' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0190 = dplyr::case_when(
          F0190 == 1 ~ 'Sem instru\u00e7\u00e3o e fundamental incompleto',
          F0190 == 2 ~ 'Fundamental completo e m\u00e9dio incompleto',
          F0190 == 3 ~ 'M\u00e9dio completo e superior incompleto',
          F0190 == 4 ~ 'Superior completo'
        )
      )
    }

    # COR OU RACA DO RESPONSAVEL PELA FAMILIA UNICA OU CONVIVENTE PRINCIPAL
    if ('F0200' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0200 = dplyr::case_when(
          F0200 == 1 ~ 'Branca',
          F0200 == 2 ~ 'Preta',
          F0200 == 3 ~ 'Amarela',
          F0200 == 4 ~ 'Parda',
          F0200 == 5 ~ 'Ind\u00edgena',
          F0200 == 9 ~ 'Ignorado'
        )
      )
    }

    # FAMILIA UNICAS E CONVIVENTES PRINCIPAIS, TIPOLOGIA
    if ('F0210' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0210 = dplyr::case_when(
          F0210 == 1 ~ 'Casal sem filhos',
          F0210 == 2 ~ 'Casal sem filhos e com parentes',
          F0210 == 3 ~ 'Casal com filhos',
          F0210 == 4 ~ 'Casal com filhos e com parentes',
          F0210 == 5 ~ 'Mulher sem c\u00f4njuge com filhos',
          F0210 == 6 ~ 'Mulher sem c\u00f4njuge com filhos e com parentes',
          F0210 == 7 ~ 'Homem sem c\u00f4njuge com filhos',
          F0210 == 8 ~ 'Homem sem c\u00f4njuge com filhos e com parentes',
          F0210 == 9 ~ 'Mulher ou homem com dois ou mais c\u00f4njuges',
          F0210 == 10 ~ 'Outro'
        )
      )
    }

    # FAMILIAS CONVIVENTES SECUNDARIAS, TIPOLOGIA
    # NOTE: the dictionary lists codes 1-4, but the data also contain a code 5
    # (87 records in the Public Access file), probably the 'Outro' category that
    # F0210 has as code 10. It is left unlabelled because IBGE does not
    # document it.
    if ('F0220' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0220 = dplyr::case_when(
          F0220 == 1 ~ 'Casal sem filhos',
          F0220 == 2 ~ 'Casal com filhos',
          F0220 == 3 ~ 'Mulher sem c\u00f4njuge com filhos',
          F0220 == 4 ~ 'Homem sem c\u00f4njuge com filhos'
        )
      )
    }

    # RENDIMENTO FAMILIAR, PARTICIPACAO
    if ('F0270' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        F0270 = dplyr::case_when(
          F0270 == 1 ~ 'Ambos com rendimento',
          F0270 == 2 ~ 'Respons\u00e1vel com rendimento e c\u00f4njuge ou companheiro(a) sem rendimento',
          F0270 == 3 ~ 'Respons\u00e1vel sem rendimento e c\u00f4njuge ou companheiro(a) com rendimento',
          F0270 == 4 ~ 'Ambos sem rendimento'
        )
      )
    }
  }


  # YEAR 2000 ------------------------------------------------------------------
  if(year == 2000 & lang == 'pt'){ # nocov start

    # CLASSE DE NUMERO DE COMPONENTES
    if ('CODV7400' %in% cols) {
      arrw <- arrw |> mutate(CODV7400 = case_when(
        CODV7400 == 1 ~ '1 pessoa',
        CODV7400 == 2 ~ '2 pessoas',
        CODV7400 == 3 ~ '3 pessoas',
        CODV7400 == 4 ~ '4 pessoas',
        CODV7400 == 5 ~ '5 pessoas',
        CODV7400 == 6 ~ '6 pessoas',
        CODV7400 == 7 ~ '7 pessoas',
        CODV7400 == 8 ~ '8 pessoas',
        CODV7400 == 9 ~ '9 pessoas',
        CODV7400 == 10 ~ '10 pessoas',
        CODV7400 == 11 ~ '11 pessoas',
        CODV7400 == 12 ~ '12 pessoas',
        CODV7400 == 13 ~ '13 pessoas',
        CODV7400 == 14 ~ '14 pessoas',
        CODV7400 == 15 ~ '15 ou mais pessoas'))
    }

    # CLASSE DE NUMERO DE COMPONENTES HOMENS
    if ('CODV7400A' %in% cols) {
      arrw <- arrw |> mutate(CODV7400A = case_when(
        CODV7400A == 0 ~ 'nenhum',
        CODV7400A == 1 ~ '1 homem',
        CODV7400A == 2 ~ '2 homens',
        CODV7400A == 3 ~ '3 homens',
        CODV7400A == 4 ~ '4 homens',
        CODV7400A == 5 ~ '5 homens',
        CODV7400A == 6 ~ '6 homens',
        CODV7400A == 7 ~ '7 homens',
        CODV7400A == 8 ~ '8 homens',
        CODV7400A == 9 ~ '9 homens',
        CODV7400A == 10 ~ '10 homens',
        CODV7400A == 11 ~ '11 homens',
        CODV7400A == 12 ~ '12 homens',
        CODV7400A == 13 ~ '13 homens',
        CODV7400A == 14 ~ '14 homens',
        CODV7400A == 15 ~ '15 ou mais homens'))
    }

    # CLASSE DE NUMERO DE COMPONENTES MULHERES
    if ('CODV7400B' %in% cols) {
      arrw <- arrw |> mutate(CODV7400B = case_when(
        CODV7400B == 0 ~ 'nenhuma',
        CODV7400B == 1 ~ '1 mulher',
        CODV7400B == 2 ~ '2 mulheres',
        CODV7400B == 3 ~ '3 mulheres',
        CODV7400B == 4 ~ '4 mulheres',
        CODV7400B == 5 ~ '5 mulheres',
        CODV7400B == 6 ~ '6 mulheres',
        CODV7400B == 7 ~ '7 mulheres',
        CODV7400B == 8 ~ '8 mulheres',
        CODV7400B == 9 ~ '9 mulheres',
        CODV7400B == 10 ~ '10 mulheres',
        CODV7400B == 11 ~ '11 mulheres',
        CODV7400B == 12 ~ '12 mulheres',
        CODV7400B == 13 ~ '13 mulheres',
        CODV7400B == 14 ~ '14 mulheres',
        CODV7400B == 15 ~ '15 ou mais mulheres'))
    }
  } # nocov end

  if(year == 2000 & lang == 'pt'){ # nocov start
    config <- load_label_config(dataset = "families", year = year, lang = lang)
    arrw <- apply_label_config(arrw, config)
  } # nocov end

  return(arrw)
}
