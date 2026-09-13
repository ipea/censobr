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

    # REGIAO METROPOLITANA
    if ('V1004' %in% cols) {
      arrw <- arrw |> mutate(V1004 = case_when(
        V1004 == '01' ~ 'Bel\u00e9m',
        V1004 == '02' ~ 'Grande S\u00e3o Lu\u00eds',
        V1004 == '03' ~ 'Fortaleza',
        V1004 == '04' ~ 'Natal',
        V1004 == '05' ~ 'Recife',
        V1004 == '06' ~ 'Macei\u00f3',
        V1004 == '07' ~ 'Salvador',
        V1004 == '08' ~ 'Belo Horizonte',
        V1004 == '09' ~ 'Colar Metropolitano da RM de Belo Horizonte',
        V1004 == '10' ~ 'Vale do A\u00e7o',
        V1004 == '11' ~ 'Colar Metropolitano da RM do Vale do A\u00e7o',
        V1004 == '12' ~ 'Grande Vit\u00f3ria',
        V1004 == '13' ~ 'Rio de Janeiro',
        V1004 == '14' ~ 'S\u00e3o Paulo',
        V1004 == '15' ~ 'Baixada Santista',
        V1004 == '16' ~ 'Campinas',
        V1004 == '17' ~ 'Curitiba',
        V1004 == '18' ~ 'Londrina',
        V1004 == '19' ~ 'Maring\u00e1',
        V1004 == '20' ~ 'Florian\u00f3polis',
        V1004 == '21' ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM de Florian\u00f3polis',
        V1004 == '22' ~ 'N\u00facleo Metropolitano da RM Vale do Itaja\u00ed',
        V1004 == '23' ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM Vale do Itaja\u00ed',
        V1004 == '24' ~ 'Norte/Nordeste Catarinense',
        V1004 == '25' ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM Norte/Nordeste Catarinense',
        V1004 == '26' ~ 'Porto Alegre',
        V1004 == '27' ~ 'Goi\u00e2nia',
        V1004 == '28' ~ 'RIDE (Regi\u00e3o Integrada de Desenvolvimento do Distrito Federal e Entorno)'))
      }

    # TIPO DE FAMILIA (1)
    if ('CODV0404' %in% cols) {
      arrw <- arrw |> mutate(CODV0404 = case_when(
        CODV0404 == '0' ~ '\u00danica (uma s\u00f3 fam\u00edlia vive no domic\u00edlio)',
        CODV0404 == '1' ~ 'Fam\u00edlias conviventes: 1\u00aa fam\u00edlia',
        CODV0404 == '2' ~ 'Fam\u00edlias conviventes: 2\u00aa fam\u00edlia',
        CODV0404 == '3' ~ 'Fam\u00edlias conviventes: 3\u00aa fam\u00edlia',
        CODV0404 == '4' ~ 'Fam\u00edlias conviventes: 4\u00aa fam\u00edlia',
        CODV0404 == '5' ~ 'Fam\u00edlias conviventes: 5\u00aa fam\u00edlia e mais',
        CODV0404 == '9' ~ 'Morador individual'))
      }

    # TIPO DE FAMILIA (2)
    if ('CODV0404_2' %in% cols) {
      arrw <- arrw |> mutate(CODV0404_2 = case_when(
        CODV0404_2 == '01' ~ 'Casal sem filhos',
        CODV0404_2 == '02' ~ 'Casal com filhos menores de 14 anos',
        CODV0404_2 == '03' ~ 'Casal com filhos de 14 anos ou mais',
        CODV0404_2 == '04' ~ 'Casal com filhos de idades variadas',
        CODV0404_2 == '05' ~ 'M\u00e3e com filhos menores de 14 anos',
        CODV0404_2 == '06' ~ 'M\u00e3e com filhos de 14 anos ou mais',
        CODV0404_2 == '07' ~ 'M\u00e3e com filhos de idades variadas',
        CODV0404_2 == '08' ~ 'Pai com filhos menores de 14 anos',
        CODV0404_2 == '09' ~ 'Pai com filhos de 14 anos ou mais',
        CODV0404_2 == '10' ~ 'Pai com filhos de idades variadas',
        CODV0404_2 == '11' ~ 'Outros tipos de fam\u00edlias',
        CODV0404_2 == '12' ~ 'Morador individual'))
      }

    # CLASSE DE RENDIMENTO NOMINAL FAMILIAR
    if ('CODV4615B' %in% cols) {
      arrw <- arrw |> mutate(CODV4615B = case_when(
        CODV4615B == '01' ~ 'At\u00e9 0,25 sal\u00e1rio m\u00ednimo',
        CODV4615B == '02' ~ 'Mais de 0,25 a 0,5 sal\u00e1rio m\u00ednimo',
        CODV4615B == '03' ~ 'Mais de 0,5 a 1 sal\u00e1rio m\u00ednimo',
        CODV4615B == '04' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
        CODV4615B == '05' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
        CODV4615B == '06' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
        CODV4615B == '07' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
        CODV4615B == '08' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
        CODV4615B == '09' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
        CODV4615B == '10' ~ 'Mais de 20 a 30 sal\u00e1rios m\u00ednimos',
        CODV4615B == '11' ~ 'Mais de 30 sal\u00e1rios m\u00ednimos',
        CODV4615B == '12' ~ 'Sem rendimento'))
    }

    # CLASSE DE RENDIMENTO NOMINAL, RESPONSAVEL/CASAL
    if ('CODV4615C' %in% cols) {
      arrw <- arrw |> mutate(CODV4615C = case_when(
        CODV4615C == '01' ~ 'At\u00e9 0,25 sal\u00e1rio m\u00ednimo',
        CODV4615C == '02' ~ 'Mais de 0,25 a 0,5 sal\u00e1rio m\u00ednimo',
        CODV4615C == '03' ~ 'Mais de 0,5 a 0,75 sal\u00e1rio m\u00ednimo',
        CODV4615C == '04' ~ 'Mais de 0,75 a 1 sal\u00e1rio m\u00ednimo',
        CODV4615C == '05' ~ 'Mais de 1 a 1,25 sal\u00e1rios m\u00ednimos',
        CODV4615C == '06' ~ 'Mais de 1,25 a 1,5 sal\u00e1rios m\u00ednimos',
        CODV4615C == '07' ~ 'Mais de 1,5 a 2 sal\u00e1rios m\u00ednimos',
        CODV4615C == '08' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
        CODV4615C == '09' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
        CODV4615C == '10' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
        CODV4615C == '11' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
        CODV4615C == '12' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
        CODV4615C == '13' ~ 'Mais de 20 a 30 sal\u00e1rios m\u00ednimos',
        CODV4615C == '14' ~ 'Mais de 30 sal\u00e1rios m\u00ednimos',
        CODV4615C == '15' ~ 'Sem rendimento'))
    }

  # CLASSE DE RENDIMENTO NOMINAL FAMILIAR PER-CAPITA
  if ('CODV4615_7400' %in% cols) {
    arrw <- arrw |> mutate(CODV4615_7400 = case_when(
      CODV4615_7400 == '01' ~ 'At\u00e9 0,25 sal\u00e1rio m\u00ednimo',
      CODV4615_7400 == '02' ~ 'Mais de 0,25 a 0,5 sal\u00e1rio m\u00ednimo',
      CODV4615_7400 == '03' ~ 'Mais de 0,5 a 1 sal\u00e1rio m\u00ednimo',
      CODV4615_7400 == '04' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
      CODV4615_7400 == '05' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
      CODV4615_7400 == '06' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
      CODV4615_7400 == '07' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
      CODV4615_7400 == '08' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
      CODV4615_7400 == '09' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
      CODV4615_7400 == '10' ~ 'Mais de 20 a 30 sal\u00e1rios m\u00ednimos',
      CODV4615_7400 == '11' ~ 'Mais de 30 sal\u00e1rios m\u00ednimos',
      CODV4615_7400 == '12' ~ 'Sem rendimento'))
    }

    # CLASSE DE NUMERO DE COMPONENTES
    if ('CODV7400' %in% cols) {
      arrw <- arrw |> mutate(CODV7400 = case_when(
        CODV7400 == '01' ~ '1 pessoa',
        CODV7400 == '02' ~ '2 pessoas',
        CODV7400 == '03' ~ '3 pessoas',
        CODV7400 == '04' ~ '4 pessoas',
        CODV7400 == '05' ~ '5 pessoas',
        CODV7400 == '06' ~ '6 pessoas',
        CODV7400 == '07' ~ '7 pessoas',
        CODV7400 == '08' ~ '8 pessoas',
        CODV7400 == '09' ~ '9 pessoas',
        CODV7400 == '10' ~ '10 pessoas',
        CODV7400 == '11' ~ '11 pessoas',
        CODV7400 == '12' ~ '12 pessoas',
        CODV7400 == '13' ~ '13 pessoas',
        CODV7400 == '14' ~ '14 pessoas',
        CODV7400 == '15' ~ '15 ou mais pessoas'))
    }

    # CLASSE DE NUMERO DE COMPONENTES HOMENS
    if ('CODV7400A' %in% cols) {
      arrw <- arrw |> mutate(CODV7400A = case_when(
        CODV7400A == '00' ~ 'nenhum',
        CODV7400A == '01' ~ '1 homem',
        CODV7400A == '02' ~ '2 homens',
        CODV7400A == '03' ~ '3 homens',
        CODV7400A == '04' ~ '4 homens',
        CODV7400A == '05' ~ '5 homens',
        CODV7400A == '06' ~ '6 homens',
        CODV7400A == '07' ~ '7 homens',
        CODV7400A == '08' ~ '8 homens',
        CODV7400A == '09' ~ '9 homens',
        CODV7400A == '10' ~ '10 homens',
        CODV7400A == '11' ~ '11 homens',
        CODV7400A == '12' ~ '12 homens',
        CODV7400A == '13' ~ '13 homens',
        CODV7400A == '14' ~ '14 homens',
        CODV7400A == '15' ~ '15 ou mais homens'))
    }

    # CLASSE DE NUMERO DE COMPONENTES MULHERES
    if ('CODV7400B' %in% cols) {
      arrw <- arrw |> mutate(CODV7400B = case_when(
        CODV7400B == '00' ~ 'nenhuma',
        CODV7400B == '01' ~ '1 mulher',
        CODV7400B == '02' ~ '2 mulheres',
        CODV7400B == '03' ~ '3 mulheres',
        CODV7400B == '04' ~ '4 mulheres',
        CODV7400B == '05' ~ '5 mulheres',
        CODV7400B == '06' ~ '6 mulheres',
        CODV7400B == '07' ~ '7 mulheres',
        CODV7400B == '08' ~ '8 mulheres',
        CODV7400B == '09' ~ '9 mulheres',
        CODV7400B == '10' ~ '10 mulheres',
        CODV7400B == '11' ~ '11 mulheres',
        CODV7400B == '12' ~ '12 mulheres',
        CODV7400B == '13' ~ '13 mulheres',
        CODV7400B == '14' ~ '14 mulheres',
        CODV7400B == '15' ~ '15 ou mais mulheres'))
    }
  } # nocov end

  return(arrw)
}
