# Add labels to categorical variables of household datasets
#' @keywords internal
add_labels_households <- function(
  arrw,
  year = parent.frame()$year,
  lang = 'pt'
) {
  # check input
  checkmate::assert_string(lang, pattern = 'pt', na.ok = TRUE)
  if (!(year %in% c(1960, 1970, 1980, 1991, 2000, 2010, 2022))) {
    cli::cli_abort(
      "Labels for this data are only available for the years c(1960, 1970, 1980, 1991, 2000, 2010, 2022)"
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
        V1006 == 1 ~ 'Urbana',
        V1006 == 2 ~ 'Rural'
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
          V4001 == 1 ~ 'Domic\u00edlio particular permanente ocupado',
          V4001 == 2 ~ 'Domic\u00edlio particular permanente ocupado sem entrevista realizada',
          V4001 == 5 ~ 'Domic\u00edlio particular improvisado ocupado',
          V4001 == 6 ~ 'Domic\u00edlio coletivo com morador'
        )
      )
    }

    # household type
    if ('V4002' %in% cols) {
      arrw <- mutate(
        arrw,
        V4002 = case_when(
          V4002 == 11 ~ 'Casa',
          V4002 == 12 ~ 'Casa de vila ou em condom\u00ednio',
          V4002 == 13 ~ 'Apartamento',
          V4002 == 14 ~ 'Habita\u00e7\u00e3o em: casa de c\u00f4modos, corti\u00e7o ou cabe\u00e7a de porco',
          V4002 == 15 ~ 'Oca ou maloca ',
          V4002 == 51 ~ 'Tenda ou barraca',
          V4002 == 52 ~ 'Dentro de estabelecimento',
          V4002 == 53 ~ 'Outro (vag\u00e3o, trailer, gruta, etc)',
          V4002 == 61 ~ 'Asilo, orfanato e similares  com morador',
          V4002 == 62 ~ 'Hotel, pens\u00e3o e similares com morador',
          V4002 == 63 ~ 'Alojamento de trabalhadores com morador',
          V4002 == 64 ~ 'Penitenci\u00e1ria, pres\u00eddio ou casa de deten\u00e7\u00e3o com morador',
          V4002 == 65 ~ 'Outro com morador'
        )
      )
    }

    # household tenure / occupancy status
    if ('V0201' %in% cols) {
      arrw <- mutate(
        arrw,
        V0201 = case_when(
          V0201 == 1 ~ 'Pr\u00f3prio de algum morador - j\u00e1 pago',
          V0201 == 2 ~ 'Pr\u00f3prio de algum morador - ainda pagando',
          V0201 == 3 ~ 'Alugado',
          V0201 == 4 ~ 'Cedido por empregador',
          V0201 == 5 ~ 'Cedido de outra forma',
          V0201 == 6 ~ 'Outra condi\u00e7\u00e3o'
        )
      )
    }

    # material used to build household wall
    if ('V0202' %in% cols) {
      arrw <- mutate(
        arrw,
        V0202 = case_when(
          V0202 == 1 ~ 'Alvenaria com revestimento',
          V0202 == 2 ~ 'Alvenaria sem revestimento',
          V0202 == 3 ~ 'Madeira apropriada para constru\u00e7\u00e3o (aparelhada)',
          V0202 == 4 ~ 'Taipa revestida',
          V0202 == 5 ~ 'Taipa n\u00e3o revestida',
          V0202 == 6 ~ 'Madeira aproveitada',
          V0202 == 7 ~ 'Palha',
          V0202 == 8 ~ 'Outro material',
          V0202 == 9 ~ 'Sem parede'
        )
      )
    }

    # type of sanitation connection
    if ('V0207' %in% cols) {
      arrw <- mutate(
        arrw,
        V0207 = case_when(
          V0207 == 1 ~ 'Rede geral de esgoto ou pluvial',
          V0207 == 2 ~ 'Fossa s\u00e9ptica',
          V0207 == 3 ~ 'Fossa rudimentar',
          V0207 == 4 ~ 'Vala',
          V0207 == 5 ~ 'Rio, lago ou mar',
          V0207 == 6 ~ 'Outro'
        )
      )
    }

    # access to water
    if ('V0208' %in% cols) {
      arrw <- mutate(
        arrw,
        V0208 = case_when(
          V0208 == 1 ~ 'Rede geral de distribui\u00e7\u00e3o',
          V0208 == 2 ~ 'Po\u00e7o ou nascente na propriedade',
          V0208 == 3 ~ 'Po\u00e7o ou nascente fora da propriedade',
          V0208 == 4 ~ 'Carro-pipa',
          V0208 == 5 ~ '\u00c1gua da chuva armazenada em cisterna',
          V0208 == 6 ~ '\u00c1gua da chuva armazenada de outra forma',
          V0208 == 7 ~ 'Rios, a\u00e7udes, lagos e igarap\u00e9s',
          V0208 == 8 ~ 'Outra',
          V0208 == 9 ~ 'Po\u00e7o ou nascente na aldeia',
          V0208 == 10 ~ 'Po\u00e7o ou nascente fora da aldeia'
        )
      )
    }

    # water connection
    if ('V0209' %in% cols) {
      arrw <- mutate(
        arrw,
        V0209 = case_when(
          V0209 == 1 ~ 'Sim, em pelo menos um c\u00f4modo',
          V0209 == 2 ~ 'Sim, s\u00f3 na propriedade ou terreno',
          V0209 == 3 ~ 'N\u00e3o'
        )
      )
    }

    # waste treatment
    if ('V0210' %in% cols) {
      arrw <- mutate(
        arrw,
        V0210 = case_when(
          V0210 == 1 ~ 'Coletado diretamente por servi\u00e7o de limpeza',
          V0210 == 2 ~ 'Colocado em ca\u00e7amba de servi\u00e7o de limpeza',
          V0210 == 3 ~ 'Queimado (na propriedade)',
          V0210 == 4 ~ 'Enterrado (na propriedade)',
          V0210 == 5 ~ 'Jogado em terreno baldio ou logradouro',
          V0210 == 6 ~ 'Jogado em rio, lago ou mar',
          V0210 == 7 ~ 'Tem outro destino'
        )
      )
    }

    # eletricity
    if ('V0211' %in% cols) {
      arrw <- mutate(
        arrw,
        V0211 = case_when(
          V0211 == 1 ~ 'Sim, de companhia distribuidora',
          V0211 == 2 ~ 'Sim, de outras fontes',
          V0211 == 3 ~ 'N\u00e3o existe energia el\u00e9trica'
        )
      )
    }

    # eletricity meter
    if ('V0212' %in% cols) {
      arrw <- mutate(
        arrw,
        V0212 = case_when(
          V0212 == 1 ~ 'Sim, de uso exclusivo',
          V0212 == 2 ~ 'Sim, de uso comum ',
          V0212 == 3 ~ 'N\u00e3o tem medidor ou rel\u00f3gio'
        )
      )
    }

    # shared household head
    if ('V0402' %in% cols) {
      arrw <- mutate(
        arrw,
        V0402 = case_when(
          V0402 == 1 ~ 'Apenas um morador',
          V0402 == 2 ~ 'Mais de um morador',
          V0402 == 9 ~ 'Ignorado'
        )
      )
    }

    # type of domestic / family
    if ('V6600' %in% cols) {
      arrw <- mutate(
        arrw,
        V6600 = case_when(
          V6600 == 1 ~ 'Unipessoal',
          V6600 == 2 ~ 'Nuclear',
          V6600 == 3 ~ 'Estendida',
          V6600 == 4 ~ 'Composta'
        )
      )
    }

    # adequate housing
    if ('V6210' %in% cols) {
      arrw <- mutate(
        arrw,
        V6210 = case_when(
          V6210 == 1 ~ 'Adequada',
          V6210 == 2 ~ 'Semi-adequada',
          V6210 == 3 ~ 'Inadequada'
        )
      )
    }

    # census tract type
    if ('V1005' %in% cols) {
      arrw <- mutate(
        arrw,
        V1005 = case_when(
          V1005 == 1 ~ '\u00c1rea urbanizada',
          V1005 == 2 ~ '\u00c1rea n\u00e3o urbanizada',
          V1005 == 3 ~ '\u00c1rea urbanizada isolada',
          V1005 == 4 ~ '\u00c1rea rural de extens\u00e3o urbana',
          V1005 == 5 ~ 'Aglomerado rural (povoado)',
          V1005 == 6 ~ 'Aglomerado rural (n\u00facleo)',
          V1005 == 7 ~ 'Aglomerado rural (outros)',
          V1005 == 8 ~ '\u00c1rea rural exclusive aglomerado rural'
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
        ~ if_else(.x == 1, 'Sim', 'N\u00e3o')
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
          V1004 == 1 ~ 'Bel\u00e9m',
          V1004 == 2 ~ 'Grande S\u00e3o Lu\u00eds',
          V1004 == 3 ~ 'Fortaleza',
          V1004 == 4 ~ 'Natal',
          V1004 == 5 ~ 'Recife',
          V1004 == 6 ~ 'Macei\u00f3',
          V1004 == 7 ~ 'Salvador',
          V1004 == 8 ~ 'Belo Horizonte',
          V1004 == 9 ~ 'Colar Metropolitano da RM de Belo Horizonte',
          V1004 == 10 ~ 'Vale do A\u00e7o',
          V1004 == 11 ~ 'Colar Metropolitano da RM do Vale do A\u00e7o',
          V1004 == 12 ~ 'Grande Vit\u00f3ria',
          V1004 == 13 ~ 'Rio de Janeiro',
          V1004 == 14 ~ 'S\u00e3o Paulo',
          V1004 == 15 ~ 'Baixada Santista',
          V1004 == 16 ~ 'Campinas',
          V1004 == 17 ~ 'Curitiba',
          V1004 == 18 ~ 'Londrina',
          V1004 == 19 ~ 'Maring\u00e1',
          V1004 == 20 ~ 'Florian\u00f3polis',
          V1004 == 21 ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM de Florian\u00f3polis',
          V1004 == 22 ~ 'N\u00facleo Metropolitano da RM Vale do Itaja\u00ed',
          V1004 == 23 ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM Vale do Itaja\u00ed',
          V1004 == 24 ~ 'Norte/Nordeste Catarinense',
          V1004 == 25 ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM Norte/Nordeste Catarinense',
          V1004 == 26 ~ 'Porto Alegre',
          V1004 == 27 ~ 'Goi\u00e2nia',
          V1004 == 28 ~ 'RIDE (Regi\u00e3o Integrada de Desenvolvimento do Distrito Federal e Entorno)'
        )
      )
    }

    # SITUACAO DO SETOR
    if ('V1005' %in% cols) {
      arrw <- mutate(
        arrw,
        V1005 = case_when(
          V1005 == 1 ~ '\u00c1rea urbanizada de vila ou cidade',
          V1005 == 2 ~ '\u00c1rea n\u00e3o urbanizada de vila ou cidade',
          V1005 == 3 ~ '\u00c1rea urbanizada isolada',
          V1005 == 4 ~ 'Rural - extens\u00e3o urbana',
          V1005 == 5 ~ 'Rural - povoado',
          V1005 == 6 ~ 'Rural - n\u00facleo',
          V1005 == 7 ~ 'Rural - outros aglomerados',
          V1005 == 8 ~ 'Rural - exclusive os aglomerados rurais'
        )
      )
    }

    # TIPO DO SETOR
    if ('V1007' %in% cols) {
      arrw <- mutate(
        arrw,
        V1007 = case_when(
          V1007 == 0 ~ 'Setor comum ou n\u00e3o especial',
          V1007 == 1 ~ 'Setor especial de aglomerado subnormal',
          V1007 == 2 ~ 'Setor especial de quart\u00e9is, bases militares, etc.',
          V1007 == 3 ~ 'Setor especial de alojamento, acampamentos, etc.',
          V1007 == 4 ~ 'Setor especial de embarca\u00e7\u00f5es, barcos, navios, etc.',
          V1007 == 5 ~ 'Setor especial de aldeia ind\u00edgena',
          V1007 == 6 ~ 'Setor especial de penitenci\u00e1rias, col\u00f4nias penais, pres\u00eddios, cadeias, etc.',
          V1007 == 7 ~ 'Setor especial de asilos, orfanatos, conventos, hospitais, etc.'
        )
      )
    }

    # ESPECIE DE DOMICILIO
    if ('V0201' %in% cols) {
      arrw <- mutate(
        arrw,
        V0201 = case_when(
          V0201 == 1 ~ 'Particular permanente',
          V0201 == 2 ~ 'Particular improvisado',
          V0201 == 3 ~ 'Coletivo'
        )
      )
    }

    # TIPO DO DOMICILIO
    if ('V0202' %in% cols) {
      arrw <- mutate(
        arrw,
        V0202 = case_when(
          V0202 == 1 ~ 'Casa',
          V0202 == 2 ~ 'Apartamento',
          V0202 == 3 ~ 'C\u00f4modo'
        )
      )
    }

    # CONDICAO DO DOMICILIO
    if ('V0205' %in% cols) {
      arrw <- mutate(
        arrw,
        V0205 = case_when(
          V0205 == 1 ~ 'Pr\u00f3prio, j\u00e1 pago',
          V0205 == 2 ~ 'Pr\u00f3prio, ainda pagando',
          V0205 == 3 ~ 'Alugado',
          V0205 == 4 ~ 'Cedido por empregador',
          V0205 == 5 ~ 'Cedido de outra forma',
          V0205 == 6 ~ 'Outra Condi\u00e7\u00e3o'
        )
      )
    }

    # CONDICAO DO TERRENO
    if ('V0206' %in% cols) {
      arrw <- mutate(
        arrw,
        V0206 = case_when(
          V0206 == 1 ~ 'Pr\u00f3prio',
          V0206 == 2 ~ 'Cedido',
          V0206 == 3 ~ 'Outra condi\u00e7\u00e3o'
        )
      )
    }

    # FORMA DE ABASTECIMENTO DE AGUA
    if ('V0207' %in% cols) {
      arrw <- mutate(
        arrw,
        V0207 = case_when(
          V0207 == 1 ~ 'Rede geral',
          V0207 == 2 ~ 'Po\u00e7o ou nascente (na propriedade)',
          V0207 == 3 ~ 'Outra'
        )
      )
    }

    # TIPO DE CANALIZACAO
    if ('V0208' %in% cols) {
      arrw <- mutate(
        arrw,
        V0208 = case_when(
          V0208 == 1 ~ 'Canalizada em pelo menos um c\u00f4modo',
          V0208 == 2 ~ 'Canalizada s\u00f3 na propriedade ou terreno',
          V0208 == 3 ~ 'N\u00e3o canalizada'
        )
      )
    }

    # TIPO DE ESCOADOURO
    if ('V0211' %in% cols) {
      arrw <- mutate(
        arrw,
        V0211 = case_when(
          V0211 == 1 ~ 'Rede geral de esgoto ou pluvial',
          V0211 == 2 ~ 'Fossa s\u00e9ptica',
          V0211 == 3 ~ 'Fossa rudimentar',
          V0211 == 4 ~ 'Vala',
          V0211 == 5 ~ 'Rio, lago ou mar',
          V0211 == 6 ~ 'Outro escoadouro'
        )
      )
    }

    # COLETA DE LIXO
    if ('V0212' %in% cols) {
      arrw <- mutate(
        arrw,
        V0212 = case_when(
          V0212 == 1 ~ 'Coletado por servi\u00e7o de limpeza',
          V0212 == 2 ~ 'Colocado em ca\u00e7amba de servi\u00e7o de limpeza',
          V0212 == 3 ~ 'Queimado (na propriedade)',
          V0212 == 4 ~ 'Enterrado (na propriedade)',
          V0212 == 5 ~ 'Jogado em terreno baldio ou logradouro',
          V0212 == 6 ~ 'Jogado em rio, lago ou mar',
          V0212 == 7 ~ 'Tem outro destino'
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
          V0223 == 0 ~ 'N\u00e3o tem',
          V0223 == 1 ~ '1 aparelho',
          V0223 == 2 ~ '2 aparelhos',
          V0223 == 3 ~ '3 aparelhos',
          V0223 == 4 ~ '4 aparelhos',
          V0223 == 5 ~ '5 aparelhos',
          V0223 == 6 ~ '6 aparelhos',
          V0223 == 7 ~ '7 aparelhos',
          V0223 == 8 ~ '8 aparelhos',
          V0223 == 9 ~ '9 ou mais aparelhos'
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
          v1111 == 1 ~ 'Sim',
          v1111 == 2 ~ 'N\u00e3o',
          v1111 == 9 ~ 'Ignorado'
        )
      )
    }

    # EXISTENCIA DE ILUMINACAO PUBLICA
    if ('v1112' %in% cols) {
      arrw <- mutate(
        arrw,
        v1112 = case_when(
          v1112 == 1 ~ 'Sim',
          v1112 == 2 ~ 'N\u00e3o',
          v1112 == 9 ~ 'Ignorado'
        )
      )
    }

    # EXISTENCIA DE CALCAMENTO/PAVIMENTACAO
    if ('v1113' %in% cols) {
      arrw <- mutate(
        arrw,
        v1113 = case_when(
          v1113 == 1 ~ 'Total',
          v1113 == 2 ~ 'Parcial',
          v1113 == 3 ~ 'N\u00e3o Existe',
          v1113 == 9 ~ 'Ignorado'
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
        ~ if_else(.x == 1, 'Sim', 'N\u00e3o')
      )
    )
  } # nocov end

  # YEAR 1960 ------------------------------------------------------------------
  if (year == 1960 & lang == 'pt') {
    # NOTE: labels transcribed from the 1960 households dictionary,
    # `data_dictionary(1960, "households")`, normalised to sentence case as in
    # the other blocks and identical to the household variables of the 1960
    # block in add_labels_population(). Unlike 2000/2010, the 1960 codes are
    # stored as integers, so comparisons below are numeric. Numeric variables
    # (V100, V112, V113, weights, ids and counts), the record-identification
    # and sample-design variables (V001-V004, censobr_estrato, censobr_upa,
    # censobr_usa), the censobr_diag_households_vars text column and the
    # geography codes code_muni_1960, V116 and V117 are left as they are.

    # FONTE DA INFORMACAO SOBRE O REGISTRO (variavel adicionada pelo censobr)
    if ('censobr_source' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        censobr_source = dplyr::case_when(
          censobr_source == 1 ~ 'Registro advindo da amostra de 1,27%',
          censobr_source == 2 ~ 'Registro advindo da amostra de 25%'
        )
      )
    }

    # ESPECIE DO DOMICILIO
    if ('V101' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V101 = dplyr::case_when(
          V101 == 1 ~ 'Domic\u00edlio particular \u00fanico',
          V101 == 2 ~ 'Domic\u00edlio particular 1\u00aa fam\u00edlia',
          V101 == 3 ~ 'Domic\u00edlio coletivo',
          V101 == 4 ~ 'Domic\u00edlio particular 2\u00aa fam\u00edlia',
          V101 == 5 ~ 'Domic\u00edlio particular 3\u00aa fam\u00edlia',
          V101 == 9 ~ 'Boletim individual'
        )
      )
    }

    # TIPO DO DOMICILIO
    if ('V102' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V102 = dplyr::case_when(
          V102 == 4 ~ 'Dur\u00e1vel',
          V102 == 5 ~ 'R\u00fastico',
          V102 == 6 ~ 'Improvisado',
          V102 == 7 ~ 'Ignorado'
        )
      )
    }

    # CONDICAO DE OCUPACAO
    if ('V103' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V103 = dplyr::case_when(
          V103 == 7 ~ 'Pr\u00f3prio',
          V103 == 8 ~ 'Alugado',
          V103 == 9 ~ 'Outra',
          V103 == 0 ~ 'Ignorado'
        )
      )
    }

    # ALUGUEL MENSAL (Cr$). Brackets follow the questionnaire (item D); the
    # dictionary prints the second bracket as 'de 500 a 1000'.
    if ('V104' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V104 = dplyr::case_when(
          V104 == 0 ~ 'At\u00e9 500',
          V104 == 1 ~ 'De 501 a 1000',
          V104 == 2 ~ 'De 1001 a 2000',
          V104 == 3 ~ 'De 2001 a 4000',
          V104 == 4 ~ 'De 4001 a 6000',
          V104 == 5 ~ 'De 6001 a 10000',
          V104 == 6 ~ 'De 10001 a 20000',
          V104 == 7 ~ 'De 20001 e mais',
          V104 == 8 ~ 'N\u00e3o paga aluguel',
          V104 == 9 ~ 'Ignorado'
        )
      )
    }

    # ABASTECIMENTO DE AGUA
    if ('V105' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V105 = dplyr::case_when(
          V105 == 9 ~ 'Rede geral com canaliza\u00e7\u00e3o interna',
          V105 == 0 ~ 'Rede geral com canaliza\u00e7\u00e3o externa',
          V105 == 1 ~ 'Po\u00e7o/nascente com canaliza\u00e7\u00e3o',
          V105 == 2 ~ 'Po\u00e7o/nascente sem canaliza\u00e7\u00e3o',
          V105 == 3 ~ 'Outra forma de abastecimento',
          V105 == 4 ~ 'Ignorada'
        )
      )
    }

    # INSTALACAO SANITARIA
    if ('V106' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V106 = dplyr::case_when(
          V106 == 4 ~ 'Rede de esgoto',
          V106 == 5 ~ 'Fossa ass\u00e9ptica',
          V106 == 6 ~ 'Fossa rudimentar',
          V106 == 7 ~ 'Outro escoadouro',
          V106 == 8 ~ 'N\u00e3o tem',
          V106 == 9 ~ 'Ignorado'
        )
      )
    }

    # FOGAO
    if ('V107' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V107 = dplyr::case_when(
          V107 == 9 ~ 'Lenha',
          V107 == 0 ~ 'Carv\u00e3o',
          V107 == 1 ~ 'El\u00e9trico',
          V107 == 2 ~ 'G\u00e1s',
          V107 == 3 ~ '\u00d3leo/querosene',
          V107 == 4 ~ 'N\u00e3o tem',
          V107 == 5 ~ 'Ignorado'
        )
      )
    }

    # ILUMINACAO ELETRICA
    if ('V108' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V108 = dplyr::case_when(
          V108 == 5 ~ 'Tem',
          V108 == 6 ~ 'N\u00e3o tem',
          V108 == 7 ~ 'Ignorado'
        )
      )
    }

    # RADIO
    if ('V109' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V109 = dplyr::case_when(
          V109 == 7 ~ 'Tem',
          V109 == 8 ~ 'N\u00e3o tem',
          V109 == 9 ~ 'Ignorado'
        )
      )
    }

    # GELADEIRA
    if ('V110' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V110 = dplyr::case_when(
          V110 == 9 ~ 'Tem',
          V110 == 0 ~ 'N\u00e3o tem',
          V110 == 1 ~ 'Ignorado'
        )
      )
    }

    # TELEVISAO
    if ('V111' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V111 = dplyr::case_when(
          V111 == 1 ~ 'Tem',
          V111 == 2 ~ 'N\u00e3o tem',
          V111 == 3 ~ 'Ignorado'
        )
      )
    }

    # UNIDADE DA FEDERACAO (1960 territorial division). Since the v0.7.0 data
    # release the 1960 files also carry code_state/abbrev_state/name_state built
    # from this same division (Guanabara, Fernando de Noronha, Serra dos
    # Aimores), so these labels duplicate name_state; they are kept because `uf`
    # is the raw census variable and can be selected on its own. Accents added
    # to the dictionary spellings.
    if ('uf' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        uf = dplyr::case_when(
          uf == 0 ~ 'Rond\u00f4nia',
          uf == 1 ~ 'Acre',
          uf == 2 ~ 'Amazonas',
          uf == 3 ~ 'Roraima',
          uf == 4 ~ 'Par\u00e1',
          uf == 6 ~ 'Amap\u00e1',
          uf == 10 ~ 'Maranh\u00e3o',
          uf == 12 ~ 'Piau\u00ed',
          uf == 14 ~ 'Cear\u00e1',
          uf == 17 ~ 'Rio Grande do Norte',
          uf == 19 ~ 'Para\u00edba',
          uf == 21 ~ 'Pernambuco',
          uf == 24 ~ 'Fernando de Noronha',
          uf == 25 ~ 'Alagoas',
          uf == 30 ~ 'Sergipe',
          uf == 31 ~ 'Bahia',
          uf == 40 ~ 'Minas Gerais',
          uf == 50 ~ 'Serra dos Aimor\u00e9s',
          uf == 51 ~ 'Esp\u00edrito Santo',
          uf == 52 ~ 'Rio de Janeiro',
          uf == 54 ~ 'Guanabara',
          uf == 60 ~ 'S\u00e3o Paulo',
          uf == 71 ~ 'Paran\u00e1',
          uf == 74 ~ 'Santa Catarina',
          uf == 81 ~ 'Rio Grande do Sul',
          uf == 91 ~ 'Mato Grosso',
          uf == 94 ~ 'Goi\u00e1s',
          uf == 97 ~ 'Distrito Federal'
        )
      )
    }

    # SITUACAO DE MORADIA
    if ('V118' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V118 = dplyr::case_when(
          V118 == 1 ~ 'Urbana',
          V118 == 3 ~ 'Suburbana',
          V118 == 5 ~ 'Rural'
        )
      )
    }

    # URBANO / RURAL (variavel adicionada pelo censobr)
    if ('censobr_urban' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        censobr_urban = dplyr::case_when(
          censobr_urban == 0 ~ 'Rural',
          censobr_urban == 1 ~ 'Urbana e suburbana'
        )
      )
    }

    # DIAGNOSTICO DE CONSISTENCIA DO REGISTRO (variavel adicionada pelo
    # censobr; only filled for records from the 1.27% sample)
    if ('censobr_diag_households' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        censobr_diag_households = dplyr::case_when(
          censobr_diag_households == 2 ~ 'Problema n\u00e3o corrigido, mas ignor\u00e1vel (valores inv\u00e1lidos, n\u00e3o listados no dicion\u00e1rio, marcados como missing)',
          censobr_diag_households == 3 ~ 'Registro n\u00e3o problem\u00e1tico'
        )
      )
    }
  }

  # YEAR 1970 ------------------------------------------------------------------
  if (year == 1970 & lang == 'pt') {
    # NOTE: labels transcribed from the 1970 households dictionary,
    # `data_dictionary(1970, "households")`, identical to the household
    # variables of the 1970 block in add_labels_population() (see there for
    # the questionnaire cross-checks). Codes are stored as doubles, so the
    # comparisons below are numeric. V006 (condicao da familia) is not
    # labelled: in the households file it is a per-dwelling average of the
    # person-level codes and takes ~260 distinct values. V004 also carries a
    # few dozen fractional averages, which become NA.

    # SITUACAO DO DOMICILIO. The dictionary writes these in the masculine
    # ('URBANO', 'SUBURBANO'); the questionnaire prints 'Urbana', 'Suburbana',
    # 'Rural', which is used here and in every other census year.
    if ('V004' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V004 = dplyr::case_when(
          V004 == 0 ~ 'Urbana',
          V004 == 1 ~ 'Suburbana',
          V004 == 2 ~ 'Rural'
        )
      )
    }

    # ESPECIE DO DOMICILIO
    if ('V007' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V007 = dplyr::case_when(
          V007 == 0 ~ 'Particular',
          V007 == 1 ~ 'Coletivo'
        )
      )
    }

    # TIPO DO DOMICILIO
    if ('V008' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V008 = dplyr::case_when(
          V008 == 0 ~ 'Dur\u00e1vel',
          V008 == 1 ~ 'R\u00fastico',
          V008 == 2 ~ 'Improvisado'
        )
      )
    }

    # CONDICAO DE OCUPACAO
    if ('V009' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V009 = dplyr::case_when(
          V009 == 1 ~ 'Pr\u00f3prio j\u00e1 pago',
          V009 == 2 ~ 'Pr\u00f3prio em aquisi\u00e7\u00e3o',
          V009 == 3 ~ 'Alugado',
          V009 == 4 ~ 'Cedido',
          V009 == 5 ~ 'Outra condi\u00e7\u00e3o',
          V009 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # ALUGUEL OU PRESTACAO MENSAL. The questionnaire (item 5) gives the brackets
    # in NCr$; the dictionary header calls them 'salarios minimos'.
    if ('V010' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V010 = dplyr::case_when(
          V010 == 1 ~ 'At\u00e9 15 NCr$',
          V010 == 2 ~ 'De 16 a 30 NCr$',
          V010 == 3 ~ 'De 31 a 60 NCr$',
          V010 == 4 ~ 'De 61 a 120 NCr$',
          V010 == 5 ~ 'De 121 a 240 NCr$',
          V010 == 6 ~ 'De 241 a 480 NCr$',
          V010 == 7 ~ 'De 481 a 960 NCr$',
          V010 == 8 ~ 'De 961 NCr$ e mais',
          V010 == 9 ~ 'N\u00e3o paga aluguel',
          V010 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # TEMPO DE RESIDENCIA NO DOMICILIO
    if ('V011' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V011 = dplyr::case_when(
          V011 == 1 ~ 'Menos de 1 ano',
          V011 == 2 ~ '1 ano',
          V011 == 3 ~ '2 anos',
          V011 == 4 ~ 'De 3 a 6 anos',
          V011 == 5 ~ 'De 7 a 10 anos',
          V011 == 6 ~ 'De 11 anos e mais',
          V011 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FORMA DE ABASTECIMENTO DE AGUA
    if ('V012' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V012 = dplyr::case_when(
          V012 == 1 ~ 'Rede geral com canaliza\u00e7\u00e3o interna',
          V012 == 2 ~ 'Rede geral sem canaliza\u00e7\u00e3o interna',
          V012 == 3 ~ 'Po\u00e7o ou nascente com canaliza\u00e7\u00e3o interna',
          V012 == 4 ~ 'Po\u00e7o ou nascente sem canaliza\u00e7\u00e3o interna',
          V012 == 5 ~ 'Outra forma',
          V012 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # TIPO DE INSTALACAO SANITARIA
    if ('V013' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V013 = dplyr::case_when(
          V013 == 1 ~ 'Rede geral de esgoto',
          V013 == 2 ~ 'Fossa s\u00e9ptica',
          V013 == 3 ~ 'Fossa rudimentar',
          V013 == 4 ~ 'Outro escoadouro',
          V013 == 5 ~ 'N\u00e3o tem',
          V013 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FOGAO
    if ('V015' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V015 = dplyr::case_when(
          V015 == 1 ~ 'Lenha',
          V015 == 2 ~ 'G\u00e1s',
          V015 == 3 ~ 'Carv\u00e3o',
          V015 == 4 ~ '\u00d3leo ou querosene',
          V015 == 5 ~ 'El\u00e9trico',
          V015 == 6 ~ 'N\u00e3o tem',
          V015 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # ILUMINACAO ELETRICA (V014), RADIO (V016), GELADEIRA (V017), TELEVISAO
    # (V018), AUTOMOVEL (V019)
    tem_vars_1970 <- c('V014', 'V016', 'V017', 'V018', 'V019')
    tem_vars_1970 <- tem_vars_1970[tem_vars_1970 %in% cols]
    if (length(tem_vars_1970) > 0) {
      arrw <- dplyr::mutate(
        arrw,
        dplyr::across(
          all_of(tem_vars_1970),
          ~ case_when(
            .x == 1 ~ 'Tem',
            .x == 2 ~ 'N\u00e3o tem',
            .x == 0 ~ 'Sem declara\u00e7\u00e3o'
          )
        )
      )
    }
  }

  # YEAR 1980 ------------------------------------------------------------------
  if (year == 1980 & lang == 'pt') {
    # NOTE: labels transcribed from the 'households' sheet of the 1980
    # microdata dictionary (`data_dictionary(1980, "households")` /
    # `1980_dictionary_microdata.xlsx`), normalised to sentence case and
    # cross-checked against the 1980 sample questionnaire (CD 1.01). Identical
    # to the household variables of the 1980 block in add_labels_population().
    # Codes are stored as strings. Numeric variables (V211 tempo de residencia
    # in the auxiliary file, V212, V213, V602 aluguel, V603 peso, V601 id) and
    # the geography codes V2-V6 are left as they are.

    # SITUACAO DO DOMICILIO
    if ('V198' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V198 = dplyr::case_when(
          V198 == 1 ~ 'Cidade ou vila',
          V198 == 3 ~ '\u00c1rea urbana isolada',
          V198 == 5 ~ 'Aglomerado rural',
          V198 == 7 ~ 'Zona rural'
        )
      )
    }

    # ESPECIE DO DOMICILIO
    if ('V201' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V201 = dplyr::case_when(
          V201 == 1 ~ 'Particular permanente',
          V201 == 3 ~ 'Particular improvisado',
          V201 == 5 ~ 'Coletivo permanente',
          V201 == 7 ~ 'Coletivo improvisado'
        )
      )
    }

    # TIPO DO DOMICILIO
    if ('V202' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V202 = dplyr::case_when(
          V202 == 1 ~ 'Casa',
          V202 == 3 ~ 'Apartamento'
        )
      )
    }

    # PAREDES
    if ('V203' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V203 = dplyr::case_when(
          V203 == 2 ~ 'Alvenaria',
          V203 == 4 ~ 'Madeira',
          V203 == 6 ~ 'Taipa n\u00e3o revestida',
          V203 == 7 ~ 'Material aproveitado',
          V203 == 8 ~ 'Palha',
          V203 == 0 ~ 'Outro',
          V203 == 9 ~ 'Ignorado'
        )
      )
    }

    # PISO
    if ('V204' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V204 = dplyr::case_when(
          V204 == 1 ~ 'Madeira',
          V204 == 3 ~ 'Cer\u00e2mica',
          V204 == 4 ~ 'Cimento',
          V204 == 6 ~ 'Material aproveitado',
          V204 == 7 ~ 'Tijolo',
          V204 == 8 ~ 'Terra',
          V204 == 0 ~ 'Outro',
          V204 == 9 ~ 'Ignorado'
        )
      )
    }

    # COBERTURA
    if ('V205' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V205 = dplyr::case_when(
          V205 == 1 ~ 'Laje de concreto',
          V205 == 2 ~ 'Telha de barro',
          V205 == 3 ~ 'Telha de cimento-amianto',
          V205 == 4 ~ 'Zinco',
          V205 == 5 ~ 'Madeira',
          V205 == 6 ~ 'Palha',
          V205 == 7 ~ 'Material aproveitado',
          V205 == 0 ~ 'Outro',
          V205 == 9 ~ 'Ignorado'
        )
      )
    }

    # ABASTECIMENTO DE AGUA
    if ('V206' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V206 = dplyr::case_when(
          V206 == 1 ~ 'Com canaliza\u00e7\u00e3o interna - rede geral',
          V206 == 3 ~ 'Com canaliza\u00e7\u00e3o interna - po\u00e7o ou nascente',
          V206 == 5 ~ 'Com canaliza\u00e7\u00e3o interna - outra forma',
          V206 == 6 ~ 'Sem canaliza\u00e7\u00e3o interna - rede geral',
          V206 == 7 ~ 'Sem canaliza\u00e7\u00e3o interna - po\u00e7o ou nascente',
          V206 == 0 ~ 'Sem canaliza\u00e7\u00e3o interna - outra forma',
          V206 == 9 ~ 'Ignorado'
        )
      )
    }

    # ESCOADOURO
    if ('V207' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V207 = dplyr::case_when(
          V207 == 2 ~ 'Rede geral',
          V207 == 4 ~ 'Fossa s\u00e9ptica',
          V207 == 6 ~ 'Fossa rudimentar',
          V207 == 0 ~ 'Outro',
          V207 == 8 ~ 'N\u00e3o tem',
          V207 == 9 ~ 'Ignorado'
        )
      )
    }

    # USO DA INSTALACAO SANITARIA
    if ('V208' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V208 = dplyr::case_when(
          V208 == 1 ~ 'S\u00f3 do domic\u00edlio',
          V208 == 3 ~ 'Comum a mais de um domic\u00edlio',
          V208 == 8 ~ 'N\u00e3o tem',
          V208 == 9 ~ 'Ignorado'
        )
      )
    }

    # CONDICAO DE OCUPACAO
    if ('V209' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V209 = dplyr::case_when(
          V209 == 1 ~ 'Pr\u00f3prio - j\u00e1 acabou de pagar',
          V209 == 3 ~ 'Pr\u00f3prio - n\u00e3o acabou de pagar',
          V209 == 5 ~ 'Alugado',
          V209 == 6 ~ 'Cedido por empregador',
          V209 == 7 ~ 'Cedido por particular',
          V209 == 0 ~ 'Outra',
          V209 == 9 ~ 'Ignorado'
        )
      )
    }

    # PARA COZINHAR USA
    if ('V214' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V214 = dplyr::case_when(
          V214 == 1 ~ 'Fog\u00e3o',
          V214 == 3 ~ 'Fog\u00e3o improvisado',
          V214 == 5 ~ 'Fogareiro',
          V214 == 8 ~ 'N\u00e3o tem',
          V214 == 9 ~ 'Ignorado'
        )
      )
    }

    # COMBUSTIVEL USADO NA COZINHA
    if ('V215' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V215 = dplyr::case_when(
          V215 == 1 ~ 'G\u00e1s de botij\u00e3o',
          V215 == 2 ~ 'G\u00e1s canalizado',
          V215 == 3 ~ 'Lenha',
          V215 == 4 ~ 'Carv\u00e3o',
          V215 == 5 ~ '\u00d3leo ou querosene',
          V215 == 6 ~ '\u00c1lcool',
          V215 == 7 ~ 'Eletricidade',
          V215 == 8 ~ 'N\u00e3o tem',
          V215 == 9 ~ 'Ignorado'
        )
      )
    }

    # ILUMINACAO ELETRICA
    if ('V217' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V217 = dplyr::case_when(
          V217 == 2 ~ 'Tem - com medidor',
          V217 == 4 ~ 'Tem - sem medidor',
          V217 == 8 ~ 'N\u00e3o tem',
          V217 == 9 ~ 'Ignorado'
        )
      )
    }

    # TELEVISAO
    if ('V220' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V220 = dplyr::case_when(
          V220 == 1 ~ 'A cores',
          V220 == 3 ~ 'A cores e preto e branco',
          V220 == 5 ~ 'Preto e branco',
          V220 == 8 ~ 'N\u00e3o tem',
          V220 == 9 ~ 'Ignorado'
        )
      )
    }

    # AUTOMOVEL
    if ('V221' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V221 = dplyr::case_when(
          V221 == 1 ~ 'Tem - para uso particular',
          V221 == 3 ~ 'Tem - para trabalho',
          V221 == 8 ~ 'N\u00e3o tem',
          V221 == 9 ~ 'Ignorado'
        )
      )
    }

    # TELEFONE (V216), RADIO (V218), GELADEIRA (V219)
    tem_vars_1980 <- c('V216', 'V218', 'V219')
    tem_vars_1980 <- tem_vars_1980[tem_vars_1980 %in% cols]
    if (length(tem_vars_1980) > 0) {
      arrw <- dplyr::mutate(
        arrw,
        dplyr::across(
          all_of(tem_vars_1980),
          ~ case_when(
            .x == 1 ~ 'Tem',
            .x == 8 ~ 'N\u00e3o tem',
            .x == 9 ~ 'Ignorado'
          )
        )
      )
    }
  }

  # YEAR 1991 ------------------------------------------------------------------
  if (year == 1991 & lang == 'pt') {
    # NOTE: labels transcribed from the 'households' sheet of the 1991
    # microdata dictionary (`data_dictionary(1991, "households")` /
    # `1991_dictionary_microdata.xlsx`), normalised to sentence case and
    # cross-checked against the 1991 sample questionnaire (CD 1.02), which
    # agrees with it. Identical to the household variables of the 1991 block
    # in add_labels_population(). Every labelled variable is stored as a
    # string. Numeric variables (V0209 aluguel, V0211-V0213 comodos e
    # banheiros, V2012, V2111, V2121, V0111, V0112, weights, ids), the record
    # fields V0098/V0099 and the geography codes V1101, V1102, V7001, V7002 and
    # V7004 are left as they are.

    # SITUACAO DO DOMICILIO
    if ('V1061' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V1061 = dplyr::case_when(
          V1061 == 1 ~ '\u00c1rea urbanizada',
          V1061 == 2 ~ '\u00c1rea n\u00e3o urbanizada',
          V1061 == 3 ~ '\u00c1rea urbana isolada',
          V1061 == 4 ~ 'Aglomerado rural de extens\u00e3o urbana',
          V1061 == 5 ~ 'Aglomerado rural isolado ou povoado',
          V1061 == 6 ~ 'Aglomerado rural isolado ou n\u00facleo',
          V1061 == 7 ~ 'Outros aglomerados',
          V1061 == 8 ~ '\u00c1rea rural (exclusive aglomerado rural)'
        )
      )
    }

    # REGIAO METROPOLITANA
    if ('V7003' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V7003 = dplyr::case_when(
          V7003 == 0 ~ 'N\u00e3o metropolitana',
          V7003 == 1 ~ 'Bel\u00e9m',
          V7003 == 2 ~ 'Fortaleza',
          V7003 == 3 ~ 'Recife',
          V7003 == 4 ~ 'Salvador',
          V7003 == 5 ~ 'Belo Horizonte',
          V7003 == 6 ~ 'Rio de Janeiro',
          V7003 == 7 ~ 'S\u00e3o Paulo',
          V7003 == 8 ~ 'Curitiba',
          V7003 == 9 ~ 'Porto Alegre'
        )
      )
    }

    # ESPECIE DO DOMICILIO
    if ('V0201' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0201 = dplyr::case_when(
          V0201 == 1 ~ 'Particular permanente',
          V0201 == 2 ~ 'Particular improvisado',
          V0201 == 3 ~ 'Coletivo'
        )
      )
    }

    # LOCALIZACAO
    if ('V0202' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0202 = dplyr::case_when(
          V0202 == 1 ~ 'Casa isolada ou de condom\u00ednio',
          V0202 == 2 ~ 'Casa em conjunto residencial popular',
          V0202 == 3 ~ 'Casa em aglomerado subnormal',
          V0202 == 4 ~ 'Apartamento isolado ou de condom\u00ednio',
          V0202 == 5 ~ 'Apartamento em conjunto residencial popular',
          V0202 == 6 ~ 'Apartamento em aglomerado subnormal',
          V0202 == 7 ~ 'C\u00f4modos'
        )
      )
    }

    # PAREDES
    if ('V0203' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0203 = dplyr::case_when(
          V0203 == 1 ~ 'Alvenaria',
          V0203 == 2 ~ 'Madeira aparelhada',
          V0203 == 3 ~ 'Taipa n\u00e3o revestida',
          V0203 == 4 ~ 'Material aproveitado',
          V0203 == 5 ~ 'Palha',
          V0203 == 6 ~ 'Outro'
        )
      )
    }

    # COBERTURA
    if ('V0204' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0204 = dplyr::case_when(
          V0204 == 1 ~ 'Laje de concreto',
          V0204 == 2 ~ 'Telha de barro',
          V0204 == 3 ~ 'Telha de cimento-amianto',
          V0204 == 4 ~ 'Zinco',
          V0204 == 5 ~ 'Madeira aparelhada',
          V0204 == 6 ~ 'Palha',
          V0204 == 7 ~ 'Material aproveitado',
          V0204 == 8 ~ 'Outro'
        )
      )
    }

    # ABASTECIMENTO DE AGUA
    if ('V0205' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0205 = dplyr::case_when(
          V0205 == 1 ~ 'Rede geral com canaliza\u00e7\u00e3o interna',
          V0205 == 2 ~ 'Po\u00e7o ou nascente com canaliza\u00e7\u00e3o interna',
          V0205 == 3 ~ 'Outra forma com canaliza\u00e7\u00e3o interna',
          V0205 == 4 ~ 'Rede geral sem canaliza\u00e7\u00e3o interna',
          V0205 == 5 ~ 'Po\u00e7o ou nascente sem canaliza\u00e7\u00e3o interna',
          V0205 == 6 ~ 'Outra forma sem canaliza\u00e7\u00e3o interna'
        )
      )
    }

    # INSTALACAO SANITARIA
    if ('V0206' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0206 = dplyr::case_when(
          V0206 == 0 ~ 'N\u00e3o tem',
          V0206 == 1 ~ 'Rede geral',
          V0206 == 2 ~ 'Fossa s\u00e9ptica ligada \u00e0 rede pluvial',
          V0206 == 3 ~ 'Fossa s\u00e9ptica sem escoadouro',
          V0206 == 4 ~ 'Fossa rudimentar',
          V0206 == 5 ~ 'Vala negra',
          V0206 == 6 ~ 'Outro',
          V0206 == 7 ~ 'N\u00e3o sabe'
        )
      )
    }

    # USO DA INSTALACAO SANITARIA
    if ('V0207' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0207 = dplyr::case_when(
          V0207 == 0 ~ 'N\u00e3o tem',
          V0207 == 1 ~ 'S\u00f3 do domic\u00edlio',
          V0207 == 2 ~ 'Comum a mais de um domic\u00edlio'
        )
      )
    }

    # CONDICAO DE OCUPACAO DO DOMICILIO
    if ('V0208' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0208 = dplyr::case_when(
          V0208 == 1 ~ 'Pr\u00f3prio - a constru\u00e7\u00e3o e o terreno',
          V0208 == 2 ~ 'Pr\u00f3prio - s\u00f3 a constru\u00e7\u00e3o',
          V0208 == 3 ~ 'Alugado',
          V0208 == 4 ~ 'Cedido por empregador',
          V0208 == 5 ~ 'Cedido por particular',
          V0208 == 6 ~ 'Outra'
        )
      )
    }

    # FAIXAS DE ALUGUEL MENSAL
    if ('V2094' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2094 = dplyr::case_when(
          V2094 == 0 ~ 'N\u00e3o paga',
          V2094 == 1 ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V2094 == 2 ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V2094 == 3 ~ 'Mais de 1/2 a 1 sal\u00e1rio m\u00ednimo',
          V2094 == 4 ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V2094 == 5 ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V2094 == 6 ~ 'Mais de 3 a 4 sal\u00e1rios m\u00ednimos',
          V2094 == 7 ~ 'Mais de 4 a 5 sal\u00e1rios m\u00ednimos',
          V2094 == 8 ~ 'Mais de 5 sal\u00e1rios m\u00ednimos',
          V2094 == 9 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # COMBUSTIVEL USADO PARA COZINHAR
    if ('V0210' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0210 = dplyr::case_when(
          V0210 == 0 ~ 'N\u00e3o tem fog\u00e3o ou fogareiro',
          V0210 == 1 ~ 'G\u00e1s canalizado',
          V0210 == 2 ~ 'S\u00f3 g\u00e1s de botij\u00e3o',
          V0210 == 3 ~ 'S\u00f3 lenha',
          V0210 == 4 ~ 'G\u00e1s de botij\u00e3o e lenha',
          V0210 == 5 ~ 'Carv\u00e3o',
          V0210 == 6 ~ 'Outro'
        )
      )
    }

    # FAIXAS DE DENSIDADE DE MORADORES POR COMODO
    if ('V2112' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2112 = dplyr::case_when(
          V2112 == 1 ~ 'At\u00e9 0,5',
          V2112 == 2 ~ 'Mais de 0,5 a 1',
          V2112 == 3 ~ 'Mais de 1 a 1,5',
          V2112 == 4 ~ 'Mais de 1,5 a 2',
          V2112 == 5 ~ 'Mais de 2'
        )
      )
    }

    # FAIXAS DE DENSIDADE DE MORADORES POR DORMITORIO
    if ('V2122' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2122 = dplyr::case_when(
          V2122 == 1 ~ 'At\u00e9 1 morador',
          V2122 == 2 ~ 'Mais de 1 a 1,5 morador',
          V2122 == 3 ~ 'Mais de 1,5 a 2 moradores',
          V2122 == 4 ~ 'Mais de 2 a 2,5 moradores',
          V2122 == 5 ~ 'Mais de 2,5 a 3 moradores',
          V2122 == 6 ~ 'Mais de 3 a 4 moradores',
          V2122 == 7 ~ 'Mais de 4 moradores'
        )
      )
    }

    # DESTINO DO LIXO
    if ('V0214' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0214 = dplyr::case_when(
          V0214 == 1 ~ 'Coletado diretamente',
          V0214 == 2 ~ 'Coletado indiretamente',
          V0214 == 3 ~ 'Queimado',
          V0214 == 4 ~ 'Enterrado',
          V0214 == 5 ~ 'Jogado em terreno baldio',
          V0214 == 6 ~ 'Jogado em rio, lago ou mar',
          V0214 == 7 ~ 'Outro'
        )
      )
    }

    # TELEFONE
    if ('V0217' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0217 = dplyr::case_when(
          V0217 == 0 ~ 'N\u00e3o tem',
          V0217 == 1 ~ 'Uma linha',
          V0217 == 2 ~ 'Duas ou mais linhas'
        )
      )
    }

    # AUTOMOVEL PARTICULAR
    if ('V0218' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0218 = dplyr::case_when(
          V0218 == 0 ~ 'N\u00e3o tem',
          V0218 == 1 ~ 'Um carro',
          V0218 == 2 ~ 'Dois carros',
          V0218 == 3 ~ 'Tr\u00eas ou mais carros'
        )
      )
    }

    # AUTOMOVEL PARA TRABALHO
    if ('V0219' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0219 = dplyr::case_when(
          V0219 == 0 ~ 'N\u00e3o tem',
          V0219 == 1 ~ 'Pr\u00f3prio',
          V0219 == 2 ~ 'Cedido'
        )
      )
    }

    # ILUMINACAO
    if ('V0221' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0221 = dplyr::case_when(
          V0221 == 1 ~ 'El\u00e9trica com medidor',
          V0221 == 2 ~ 'El\u00e9trica sem medidor',
          V0221 == 3 ~ '\u00d3leo ou querosene',
          V0221 == 4 ~ 'Outra'
        )
      )
    }

    # GELADEIRA
    if ('V0222' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0222 = dplyr::case_when(
          V0222 == 0 ~ 'N\u00e3o tem',
          V0222 == 1 ~ 'Uma porta',
          V0222 == 2 ~ 'Mais de uma porta'
        )
      )
    }

    # TELEVISAO EM CORES
    if ('V0224' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0224 = dplyr::case_when(
          V0224 == 0 ~ 'N\u00e3o tem',
          V0224 == 1 ~ 'Um aparelho',
          V0224 == 2 ~ 'Dois aparelhos',
          V0224 == 3 ~ 'Tr\u00eas ou mais aparelhos'
        )
      )
    }

    # FAIXAS DE RENDIMENTO NOMINAL MEDIO MENSAL DOMICILIAR
    if ('V2013' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2013 = dplyr::case_when(
          V2013 == 1 ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V2013 == 2 ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V2013 == 3 ~ 'Mais de 1/2 a 1 sal\u00e1rio m\u00ednimo',
          V2013 == 4 ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V2013 == 5 ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V2013 == 6 ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V2013 == 7 ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V2013 == 8 ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V2013 == 9 ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V2013 == 10 ~ 'Mais de 20 a 30 sal\u00e1rios m\u00ednimos',
          V2013 == 11 ~ 'Mais de 30 sal\u00e1rios m\u00ednimos',
          V2013 == 12 ~ 'Sem rendimentos',
          V2013 == 13 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FAIXAS DE RENDIMENTO REAL MEDIO MENSAL DOMICILIAR
    if ('V2014' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2014 = dplyr::case_when(
          V2014 == 1 ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V2014 == 2 ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V2014 == 3 ~ 'Mais de 1/2 a 1 sal\u00e1rio m\u00ednimo',
          V2014 == 4 ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V2014 == 5 ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V2014 == 6 ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V2014 == 7 ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V2014 == 8 ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V2014 == 9 ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V2014 == 10 ~ 'Mais de 20 a 30 sal\u00e1rios m\u00ednimos',
          V2014 == 11 ~ 'Mais de 30 sal\u00e1rios m\u00ednimos',
          V2014 == 12 ~ 'Sem rendimentos',
          V2014 == 13 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FILTRO DE AGUA (V0216), RADIO (V0220), TELEVISAO PRETO E BRANCO (V0223),
    # FREEZER (V0225), MAQUINA DE LAVAR ROUPA (V0226), ASPIRADOR DE PO (V0227)
    tem_vars_1991 <- c('V0216', 'V0220', 'V0223', 'V0225', 'V0226', 'V0227')
    tem_vars_1991 <- tem_vars_1991[tem_vars_1991 %in% cols]
    if (length(tem_vars_1991) > 0) {
      arrw <- dplyr::mutate(
        arrw,
        dplyr::across(
          all_of(tem_vars_1991),
          ~ case_when(
            .x == 0 ~ 'N\u00e3o tem',
            .x == 1 ~ 'Tem'
          )
        )
      )
    }
  }

  return(arrw)
}
