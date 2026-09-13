# Add labels to categorical variables of household datasets
#' @keywords internal
add_labels_households <- function(
  arrw,
  year = parent.frame()$year,
  lang = 'pt'
) {
  # check input
  checkmate::assert_string(lang, pattern = 'pt', na.ok = TRUE)
  if (!(year %in% c(2000, 2010, 2022))) {
    cli::cli_abort(
      "Labels for this data are only available for the years c(2000, 2010, 2022)"
    )
  }

  # names of columns present in the data
  cols <- names(arrw) # nocov start

  # ALL YEARS ------------------------------------------------------------------

  # urban vs rural
  if ('V1006' %in% cols) {
    arrw <- mutate(
      arrw,
      V1006 = case_when(
        V1006 == '1' ~ 'Urbana',
        V1006 == '2' ~ 'Rural'
      )
    )
  }

  # YEAR 2022 ------------------------------------------------------------------
  if (year == 2022 & lang == 'pt') {
    # NOTE: variable names follow the CD2022 DOMI layout (Controlled Access).
    # Every block below checks var %in% cols first, so this same function
    # works on the Public Access layout too -- variables that only exist in
    # the Controlled Access version (D0030-D0090 geography codes, D0111 peso
    # amostral, D0171 sexo do responsavel, D0181 idade do responsavel em
    # numero) are simply skipped when absent.
    #
    # The imputation flags MD0130-MD0340 are left as 0/1 integers, as the
    # equivalent MP* flags are in add_labels_population().

    # SITUACAO DO SETOR
    if ('D0120' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0120 = dplyr::case_when(
          D0120 ==
            1 ~ '\u00c1rea urbana de alta densidade de edifica\u00e7\u00f5es',
          D0120 ==
            2 ~ '\u00c1rea urbana de baixa densidade de edifica\u00e7\u00f5es',
          D0120 == 3 ~ 'N\u00facleo urbano',
          D0120 == 5 ~ 'Povoado',
          D0120 == 6 ~ 'N\u00facleo rural',
          D0120 == 7 ~ 'Lugarejo',
          D0120 == 8 ~ '\u00c1rea rural (exclusive aglomerados)'
        )
      )
    }

    # ESPECIE DA UNIDADE VISITADA
    if ('D0130' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0130 = dplyr::case_when(
          D0130 == 1 ~ 'Domic\u00edlio particular permanente ocupado',
          D0130 == 5 ~ 'Domic\u00edlio particular improvisado ocupado',
          D0130 == 6 ~ 'Domic\u00edlio coletivo com morador'
        )
      )
    }

    # SITUACAO DO DOMICILIO
    if ('D0140' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0140 = dplyr::case_when(
          D0140 == 1 ~ 'Urbana',
          D0140 == 2 ~ 'Rural'
        )
      )
    }

    # SEXO DO MORADOR RESPONSAVEL PELO DOMICILIO
    if ('D0170' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0170 = dplyr::case_when(
          D0170 == 1 ~ 'Masculino',
          D0170 == 2 ~ 'Feminino',
          D0170 == 9 ~ 'Ignorado'
        )
      )
    }

    # SEXO DO MORADOR RESPONSAVEL PELO DOMICILIO
    if ('D0171' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0171 = dplyr::case_when(
          D0171 == 1 ~ 'Masculino',
          D0171 == 2 ~ 'Feminino'
        )
      )
    }

    # IDADE DA PESSOA RESPONSAVEL PELO DOMICILIO, CATEGORIA
    if ('D0180' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0180 = dplyr::case_when(
          D0180 == 1 ~ '0 a 4 anos',
          D0180 == 2 ~ '5 a 9 anos',
          D0180 == 3 ~ '10 a 14 anos',
          D0180 == 4 ~ '15 a 19 anos',
          D0180 == 5 ~ '20 a 24 anos',
          D0180 == 6 ~ '25 a 29 anos',
          D0180 == 7 ~ '30 a 34 anos',
          D0180 == 8 ~ '35 a 39 anos',
          D0180 == 9 ~ '40 a 44 anos',
          D0180 == 10 ~ '45 a 49 anos',
          D0180 == 11 ~ '50 a 54 anos',
          D0180 == 12 ~ '55 a 59 anos',
          D0180 == 13 ~ '60 a 64 anos',
          D0180 == 14 ~ '65 a 69 anos',
          D0180 == 15 ~ '70 a 74 anos',
          D0180 == 16 ~ '75 a 79 anos',
          D0180 == 17 ~ '80 anos ou mais',
          D0180 == 99 ~ 'Ignorado'
        )
      )
    }

    # CONDICAO DE OCUPACAO DO DOMICILIO, CATEGORIA
    if ('D0190' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0190 = dplyr::case_when(
          D0190 ==
            1 ~ 'Pr\u00f3prio de algum morador - j\u00e1 pago, herdado ou ganho',
          D0190 == 2 ~ 'Pr\u00f3prio de algum morador - ainda pagando',
          D0190 == 3 ~ 'Alugado',
          D0190 == 4 ~ 'Cedido ou emprestado - por empregador',
          D0190 == 5 ~ 'Cedido ou emprestado - por familiar',
          D0190 == 6 ~ 'Cedido ou emprestado - outra forma',
          D0190 == 7 ~ 'Outra condi\u00e7\u00e3o'
        )
      )
    }

    # TIPO DE ESPECIE
    if ('D0200' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0200 = dplyr::case_when(
          D0200 == 11 ~ '(Permanente ocupada) Casa',
          D0200 ==
            12 ~ '(Permanente ocupada) Casa de vila ou em condom\u00ednio',
          D0200 == 13 ~ '(Permanente ocupada) Apartamento',
          D0200 ==
            14 ~ '(Permanente ocupada) Habita\u00e7\u00e3o em casa de c\u00f4modos ou corti\u00e7o',
          D0200 ==
            15 ~ '(Permanente ocupada) Habita\u00e7\u00e3o ind\u00edgena sem paredes ou maloca',
          D0200 ==
            16 ~ '(Permanente ocupada) Estrutura residencial permanente degradada ou inacabada',
          D0200 ==
            51 ~ '(Improvisado ocupada) Tenda ou barraca de lona, pl\u00e1stico ou tecido ou estrutura improvisada em logradouro p\u00fablico',
          D0200 ==
            52 ~ '(Improvisado ocupada) Dentro de estabelecimento em funcionamento',
          D0200 ==
            53 ~ '(Improvisado ocupada) Estrutura n\u00e3o residencial permanente degradada ou inacabada',
          D0200 ==
            54 ~ '(Improvisado ocupada) Outros (ve\u00edculos, abrigos naturais e outras estruturas improvisadas)',
          D0200 ==
            61 ~ '(Coletivo com morador) Asilo ou outra institui\u00e7\u00e3o de longa perman\u00eancia para idosos',
          D0200 == 62 ~ '(Coletivo com morador) Hotel ou pens\u00e3o',
          D0200 == 63 ~ '(Coletivo com morador) Alojamento',
          D0200 ==
            64 ~ '(Coletivo com morador) Penitenci\u00e1ria, centro de deten\u00e7\u00e3o e similar',
          D0200 ==
            65 ~ '(Coletivo com morador) Abrigo, albergue, casa de passagem, cl\u00ednica psiqui\u00e1trica, comunidade terap\u00eautica, orfanato e similares',
          D0200 == 66 ~ '(Coletivo com morador) Outro'
        )
      )
    }

    # MATERIAL DAS PAREDES DO DOMICILIO, CATEGORIA
    if ('D0210' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0210 = dplyr::case_when(
          D0210 == 1 ~ 'Alvenaria ou taipa COM revestimento',
          D0210 == 2 ~ 'Alvenaria SEM revestimento',
          D0210 == 3 ~ 'Taipa sem revestimento',
          D0210 == 4 ~ 'Madeira para constru\u00e7\u00e3o',
          D0210 == 5 ~ 'Madeira aproveitada de tapume, embalagens, andaimes',
          D0210 == 6 ~ 'Outro material',
          D0210 == 7 ~ 'Sem parede'
        )
      )
    }

    # TIPO DE ESGOTAMENTO SANITARIO DO DOMICILIO
    if ('D0250' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0250 = dplyr::case_when(
          D0250 == 1 ~ 'Rede geral ou pluvial',
          D0250 ==
            2 ~ 'Fossa s\u00e9ptica ou fossa filtro - ligada \u00e0 rede',
          D0250 ==
            3 ~ 'Fossa s\u00e9ptica ou fossa filtro - n\u00e3o ligada \u00e0 rede',
          D0250 == 4 ~ 'Fossa rudimentar ou buraco',
          D0250 == 5 ~ 'Vala',
          D0250 == 6 ~ 'Rio, lago, c\u00f3rrego ou mar',
          D0250 == 7 ~ 'Outra forma',
          D0250 == 9 ~ 'N\u00e3o tem banheiro nem sanit\u00e1rio'
        )
      )
    }

    # ABASTECIMENTO DE AGUA DO DOMICILIO, CATEGORIA
    if ('D0260' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0260 = dplyr::case_when(
          D0260 == 1 ~ 'Rede geral de distribui\u00e7\u00e3o',
          D0260 == 2 ~ 'Po\u00e7o - profundo ou artesiano',
          D0260 == 3 ~ 'Po\u00e7o - raso, fre\u00e1tico ou cacimba',
          D0260 == 4 ~ 'Fonte, nascente ou mina',
          D0260 == 5 ~ 'Carro-pipa',
          D0260 == 6 ~ '\u00c1gua da chuva armazenada',
          D0260 ==
            7 ~ 'Rios, a\u00e7udes, c\u00f3rregos, lagos e igarap\u00e9s',
          D0260 == 8 ~ 'Outra'
        )
      )
    }

    # EXISTENCIA DE BANHEIRO OU SANITARIO E NUMERO DE BANHEIROS DE USO EXCLUSIVO DO DOMICILIO
    if ('D0270' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0270 = dplyr::case_when(
          D0270 ==
            1 ~ 'Tem banheiro de uso exclusivo do domic\u00edlio - 1 banheiro',
          D0270 ==
            2 ~ 'Tem banheiro de uso exclusivo do domic\u00edlio - 2 banheiros',
          D0270 ==
            3 ~ 'Tem banheiro de uso exclusivo do domic\u00edlio - 3 banheiros',
          D0270 ==
            4 ~ 'Tem banheiro de uso exclusivo do domic\u00edlio - 4 banheiros ou mais',
          D0270 ==
            5 ~ 'Apenas banheiro de uso comum a mais de um domic\u00edlio',
          D0270 ==
            6 ~ 'Apenas sanit\u00e1rio ou buraco para deje\u00e7\u00f5es, inclusive os localizados no terreno',
          D0270 == 7 ~ 'N\u00e3o tem banheiro nem sanit\u00e1rio'
        )
      )
    }

    # ACESSO A REDE GERAL DE DISTRIBUICAO DE AGUA DO DOMICILIO, CATEGORIA
    if ('D0290' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0290 = dplyr::case_when(
          D0290 == 1 ~ 'Sim',
          D0290 == 2 ~ 'N\u00e3o'
        )
      )
    }

    # EXISTENCIA DE AGUA CANALIZADA DO DOMICILIO, CATEGORIA
    if ('D0300' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0300 = dplyr::case_when(
          D0300 ==
            1 ~ 'Encanada at\u00e9 dentro da casa, apartamento ou habita\u00e7\u00e3o',
          D0300 == 2 ~ 'Encanada, mas apenas no terreno',
          D0300 == 3 ~ 'N\u00e3o chega encanada'
        )
      )
    }

    # DESTINO DO LIXO DO DOMICILIO, CATEGORIA
    if ('D0310' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0310 = dplyr::case_when(
          D0310 == 1 ~ 'Coletado no domic\u00edlio por servi\u00e7o de limpeza',
          D0310 == 2 ~ 'Depositado em ca\u00e7amba de servi\u00e7o de limpeza',
          D0310 == 3 ~ 'Queimado na propriedade',
          D0310 == 4 ~ 'Enterrado na propriedade',
          D0310 ==
            5 ~ 'Jogado em terreno baldio, encosta ou \u00e1rea p\u00fablica',
          D0310 == 6 ~ 'Outro destino'
        )
      )
    }

    # EXISTENCIA DE MAQUINA DE LAVAR ROUPA NO DOMICILIO, CATEGORIA
    if ('D0320' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0320 = dplyr::case_when(
          D0320 == 1 ~ 'Sim',
          D0320 == 2 ~ 'N\u00e3o'
        )
      )
    }

    # ACESSO A INTERNET, EXISTENCIA
    if ('D0330' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0330 = dplyr::case_when(
          D0330 == 1 ~ 'Sim',
          D0330 == 2 ~ 'N\u00e3o'
        )
      )
    }

    # OCORRENCIA DE OBITO DE MORADOR DO DOMICILIO (DE JANEIRO DE 2019 A JULHO DE 2022), CATEGORIA
    if ('D0340' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        D0340 = dplyr::case_when(
          D0340 == 1 ~ 'Sim',
          D0340 == 2 ~ 'N\u00e3o',
          D0340 == 9 ~ 'Ignorado'
        )
      )
    }
  }

  # YEAR 2010 ------------------------------------------------------------------
  if (year == 2010 & lang == 'pt') {
    # Private vs collective household
    if ('V4001' %in% cols) {
      arrw <- mutate(
        arrw,
        V4001 = case_when(
          V4001 == '01' ~ 'Domic\u00edlio particular permanente ocupado',
          V4001 ==
            '02' ~ 'Domic\u00edlio particular permanente ocupado sem entrevista realizada',
          V4001 == '05' ~ 'Domic\u00edlio particular improvisado ocupado',
          V4001 == '06' ~ 'Domic\u00edlio coletivo com morador'
        )
      )
    }

    # household type
    if ('V4002' %in% cols) {
      arrw <- mutate(
        arrw,
        V4002 = case_when(
          V4002 == '11' ~ 'Casa',
          V4002 == '12' ~ 'Casa de vila ou em condom\u00ednio',
          V4002 == '13' ~ 'Apartamento',
          V4002 ==
            '14' ~ 'Habita\u00e7\u00e3o em: casa de c\u00f4modos, corti\u00e7o ou cabe\u00e7a de porco',
          V4002 == '15' ~ 'Oca ou maloca ',
          V4002 == '51' ~ 'Tenda ou barraca',
          V4002 == '52' ~ 'Dentro de estabelecimento',
          V4002 == '53' ~ 'Outro (vag\u00e3o, trailer, gruta, etc)',
          V4002 == '61' ~ 'Asilo, orfanato e similares  com morador',
          V4002 == '62' ~ 'Hotel, pens\u00e3o e similares com morador',
          V4002 == '63' ~ 'Alojamento de trabalhadores com morador',
          V4002 ==
            '64' ~ 'Penitenci\u00e1ria, pres\u00eddio ou casa de deten\u00e7\u00e3o com morador',
          V4002 == '65' ~ 'Outro com morador'
        )
      )
    }

    # household tenure / occupancy status
    if ('V0201' %in% cols) {
      arrw <- mutate(
        arrw,
        V0201 = case_when(
          V0201 == '1' ~ 'Pr\u00f3prio de algum morador - j\u00e1 pago',
          V0201 == '2' ~ 'Pr\u00f3prio de algum morador - ainda pagando',
          V0201 == '3' ~ 'Alugado',
          V0201 == '4' ~ 'Cedido por empregador',
          V0201 == '5' ~ 'Cedido de outra forma',
          V0201 == '6' ~ 'Outra condi\u00e7\u00e3o'
        )
      )
    }

    # material used to build household wall
    if ('V0202' %in% cols) {
      arrw <- mutate(
        arrw,
        V0202 = case_when(
          V0202 == '1' ~ 'Alvenaria com revestimento',
          V0202 == '2' ~ 'Alvenaria sem revestimento',
          V0202 ==
            '3' ~ 'Madeira apropriada para constru\u00e7\u00e3o (aparelhada)',
          V0202 == '4' ~ 'Taipa revestida',
          V0202 == '5' ~ 'Taipa n\u00e3o revestida',
          V0202 == '6' ~ 'Madeira aproveitada',
          V0202 == '7' ~ 'Palha',
          V0202 == '8' ~ 'Outro material',
          V0202 == '9' ~ 'Sem parede'
        )
      )
    }

    # type of sanitation connection
    if ('V0207' %in% cols) {
      arrw <- mutate(
        arrw,
        V0207 = case_when(
          V0207 == '1' ~ 'Rede geral de esgoto ou pluvial',
          V0207 == '2' ~ 'Fossa s\u00e9ptica',
          V0207 == '3' ~ 'Fossa rudimentar',
          V0207 == '4' ~ 'Vala',
          V0207 == '5' ~ 'Rio, lago ou mar',
          V0207 == '6' ~ 'Outro'
        )
      )
    }

    # access to water
    if ('V0208' %in% cols) {
      arrw <- mutate(
        arrw,
        V0208 = case_when(
          V0208 == '01' ~ 'Rede geral de distribui\u00e7\u00e3o',
          V0208 == '02' ~ 'Po\u00e7o ou nascente na propriedade',
          V0208 == '03' ~ 'Po\u00e7o ou nascente fora da propriedade',
          V0208 == '04' ~ 'Carro-pipa',
          V0208 == '05' ~ '\u00c1gua da chuva armazenada em cisterna',
          V0208 == '06' ~ '\u00c1gua da chuva armazenada de outra forma',
          V0208 == '07' ~ 'Rios, a\u00e7udes, lagos e igarap\u00e9s',
          V0208 == '08' ~ 'Outra',
          V0208 == '09' ~ 'Po\u00e7o ou nascente na aldeia',
          V0208 == '10' ~ 'Po\u00e7o ou nascente fora da aldeia'
        )
      )
    }

    # water connection
    if ('V0209' %in% cols) {
      arrw <- mutate(
        arrw,
        V0209 = case_when(
          V0209 == '1' ~ 'Sim, em pelo menos um c\u00f4modo',
          V0209 == '2' ~ 'Sim, s\u00f3 na propriedade ou terreno',
          V0209 == '3' ~ 'N\u00e3o'
        )
      )
    }

    # waste treatment
    if ('V0210' %in% cols) {
      arrw <- mutate(
        arrw,
        V0210 = case_when(
          V0210 == '1' ~ 'Coletado diretamente por servi\u00e7o de limpeza',
          V0210 == '2' ~ 'Colocado em ca\u00e7amba de servi\u00e7o de limpeza',
          V0210 == '3' ~ 'Queimado (na propriedade)',
          V0210 == '4' ~ 'Enterrado (na propriedade)',
          V0210 == '5' ~ 'Jogado em terreno baldio ou logradouro',
          V0210 == '6' ~ 'Jogado em rio, lago ou mar',
          V0210 == '7' ~ 'Tem outro destino'
        )
      )
    }

    # eletricity
    if ('V0211' %in% cols) {
      arrw <- mutate(
        arrw,
        V0211 = case_when(
          V0211 == '1' ~ 'Sim, de companhia distribuidora',
          V0211 == '2' ~ 'Sim, de outras fontes',
          V0211 == '3' ~ 'N\u00e3o existe energia el\u00e9trica'
        )
      )
    }

    # eletricity meter
    if ('V0212' %in% cols) {
      arrw <- mutate(
        arrw,
        V0212 = case_when(
          V0212 == '1' ~ 'Sim, de uso exclusivo',
          V0212 == '2' ~ 'Sim, de uso comum ',
          V0212 == '3' ~ 'N\u00e3o tem medidor ou rel\u00f3gio'
        )
      )
    }

    # shared household head
    if ('V0402' %in% cols) {
      arrw <- mutate(
        arrw,
        V0402 = case_when(
          V0402 == '1' ~ 'Apenas um morador',
          V0402 == '2' ~ 'Mais de um morador',
          V0402 == '9' ~ 'Ignorado'
        )
      )
    }

    # type of domestic / family
    if ('V6600' %in% cols) {
      arrw <- mutate(
        arrw,
        V6600 = case_when(
          V6600 == '1' ~ 'Unipessoal',
          V6600 == '2' ~ 'Nuclear',
          V6600 == '3' ~ 'Estendida',
          V6600 == '4' ~ 'Composta'
        )
      )
    }

    # adequate housing
    if ('V6210' %in% cols) {
      arrw <- mutate(
        arrw,
        V6210 = case_when(
          V6210 == '1' ~ 'Adequada',
          V6210 == '2' ~ 'Semi-adequada',
          V6210 == '3' ~ 'Inadequada'
        )
      )
    }

    # census tract type
    if ('V1005' %in% cols) {
      arrw <- mutate(
        arrw,
        V1005 = case_when(
          V1005 == '1' ~ '\u00c1rea urbanizada',
          V1005 == '2' ~ '\u00c1rea n\u00e3o urbanizada',
          V1005 == '3' ~ '\u00c1rea urbanizada isolada',
          V1005 == '4' ~ '\u00c1rea rural de extens\u00e3o urbana',
          V1005 == '5' ~ 'Aglomerado rural (povoado)',
          V1005 == '6' ~ 'Aglomerado rural (n\u00facleo)',
          V1005 == '7' ~ 'Aglomerado rural (outros)',
          V1005 == '8' ~ '\u00c1rea rural exclusive aglomerado rural'
        )
      )
    }

    ### Yes (1) or No (2) columns
    vars_sim_nao <- c(
      'V0206',
      'V0213',
      'V0214',
      'V0215',
      'V0216',
      'V0217',
      'V0218',
      'V0219',
      'V0220',
      'V0221',
      'V0222',
      'V0301',
      'V0701'
    )

    # mutate only colnames present
    vars_sim_nao_present <- vars_sim_nao[vars_sim_nao %in% cols]
    arrw <- dplyr::mutate(
      arrw,
      dplyr::across(
        all_of(vars_sim_nao_present),
        ~ if_else(.x == '1', 'Sim', 'N\u00e3o')
      )
    )
    # arrw <- mutate_at(arrw,
    #                   .vars = vars_sim_nao_present,
    #                   .funs = add_sim_nao_labels)
    ## mutate(mtcars, across(all_of(cols_to_change), fchange))

    # arrw <- add_sim_nao_labels2(arrw, column_names = vars_sim_nao)
  }

  # YEAR 2000----------------------------------------------------------------
  if (year == 2000 & lang == 'pt') {
    # REGIAO METROPOLITANA
    if ('V1004' %in% cols) {
      arrw <- mutate(
        arrw,
        V1004 = case_when(
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
          V1004 ==
            '21' ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM de Florian\u00f3polis',
          V1004 == '22' ~ 'N\u00facleo Metropolitano da RM Vale do Itaja\u00ed',
          V1004 ==
            '23' ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM Vale do Itaja\u00ed',
          V1004 == '24' ~ 'Norte/Nordeste Catarinense',
          V1004 ==
            '25' ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM Norte/Nordeste Catarinense',
          V1004 == '26' ~ 'Porto Alegre',
          V1004 == '27' ~ 'Goi\u00e2nia',
          V1004 ==
            '28' ~ 'RIDE (Regi\u00e3o Integrada de Desenvolvimento do Distrito Federal e Entorno)'
        )
      )
    }

    # SITUACAO DO SETOR
    if ('V1005' %in% cols) {
      arrw <- mutate(
        arrw,
        V1005 = case_when(
          V1005 == '1' ~ '\u00c1rea urbanizada de vila ou cidade',
          V1005 == '2' ~ '\u00c1rea n\u00e3o urbanizada de vila ou cidade',
          V1005 == '3' ~ '\u00c1rea urbanizada isolada',
          V1005 == '4' ~ 'Rural - extens\u00e3o urbana',
          V1005 == '5' ~ 'Rural - povoado',
          V1005 == '6' ~ 'Rural - n\u00facleo',
          V1005 == '7' ~ 'Rural - outros aglomerados',
          V1005 == '8' ~ 'Rural - exclusive os aglomerados rurais'
        )
      )
    }

    # TIPO DO SETOR
    if ('V1007' %in% cols) {
      arrw <- mutate(
        arrw,
        V1007 = case_when(
          V1007 == '0' ~ 'Setor comum ou n\u00e3o especial',
          V1007 == '1' ~ 'Setor especial de aglomerado subnormal',
          V1007 ==
            '2' ~ 'Setor especial de quart\u00e9is, bases militares, etc.',
          V1007 == '3' ~ 'Setor especial de alojamento, acampamentos, etc.',
          V1007 ==
            '4' ~ 'Setor especial de embarca\u00e7\u00f5es, barcos, navios, etc.',
          V1007 == '5' ~ 'Setor especial de aldeia ind\u00edgena',
          V1007 ==
            '6' ~ 'Setor especial de penitenci\u00e1rias, col\u00f4nias penais, pres\u00eddios, cadeias, etc.',
          V1007 ==
            '7' ~ 'Setor especial de asilos, orfanatos, conventos, hospitais, etc.'
        )
      )
    }

    # ESPECIE DE DOMICILIO
    if ('V0201' %in% cols) {
      arrw <- mutate(
        arrw,
        V0201 = case_when(
          V0201 == '1' ~ 'Particular permanente',
          V0201 == '2' ~ 'Particular improvisado',
          V0201 == '3' ~ 'Coletivo'
        )
      )
    }

    # TIPO DO DOMICILIO
    if ('V0202' %in% cols) {
      arrw <- mutate(
        arrw,
        V0202 = case_when(
          V0202 == '1' ~ 'Casa',
          V0202 == '2' ~ 'Apartamento',
          V0202 == '3' ~ 'C\u00f4modo'
        )
      )
    }

    # CONDICAO DO DOMICILIO
    if ('V0205' %in% cols) {
      arrw <- mutate(
        arrw,
        V0205 = case_when(
          V0205 == '1' ~ 'Pr\u00f3prio, j\u00e1 pago',
          V0205 == '2' ~ 'Pr\u00f3prio, ainda pagando',
          V0205 == '3' ~ 'Alugado',
          V0205 == '4' ~ 'Cedido por empregador',
          V0205 == '5' ~ 'Cedido de outra forma',
          V0205 == '6' ~ 'Outra Condi\u00e7\u00e3o'
        )
      )
    }

    # CONDICAO DO TERRENO
    if ('V0206' %in% cols) {
      arrw <- mutate(
        arrw,
        V0206 = case_when(
          V0206 == '1' ~ 'Pr\u00f3prio',
          V0206 == '2' ~ 'Cedido',
          V0206 == '3' ~ 'Outra condi\u00e7\u00e3o'
        )
      )
    }

    # FORMA DE ABASTECIMENTO DE AGUA
    if ('V0207' %in% cols) {
      arrw <- mutate(
        arrw,
        V0207 = case_when(
          V0207 == '1' ~ 'Rede geral',
          V0207 == '2' ~ 'Po\u00e7o ou nascente (na propriedade)',
          V0207 == '3' ~ 'Outra'
        )
      )
    }

    # TIPO DE CANALIZACAO
    if ('V0208' %in% cols) {
      arrw <- mutate(
        arrw,
        V0208 = case_when(
          V0208 == '1' ~ 'Canalizada em pelo menos um c\u00f4modo',
          V0208 == '2' ~ 'Canalizada s\u00f3 na propriedade ou terreno',
          V0208 == '3' ~ 'N\u00e3o canalizada'
        )
      )
    }

    # TIPO DE ESCOADOURO
    if ('V0211' %in% cols) {
      arrw <- mutate(
        arrw,
        V0211 = case_when(
          V0211 == '1' ~ 'Rede geral de esgoto ou pluvial',
          V0211 == '2' ~ 'Fossa s\u00e9ptica',
          V0211 == '3' ~ 'Fossa rudimentar',
          V0211 == '4' ~ 'Vala',
          V0211 == '5' ~ 'Rio, lago ou mar',
          V0211 == '6' ~ 'Outro escoadouro'
        )
      )
    }

    # COLETA DE LIXO
    if ('V0212' %in% cols) {
      arrw <- mutate(
        arrw,
        V0212 = case_when(
          V0212 == '1' ~ 'Coletado por servi\u00e7o de limpeza',
          V0212 == '2' ~ 'Colocado em ca\u00e7amba de servi\u00e7o de limpeza',
          V0212 == '3' ~ 'Queimado (na propriedade)',
          V0212 == '4' ~ 'Enterrado (na propriedade)',
          V0212 == '5' ~ 'Jogado em terreno baldio ou logradouro',
          V0212 == '6' ~ 'Jogado em rio, lago ou mar',
          V0212 == '7' ~ 'Tem outro destino'
        )
      )
    }

    # NUMERO DE AUTOMOVEIS PARA USO PARTICULAR
    # NOTE: V0222 is stored as an integer in the 2000 file, while V0223 below
    # is a string. The comparisons follow each column's own type.
    if ('V0222' %in% cols) {
      arrw <- mutate(
        arrw,
        V0222 = case_when(
          V0222 == 0 ~ 'N\u00e3o tem',
          V0222 == 1 ~ '1 autom\u00f3vel',
          V0222 == 2 ~ '2 autom\u00f3veis',
          V0222 == 3 ~ '3 autom\u00f3veis',
          V0222 == 4 ~ '4 autom\u00f3veis',
          V0222 == 5 ~ '5 autom\u00f3veis',
          V0222 == 6 ~ '6 autom\u00f3veis',
          V0222 == 7 ~ '7 autom\u00f3veis',
          V0222 == 8 ~ '8 autom\u00f3veis',
          V0222 == 9 ~ '9 ou mais autom\u00f3veis'
        )
      )
    }

    # NUMERO DE APARELHOS DE AR-CONDICIONADO
    if ('V0223' %in% cols) {
      arrw <- mutate(
        arrw,
        V0223 = case_when(
          V0223 == '0' ~ 'N\u00e3o tem',
          V0223 == '1' ~ '1 aparelho',
          V0223 == '2' ~ '2 aparelhos',
          V0223 == '3' ~ '3 aparelhos',
          V0223 == '4' ~ '4 aparelhos',
          V0223 == '5' ~ '5 aparelhos',
          V0223 == '6' ~ '6 aparelhos',
          V0223 == '7' ~ '7 aparelhos',
          V0223 == '8' ~ '8 aparelhos',
          V0223 == '9' ~ '9 ou mais aparelhos'
        )
      )
    }

    # CHARACTERISTICS OF THE SURROUNDINGS
    # NOTE: the 2000 file stores these three columns in lower case
    # ('v1111', 'v1112', 'v1113'), unlike every other variable of this
    # census. They also carry a '.' for households where the question does
    # not apply (collective households), which is left unlabelled.

    # EXISTENCIA DE IDENTIFICACAO DO LOGRADOURO
    if ('v1111' %in% cols) {
      arrw <- mutate(
        arrw,
        v1111 = case_when(
          v1111 == '1' ~ 'Sim',
          v1111 == '2' ~ 'N\u00e3o',
          v1111 == '9' ~ 'Ignorado'
        )
      )
    }

    # EXISTENCIA DE ILUMINACAO PUBLICA
    if ('v1112' %in% cols) {
      arrw <- mutate(
        arrw,
        v1112 = case_when(
          v1112 == '1' ~ 'Sim',
          v1112 == '2' ~ 'N\u00e3o',
          v1112 == '9' ~ 'Ignorado'
        )
      )
    }

    # EXISTENCIA DE CALCAMENTO/PAVIMENTACAO
    if ('v1113' %in% cols) {
      arrw <- mutate(
        arrw,
        v1113 = case_when(
          v1113 == '1' ~ 'Total',
          v1113 == '2' ~ 'Parcial',
          v1113 == '3' ~ 'N\u00e3o Existe',
          v1113 == '9' ~ 'Ignorado'
        )
      )
    }

    ### Yes (1) or No (2) columns
    vars_sim_nao <- c(
      'V0210',
      'V0213',
      'V0214',
      'V0215',
      'V0216',
      'V0217',
      'V0218',
      'V0219',
      'V0220'
    )

    # mutate only colnames present
    vars_sim_nao_present <- vars_sim_nao[vars_sim_nao %in% cols]
    arrw <- dplyr::mutate(
      arrw,
      dplyr::across(
        all_of(vars_sim_nao_present),
        ~ if_else(.x == '1', 'Sim', 'N\u00e3o')
      )
    )
  } # nocov end

  return(arrw)
}
