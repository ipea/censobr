# Add labels to categorical variables of population datasets
#' @keywords internal
add_labels_population <- function(
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
  cols <- names(arrw)

  # ALL YEARS ------------------------------------------------------------------

  # urban vs rural
  if ('V1006' %in% cols) {
    arrw <- dplyr::mutate(
      arrw,
      V1006 = dplyr::case_when(
        V1006 == '1' ~ 'Urbana',
        V1006 == '2' ~ 'Rural'
      )
    )
  }

  # YEAR 2022 ------------------------------------------------------------------
  if (year == 2022 & lang == 'pt') {
    # NOTE: variable names follow the CD2022 PESS layout (Controlled Access).
    # Every block below checks var %in% cols first, so this same function
    # works on the Public Access layout too -- variables that only exist in
    # the Controlled Access version (e.g. P0080 municipio, P0111 peso amostral,
    # P0181/P0190 idade em numero, P0411 religiao detalhada, P0500/P0510/
    # P0580/P0590/P0620/P0630 municipio/pais codigo, P0750 area do curso,
    # P0820/P0830 municipio/pais de estudo, P0970/P0980 ocupacao/atividade
    # codigo, P1030/P1040 atividade/grande grupo ocupacional, P1140/P1150
    # municipio/pais de trabalho) are simply skipped when absent.

    # SITUACAO DO SETOR
    if ('P0120' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0120 = dplyr::case_when(
          P0120 ==
            1 ~ '\u00c1rea urbana de alta densidade de edifica\u00e7\u00f5es',
          P0120 ==
            2 ~ '\u00c1rea urbana de baixa densidade de edifica\u00e7\u00f5es',
          P0120 == 3 ~ 'N\u00facleo urbano',
          P0120 == 5 ~ 'Povoado',
          P0120 == 6 ~ 'N\u00facleo rural',
          P0120 == 7 ~ 'Lugarejo',
          P0120 == 8 ~ '\u00c1rea rural (exclusive aglomerados)'
        )
      )
    }

    # ESPECIE DA UNIDADE VISITADA
    if ('P0130' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0130 = dplyr::case_when(
          P0130 == 1 ~ 'Domic\u00edlio particular permanente ocupado',
          P0130 == 5 ~ 'Domic\u00edlio particular improvisado ocupado',
          P0130 == 6 ~ 'Domic\u00edlio coletivo com morador'
        )
      )
    }

    # SITUACAO DO DOMICILIO
    if ('P0140' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0140 = dplyr::case_when(
          P0140 == 1 ~ 'Urbana',
          P0140 == 2 ~ 'Rural'
        )
      )
    }

    # SEXO (UNIDADE DOMICILIAR)
    if ('P0150' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0150 = dplyr::case_when(
          P0150 == 1 ~ 'Masculino',
          P0150 == 2 ~ 'Feminino',
          P0150 == 9 ~ 'Ignorado'
        )
      )
    }

    # SEXO
    if ('P0160' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0160 = dplyr::case_when(
          P0160 == 1 ~ 'Masculino',
          P0160 == 2 ~ 'Feminino'
        )
      )
    }

    # CONDICAO NO DOMICILIO DA PESSOA
    if ('P0170' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0170 = dplyr::case_when(
          P0170 == 1 ~ 'Pessoa respons\u00e1vel pelo domic\u00edlio',
          P0170 == 2 ~ 'C\u00f4njuge ou companheiro(a) de sexo diferente',
          P0170 == 3 ~ 'C\u00f4njuge ou companheiro(a) do mesmo sexo',
          P0170 == 4 ~ 'Filho(a) do respons\u00e1vel e do c\u00f4njuge',
          P0170 == 5 ~ 'Filho(a) somente do respons\u00e1vel',
          P0170 == 6 ~ 'Enteado(a)',
          P0170 == 7 ~ 'Genro ou nora',
          P0170 == 8 ~ 'Pai, m\u00e3e, padrasto ou madrasta',
          P0170 == 9 ~ 'Sogro(a)',
          P0170 == 10 ~ 'Neto(a)',
          P0170 == 11 ~ 'Bisneto(a)',
          P0170 == 12 ~ 'Irm\u00e3o ou irm\u00e3',
          P0170 == 13 ~ 'Av\u00f4 ou av\u00f3',
          P0170 == 14 ~ 'Outro parente',
          P0170 == 15 ~ 'Agregado(a)',
          P0170 == 16 ~ 'Convivente',
          P0170 == 17 ~ 'Pensionista',
          P0170 == 18 ~ 'Empregado(a) dom\u00e9stico(a)',
          P0170 == 19 ~ 'Parente do(a) empregado(a) dom\u00e9stico(a)',
          P0170 == 20 ~ 'Individual em domic\u00edlio coletivo'
        )
      )
    }

    # IDADE CALCULADA EM ANOS DA PESSOA, CATEGORIA
    if ('P0180' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0180 = dplyr::case_when(
          P0180 == 1 ~ '0 a 4 anos',
          P0180 == 2 ~ '5 a 9 anos',
          P0180 == 3 ~ '10 a 14 anos',
          P0180 == 4 ~ '15 a 19 anos',
          P0180 == 5 ~ '20 a 24 anos',
          P0180 == 6 ~ '25 a 29 anos',
          P0180 == 7 ~ '30 a 34 anos',
          P0180 == 8 ~ '35 a 39 anos',
          P0180 == 9 ~ '40 a 44 anos',
          P0180 == 10 ~ '45 a 49 anos',
          P0180 == 11 ~ '50 a 54 anos',
          P0180 == 12 ~ '55 a 59 anos',
          P0180 == 13 ~ '60 a 64 anos',
          P0180 == 14 ~ '65 a 69 anos',
          P0180 == 15 ~ '70 a 74 anos',
          P0180 == 16 ~ '75 a 79 anos',
          P0180 == 17 ~ '80 anos ou mais',
          P0180 == 99 ~ 'Ignorado'
        )
      )
    }

    # FORMA DE DECLARACAO DE IDADE
    if ('P0200' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0200 = dplyr::case_when(
          P0200 == 1 ~ 'Data de nascimento',
          P0200 == 2 ~ 'Idade declarada'
        )
      )
    }

    # COR OU RACA DA PESSOA
    if ('P0210' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0210 = dplyr::case_when(
          P0210 == 1 ~ 'Branca',
          P0210 == 2 ~ 'Preta',
          P0210 == 3 ~ 'Amarela',
          P0210 == 4 ~ 'Parda',
          P0210 == 5 ~ 'Ind\u00edgena',
          P0210 == 9 ~ 'Ignorado'
        )
      )
    }

    # PESSOA INDIGENA
    if ('P0220' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0220 = dplyr::case_when(
          P0220 == 1 ~ 'Sim',
          P0220 == 0 ~ 'N\u00e3o',
          P0220 == 9 ~ 'Ignorado'
        )
      )
    }

    # STATUS DE DECLARACAO DE ETNIA
    if ('P0240' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0240 = dplyr::case_when(
          P0240 == 1 ~ 'Declarou uma etnia',
          P0240 == 2 ~ 'Declarou duas etnias',
          P0240 == 3 ~ 'Declara\u00e7\u00e3o n\u00e3o-determinada',
          P0240 == 4 ~ 'Declara\u00e7\u00e3o mal definida',
          P0240 == 5 ~ 'N\u00e3o sabe',
          P0240 == 6 ~ 'N\u00e3o declarou'
        )
      )
    }

    # STATUS DE DECLARACAO DE LINGUA INDIGENA
    if ('P0250' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0250 = dplyr::case_when(
          P0250 == 1 ~ 'Declarou uma l\u00edngua ind\u00edgena',
          P0250 == 2 ~ 'Declarou duas l\u00ednguas ind\u00edgenas',
          P0250 == 3 ~ 'Declarou tr\u00eas l\u00ednguas ind\u00edgenas',
          P0250 == 4 ~ 'Declara\u00e7\u00e3o n\u00e3o-determinada',
          P0250 == 5 ~ 'Declara\u00e7\u00e3o mal definida',
          P0250 == 6 ~ 'N\u00e3o sabe',
          P0250 ==
            7 ~ 'N\u00e3o fala l\u00edngua ind\u00edgena no domic\u00edlio'
        )
      )
    }

    # EXISTENCIA E TIPO DE REGISTRO DE NASCIMENTO DA PESSOA
    if ('P0270' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0270 = dplyr::case_when(
          P0270 == 1 ~ 'Do cart\u00f3rio',
          P0270 ==
            2 ~ 'Registro Administrativo de Nascimento Ind\u00edgena (RANI)',
          P0270 == 3 ~ 'N\u00e3o tem',
          P0270 == 4 ~ 'N\u00e3o sabe',
          P0270 == 9 ~ 'Ignorado'
        )
      )
    }

    # CONVIVENCIA COM CONJUGE OU COMPANHEIRO DA PESSOA
    if ('P0280' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0280 = dplyr::case_when(
          P0280 == 1 ~ 'Sim',
          P0280 == 2 ~ 'N\u00e3o, j\u00e1 viveu antes',
          P0280 == 3 ~ 'N\u00e3o, nunca viveu'
        )
      )
    }

    # NATUREZA DA UNIAO
    if ('P0290' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0290 = dplyr::case_when(
          P0290 == 1 ~ 'Casamento civil e religioso',
          P0290 == 2 ~ 'S\u00f3 casamento civil',
          P0290 == 3 ~ 'S\u00f3 casamento religioso',
          P0290 == 4 ~ 'Uni\u00e3o consensual'
        )
      )
    }

    # IDADE CALCULADA DO ULTIMO FILHO NASCIDO VIVO DA PESSOA, CATEGORIA
    if ('P0380' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0380 = dplyr::case_when(
          P0380 == 1 ~ '0 a 4 anos',
          P0380 == 2 ~ '5 a 9 anos',
          P0380 == 3 ~ '10 a 14 anos',
          P0380 == 4 ~ '15 a 19 anos',
          P0380 == 5 ~ '20 a 24 anos',
          P0380 == 6 ~ '25 a 29 anos',
          P0380 == 7 ~ '30 a 34 anos',
          P0380 == 8 ~ '35 a 39 anos',
          P0380 == 9 ~ '40 a 44 anos',
          P0380 == 10 ~ '45 a 49 anos',
          P0380 == 11 ~ '50 a 54 anos',
          P0380 == 12 ~ '55 a 59 anos',
          P0380 == 13 ~ '60 a 64 anos',
          P0380 == 14 ~ '65 a 69 anos',
          P0380 == 15 ~ '70 a 74 anos',
          P0380 == 16 ~ '75 a 79 anos',
          P0380 == 17 ~ '80 anos ou mais',
          P0380 == 99 ~ 'Ignorado'
        )
      )
    }

    # FORMA DE DECLARACAO DE IDADE DO ULTIMO FILHO TIDO NASCIDO VIVO
    if ('P0390' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0390 = dplyr::case_when(
          P0390 == 1 ~ 'Data de nascimento',
          P0390 == 2 ~ 'Idade declarada'
        )
      )
    }

    # RELIGIAO OU CULTO
    if ('P0410' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0410 = dplyr::case_when(
          P0410 == 1 ~ 'Cat\u00f3lica Apost\u00f3lica Romana',
          P0410 == 2 ~ 'Evang\u00e9licas',
          P0410 == 3 ~ 'Esp\u00edrita',
          P0410 == 4 ~ 'Umbanda e Candombl\u00e9',
          P0410 == 5 ~ 'Tradi\u00e7\u00f5es ind\u00edgenas',
          P0410 == 6 ~ 'Outras religiosidades',
          P0410 == 7 ~ 'Sem religi\u00e3o',
          P0410 == 8 ~ 'N\u00e3o sabe',
          P0410 == 9 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # RELIGIAO OU CULTO, CATEGORIA DETALHADA (SOMENTE ACESSO CONTROLADO)
    if ('P0411' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0411 = dplyr::case_when(
          P0411 == 1 ~ 'Cat\u00f3lica Apost\u00f3lica Romana',
          P0411 == 2 ~ 'Cat\u00f3lica Apost\u00f3lica Brasileira',
          P0411 == 3 ~ 'Cat\u00f3lica Ortodoxa',
          P0411 == 4 ~ 'Evang\u00e9licas de Miss\u00e3o',
          P0411 == 5 ~ 'Evang\u00e9licas de origem pentecostal',
          P0411 == 6 ~ 'Igrejas evang\u00e9licas ind\u00edgenas',
          P0411 == 7 ~ 'Evang\u00e9lica n\u00e3o determinada',
          P0411 == 8 ~ 'Outras religiosidades crist\u00e3s',
          P0411 ==
            9 ~ 'Igreja de Jesus Cristo dos Santos dos \u00daltimos Dias',
          P0411 == 10 ~ 'Testemunhas de Jeov\u00e1',
          P0411 == 11 ~ 'Espiritualista',
          P0411 == 12 ~ 'Esp\u00edrita',
          P0411 == 13 ~ 'Umbanda',
          P0411 == 14 ~ 'Candombl\u00e9',
          P0411 ==
            15 ~ 'Outras declara\u00e7\u00f5es de religiosidades afrobrasileira',
          P0411 == 16 ~ 'Juda\u00edsmo',
          P0411 == 17 ~ 'Hindu\u00edsmo',
          P0411 == 18 ~ 'Budismo',
          P0411 == 19 ~ 'Igreja Messi\u00e2nica Mundial',
          P0411 == 20 ~ 'Outras novas religi\u00f5es orientais',
          P0411 == 21 ~ 'Outras religi\u00f5es orientais',
          P0411 == 22 ~ 'Islamismo',
          P0411 == 23 ~ 'Tradi\u00e7\u00f5es esot\u00e9ricas',
          P0411 == 24 ~ 'Tradi\u00e7\u00f5es ind\u00edgenas',
          P0411 == 25 ~ 'Religi\u00f5es Ayahuasqueiras',
          P0411 == 26 ~ 'LBV',
          P0411 == 27 ~ 'Sem religi\u00e3o - Sem religi\u00e3o',
          P0411 == 28 ~ 'Sem religi\u00e3o - Ateu',
          P0411 == 29 ~ 'Sem religi\u00e3o - Agn\u00f3stico',
          P0411 == 30 ~ 'M\u00faltiplo pertencimento',
          P0411 == 31 ~ 'N\u00e3o determinada',
          P0411 == 32 ~ 'N\u00e3o sabe',
          P0411 == 33 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # EXISTENCIA DE DEFICIENCIA (VISUAL, AUDITIVA, MOTORA, DE PEGAR OBJETOS, MENTAL/INTELECTUAL)
    pd_vars_2022 <- c('P0420', 'P0430', 'P0440', 'P0450', 'P0460')
    pd_vars_2022 <- pd_vars_2022[pd_vars_2022 %in% cols]
    arrw <- dplyr::mutate(
      arrw,
      dplyr::across(
        all_of(pd_vars_2022),
        ~ case_when(
          .x == 1 ~ 'Tem, n\u00e3o consegue de modo algum',
          .x == 2 ~ 'Tem muita dificuldade',
          .x == 3 ~ 'Tem alguma dificuldade',
          .x == 4 ~ 'N\u00e3o tem dificuldade',
          .x == 9 ~ 'Ignorado'
        )
      )
    )

    # VARIAVEL INDICADORA DA EXISTENCIA DE DEFICIENCIA
    if ('P0470' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0470 = dplyr::case_when(
          P0470 == 1 ~ 'Pessoa COM Defici\u00eancia',
          P0470 == 2 ~ 'Pessoa SEM Defici\u00eancia',
          P0470 ==
            9 ~ 'N\u00e3o aplic\u00e1vel - Pessoa com menos de 2 anos de idade'
        )
      )
    }

    # LOCAL DE NASCIMENTO DA PESSOA
    if ('P0480' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0480 = dplyr::case_when(
          P0480 == 1 ~ 'Neste munic\u00edpio',
          P0480 == 2 ~ 'Em outro munic\u00edpio do Brasil',
          P0480 == 3 ~ 'Em outro pa\u00eds',
          P0480 == 9 ~ 'Ignorado'
        )
      )
    }

    # NACIONALIDADE DA PESSOA
    if ('P0520' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0520 = dplyr::case_when(
          P0520 == 1 ~ 'Brasileiro nato',
          P0520 == 2 ~ 'Naturalizado brasileiro',
          P0520 == 3 ~ 'Estrangeiro'
        )
      )
    }

    # UF E MUNICIPIO OU PAIS ESTRANGEIRO DE MORADIA ANTERIOR DA PESSOA
    if ('P0560' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0560 = dplyr::case_when(
          P0560 == 1 ~ 'Estado/Munic\u00edpio',
          P0560 == 2 ~ 'Pa\u00eds estrangeiro',
          P0560 == 9 ~ 'Ignorado'
        )
      )
    }

    # UF E MUNICIPIO OU PAIS ESTRANGEIRO DE MORADIA HA 5 ANOS DA PESSOA
    if ('P0600' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0600 = dplyr::case_when(
          P0600 == 1 ~ 'Neste munic\u00edpio',
          P0600 == 2 ~ 'Outro munic\u00edpio do Brasil',
          P0600 == 3 ~ 'Outro pa\u00eds',
          P0600 == 9 ~ 'Ignorado'
        )
      )
    }

    # FREQUENCIA ESCOLAR DA PESSOA
    if ('P0650' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0650 = dplyr::case_when(
          P0650 == 1 ~ 'Sim',
          P0650 == 2 ~ 'N\u00e3o, mas j\u00e1 frequentou',
          P0650 == 3 ~ 'N\u00e3o, nunca frequentou'
        )
      )
    }

    # CURSO FREQUENTADO PELA PESSOA
    if ('P0660' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0660 = dplyr::case_when(
          P0660 == 1 ~ 'Creche',
          P0660 == 2 ~ 'Pr\u00e9 escola',
          P0660 == 3 ~ 'Alfabetiza\u00e7\u00e3o de jovens e adultos',
          P0660 == 4 ~ 'Regular do ensino fundamental',
          P0660 ==
            5 ~ 'Educa\u00e7\u00e3o de jovens e adultos (EJA) do ensino fundamental',
          P0660 == 6 ~ 'Regular do ensino m\u00e9dio',
          P0660 ==
            7 ~ 'Educa\u00e7\u00e3o de jovens e adultos (EJA) do ensino m\u00e9dio',
          P0660 == 8 ~ 'Superior de gradua\u00e7\u00e3o',
          P0660 ==
            9 ~ 'Especializa\u00e7\u00e3o de n\u00edvel superior (dura\u00e7\u00e3o m\u00ednima de 360 horas)',
          P0660 == 10 ~ 'Mestrado',
          P0660 == 11 ~ 'Doutorado',
          P0660 == 99 ~ 'Ignorado'
        )
      )
    }

    # ANO DO CURSO FREQUENTADO PELA PESSOA
    if ('P0670' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0670 = dplyr::case_when(
          P0670 == 1 ~ 'Primeiro',
          P0670 == 2 ~ 'Segundo',
          P0670 == 3 ~ 'Terceiro',
          P0670 == 4 ~ 'Quarto',
          P0670 == 5 ~ 'Quinto',
          P0670 == 6 ~ 'Sexto',
          P0670 == 7 ~ 'S\u00e9timo',
          P0670 == 8 ~ 'Oitavo',
          P0670 == 9 ~ 'Nono',
          P0670 == 10 ~ 'Curso n\u00e3o classificado em anos',
          P0670 == 99 ~ 'Ignorado'
        )
      )
    }

    # SERIE DO CURSO FREQUENTADO PELA PESSOA
    if ('P0680' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0680 = dplyr::case_when(
          P0680 == 1 ~ 'Primeira',
          P0680 == 2 ~ 'Segunda',
          P0680 == 3 ~ 'Terceira',
          P0680 == 4 ~ 'Quarta',
          P0680 == 5 ~ 'Quinta',
          P0680 == 6 ~ 'Sexta',
          P0680 == 7 ~ 'S\u00e9tima',
          P0680 == 8 ~ 'Oitava',
          P0680 == 9 ~ 'Nona',
          P0680 == 10 ~ 'Curso n\u00e3o classificado em s\u00e9ries',
          P0680 == 99 ~ 'Ignorado'
        )
      )
    }

    # CURSO MAIS ELEVADO FREQUENTADO ANTERIORMENTE DA PESSOA
    if ('P0700' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0700 = dplyr::case_when(
          P0700 == 1 ~ 'Creche',
          P0700 == 2 ~ 'Pr\u00e9 escola',
          P0700 == 3 ~ 'Classe de alfabetiza\u00e7\u00e3o',
          P0700 == 4 ~ 'Alfabetiza\u00e7\u00e3o de jovens e adultos',
          P0700 == 5 ~ 'Antigo prim\u00e1rio (elementar)',
          P0700 == 6 ~ 'Antigo ginasial (m\u00e9dio 1\u00ba ciclo)',
          P0700 == 7 ~ 'Regular do ensino fundamental ou do 1\u00ba grau',
          P0700 ==
            8 ~ 'Educa\u00e7\u00e3o de jovens e adultos (EJA) do ensino fundamental ou supletivo do 1\u00ba grau',
          P0700 ==
            9 ~ 'Antigo cient\u00edfico, cl\u00e1ssico, etc. (m\u00e9dio 2\u00ba ciclo)',
          P0700 == 10 ~ 'Regular do ensino m\u00e9dio ou do 2\u00ba grau',
          P0700 ==
            11 ~ 'Educa\u00e7\u00e3o de jovens e adultos (EJA) do ensino m\u00e9dio ou supletivo do 2\u00ba grau',
          P0700 == 12 ~ 'Superior de gradua\u00e7\u00e3o',
          P0700 ==
            13 ~ 'Especializa\u00e7\u00e3o de n\u00edvel superior (dura\u00e7\u00e3o m\u00ednima de 360 horas)',
          P0700 == 14 ~ 'Mestrado',
          P0700 == 15 ~ 'Doutorado',
          P0700 == 99 ~ 'Ignorado'
        )
      )
    }

    # DURACAO DO CURSO FREQUENTADO ANTERIORMENTE DA PESSOA
    if ('P0710' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0710 = dplyr::case_when(
          P0710 == 1 ~ '8 s\u00e9ries',
          P0710 == 2 ~ '9 anos',
          P0710 == 9 ~ 'Ignorado'
        )
      )
    }

    # ULTIMO ANO CONCLUIDO COM APROVACAO NO CURSO FREQUENTADO ANTERIORMENTE
    if ('P0720' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0720 = dplyr::case_when(
          P0720 == 1 ~ 'Nenhum',
          P0720 == 2 ~ 'Primeiro',
          P0720 == 3 ~ 'Segundo',
          P0720 == 4 ~ 'Terceiro',
          P0720 == 5 ~ 'Quarto',
          P0720 == 6 ~ 'Quinto',
          P0720 == 7 ~ 'Sexto',
          P0720 == 8 ~ 'S\u00e9timo',
          P0720 == 9 ~ 'Oitavo',
          P0720 == 10 ~ 'Nono',
          P0720 == 11 ~ 'Curso n\u00e3o era classificado em anos',
          P0720 == 99 ~ 'Ignorado'
        )
      )
    }

    # ULTIMA SERIE CONCLUIDA COM APROVACAO NO CURSO FREQUENTADO ANTERIORMENTE
    if ('P0730' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0730 = dplyr::case_when(
          P0730 == 1 ~ 'Nenhuma',
          P0730 == 2 ~ 'Primeira',
          P0730 == 3 ~ 'Segunda',
          P0730 == 4 ~ 'Terceira',
          P0730 == 5 ~ 'Quarta',
          P0730 == 6 ~ 'Quinta',
          P0730 == 7 ~ 'Sexta',
          P0730 == 8 ~ 'S\u00e9tima',
          P0730 == 9 ~ 'Oitava',
          P0730 == 10 ~ 'Nona',
          P0730 == 11 ~ 'Curso n\u00e3o classificado em s\u00e9ries',
          P0730 == 99 ~ 'Ignorado'
        )
      )
    }

    # MORADOR, NIVEL DE INSTRUCAO DE ENSINO
    if ('P0760' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0760 = dplyr::case_when(
          P0760 == 1 ~ 'Sem instru\u00e7\u00e3o e menos de 1 ano',
          P0760 == 2 ~ 'Ensino fundamental incompleto ou equivalente',
          P0760 == 3 ~ 'Ensino fundamental completo ou equivalente',
          P0760 == 4 ~ 'Ensino m\u00e9dio incompleto ou equivalente',
          P0760 == 5 ~ 'Ensino m\u00e9dio completo ou equivalente',
          P0760 == 6 ~ 'Superior incompleto ou equivalente',
          P0760 == 7 ~ 'Superior completo',
          P0760 == 8 ~ 'N\u00e3o determinado',
          P0760 == 9 ~ 'Ignorado "se frequenta curso"',
          P0760 == 901 ~ 'Ignorado "curso que frequenta"',
          P0760 == 902 ~ 'Ignorado "ano/s\u00e9rie que frequenta"',
          P0760 ==
            903 ~ 'Ignorado "se concluiu outro curso de gradua\u00e7\u00e3o"',
          P0760 == 911 ~ 'Ignorado "curso que frequentou"',
          P0760 == 912 ~ 'Ignorado "se concluiu o curso que frequentou"',
          P0760 == 913 ~ 'Ignorado "ano/s\u00e9rie que frequentou"',
          P0760 ==
            914 ~ 'Ignorado "dura\u00e7\u00e3o do curso regular de Ensino Fundamental"'
        )
      )
    }

    # MORADOR, NIVEL DE INSTRUCAO DE ENSINO, COMPATIVEL COM O CENSO DEMOGRAFICO DE 2010
    if ('P0770' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0770 = dplyr::case_when(
          P0770 == 1 ~ 'Sem instru\u00e7\u00e3o e fundamental incompleto',
          P0770 == 2 ~ 'Fundamental completo e m\u00e9dio incompleto',
          P0770 == 3 ~ 'M\u00e9dio completo e superior incompleto',
          P0770 == 4 ~ 'Superior completo',
          P0770 == 5 ~ 'N\u00e3o determinado'
        )
      )
    }

    # VARIAVEL INDICADORA DE FREQUENCIA ESCOLAR EM NIVEL ADEQUADO A IDADE
    if ('P0780' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0780 = dplyr::case_when(
          P0780 == 1 ~ 'Adequado',
          P0780 == 2 ~ 'N\u00e3o adequado',
          P0780 ==
            9 ~ 'N\u00e3o aplic\u00e1vel - Pessoa com menos de 6 anos ou maior que 24 anos de idade'
        )
      )
    }

    # UF E MUNICIPIO OU PAIS ESTRANGEIRO DA ESCOLA DA PESSOA
    if ('P0800' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0800 = dplyr::case_when(
          P0800 == 1 ~ 'Neste munic\u00edpio',
          P0800 == 2 ~ 'Em outro munic\u00edpio do Brasil',
          P0800 == 3 ~ 'Em outro pa\u00eds',
          P0800 == 9 ~ 'Ignorado'
        )
      )
    }

    # TRABALHOS DA PESSOA
    if ('P0900' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0900 = dplyr::case_when(
          P0900 == 1 ~ 'Um',
          P0900 == 2 ~ 'Dois',
          P0900 == 3 ~ 'Tr\u00eas ou mais',
          P0900 == 9 ~ 'Ignorado'
        )
      )
    }

    # PESSOA DE 10 ANOS OU MAIS DE IDADE, CATEGORIA
    if ('P0910' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0910 = dplyr::case_when(
          P0910 == 0 ~ 'Pessoa de menos de 10 anos de idade',
          P0910 == 1 ~ 'Pessoa de 10 anos ou mais de idade'
        )
      )
    }

    # PESSOA DE 14 ANOS OU MAIS DE IDADE, CATEGORIA
    if ('P0920' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0920 = dplyr::case_when(
          P0920 == 0 ~ 'Pessoa de menos de 14 anos de idade',
          P0920 == 1 ~ 'Pessoa de 14 anos ou mais de idade'
        )
      )
    }

    # PESSOA DE 14 ANOS OU MAIS DE IDADE NA FORCA DE TRABALHO, CATEGORIA
    if ('P0930' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0930 = dplyr::case_when(
          P0930 ==
            0 ~ 'Pessoa de 14 anos ou mais de idade FORA da for\u00e7a de trabalho',
          P0930 ==
            1 ~ 'Pessoa de 14 anos ou mais de idade na for\u00e7a de trabalho'
        )
      )
    }

    # PESSOA DE 14 ANOS OU MAIS, OCUPADA, CONTRIBUINTE DE INSTITUTO DE PREVIDENCIA NO TRABALHO PRINCIPAL, CATEGORIA
    if ('P0940' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0940 = dplyr::case_when(
          P0940 ==
            0 ~ 'Pessoa de 14 anos ou mais de idade ocupada N\u00c3O contribuinte de instituto de previd\u00eancia no trabalho principal',
          P0940 ==
            1 ~ 'Pessoa de 14 anos ou mais de idade ocupada contribuinte de instituto de previd\u00eancia no trabalho principal'
        )
      )
    }

    # PESSOAS DE 14 ANOS OU MAIS OCUPADA, CATEGORIA
    if ('P0950' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0950 = dplyr::case_when(
          P0950 == 0 ~ 'Desocupada',
          P0950 == 1 ~ 'Ocupada'
        )
      )
    }

    # PESSOAS DE 10 ANOS OU MAIS OCUPADA, CATEGORIA
    if ('P0960' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0960 = dplyr::case_when(
          P0960 == 0 ~ 'N\u00e3o ocupada',
          P0960 == 1 ~ 'Ocupada'
        )
      )
    }

    # POSICAO NA OCUPACAO DO TRABALHO PRINCIPAL DA PESSOA
    if ('P0990' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P0990 = dplyr::case_when(
          P0990 == 1 ~ 'Trabalhador dom\u00e9stico (inclusive diarista)',
          P0990 ==
            2 ~ 'Militar do ex\u00e9rcito, da marinha, da aeron\u00e1utica, da pol\u00edcia militar ou do corpo de bombeiros militar',
          P0990 == 3 ~ 'Empregado do setor privado',
          P0990 ==
            4 ~ 'Empregado do setor p\u00fablico - funcion\u00e1rio estatut\u00e1rio',
          P0990 ==
            5 ~ 'Empregado do setor p\u00fablico - empregado n\u00e3o estatut\u00e1rio',
          P0990 == 6 ~ 'Empregado de empresas estatais',
          P0990 == 7 ~ 'Empregador (com pelo menos um empregado)',
          P0990 == 8 ~ 'Conta pr\u00f3pria (sem empregados)',
          P0990 ==
            9 ~ 'Trabalhador n\u00e3o remunerado em ajuda a morador do domic\u00edlio ou parente',
          P0990 == 99 ~ 'Ignorado'
        )
      )
    }

    # POSICAO NA OCUPACAO NO TRABALHO PRINCIPAL, SEMANA DE REFERENCIA, PESSOAS DE 10 ANOS OU MAIS
    if ('P1020' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P1020 = dplyr::case_when(
          P1020 ==
            1 ~ 'Empregado no setor privado COM carteira de trabalho assinada',
          P1020 ==
            2 ~ 'Empregado no setor privado SEM carteira de trabalho assinada',
          P1020 ==
            3 ~ 'Trabalhador dom\u00e9stico COM carteira de trabalho assinada',
          P1020 ==
            4 ~ 'Trabalhador dom\u00e9stico SEM carteira de trabalho assinada',
          P1020 ==
            5 ~ 'Empregado no setor p\u00fablico COM carteira de trabalho assinada',
          P1020 ==
            6 ~ 'Empregado no setor p\u00fablico SEM carteira de trabalho assinada',
          P1020 == 7 ~ 'Militar e servidor estatut\u00e1rio',
          P1020 == 8 ~ 'Empregador',
          P1020 == 9 ~ 'Conta pr\u00f3pria',
          P1020 == 10 ~ 'Trabalhador familiar auxiliar'
        )
      )
    }

    # ATIVIDADE PRINCIPAL, NO TRABALHO PRINCIPAL, SEMANA DE REFERENCIA, PESSOAS DE 10 ANOS OU MAIS (SOMENTE ACESSO CONTROLADO)
    if ('P1030' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P1030 = dplyr::case_when(
          P1030 ==
            1 ~ 'Agricultura, pecu\u00e1ria, produ\u00e7\u00e3o florestal, pesca e aquicultura',
          P1030 == 2 ~ 'Ind\u00fastrias extrativas',
          P1030 == 3 ~ 'Ind\u00fastrias de transforma\u00e7\u00e3o',
          P1030 == 4 ~ 'Eletricidade e g\u00e1s',
          P1030 ==
            5 ~ '\u00c1gua, esgoto, atividades de gest\u00e3o de res\u00edduos e descontamina\u00e7\u00e3o',
          P1030 == 6 ~ 'Constru\u00e7\u00e3o',
          P1030 ==
            7 ~ 'Com\u00e9rcio, repara\u00e7\u00e3o de ve\u00edculos automotores e motocicletas',
          P1030 == 8 ~ 'Transporte, armazenagem e correio',
          P1030 == 9 ~ 'Alojamento e alimenta\u00e7\u00e3o',
          P1030 == 10 ~ 'Informa\u00e7\u00e3o e comunica\u00e7\u00e3o',
          P1030 ==
            11 ~ 'Atividades financeiras, de seguros e servi\u00e7os relacionados',
          P1030 == 12 ~ 'Atividades imobili\u00e1rias',
          P1030 ==
            13 ~ 'Atividades profissionais, cient\u00edficas e t\u00e9cnicas',
          P1030 ==
            14 ~ 'Atividades administrativas e servi\u00e7os complementares',
          P1030 ==
            15 ~ 'Administra\u00e7\u00e3o p\u00fablica, defesa e seguridade social',
          P1030 == 16 ~ 'Educa\u00e7\u00e3o',
          P1030 == 17 ~ 'Sa\u00fade humana e servi\u00e7os sociais',
          P1030 == 18 ~ 'Artes, cultura, esporte e recrea\u00e7\u00e3o',
          P1030 == 19 ~ 'Outras atividades de servi\u00e7os',
          P1030 == 20 ~ 'Servi\u00e7os dom\u00e9sticos',
          P1030 ==
            21 ~ 'Organismos internacionais e outras institui\u00e7\u00f5es extraterritoriais',
          P1030 ==
            22 ~ 'Atividades mal definidas ou n\u00e3o especificadas (biscate)'
        )
      )
    }

    # GRANDES GRUPOS OCUPACIONAIS, TRABALHO PRINCIPAL, SEMANA DE REFERENCIA, PESSOAS DE 10 ANOS OU MAIS (SOMENTE ACESSO CONTROLADO)
    if ('P1040' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P1040 = dplyr::case_when(
          P1040 == 1 ~ 'Diretores e gerentes',
          P1040 == 2 ~ 'Profissionais das ci\u00eancias e intelectuais',
          P1040 == 3 ~ 'T\u00e9cnicos e profissionais de n\u00edvel m\u00e9dio',
          P1040 == 4 ~ 'Trabalhadores de apoio administrativo',
          P1040 ==
            5 ~ 'Trabalhadores dos servi\u00e7os, vendedores dos com\u00e9rcios e mercados',
          P1040 ==
            6 ~ 'Trabalhadores qualificados da agropecu\u00e1ria, florestais, da ca\u00e7a e da pesca',
          P1040 ==
            7 ~ 'Trabalhadores qualificados, oper\u00e1rios e artes\u00f5es da constru\u00e7\u00e3o, das artes mec\u00e2nicas e outros of\u00edcios',
          P1040 ==
            8 ~ 'Operadores de instala\u00e7\u00f5es e m\u00e1quinas e montadores',
          P1040 == 9 ~ 'Ocupa\u00e7\u00f5es elementares',
          P1040 ==
            10 ~ 'Membros das for\u00e7as armadas, policiais e bombeiros militares',
          P1040 == 11 ~ 'Ocupa\u00e7\u00f5es maldefinidas'
        )
      )
    }

    # TIPO DE RENDIMENTO BRUTO MENSAL HABITUALMENTE RECEBIDO EM TODOS OS TRABALHOS
    if ('P1070' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P1070 = dplyr::case_when(
          P1070 == 1 ~ 'Valor em dinheiro, produtos ou mercadorias',
          P1070 ==
            2 ~ 'Outra forma (Moradia, Alimenta\u00e7\u00e3o, Treinamento, etc.)'
        )
      )
    }

    # UF E MUNICIPIO OU PAIS ESTRANGEIRO DO LOCAL DE TRABALHO DA PESSOA
    if ('P1120' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P1120 = dplyr::case_when(
          P1120 == 1 ~ 'Em casa ou na propriedade',
          P1120 == 2 ~ 'Fora de casa e da propriedade',
          P1120 == 3 ~ 'Em outro munic\u00edpio do Brasil',
          P1120 == 4 ~ 'Em outro pa\u00eds',
          P1120 == 5 ~ 'Em mais de um munic\u00edpio ou pa\u00eds',
          P1120 == 9 ~ 'Ignorado'
        )
      )
    }

    # MEIO DE TRANSPORTE DE DESLOCAMENTO PARA O LOCAL DE TRABALHO DA PESSOA
    if ('P1170' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P1170 = dplyr::case_when(
          P1170 == 1 ~ 'A p\u00e9',
          P1170 == 2 ~ 'Bicicleta',
          P1170 == 3 ~ 'Motocicleta',
          P1170 == 4 ~ 'Motot\u00e1xi',
          P1170 == 5 ~ 'Autom\u00f3vel',
          P1170 == 6 ~ 'T\u00e1xi ou assemelhados',
          P1170 == 7 ~ 'Van, perua ou assemelhados',
          P1170 == 8 ~ '\u00d4nibus',
          P1170 == 9 ~ 'BRT ou \u00f4nibus de tr\u00e2nsito r\u00e1pido',
          P1170 == 10 ~ 'Trem ou metr\u00f4',
          P1170 == 11 ~ 'Caminhonete ou caminh\u00e3o adaptado (pau de arara)',
          P1170 ==
            12 ~ 'Embarca\u00e7\u00e3o de m\u00e9dio e grande porte (acima de 20 pessoas)',
          P1170 ==
            13 ~ 'Embarca\u00e7\u00e3o de pequeno porte (at\u00e9 20 pessoas)',
          P1170 == 14 ~ 'Outros',
          P1170 == 99 ~ 'Ignorado'
        )
      )
    }

    # TEMPO ENTRE A CASA E O LOCAL DE TRABALHO, CATEGORIA
    if ('P1180' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P1180 = dplyr::case_when(
          P1180 == 0 ~ 'N\u00e3o se desloca para local de trabalho',
          P1180 == 1 ~ 'At\u00e9 cinco minutos',
          P1180 == 2 ~ 'De seis minutos at\u00e9 quinze minutos',
          P1180 == 3 ~ 'Mais de quinze minutos at\u00e9 meia hora',
          P1180 == 4 ~ 'Mais de meia hora at\u00e9 uma hora',
          P1180 == 5 ~ 'Mais de uma hora at\u00e9 duas horas',
          P1180 == 6 ~ 'Mais de duas horas at\u00e9 quatro horas',
          P1180 == 7 ~ 'Mais de quatro horas',
          P1180 == 9 ~ 'Tempo n\u00e3o informado (ignorado)'
        )
      )
    }

    # QUEM PRESTOU AS INFORMACOES DA PESSOA
    if ('P1210' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        P1210 = dplyr::case_when(
          P1210 == 1 ~ 'A pr\u00f3pria pessoa',
          P1210 == 2 ~ 'Outro morador',
          P1210 == 3 ~ 'N\u00e3o morador',
          P1210 == 9 ~ 'Ignorado'
        )
      )
    }

    # VARIAVEIS SIM(1) / NAO(2), SEM CATEGORIA "IGNORADO"
    vars_sim_nao_2022 <- c(
      'P0260',
      'P0300',
      'P0310',
      'P0400',
      'P0640',
      'P1010',
      'P1200'
    )
    vars_sim_nao_2022 <- vars_sim_nao_2022[vars_sim_nao_2022 %in% cols]
    arrw <- dplyr::mutate(
      arrw,
      dplyr::across(
        all_of(vars_sim_nao_2022),
        ~ case_when(
          .x == 1 ~ 'Sim',
          .x == 2 ~ 'N\u00e3o'
        )
      )
    )

    # VARIAVEIS SIM(1) / NAO(2) / IGNORADO(9)
    vars_sim_nao_ignorado_2022 <- c(
      'P0230',
      'P0530',
      'P0690',
      'P0740',
      'P0840',
      'P0850',
      'P0860',
      'P0870',
      'P0880',
      'P0890',
      'P1000',
      'P1050',
      'P1060',
      'P1090',
      'P1160'
    )
    vars_sim_nao_ignorado_2022 <- vars_sim_nao_ignorado_2022[
      vars_sim_nao_ignorado_2022 %in% cols
    ]
    arrw <- dplyr::mutate(
      arrw,
      dplyr::across(
        all_of(vars_sim_nao_ignorado_2022),
        ~ case_when(
          .x == 1 ~ 'Sim',
          .x == 2 ~ 'N\u00e3o',
          .x == 9 ~ 'Ignorado'
        )
      )
    )
  }

  # YEAR 2010 ------------------------------------------------------------------
  if (year == 2010 & lang == 'pt') {
    # RELACAO DE PARENTESCO OU DE CONVIVENCIA COM A PESSOA RESPONSAVEL PELO DOMICILIO
    if ('V0502' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0502 = dplyr::case_when(
          V0502 == '01' ~ 'Pessoa respons\u00e1vel pelo domic\u00edlio ',
          V0502 == '02' ~ 'C\u00f4njuge ou companheiro(a) de sexo diferente',
          V0502 == '03' ~ 'C\u00f4njuge ou companheiro(a) do mesmo sexo',
          V0502 == '04' ~ 'Filho(a) do respons\u00e1vel e do c\u00f4njuge',
          V0502 == '05' ~ 'Filho(a) somente do respons\u00e1vel',
          V0502 == '06' ~ 'Enteado(a)',
          V0502 == '07' ~ 'Genro ou nora',
          V0502 == '08' ~ 'Pai, m\u00e3e, padrasto ou madrasta',
          V0502 == '09' ~ 'Sogro(a)',
          V0502 == '10' ~ 'Neto(a)',
          V0502 == '11' ~ 'Bisneto(a)',
          V0502 == '12' ~ 'Irm\u00e3o ou irm\u00e3',
          V0502 == '13' ~ 'Av\u00f4 ou av\u00f3',
          V0502 == '14' ~ 'Outro parente',
          V0502 == '15' ~ 'Agregado(a)',
          V0502 == '16' ~ 'Convivente',
          V0502 == '17' ~ 'Pensionista',
          V0502 == '18' ~ 'Empregado(a) dom\u00e9stico(a)',
          V0502 == '19' ~ 'Parente do(a) empregado(a)  dom\u00e9stico(a)',
          V0502 == '20' ~ 'Individual em domic\u00edlio coletivo'
        )
      )
    }

    # sex
    if ('V0601' %in% cols) {
      arrw <- arrw |>
        mutate(
          V0601 = dplyr::case_when(
            V0601 == '1' ~ 'Masculino',
            V0601 == '2' ~ 'Feminino',
            V0601 == '9' ~ 'Ignorado'
          )
        )
    }

    # FORMA DE DECLARACAO DA IDADE:
    if ('V6040' %in% cols) {
      arrw <- arrw |>
        mutate(
          V6040 = dplyr::case_when(
            V6040 == '1' ~ 'Data de nascimento',
            V6040 == '2' ~ 'Idade declarada'
          )
        )
    }

    # COR OU RACA
    if ('V0606' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0606 = dplyr::case_when(
          V0606 == '1' ~ 'Branca',
          V0606 == '2' ~ 'Preta',
          V0606 == '3' ~ 'Amarela',
          V0606 == '4' ~ 'Parda',
          V0606 == '5' ~ 'Ind\u00edgena',
          V0606 == '9' ~ 'Ignorado'
        )
      )
    }

    # REGISTRO DE NASCIMENTO
    if ('V0613' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0613 = dplyr::case_when(
          V0613 == '1' ~ 'Do cart\u00f3rio',
          V0613 ==
            '2' ~ 'Declara\u00e7\u00e3o de nascido vivo (DNV) do hospital ou da maternidade',
          V0613 ==
            '3' ~ 'Registro administrativo de nascimento ind\u00edgena (RANI)',
          V0613 == '4' ~ 'N\u00e3o tem',
          V0613 == '5' ~ 'N\u00e3o sabe',
          V0613 == '9' ~ 'Ignorado'
        )
      )
    }

    # physical disabilities
    pd_vars <- c('V0614', 'V0615', 'V0616')
    pd_vars <- pd_vars[pd_vars %in% cols]
    arrw <- dplyr::mutate(
      arrw,
      dplyr::across(
        all_of(pd_vars),
        ~ case_when(
          .x == '1' ~ 'Sim, n\u00e3o consegue de modo algum',
          .x == '2' ~ 'Sim, grande dificuldade',
          .x == '3' ~ 'Sim, alguma dificuldade',
          .x == '4' ~ 'N\u00e3o, nenhuma dificuldade',
          .x == '9' ~ 'Ignorado'
        )
      )
    )

    # NASCEU NESTE MUNICIPIO
    if ('V0618' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0618 = dplyr::case_when(
          V0618 == '1' ~ 'Sim, e sempre morou',
          V0618 ==
            '2' ~ 'Sim mas morou em outro munic\u00edpio ou pa\u00eds estrangeiro',
          V0618 == '3' ~ 'N\u00e3o'
        )
      )
    }

    # NASCEU NESTA UNIDADE DA FEDERACAO
    if ('V0619' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0619 = dplyr::case_when(
          V0619 == '1' ~ 'Sim, e sempre morou',
          V0619 == '2' ~ 'Sim, mas morou em outra UF ou pa\u00eds estrangeiro',
          V0619 == '3' ~ 'N\u00e3o'
        )
      )
    }

    # NACIONALIDADE
    if ('V0620' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0620 = dplyr::case_when(
          V0620 == '1' ~ 'Brasileiro nato',
          V0620 == '2' ~ 'Naturalizado brasileiro',
          V0620 == '3' ~ 'Estrangeiro'
        )
      )
    }

    ## migration block
    # V6222 UF de nascimento
    # V6224 pais de nascimento
    # V0625
    # V6252
    # V6254
    # V6256
    # V0626
    # V6262
    # V6264
    # V6266

    # FREQUENTA ESCOLA OU CRECHE
    if ('V0628' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0628 = dplyr::case_when(
          V0628 == '1' ~ 'Sim, p\u00fablica ',
          V0628 == '2' ~ 'Sim, particular',
          V0628 == '3' ~ 'N\u00e3o, j\u00e1 frequentou',
          V0628 == '4' ~ 'N\u00e3o, nunca frequentou'
        )
      )
    }

    # CURSO QUE FREQUENTA
    if ('V0629' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0629 = dplyr::case_when(
          V0629 == '01' ~ "Creche",
          V0629 ==
            '02' ~ "Pr\u00e9-escolar (maternal e jardim da inf\u00e2ncia)",
          V0629 == '03' ~ "Classe de alfabetiza\u00e7\u00e3o - CA",
          V0629 == '04' ~ "Alfabetiza\u00e7\u00e3o de jovens e adultos",
          V0629 == '05' ~ "Regular do ensino fundamental",
          V0629 ==
            '06' ~ "Educa\u00e7\u00e3o de jovens e adultos - EJA - ou supletivo do ensino fundamental",
          V0629 == '07' ~ "Regular do ensino m\u00e9dio",
          V0629 ==
            '08' ~ "Educa\u00e7\u00e3o de jovens e adultos - EJA - ou supletivo do ensino m\u00e9dio",
          V0629 == '09' ~ "Superior de gradua\u00e7\u00e3o",
          V0629 ==
            '10' ~ "Especializa\u00e7\u00e3o de n\u00edvel superior ( m\u00ednimo de 360 horas )",
          V0629 == '11' ~ "Mestrado",
          V0629 == '12' ~ "Doutorado"
        )
      )
    }

    # SERIE / ANO QUE FREQUENTA
    if ('V0630' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0630 = dplyr::case_when(
          V0630 == '01' ~ 'Primeiro ano',
          V0630 == '02' ~ 'Primeira s\u00e9rie - Segundo ano',
          V0630 == '03' ~ 'Segunda s\u00e9rie - Terceiro ano',
          V0630 == '04' ~ 'Terceira s\u00e9rie - Quarto ano',
          V0630 == '05' ~ 'Quarta s\u00e9rie - Quinto ano',
          V0630 == '06' ~ 'Quinta s\u00e9rie - Sexto ano',
          V0630 == '07' ~ 'Sexta s\u00e9rie - S\u00e9timo ano',
          V0630 == '08' ~ 'S\u00e9tima s\u00e9rie - Oitavo ano',
          V0630 == '09' ~ 'Oitava s\u00e9rie - Nono ano',
          V0630 == '10' ~ 'N\u00e3o seriado'
        )
      )
    }

    # SERIE QUE FREQUENTA
    if ('V0631' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0631 = dplyr::case_when(
          V0631 == '1' ~ 'Primeira s\u00e9rie',
          V0631 == '2' ~ 'Segunda s\u00e9rie',
          V0631 == '3' ~ 'Terceira s\u00e9rie',
          V0631 == '4' ~ 'Quarta s\u00e9rie',
          V0631 == '5' ~ 'N\u00e3o seriado'
        )
      )
    }

    # CURSO MAIS ELEVADO QUE FREQUENTOU
    if ('V0633' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0633 = dplyr::case_when(
          V0633 ==
            '01' ~ "Creche, pr\u00e9-escolar (maternal e jardim de inf\u00e2ncia), classe de alfabetiza\u00e7\u00e3o - CA",
          V0633 == '02' ~ "Alfabetiza\u00e7\u00e3o de jovens e adultos",
          V0633 == '03' ~ "Antigo prim\u00e1rio (elementar)",
          V0633 == '04' ~ "Antigo gin\u00e1sio (m\u00e9dio 1\u00ba ciclo)",
          V0633 ==
            '05' ~ "Ensino fundamental ou 1\u00ba grau (da 1\u00aa a 3\u00aa s\u00e9rie/ do 1\u00ba ao 4\u00ba ano)",
          V0633 ==
            '06' ~ "Ensino fundamental ou 1\u00ba grau (4\u00aa s\u00e9rie/ 5\u00ba ano)",
          V0633 ==
            '07' ~ "Ensino fundamental ou 1\u00ba grau (da 5\u00aa a 8\u00aa s\u00e9rie/ 6\u00ba ao 9\u00ba ano)",
          V0633 == '08' ~ "Supletivo do ensino fundamental ou do 1\u00ba grau",
          V0633 ==
            '09' ~ "Antigo cient\u00edfico, cl\u00e1ssico, etc.....(m\u00e9dio 2\u00ba ciclo)",
          V0633 ==
            '10' ~ "Regular ou supletivo do ensino m\u00e9dio ou do 2\u00ba grau",
          V0633 == '11' ~ "Superior de gradua\u00e7\u00e3o",
          V0633 ==
            '12' ~ "Especializa\u00e7\u00e3o de n\u00edvel superior ( m\u00ednimo de 360 horas )",
          V0633 == '13' ~ "Mestrado",
          V0633 == '14' ~ "Doutorado"
        )
      )
    }

    # ESPECIE DO CURSO MAIS ELEVADO CONCLUIDO
    if ('V0635' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0635 = dplyr::case_when(
          V0635 == '1' ~ 'Superior de gradua\u00e7\u00e3o',
          V0635 == '2' ~ 'Mestrado',
          V0635 == '3' ~ 'Doutorado'
        )
      )
    }

    # NIVEL DE INSTRUCAO
    if ('V6400' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V6400 = dplyr::case_when(
          V6400 == '1' ~ "Sem instru\u00e7\u00e3o e fundamental incompleto",
          V6400 == '2' ~ "Fundamental completo e m\u00e9dio incompleto",
          V6400 == '3' ~ "M\u00e9dio completo e superior incompleto",
          V6400 == '4' ~ "Superior completo",
          V6400 == '5' ~ "N\u00e3o determinado"
        )
      )
    }

    # V6352 curso superior de graduacao
    # V6354 curso superior de mestrado
    # V6356 curso superior de doutorado

    # MUNICIPIO E UNIDADE DA FEDERACAO OU PAIS ESTRANGEIRO QUE FREQUENTAVA ESCOLA (OU CRECHE):
    if ('V0636' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0636 = dplyr::case_when(
          V0636 == '1' ~ 'Neste munic\u00edpio',
          V0636 == '2' ~ 'Em outro munic\u00edpio',
          V0636 == '3' ~ 'Em pa\u00eds estrangeiro'
        )
      )
    }

    # V6362 municipio q frequenta escola
    # V6364 uf q frequenta escola
    # V6366 pais q frequenta escola

    # VIVE EM COMPANHIA DE CONJUGE OU COMPANHEIRO(A):
    if ('V0637' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0637 = dplyr::case_when(
          V0637 == '1' ~ 'Sim',
          V0637 == '2' ~ 'N\u00e3o, mas viveu',
          V0637 == '3' ~ 'N\u00e3o, nunca viveu'
        )
      )
    }

    # NATUREZA DA UNIAO
    if ('V0639' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0639 = dplyr::case_when(
          V0639 == '1' ~ 'Casamento civil e religioso',
          V0639 == '2' ~ 'S\u00f3 casamento civil',
          V0639 == '3' ~ 'S\u00f3 casamento religioso',
          V0639 == '4' ~ 'Uni\u00e3o consensual'
        )
      )
    }

    # ESTADO CIVIL
    if ('V0640' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0640 = dplyr::case_when(
          V0640 == '1' ~ 'Casado(a)',
          V0640 == '2' ~ 'Desquitado(a) ou separado(a) judicialmente',
          V0640 == '3' ~ 'Divorciado(a)',
          V0640 == '4' ~ 'Vi\u00favo(a)',
          V0640 == '5' ~ 'Solteiro(a)'
        )
      )
    }

    # QUANTOS TRABALHOS TINHA
    if ('V0645' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0645 = dplyr::case_when(
          V0645 == '1' ~ 'Um',
          V0645 == '2' ~ 'Dois ou mais'
        )
      )
    }

    # V6461 codigo ocupacao
    # V6471 codigo atividade

    # NESSE TRABALHO ERA
    if ('V0648' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0648 = dplyr::case_when(
          V0648 == '1' ~ "Empregado com carteira de trabalho assinada ",
          V0648 ==
            '2' ~ "Militar do ex\u00e9rcito, marinha, aeron\u00e1utica, policia militar ou corpo de bombeiros",
          V0648 ==
            '3' ~ "Empregado pelo regime jur\u00eddico dos funcion\u00e1rios p\u00fablicos",
          V0648 == '4' ~ "Empregado sem carteira de trabalho assinada",
          V0648 == '5' ~ "Conta pr\u00f3pria",
          V0648 == '6' ~ "Empregador",
          V0648 == '7' ~ "N\u00e3o remunerado"
        )
      )
    }

    # QUANTAS PESSOAS EMPREGAVA NESSE TRABALHO
    if ('V0649' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0649 = dplyr::case_when(
          V0649 == '1' ~ "1 a 5 pessoas",
          V0649 == '2' ~ "6 ou mais pessoas"
        )
      )
    }

    # ERA CONTRIBUINTE DE INSTITUTO DE PREVIDENCIA
    if ('V0650' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0650 = dplyr::case_when(
          V0650 == '1' ~ "Sim, no trabalho principal",
          V0650 == '2' ~ "Sim, em outro trabalho",
          V0650 == '3' ~ "N\u00e3o"
        )
      )
    }

    # V0651
    # V0652

    # EM QUE MUNICIPIO E UNIDADE DA FEDERACAO OU PAIS ESTRANGEIRO TRABALHA:
    if ('V0660' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0660 = dplyr::case_when(
          V0660 == '1' ~ "No pr\u00f3prio domic\u00edlio",
          V0660 ==
            '2' ~ "Apenas neste munic\u00edpio, mas n\u00e3o no pr\u00f3prio domic\u00edlio",
          V0660 == '3' ~ "Em outro munic\u00edpio",
          V0660 == '4' ~ "Em pa\u00eds estrangeiro",
          V0660 == '5' ~ "Em mais de um munic\u00edpio ou pa\u00eds"
        )
      )
    }

    # V6602 em que municipio trbalhava
    # V6604 em que uf trbalhava
    # V6606 em que pais trbalhava

    # QUAL E O TEMPO HABITUAL GASTO DE DESLOCAMENTO DE SUA CASA ATE O TRABALHO
    if ('V0662' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0662 = dplyr::case_when(
          V0662 == '1' ~ "At\u00e9 05 minutos",
          V0662 == '2' ~ "De 06 minutos at\u00e9 meia hora",
          V0662 == '3' ~ "Mais de meia hora at\u00e9 uma hora",
          V0662 == '4' ~ "Mais de uma hora at\u00e9 duas horas",
          V0662 == '5' ~ "Mais de duas horas"
        )
      )
    }

    ## fertility block
    # V0663
    # V0664
    # V0665
    # V0667
    # V0668
    # V0669

    # ASSINALE QUEM PRESTOU AS INFORMACOES DESTA PESSOA
    if ('V0670' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0670 = dplyr::case_when(
          V0670 == '1' ~ "A pr\u00f3pria pessoa",
          V0670 == '2' ~ "Outro morador",
          V0670 == '3' ~ "N\u00e3o morador",
          V0670 == '9' ~ "Ignorado"
        )
      )
    }

    # CONDICAO DE OCUPACAO NA SEMANA DE REFERENCIA
    if ('V6910' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V6910 = dplyr::case_when(
          V6910 == '1' ~ "Ocupadas",
          V6910 == '2' ~ "Desocupadas"
        )
      )
    }

    # SITUACAO DE OCUPACAO NA SEMANA DE REFERENCIA
    if ('V6920' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V6920 = dplyr::case_when(
          V6920 == '1' ~ "Ocupadas",
          V6920 == '2' ~ "N\u00e3o ocupadas"
        )
      )
    }

    # POSICAO NA OCUPACAO E CATEGORIA DO EMPREGO NO TRABALHO PRINCIPAL
    if ('V6930' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V6930 = dplyr::case_when(
          V6930 == '1' ~ "Empregados com carteira de trabalho assinada",
          V6930 ==
            '2' ~ "Militares e funcion\u00e1rios p\u00fablicos estatut\u00e1rios",
          V6930 == '3' ~ "Empregados sem carteira de trabalho assinada",
          V6930 == '4' ~ "Conta pr\u00f3pria",
          V6930 == '5' ~ "Empregadores",
          V6930 == '6' ~ "N\u00e3o remunerados",
          V6930 ==
            '7' ~ "Trabalhadores na produ\u00e7\u00e3o para o pr\u00f3prio consumo"
        )
      )
    }

    # SUBGRUPO E CATEGORIA DO EMPREGO NO TRABALHO PRINCIPAL
    if ('V6940' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V6940 = dplyr::case_when(
          V6940 ==
            '1' ~ "Trabalhadores dom\u00e9sticos com carteira de trabalho assinada",
          V6940 ==
            '2' ~ "Trabalhadores dom\u00e9sticos sem carteira de trabalho assinada",
          V6940 == '3' ~ "Demais empregados com carteira de trabalho assinada",
          V6940 ==
            '4' ~ "Militares e funcion\u00e1rios p\u00fablicos estatut\u00e1rios",
          V6940 == '5' ~ "Demais empregados sem carteira de trabalho assinada"
        )
      )
    }

    # V6121 religiao ou culto

    # TEM MAE VIVA
    if ('V0604' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0604 = dplyr::case_when(
          V0604 == '1' ~ "Sim e mora neste domic\u00edlio",
          V0604 == '2' ~ "Sim e mora em outro domic\u00edlio",
          V0604 == '3' ~ "N\u00e3o",
          V0604 == '4' ~ "N\u00e3o sabe",
          V0604 == '9' ~ "Ignorado"
        )
      )
    }

    # V6462 ocupacao
    # V6472 atividade

    # TIPO DE UNIDADE DOMESTICA
    if ('V5030' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V5030 = dplyr::case_when(
          V5030 == '1' ~ "Unipessoal",
          V5030 == '2' ~ "Duas pessoas ou mais sem parentesco",
          V5030 == '3' ~ "Duas pessoas ou mais com parentesco"
        )
      )
    }

    ## family block
    # V5040
    # V5090
    # V5100

    ### Yes (1) or No (2) columns
    vars_sim_nao <- c(
      'V0617',
      'V0627',
      'V0632',
      'V0634',
      'V0641',
      'V0642',
      'V0643',
      'V0644',
      'V0654',
      'V0655',
      'V0661',
      'V6664',

      # 1 (yes), (0) no, (9) ignored
      'V0656',
      'V0657',
      'V0658',
      'V0659'
    )

    # mutate only colnames present. Codes observed in the 2010 microdata are
    # 1 / 2 (most variables), 1 / 0 (V6664) and 1 / 0 / 9 (V0617, V0656-V0659);
    # 9 is "Ignorado" and must not be collapsed into "Nao".
    vars_sim_nao_present <- vars_sim_nao[vars_sim_nao %in% cols]
    arrw <- dplyr::mutate(
      arrw,
      dplyr::across(
        all_of(vars_sim_nao_present),
        ~ case_when(
          .x == '1' ~ 'Sim',
          .x %in% c('0', '2') ~ 'N\u00e3o',
          .x == '9' ~ 'Ignorado'
        )
      )
    )

    # census tract type
    if ('V1005' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V1005 = dplyr::case_when(
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
  }

  # YEAR 2000----------------------------------------------------------------
  if (year == 2000 & lang == 'pt') {
    # NOTE: labels transcribed from the 'Population' sheet of the 2000 microdata
    # dictionary, `data_dictionary(2000, "microdata")`. Where that sheet spells a
    # category as "<short label>: <long explanation>" (V0408, V0411-V0413, V0414,
    # V0419, V4070), only the short label is used, as in the 2010 block.
    # Variables holding codes from a separate lookup table (V4090 religion,
    # V4210/V4219/V4230/V4239/V4250/V4260/V4269/V4276/V4279 migration,
    # V4354/V4355 courses, V4451/V4452/V4461/V4462 occupation and activity) are
    # left as codes, as are the `M*` imputation flags and the geography columns
    # V0102 and V1001, which censobr already provides as `abbrev_state`,
    # `name_state`, `code_region` and `name_region`.
    # V1006 is labelled by the ALL YEARS block above.

    # REGIAO METROPOLITANA
    if ('V1004' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V1004 = dplyr::case_when(
          V1004 == '00' ~ paste0('Sem \u00c1rea de Pondera\u00e7\u00e3o'),
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
          V1004 == '23' ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM Vale do Itaja\u00ed',
          V1004 == '24' ~ 'Norte/Nordeste Catarinense',
          V1004 ==
            '25' ~ '\u00c1rea de Expans\u00e3o Metropolitana da RM Norte/Nordeste Catarinense',
          V1004 == '26' ~ 'Porto Alegre',
          V1004 == '27' ~ 'Goi\u00e2nia',
          V1004 == '28' ~ 'Distrito Federal e Entorno'
        )
      )
    }

    # SITUACAO DO SETOR
    if ('V1005' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V1005 = dplyr::case_when(
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

    # TIPO DE SETOR
    if ('V1007' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V1007 = dplyr::case_when(
          V1007 == '0' ~ 'N\u00e3o especial: Setor comum',
          V1007 == '1' ~ 'Aglomerado subnormal',
          V1007 == '2' ~ 'Quartel',
          V1007 == '3' ~ 'Alojamento',
          V1007 == '4' ~ 'Embarca\u00e7\u00e3o',
          V1007 == '5' ~ 'Aldeia ind\u00edgena',
          V1007 == '6' ~ 'Penitenci\u00e1ria',
          V1007 == '7' ~ 'Asilo'
        )
      )
    }

    # SE A PROPRIA PESSOA PRESTOU AS INFORMACOES
    # NOTE: the dictionary documents a single code. Blank (NA) means the
    # information was given by another resident of the household.
    if ('MARCA' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        MARCA = dplyr::case_when(
          MARCA == '1' ~ 'A pr\u00f3pria pessoa prestou as informa\u00e7\u00f5es'
        )
      )
    }

    # SEXO
    if ('V0401' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0401 = dplyr::case_when(
          V0401 == '1' ~ 'Masculino',
          V0401 == '2' ~ 'Feminino'
        )
      )
    }

    # RELACAO COM A PESSOA RESPONSAVEL PELO DOMICILIO (V0402) E PELA FAMILIA (V0403)
    rel_vars <- c('V0402', 'V0403')
    rel_vars <- rel_vars[rel_vars %in% cols]
    if (length(rel_vars) > 0) {
      arrw <- dplyr::mutate(
        arrw,
        dplyr::across(
          all_of(rel_vars),
          ~ case_when(
            .x == '01' ~ 'Pessoa respons\u00e1vel',
            .x == '02' ~ 'C\u00f4njuge, companheiro(a)',
            .x == '03' ~ 'Filho(a), enteado(a)',
            .x == '04' ~ 'Pai, m\u00e3e, sogro(a)',
            .x == '05' ~ 'Neto(a), bisneto(a)',
            .x == '06' ~ 'Irm\u00e3o, irm\u00e3',
            .x == '07' ~ 'Outro parente',
            .x == '08' ~ 'Agregado(a)',
            .x == '09' ~ 'Pensionista',
            .x == '10' ~ 'Empregado(a) dom\u00e9stico(a)',
            .x == '11' ~ 'Parente do empregado(a) dom\u00e9stico(a)',
            .x == '12' ~ 'Individual em domic\u00edlio coletivo'
          )
        )
      )
    }

    # FORMA DE DECLARACAO DA IDADE
    if ('V4070' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V4070 = dplyr::case_when(
          V4070 == '1' ~ 'Idade calculada',
          V4070 == '2' ~ 'Idade presumida/declarada'
        )
      )
    }

    # COR OU RACA
    if ('V0408' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0408 = dplyr::case_when(
          V0408 == '1' ~ 'Branca',
          V0408 == '2' ~ 'Preta',
          V0408 == '3' ~ 'Amarela',
          V0408 == '4' ~ 'Parda',
          V0408 == '5' ~ 'Ind\u00edgena',
          V0408 == '9' ~ 'Ignorado'
        )
      )
    }

    # PROBLEMA MENTAL PERMANENTE
    if ('V0410' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0410 = dplyr::case_when(
          V0410 == '1' ~ 'Sim',
          V0410 == '2' ~ 'N\u00e3o',
          V0410 == '9' ~ 'Ignorado'
        )
      )
    }

    # CAPACIDADE DE ENXERGAR (V0411), OUVIR (V0412) E CAMINHAR/SUBIR ESCADAS (V0413)
    dif_vars <- c('V0411', 'V0412', 'V0413')
    dif_vars <- dif_vars[dif_vars %in% cols]
    if (length(dif_vars) > 0) {
      arrw <- dplyr::mutate(
        arrw,
        dplyr::across(
          all_of(dif_vars),
          ~ case_when(
            .x == '1' ~ 'Incapaz',
            .x == '2' ~ 'Grande dificuldade permanente',
            .x == '3' ~ 'Alguma dificuldade permanente',
            .x == '4' ~ 'Nenhuma dificuldade',
            .x == '9' ~ 'Ignorado'
          )
        )
      )
    }

    # DEFICIENCIAS
    if ('V0414' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0414 = dplyr::case_when(
          V0414 == '1' ~ 'Paralisia permanente total',
          V0414 == '2' ~ 'Paralisia permanente das pernas',
          V0414 == '3' ~ 'Paralisia permanente de um dos lados do corpo',
          V0414 == '4' ~ 'Falta de perna, bra\u00e7o, m\u00e3o, p\u00e9 ou dedo polegar',
          V0414 == '5' ~ 'Nenhuma das enumeradas',
          V0414 == '9' ~ 'Ignorado'
        )
      )
    }

    # NACIONALIDADE
    if ('V0419' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0419 = dplyr::case_when(
          V0419 == '1' ~ 'Brasileiro nato',
          V0419 == '2' ~ 'Naturalizado brasileiro',
          V0419 == '3' ~ 'Estrangeiro'
        )
      )
    }

    # RESIDENCIA EM 31 DE JULHO DE 1995
    if ('V0424' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0424 = dplyr::case_when(
          V0424 == '1' ~ 'Neste Munic\u00edpio, na Zona Urbana',
          V0424 == '2' ~ 'Neste Munic\u00edpio, na Zona Rural',
          V0424 == '3' ~ 'Em outro Munic\u00edpio, na Zona Urbana',
          V0424 == '4' ~ 'Em outro Munic\u00edpio, na Zona Rural',
          V0424 == '5' ~ 'Em outro Pa\u00eds',
          V0424 == '6' ~ 'N\u00e3o era nascido'
        )
      )
    }

    # SABE LER E ESCREVER
    if ('V0428' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0428 = dplyr::case_when(
          V0428 == '1' ~ 'Sabe ler e escrever',
          V0428 == '2' ~ 'N\u00e3o sabe'
        )
      )
    }

    # FREQUENTA ESCOLA OU CRECHE
    if ('V0429' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0429 = dplyr::case_when(
          V0429 == '1' ~ 'Sim, rede particular',
          V0429 == '2' ~ 'Sim, rede p\u00fablica',
          V0429 == '3' ~ 'N\u00e3o, j\u00e1 frequentou',
          V0429 == '4' ~ 'Nunca frequentou'
        )
      )
    }

    # CURSO QUE FREQUENTA
    if ('V0430' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0430 = dplyr::case_when(
          V0430 == '01' ~ 'Creche',
          V0430 == '02' ~ 'Pr\u00e9-escolar',
          V0430 == '03' ~ 'Classe de alfabetiza\u00e7\u00e3o',
          V0430 == '04' ~ 'Alfabetiza\u00e7\u00e3o de adultos',
          V0430 == '05' ~ 'Ensino fundamental ou 1\u00ba grau - regular seriado',
          V0430 == '06' ~ 'Ensino fundamental ou 1\u00ba grau - regular n\u00e3o-seriado',
          V0430 == '07' ~ 'Supletivo (ensino fundamental ou 1\u00ba grau)',
          V0430 == '08' ~ 'Ensino m\u00e9dio ou 2\u00ba grau - regular seriado',
          V0430 == '09' ~ 'Ensino m\u00e9dio ou 2\u00ba grau - regular n\u00e3o-seriado',
          V0430 == '10' ~ 'Supletivo (ensino m\u00e9dio ou 2\u00ba grau)',
          V0430 == '11' ~ 'Pr\u00e9-vestibular',
          V0430 == '12' ~ 'Superior - gradua\u00e7\u00e3o',
          V0430 == '13' ~ 'Mestrado ou doutorado'
        )
      )
    }

    # SERIE QUE FREQUENTA
    if ('V0431' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0431 = dplyr::case_when(
          V0431 == '1' ~ 'Primeira S\u00e9rie',
          V0431 == '2' ~ 'Segunda S\u00e9rie',
          V0431 == '3' ~ 'Terceira S\u00e9rie',
          V0431 == '4' ~ 'Quarta S\u00e9rie',
          V0431 == '5' ~ 'Quinta S\u00e9rie',
          V0431 == '6' ~ 'Sexta S\u00e9rie',
          V0431 == '7' ~ 'S\u00e9tima S\u00e9rie',
          V0431 == '8' ~ 'Oitava S\u00e9rie',
          V0431 == '9' ~ 'Curso n\u00e3o seriado'
        )
      )
    }

    # CURSO MAIS ELEVADO QUE FREQUENTOU, CONCLUINDO PELO MENOS UMA SERIE
    if ('V0432' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0432 = dplyr::case_when(
          V0432 == '1' ~ 'Alfabetiza\u00e7\u00e3o de adultos',
          V0432 == '2' ~ 'Antigo prim\u00e1rio',
          V0432 == '3' ~ 'Antigo gin\u00e1sio',
          V0432 == '4' ~ 'Antigo cl\u00e1ssico, cient\u00edfico, etc.',
          V0432 == '5' ~ 'Ensino fundamental ou 1\u00ba grau',
          V0432 == '6' ~ 'Ensino m\u00e9dio ou 2\u00ba grau',
          V0432 == '7' ~ 'Superior - gradua\u00e7\u00e3o',
          V0432 == '8' ~ 'Mestrado ou doutorado',
          V0432 == '9' ~ 'Nenhum'
        )
      )
    }

    # ULTIMA SERIE CONCLUIDA COM APROVACAO
    if ('V0433' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0433 = dplyr::case_when(
          V0433 == '01' ~ 'Primeira S\u00e9rie',
          V0433 == '02' ~ 'Segunda S\u00e9rie',
          V0433 == '03' ~ 'Terceira S\u00e9rie',
          V0433 == '04' ~ 'Quarta S\u00e9rie',
          V0433 == '05' ~ 'Quinta S\u00e9rie',
          V0433 == '06' ~ 'Sexta S\u00e9rie',
          V0433 == '07' ~ 'S\u00e9tima S\u00e9rie',
          V0433 == '08' ~ 'Oitava S\u00e9rie',
          V0433 == '09' ~ 'Curso n\u00e3o seriado',
          V0433 == '10' ~ 'Nenhuma'
        )
      )
    }

    # ANOS DE ESTUDO
    if ('V4300' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V4300 = dplyr::case_when(
          V4300 == '00' ~ 'Sem instru\u00e7\u00e3o ou menos de 1 ano',
          V4300 == '01' ~ '1 ano',
          V4300 == '02' ~ '2 anos',
          V4300 == '03' ~ '3 anos',
          V4300 == '04' ~ '4 anos',
          V4300 == '05' ~ '5 anos',
          V4300 == '06' ~ '6 anos',
          V4300 == '07' ~ '7 anos',
          V4300 == '08' ~ '8 anos',
          V4300 == '09' ~ '9 anos',
          V4300 == '10' ~ '10 anos',
          V4300 == '11' ~ '11 anos',
          V4300 == '12' ~ '12 anos',
          V4300 == '13' ~ '13 anos',
          V4300 == '14' ~ '14 anos',
          V4300 == '15' ~ '15 anos',
          V4300 == '16' ~ '16 anos',
          V4300 == '17' ~ '17 anos ou mais',
          V4300 == '20' ~ 'N\u00e3o determinado',
          V4300 == '30' ~ 'Alfabetiza\u00e7\u00e3o de adultos'
        )
      )
    }

    # VIVE EM COMPANHIA DE CONJUGE OU COMPANHEIRO(A)
    if ('V0436' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0436 = dplyr::case_when(
          V0436 == '1' ~ 'Sim',
          V0436 == '2' ~ 'N\u00e3o, mas viveu',
          V0436 == '3' ~ 'Nunca viveu'
        )
      )
    }

    # NATUREZA DA ULTIMA UNIAO
    if ('V0437' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0437 = dplyr::case_when(
          V0437 == '1' ~ 'Casamento civil e religioso',
          V0437 == '2' ~ 'S\u00f3 casamento civil',
          V0437 == '3' ~ 'S\u00f3 casamento religioso',
          V0437 == '4' ~ 'Uni\u00e3o consensual',
          V0437 == '5' ~ 'Nunca viveu'
        )
      )
    }

    # ESTADO CIVIL
    if ('V0438' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0438 = dplyr::case_when(
          V0438 == '1' ~ 'Casado(a)',
          V0438 == '2' ~ 'Desquitado(a) ou separado(a) judicialmente',
          V0438 == '3' ~ 'Divorciado(a)',
          V0438 == '4' ~ 'Vi\u00favo(a)',
          V0438 == '5' ~ 'Solteiro(a)'
        )
      )
    }

    # QUANTOS TRABALHOS TINHA NA SEMANA DE 23 A 29 DE JULHO DE 2000
    if ('V0444' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0444 = dplyr::case_when(
          V0444 == '1' ~ 'Um',
          V0444 == '2' ~ 'Dois ou mais'
        )
      )
    }

    # POSICAO NA OCUPACAO NO TRABALHO PRINCIPAL
    if ('V0447' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0447 = dplyr::case_when(
          V0447 ==
            '1' ~ 'Trabalhador dom\u00e9stico com carteira de trabalho assinada',
          V0447 ==
            '2' ~ 'Trabalhador dom\u00e9stico sem carteira de trabalho assinada',
          V0447 == '3' ~ 'Empregado com carteira de trabalho assinada',
          V0447 == '4' ~ 'Empregado sem carteira de trabalho assinada',
          V0447 == '5' ~ 'Empregador',
          V0447 == '6' ~ 'Conta-pr\u00f3pria',
          V0447 == '7' ~ 'Aprendiz ou estagi\u00e1rio sem remunera\u00e7\u00e3o',
          V0447 == '8' ~ 'N\u00e3o remunerado em ajuda a membro do domic\u00edlio',
          V0447 == '9' ~ 'Trabalhador na produ\u00e7\u00e3o para o pr\u00f3prio consumo'
        )
      )
    }

    # QUANTOS EMPREGADOS TRABALHAVAM NESSA FIRMA
    if ('V0449' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0449 = dplyr::case_when(
          V0449 == '1' ~ 'Um',
          V0449 == '2' ~ 'Dois',
          V0449 == '3' ~ 'De 3 a 5 empregados',
          V0449 == '4' ~ 'De 6 a 10 empregados',
          V0449 == '5' ~ '11 ou mais empregados'
        )
      )
    }

    # NAO TEM RENDIMENTO NO TRABALHO PRINCIPAL (V4511) E NOS DEMAIS TRABALHOS (V4521)
    inc_vars <- c('V4511', 'V4521')
    inc_vars <- inc_vars[inc_vars %in% cols]
    if (length(inc_vars) > 0) {
      arrw <- dplyr::mutate(
        arrw,
        dplyr::across(
          all_of(inc_vars),
          ~ case_when(
            .x == '0' ~ 'N\u00e3o tem',
            .x == '1' ~ 'Somente em benef\u00edcios'
          )
        )
      )
    }

    # SEXO DO ULTIMO FILHO NASCIDO VIVO
    if ('V0464' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0464 = dplyr::case_when(
          V0464 == '1' ~ 'Masculino',
          V0464 == '2' ~ 'Feminino'
        )
      )
    }

    # SIM / NAO
    # V0415 sempre morou neste municipio; V0417 nasceu neste municipio;
    # V0418 nasceu nesta UF; V0434 concluiu o curso no qual estudou;
    # V0439 trabalhou remunerado na semana; V0440 tinha trabalho mas estava
    # afastado; V0441/V0442/V0443 ajudou sem remuneracao / trabalhou no cultivo;
    # V0448 era empregado pelo RJFP ou como militar; V0450 era contribuinte de
    # instituto de previdencia oficial; V0455 tomou providencia para conseguir
    # trabalho; V0456 era aposentado de instituto de previdencia oficial.
    yn_vars <- c(
      'V0415',
      'V0417',
      'V0418',
      'V0434',
      'V0439',
      'V0440',
      'V0441',
      'V0442',
      'V0443',
      'V0448',
      'V0450',
      'V0455',
      'V0456'
    )
    yn_vars <- yn_vars[yn_vars %in% cols]
    if (length(yn_vars) > 0) {
      arrw <- dplyr::mutate(
        arrw,
        dplyr::across(
          all_of(yn_vars),
          ~ case_when(
            .x == '1' ~ 'Sim',
            .x == '2' ~ 'N\u00e3o'
          )
        )
      )
    }
  }

  # YEAR 1960 ------------------------------------------------------------------
  if (year == 1960 & lang == 'pt') {
    # NOTE: labels transcribed from the 1960 population dictionary,
    # `data_dictionary(1960, "population")`, normalised to sentence case as in
    # the other blocks. Unlike 2000/2010, the 1960 codes are stored as integers,
    # so comparisons below are numeric. Variables whose categories live in a
    # separate lookup sheet of the dictionary ("Ver aba": V207 naturalidade,
    # V210 residencia anterior, V214 curso completo, V216 ano do casamento,
    # V221 ocupacao habitual, V223b ramo de atividade) are left as codes, as
    # are the numeric variables (V100, V112, V113, V204b, V217, V218, the
    # censobr_* ids, weights and counts), the record-identification and
    # sample-design variables (V001-V004, V200, V201, censobr_estrato,
    # censobr_upa, censobr_usa), the two censobr_diag_*_vars text columns, and
    # the geography codes code_muni_1960, V116 and V117.

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

    # UNIDADE DA FEDERACAO (1960 territorial division). The 1960 microdata carry
    # no abbrev_state/name_state columns, so the state code is labelled here;
    # accents added to the dictionary spellings.
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

    # SEXO E CONDICAO DE PRESENCA NO DOMICILIO
    if ('V202' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V202 = dplyr::case_when(
          V202 == 1 ~ 'Homem presente',
          V202 == 2 ~ 'Mulher presente',
          V202 == 3 ~ 'Homem ausente',
          V202 == 4 ~ 'Mulher ausente',
          V202 == 5 ~ 'Homem n\u00e3o morador presente',
          V202 == 6 ~ 'Mulher n\u00e3o morador presente'
        )
      )
    }

    # RELACAO COM O CHEFE
    if ('V203' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V203 = dplyr::case_when(
          V203 == 7 ~ 'Chefe',
          V203 == 8 ~ 'C\u00f4njuge',
          V203 == 9 ~ 'Filho ou enteado',
          V203 == 0 ~ 'Neto',
          V203 == 1 ~ 'Pais e sogros',
          V203 == 2 ~ 'Outros parentes',
          V203 == 3 ~ 'Agregado',
          V203 == 4 ~ 'H\u00f3spede, pensionista ou empregado dom\u00e9stico',
          V203 == 5 ~ 'Ignorado',
          V203 == 6 ~ 'Boletim individual'
        )
      )
    }

    # TIPO DE IDADE - MESES OU ANOS (the value itself is in V204b)
    if ('V204' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V204 = dplyr::case_when(
          V204 == 0 ~ 'Meses',
          V204 == 1 ~ 'Anos',
          V204 == 5 ~ 'Idade acima de 99 anos',
          V204 == 9 ~ 'Ignorado'
        )
      )
    }

    # RELIGIAO
    if ('V205' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V205 = dplyr::case_when(
          V205 == 5 ~ 'Cat\u00f3lica romana',
          V205 == 6 ~ 'Protestante',
          V205 == 7 ~ 'Esp\u00edrita',
          V205 == 8 ~ 'Budista',
          V205 == 9 ~ 'Israelita',
          V205 == 0 ~ 'Ortodoxa',
          V205 == 1 ~ 'Maometana',
          V205 == 2 ~ 'Outra religi\u00e3o',
          V205 == 3 ~ 'Sem religi\u00e3o',
          V205 == 4 ~ 'Ignorado'
        )
      )
    }

    # COR
    if ('V206' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V206 = dplyr::case_when(
          V206 == 4 ~ 'Branca',
          V206 == 5 ~ 'Preta',
          V206 == 6 ~ 'Amarela',
          V206 == 7 ~ 'Parda',
          V206 == 8 ~ '\u00cdndia',
          V206 == 9 ~ 'Ignorado'
        )
      )
    }

    # NACIONALIDADE. Both sources are followed except on the wording of the
    # naturalised category: the questionnaire reads 'Naturalizado brasileiro',
    # which is used here and in every other census year.
    if ('V208' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V208 = dplyr::case_when(
          V208 == 9 ~ 'Brasileiro nato',
          V208 == 0 ~ 'Naturalizado brasileiro',
          V208 == 1 ~ 'Estrangeiro'
        )
      )
    }

    # PROCEDENCIA: URBANA OU RURAL (pessoas nao naturais do municipio)
    if ('V209' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V209 = dplyr::case_when(
          V209 == 0 ~ 'Zona rural de outro munic\u00edpio',
          V209 == 1 ~ 'Zona urbana de outro munic\u00edpio',
          V209 == 2 ~ 'Proced\u00eancia desconhecida (nascidos na UF de resid\u00eancia ou n\u00e3o moradores presentes)',
          V209 == 3 ~ 'Proced\u00eancia desconhecida (n\u00e3o naturais da UF de resid\u00eancia)'
        )
      )
    }

    # TEMPO DE IMIGRACAO. Code 0 is not numbered in the dictionary; it is the
    # state its unnumbered trailing line describes. Verified in the v0.7.0 file:
    # V299 == 0 occurs 10447853 times and coincides exactly with V209 == 2
    # (neither value ever pairs with any other), so it is the not-applicable code.
    if ('V299' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V299 = dplyr::case_when(
          V299 == 2 ~ 'Menos de 1 ano',
          V299 == 3 ~ '1 ano',
          V299 == 4 ~ '2 anos',
          V299 == 5 ~ '3 anos',
          V299 == 6 ~ '4 anos',
          V299 == 7 ~ '5 anos',
          V299 == 8 ~ '6 a 10 anos',
          V299 == 9 ~ '11 anos e mais',
          V299 == 1 ~ 'Aus\u00eancia de informa\u00e7\u00e3o',
          V299 == 0 ~ 'N\u00e3o se aplica (pessoas naturais do munic\u00edpio)'
        )
      )
    }

    # ALFABETIZACAO E FREQUENCIA A ESCOLA
    if ('V211' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V211 = dplyr::case_when(
          V211 == 0 ~ 'L\u00ea e frequenta escola',
          V211 == 1 ~ 'L\u00ea e n\u00e3o frequenta escola',
          V211 == 2 ~ 'N\u00e3o l\u00ea e frequenta escola',
          V211 == 3 ~ 'N\u00e3o l\u00ea e n\u00e3o frequenta escola',
          V211 == 4 ~ 'Ignorada'
        )
      )
    }

    # ULTIMA SERIE QUE CONCLUIU
    if ('V212' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V212 = dplyr::case_when(
          V212 == 4 ~ 'Primeira s\u00e9rie',
          V212 == 5 ~ 'Segunda s\u00e9rie',
          V212 == 6 ~ 'Terceira s\u00e9rie',
          V212 == 7 ~ 'Quarta s\u00e9rie',
          V212 == 8 ~ 'Quinta s\u00e9rie',
          V212 == 9 ~ 'Sexta s\u00e9rie',
          V212 == 0 ~ 'Est\u00e1 cursando o primeiro ano do elementar (n\u00e3o possui s\u00e9rie conclu\u00edda)',
          V212 == 1 ~ 'Nunca frequentou escola',
          V212 == 2 ~ 'Ignorado'
        )
      )
    }

    # GRAU DO CURSO
    if ('V213' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V213 = dplyr::case_when(
          V213 == 2 ~ 'Elementar (prim\u00e1rio)',
          V213 == 3 ~ 'M\u00e9dio primeiro ciclo (ginasial)',
          V213 == 4 ~ 'M\u00e9dio segundo ciclo (secund\u00e1rio, cient\u00edfico etc.)',
          V213 == 5 ~ 'Superior',
          V213 == 6 ~ 'Ignorado',
          V213 == 1 ~ 'Nunca frequentou escola',
          V213 == 0 ~ 'Est\u00e1 cursando o primeiro ano do elementar (n\u00e3o possui s\u00e9rie conclu\u00edda)'
        )
      )
    }

    # ESTADO CONJUGAL. Codes 6-8 follow the questionnaire (item P, boxes 56-58:
    # 'Casamento civil e religioso / Somente casamento civil / Somente casamento
    # religioso'), which the dictionary now matches. Code 9 keeps the
    # dictionary's 'Vivendo maritalmente', which is what questionnaire box 59
    # ('Outra', asked only of people living with a partner) substantively means.
    if ('V215' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V215 = dplyr::case_when(
          V215 == 6 ~ 'Casamento civil e religioso',
          V215 == 7 ~ 'Somente casamento civil',
          V215 == 8 ~ 'Somente casamento religioso',
          V215 == 9 ~ 'Vivendo maritalmente',
          V215 == 0 ~ 'Solteiro',
          V215 == 1 ~ 'Separado',
          V215 == 2 ~ 'Desquitado',
          V215 == 3 ~ 'Divorciado',
          V215 == 4 ~ 'Vi\u00favo',
          V215 == 5 ~ 'Ignorado'
        )
      )
    }

    # RENDIMENTOS (Cr$, media mensal)
    if ('V219' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V219 = dplyr::case_when(
          V219 == 5 ~ 'At\u00e9 2100',
          V219 == 6 ~ 'De 2101 a 3300',
          V219 == 7 ~ 'De 3301 a 4500',
          V219 == 8 ~ 'De 4501 a 6000',
          V219 == 9 ~ 'De 6001 a 10000',
          V219 == 0 ~ 'De 10001 a 20000',
          V219 == 1 ~ 'De 20001 a 50000',
          V219 == 2 ~ 'De 50001 e mais',
          V219 == 3 ~ 'N\u00e3o tem',
          V219 == 4 ~ 'Ignorado'
        )
      )
    }

    # ATIVIDADE NAO ECONOMICA
    if ('V220' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V220 = dplyr::case_when(
          V220 == 4 ~ 'Afazeres dom\u00e9sticos',
          V220 == 5 ~ 'Estudante',
          V220 == 6 ~ 'Aposentado',
          V220 == 7 ~ 'Vive de rendas',
          V220 == 8 ~ 'Doen\u00e7a tempor\u00e1ria',
          V220 == 9 ~ 'Invalidez permanente',
          V220 == 0 ~ 'Detento',
          V220 == 1 ~ 'Sem ocupa\u00e7\u00e3o',
          V220 == 2 ~ 'Ignorado',
          V220 == 3 ~ 'Prejudicado (economicamente ativos)'
        )
      )
    }

    # OCUPACAO NA ULTIMA SEMANA
    if ('V223' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V223 = dplyr::case_when(
          V223 == 2 ~ 'Mesma ocupa\u00e7\u00e3o declarada na V221',
          V223 == 3 ~ 'Outra ocupa\u00e7\u00e3o',
          V223 == 4 ~ 'Desempregado',
          V223 == 5 ~ 'Ignorado'
        )
      )
    }

    # POSICAO NA OCUPACAO
    if ('V224' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V224 = dplyr::case_when(
          V224 == 0 ~ 'Membro de fam\u00edlia ou institui\u00e7\u00e3o',
          V224 == 1 ~ 'Ignorado',
          V224 == 5 ~ 'Empregado p\u00fablico',
          V224 == 6 ~ 'Empregado particular',
          V224 == 7 ~ 'Trabalha por conta pr\u00f3pria',
          V224 == 8 ~ 'Parceiro ou meeiro',
          V224 == 9 ~ 'Empregador'
        )
      )
    }

    # DIAGNOSTICO DE CONSISTENCIA DO REGISTRO (variaveis adicionadas pelo
    # censobr; only filled for records from the 1.27% sample)
    diag_vars_1960 <- c('censobr_diag_households', 'censobr_diag_persons')
    diag_vars_1960 <- diag_vars_1960[diag_vars_1960 %in% cols]
    if (length(diag_vars_1960) > 0) {
      arrw <- dplyr::mutate(
        arrw,
        dplyr::across(
          all_of(diag_vars_1960),
          ~ case_when(
            .x == 2 ~ 'Problema n\u00e3o corrigido, mas ignor\u00e1vel (valores inv\u00e1lidos, n\u00e3o listados no dicion\u00e1rio, marcados como missing)',
            .x == 3 ~ 'Registro n\u00e3o problem\u00e1tico'
          )
        )
      )
    }
  }

  # YEAR 1970 ------------------------------------------------------------------
  if (year == 1970 & lang == 'pt') {
    # NOTE: labels transcribed from the 1970 population dictionary, normalised to
    # sentence case and cross-checked against the 1970 sample questionnaire
    # (CD 1.01, `questionnaire(1970)`); where the two disagree the comment on the
    # variable says which was used. CAVEAT: the dictionary currently served by
    # `data_dictionary(1970, ...)` is an earlier edition that miscodes V010, V025,
    # V031, V034, V035, V036, V037, V038 and V040; the labels here follow the
    # corrected dictionary, which the observed distributions confirm (e.g. V035
    # alfabetizacao: code 1 = 12944644, code 2 = 8159423, code 0 = 17688, so 1 is
    # 'Sim' and 0 is 'Sem declaracao', not the reverse). Codes are stored as doubles, so the
    # comparisons below are numeric. Variables whose categories live in the
    # dictionary's auxiliary files (V027 idade, V030 naturalidade, V033 UF
    # anterior, V039 curso, V044 ocupacao, V045 atividade, V050 filhos
    # nascidos vivos) are left as codes, as are the numeric variables (V005,
    # V020, V021, V041, V053, V054, ids), the geography codes V001-V003 and
    # the state/region columns censobr already provides as names.

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

    # CONDICAO DA FAMILIA
    if ('V006' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V006 = dplyr::case_when(
          V006 == 0 ~ 'Pessoa s\u00f3',
          V006 == 1 ~ '\u00danica',
          V006 == 2 ~ 'Principal',
          V006 == 3 ~ 'Secund\u00e1rio parente',
          V006 == 4 ~ 'Secund\u00e1rio n\u00e3o parente'
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
    # in NCr$; the dictionary as first published called them 'salarios minimos'.
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

    # CODIGO DO INFORMANTE
    if ('V022' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V022 = dplyr::case_when(
          V022 == 0 ~ 'N\u00e3o informante',
          V022 == 1 ~ 'Informante'
        )
      )
    }

    # SEXO
    if ('V023' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V023 = dplyr::case_when(
          V023 == 0 ~ 'Homem',
          V023 == 1 ~ 'Mulher'
        )
      )
    }

    # CONDICAO DE PRESENCA
    if ('V024' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V024 = dplyr::case_when(
          V024 == 0 ~ 'Morador presente',
          V024 == 1 ~ 'Morador ausente',
          V024 == 2 ~ 'N\u00e3o morador presente'
        )
      )
    }

    # PARENTESCO OU RELACAO COM O CHEFE DA FAMILIA. Code 9 is 'Individual (em
    # domicilio coletivo)' in the questionnaire (item 4); the dictionary as first published printed
    # it as 'Membro grupo-convidado'.
    if ('V025' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V025 = dplyr::case_when(
          V025 == 1 ~ 'Chefe da fam\u00edlia',
          V025 == 2 ~ 'C\u00f4njuge',
          V025 == 3 ~ 'Filho',
          V025 == 4 ~ 'Pais ou sogros',
          V025 == 5 ~ 'Outro parente',
          V025 == 6 ~ 'Agregado',
          V025 == 7 ~ 'Pensionista ou h\u00f3spede',
          V025 == 8 ~ 'Empregado dom\u00e9stico',
          V025 == 9 ~ 'Individual (em domic\u00edlio coletivo)',
          V025 == 0 ~ 'Ignorado'
        )
      )
    }

    # TIPO DE IDADE (the value itself is in V027)
    if ('V026' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V026 = dplyr::case_when(
          V026 == 0 ~ 'Ignorada',
          V026 == 1 ~ 'Declarada em meses',
          V026 == 2 ~ 'Presumida em meses',
          V026 == 3 ~ 'Declarada em anos',
          V026 == 4 ~ 'Presumida em anos'
        )
      )
    }

    # RELIGIAO
    if ('V028' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V028 = dplyr::case_when(
          V028 == 1 ~ 'Cat\u00f3lica romana',
          V028 == 2 ~ 'Evang\u00e9lica',
          V028 == 3 ~ 'Esp\u00edrita',
          V028 == 4 ~ 'Outra religi\u00e3o',
          V028 == 5 ~ 'Sem religi\u00e3o',
          V028 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # NACIONALIDADE. Both sources are followed except on the wording of the
    # naturalised category: the questionnaire reads 'Naturalizado brasileiro',
    # which is used here and in every other census year.
    if ('V029' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V029 = dplyr::case_when(
          V029 == 0 ~ 'Brasileiro nato',
          V029 == 1 ~ 'Naturalizado brasileiro',
          V029 == 2 ~ 'Estrangeiro'
        )
      )
    }

    # TEMPO DE RESIDENCIA NESTA UF. The dictionary as first published listed these categories shifted
    # one code down (0 = 'Menos de 1 ano', ..., 8 = 'Frente de seca', 9 = 'Nao
    # aplicavel'); the questionnaire (item 11) codes them 1-8 and the observed
    # distribution matches the questionnaire (and V032), so the questionnaire
    # coding is used, with the two extra dictionary categories moved along.
    if ('V031' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V031 = dplyr::case_when(
          V031 == 1 ~ 'Menos de 1 ano',
          V031 == 2 ~ '1 ano',
          V031 == 3 ~ '2 anos',
          V031 == 4 ~ '3 anos',
          V031 == 5 ~ '4 anos',
          V031 == 6 ~ '5 anos',
          V031 == 7 ~ 'De 6 a 10 anos',
          V031 == 8 ~ 'De 11 anos e mais',
          V031 == 9 ~ 'Frente de seca',
          V031 == 0 ~ 'N\u00e3o aplic\u00e1vel'
        )
      )
    }

    # TEMPO DE RESIDENCIA NESTE MUNICIPIO
    if ('V032' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V032 = dplyr::case_when(
          V032 == 1 ~ 'Menos de 1 ano',
          V032 == 2 ~ '1 ano',
          V032 == 3 ~ '2 anos',
          V032 == 4 ~ '3 anos',
          V032 == 5 ~ '4 anos',
          V032 == 6 ~ '5 anos',
          V032 == 7 ~ 'De 6 a 10 anos',
          V032 == 8 ~ 'De 11 anos e mais',
          V032 == 0 ~ 'N\u00e3o aplic\u00e1vel'
        )
      )
    }

    # SITUACAO DA RESIDENCIA NO MUNICIPIO ONDE MORAVA ANTERIORMENTE. The
    # questionnaire (item 14) has two options only; the dictionary as first published listed 2, 8
    # and 9 as 'Povoado rural 1/2/3'. Codes 3-7 also occur in the data but are
    # not in the dictionary and are left as NA.
    if ('V034' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V034 = dplyr::case_when(
          V034 == 0 ~ 'N\u00e3o aplic\u00e1vel',
          V034 == 1 ~ 'Cidade ou vila',
          V034 == 2 ~ 'Povoado ou zona rural',
          V034 == 8 ~ 'Povoado ou zona rural',
          V034 == 9 ~ 'Povoado ou zona rural'
        )
      )
    }

    # ALFABETIZACAO. The dictionary as first published listed 0 = Sim, 1 = Nao, 2 = Sem declaracao; the
    # questionnaire (item 15) codes Sim = 1, Nao = 2, and the observed
    # distribution (0 is a residual ~18k) matches the questionnaire.
    if ('V035' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V035 = dplyr::case_when(
          V035 == 1 ~ 'Sim',
          V035 == 2 ~ 'N\u00e3o',
          V035 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FREQUENTA A ESCOLA (same one-code shift as V035 in the dictionary as first published;
    # questionnaire item 16)
    if ('V036' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V036 = dplyr::case_when(
          V036 == 1 ~ 'Sim',
          V036 == 2 ~ 'N\u00e3o',
          V036 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # ULTIMA SERIE QUE CONCLUIU COM APROVACAO. Code 1 follows the questionnaire
    # (item 17, box 1 'Cursa 1o elementar', box 2 '1a serie'); the earlier HTML
    # dictionary printed code 1 as '1a serie do elementar', duplicating code 2.
    if ('V037' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V037 = dplyr::case_when(
          V037 == 1 ~ 'Cursa a 1\u00aa s\u00e9rie do elementar (nenhuma s\u00e9rie conclu\u00edda)',
          V037 == 2 ~ '1\u00aa s\u00e9rie',
          V037 == 3 ~ '2\u00aa s\u00e9rie',
          V037 == 4 ~ '3\u00aa s\u00e9rie',
          V037 == 5 ~ '4\u00aa s\u00e9rie',
          V037 == 6 ~ '5\u00aa ou 6\u00aa s\u00e9rie',
          V037 == 7 ~ 'Admiss\u00e3o ou vestibular',
          V037 == 8 ~ 'Artigo 99',
          V037 == 9 ~ 'Alfabetiza\u00e7\u00e3o de adultos',
          V037 == 0 ~ 'Nenhuma ou sem declara\u00e7\u00e3o'
        )
      )
    }

    # ULTIMO GRAU CONCLUIDO COM APROVACAO. Code 3 is 'Medio 2o ciclo' in the
    # questionnaire (item 17); the dictionary as first published printed 'Ginasial/medio 2o ciclo'.
    if ('V038' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V038 = dplyr::case_when(
          V038 == 1 ~ 'Prim\u00e1rio/elementar',
          V038 == 2 ~ 'Ginasial/m\u00e9dio 1\u00ba ciclo',
          V038 == 3 ~ 'M\u00e9dio 2\u00ba ciclo',
          V038 == 4 ~ 'Superior',
          V038 == 5 ~ 'Nunca frequentou escola',
          V038 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # ESTADO CONJUGAL. Code 1 is 'Casamento civil e religioso' in the
    # questionnaire (item 19); the dictionary as first published printed 'Casamento no civil'.
    if ('V040' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V040 = dplyr::case_when(
          V040 == 1 ~ 'Casamento civil e religioso',
          V040 == 2 ~ 'Casamento s\u00f3 no civil',
          V040 == 3 ~ 'Casamento s\u00f3 no religioso',
          V040 == 4 ~ 'Consensual ou outro',
          V040 == 5 ~ 'Solteiro',
          V040 == 6 ~ 'Separado',
          V040 == 7 ~ 'Desquitado',
          V040 == 8 ~ 'Divorciado',
          V040 == 9 ~ 'Vi\u00favo',
          V040 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # MUNICIPIO ONDE TRABALHA OU ESTUDA
    if ('V042' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V042 = dplyr::case_when(
          V042 == 1 ~ 'N\u00e3o trabalha nem estuda',
          V042 == 2 ~ 'Mora no munic\u00edpio',
          V042 == 3 ~ 'Outro munic\u00edpio',
          V042 == 4 ~ 'Frente de seca',
          V042 == 0 ~ 'Sem declara\u00e7\u00e3o, mas trabalha e estuda'
        )
      )
    }

    # SITUACAO PRINCIPAL DE EMPREGO
    if ('V043' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V043 = dplyr::case_when(
          V043 == 0 ~ 'Afazeres dom\u00e9sticos',
          V043 == 1 ~ 'Estudante',
          V043 == 2 ~ 'Aposentado',
          V043 == 3 ~ 'Vive de renda',
          V043 == 4 ~ 'Doente ou inv\u00e1lido',
          V043 == 5 ~ 'Detento',
          V043 == 6 ~ 'Sem ocupa\u00e7\u00e3o',
          V043 == 7 ~ 'Trabalha ou procura emprego e sem declara\u00e7\u00e3o'
        )
      )
    }

    # POSICAO NA OCUPACAO
    if ('V046' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V046 = dplyr::case_when(
          V046 == 1 ~ 'Empregado p\u00fablico',
          V046 == 2 ~ 'Empregado particular',
          V046 == 3 ~ 'Conta pr\u00f3pria ou aut\u00f4nomo',
          V046 == 4 ~ 'Parceiro ou meeiro',
          V046 == 5 ~ 'Empregador',
          V046 == 6 ~ 'N\u00e3o remunerado ou procura trabalho',
          V046 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # OCUPACAO QUE EXERCIA NA ULTIMA SEMANA (25/08/1970 A 31/08/1970)
    if ('V047' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V047 = dplyr::case_when(
          V047 == 1 ~ 'S\u00f3 a ocupa\u00e7\u00e3o habitual',
          V047 == 2 ~ 'S\u00f3 outra ocupa\u00e7\u00e3o',
          V047 == 3 ~ 'Ocupa\u00e7\u00e3o habitual e outra ocupa\u00e7\u00e3o',
          V047 == 4 ~ 'Desempregado',
          V047 == 5 ~ 'Procurando o primeiro trabalho',
          V047 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # TEMPO (MESES, ATIVIDADES AGROPECUARIAS) OU HORAS DE TRABALHO NA ULTIMA
    # SEMANA (questionnaire item 27)
    if ('V048' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V048 = dplyr::case_when(
          V048 == 1 ~ 'Menos de 3 meses',
          V048 == 2 ~ 'De 3 a 5 meses',
          V048 == 3 ~ 'De 6 a 8 meses',
          V048 == 4 ~ 'De 9 a 12 meses',
          V048 == 5 ~ 'Menos de 15 horas',
          V048 == 6 ~ 'De 15 a 39 horas',
          V048 == 7 ~ 'De 40 a 49 horas',
          V048 == 8 ~ 'De 50 horas e mais',
          V048 == 9 ~ 'Procurando trabalho',
          V048 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # HA QUANTO TEMPO PROCURA TRABALHO
    if ('V049' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V049 = dplyr::case_when(
          V049 == 1 ~ 'Menos de 3 meses',
          V049 == 2 ~ 'De 3 meses e mais',
          V049 == 3 ~ 'Trabalha',
          V049 == 0 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # QUANTIDADE DE FILHOS NASCIDOS MORTOS (9 = ignorado, not nine children)
    if ('V051' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V051 = dplyr::case_when(
          V051 == 0 ~ 'N\u00e3o teve',
          V051 == 1 ~ '1 filho',
          V051 == 2 ~ '2 filhos',
          V051 == 3 ~ '3 filhos',
          V051 == 4 ~ '4 filhos',
          V051 == 5 ~ '5 filhos',
          V051 == 6 ~ '6 filhos',
          V051 == 7 ~ '7 filhos',
          V051 == 8 ~ '8 filhos',
          V051 == 9 ~ 'Ignorado'
        )
      )
    }

    # QUANTIDADE DE FILHOS NASCIDOS NO ANO ANTERIOR AO CENSO (9 = ignorado)
    if ('V052' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V052 = dplyr::case_when(
          V052 == 0 ~ 'N\u00e3o teve',
          V052 == 1 ~ '1 filho',
          V052 == 2 ~ '2 filhos',
          V052 == 3 ~ '3 filhos',
          V052 == 9 ~ 'Ignorado'
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
    # NOTE: labels transcribed from the 1980 microdata dictionary
    # (`data_dictionary(1980, "population")` / `1980_dictionary_microdata.xlsx`,
    # both sheets), normalised to sentence case and cross-checked against the
    # 1980 sample questionnaire (CD 1.01, `questionnaire(1980)`); where the two
    # disagree the comment on the variable says which was used. The 1980
    # population file also carries the household record (V198, V201-V221),
    # which is labelled here with the same strings as in
    # add_labels_households(). Codes are stored as strings, except V517 and
    # V536, which are numbers. Variables whose categories live in the
    # dictionary's auxiliary files (V211 tempo de residencia, V512 UF/pais de
    # nascimento, V525 curso, V530/V542 ocupacao, V532/V544 ramo, V606 idade)
    # are left as codes, as are the 6-digit UF+municipio identifiers V518/V527,
    # the numeric variables (V212, V213, V602-V604, V606-V613, V557, V570, ids),
    # V605 (idade em meses, whose 12 categories are just the month count) and
    # the geography codes V2-V6, which censobr already provides as names.

    # SITUACAO DO DOMICILIO
    if ('V198' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V198 = dplyr::case_when(
          V198 == '1' ~ 'Cidade ou vila',
          V198 == '3' ~ '\u00c1rea urbana isolada',
          V198 == '5' ~ 'Aglomerado rural',
          V198 == '7' ~ 'Zona rural'
        )
      )
    }

    # ESPECIE DO DOMICILIO
    if ('V201' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V201 = dplyr::case_when(
          V201 == '1' ~ 'Particular permanente',
          V201 == '3' ~ 'Particular improvisado',
          V201 == '5' ~ 'Coletivo permanente',
          V201 == '7' ~ 'Coletivo improvisado'
        )
      )
    }

    # TIPO DO DOMICILIO
    if ('V202' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V202 = dplyr::case_when(
          V202 == '1' ~ 'Casa',
          V202 == '3' ~ 'Apartamento'
        )
      )
    }

    # PAREDES
    if ('V203' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V203 = dplyr::case_when(
          V203 == '2' ~ 'Alvenaria',
          V203 == '4' ~ 'Madeira',
          V203 == '6' ~ 'Taipa n\u00e3o revestida',
          V203 == '7' ~ 'Material aproveitado',
          V203 == '8' ~ 'Palha',
          V203 == '0' ~ 'Outro',
          V203 == '9' ~ 'Ignorado'
        )
      )
    }

    # PISO
    if ('V204' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V204 = dplyr::case_when(
          V204 == '1' ~ 'Madeira',
          V204 == '3' ~ 'Cer\u00e2mica',
          V204 == '4' ~ 'Cimento',
          V204 == '6' ~ 'Material aproveitado',
          V204 == '7' ~ 'Tijolo',
          V204 == '8' ~ 'Terra',
          V204 == '0' ~ 'Outro',
          V204 == '9' ~ 'Ignorado'
        )
      )
    }

    # COBERTURA
    if ('V205' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V205 = dplyr::case_when(
          V205 == '1' ~ 'Laje de concreto',
          V205 == '2' ~ 'Telha de barro',
          V205 == '3' ~ 'Telha de cimento-amianto',
          V205 == '4' ~ 'Zinco',
          V205 == '5' ~ 'Madeira',
          V205 == '6' ~ 'Palha',
          V205 == '7' ~ 'Material aproveitado',
          V205 == '0' ~ 'Outro',
          V205 == '9' ~ 'Ignorado'
        )
      )
    }

    # ABASTECIMENTO DE AGUA
    if ('V206' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V206 = dplyr::case_when(
          V206 == '1' ~ 'Com canaliza\u00e7\u00e3o interna - rede geral',
          V206 == '3' ~ 'Com canaliza\u00e7\u00e3o interna - po\u00e7o ou nascente',
          V206 == '5' ~ 'Com canaliza\u00e7\u00e3o interna - outra forma',
          V206 == '6' ~ 'Sem canaliza\u00e7\u00e3o interna - rede geral',
          V206 == '7' ~ 'Sem canaliza\u00e7\u00e3o interna - po\u00e7o ou nascente',
          V206 == '0' ~ 'Sem canaliza\u00e7\u00e3o interna - outra forma',
          V206 == '9' ~ 'Ignorado'
        )
      )
    }

    # ESCOADOURO
    if ('V207' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V207 = dplyr::case_when(
          V207 == '2' ~ 'Rede geral',
          V207 == '4' ~ 'Fossa s\u00e9ptica',
          V207 == '6' ~ 'Fossa rudimentar',
          V207 == '0' ~ 'Outro',
          V207 == '8' ~ 'N\u00e3o tem',
          V207 == '9' ~ 'Ignorado'
        )
      )
    }

    # USO DA INSTALACAO SANITARIA
    if ('V208' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V208 = dplyr::case_when(
          V208 == '1' ~ 'S\u00f3 do domic\u00edlio',
          V208 == '3' ~ 'Comum a mais de um domic\u00edlio',
          V208 == '8' ~ 'N\u00e3o tem',
          V208 == '9' ~ 'Ignorado'
        )
      )
    }

    # CONDICAO DE OCUPACAO
    if ('V209' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V209 = dplyr::case_when(
          V209 == '1' ~ 'Pr\u00f3prio - j\u00e1 acabou de pagar',
          V209 == '3' ~ 'Pr\u00f3prio - n\u00e3o acabou de pagar',
          V209 == '5' ~ 'Alugado',
          V209 == '6' ~ 'Cedido por empregador',
          V209 == '7' ~ 'Cedido por particular',
          V209 == '0' ~ 'Outra',
          V209 == '9' ~ 'Ignorado'
        )
      )
    }

    # PARA COZINHAR USA
    if ('V214' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V214 = dplyr::case_when(
          V214 == '1' ~ 'Fog\u00e3o',
          V214 == '3' ~ 'Fog\u00e3o improvisado',
          V214 == '5' ~ 'Fogareiro',
          V214 == '8' ~ 'N\u00e3o tem',
          V214 == '9' ~ 'Ignorado'
        )
      )
    }

    # COMBUSTIVEL USADO NA COZINHA
    if ('V215' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V215 = dplyr::case_when(
          V215 == '1' ~ 'G\u00e1s de botij\u00e3o',
          V215 == '2' ~ 'G\u00e1s canalizado',
          V215 == '3' ~ 'Lenha',
          V215 == '4' ~ 'Carv\u00e3o',
          V215 == '5' ~ '\u00d3leo ou querosene',
          V215 == '6' ~ '\u00c1lcool',
          V215 == '7' ~ 'Eletricidade',
          V215 == '8' ~ 'N\u00e3o tem',
          V215 == '9' ~ 'Ignorado'
        )
      )
    }

    # ILUMINACAO ELETRICA
    if ('V217' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V217 = dplyr::case_when(
          V217 == '2' ~ 'Tem - com medidor',
          V217 == '4' ~ 'Tem - sem medidor',
          V217 == '8' ~ 'N\u00e3o tem',
          V217 == '9' ~ 'Ignorado'
        )
      )
    }

    # TELEVISAO
    if ('V220' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V220 = dplyr::case_when(
          V220 == '1' ~ 'A cores',
          V220 == '3' ~ 'A cores e preto e branco',
          V220 == '5' ~ 'Preto e branco',
          V220 == '8' ~ 'N\u00e3o tem',
          V220 == '9' ~ 'Ignorado'
        )
      )
    }

    # AUTOMOVEL
    if ('V221' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V221 = dplyr::case_when(
          V221 == '1' ~ 'Tem - para uso particular',
          V221 == '3' ~ 'Tem - para trabalho',
          V221 == '8' ~ 'N\u00e3o tem',
          V221 == '9' ~ 'Ignorado'
        )
      )
    }

    # SITUACAO DA PESSOA (variavel 598). The dictionary writes code 0 in the
    # masculine ('urbano'); 'Urbana' is used here, as in every other census year.
    if ('V598' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V598 = dplyr::case_when(
          V598 == '0' ~ 'Urbana',
          V598 == '1' ~ 'Rural'
        )
      )
    }

    # SEXO
    if ('V501' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V501 = dplyr::case_when(
          V501 == '1' ~ 'Homem',
          V501 == '3' ~ 'Mulher'
        )
      )
    }

    # RELACAO COM O CHEFE DO DOMICILIO
    if ('V503' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V503 = dplyr::case_when(
          V503 == '0' ~ 'Individual',
          V503 == '1' ~ 'Chefe',
          V503 == '2' ~ 'C\u00f4njuge',
          V503 == '3' ~ 'Filho ou enteado',
          V503 == '4' ~ 'Pais ou sogros',
          V503 == '5' ~ 'Genro, nora ou outro parente',
          V503 == '6' ~ 'Agregado',
          V503 == '7' ~ 'H\u00f3spede ou pensionista',
          V503 == '8' ~ 'Empregado dom\u00e9stico',
          V503 == '9' ~ 'Parente do empregado dom\u00e9stico'
        )
      )
    }

    # RELACAO COM O CHEFE DA FAMILIA
    if ('V504' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V504 = dplyr::case_when(
          V504 == '0' ~ 'Individual',
          V504 == '1' ~ 'Chefe',
          V504 == '2' ~ 'C\u00f4njuge',
          V504 == '3' ~ 'Filho ou enteado',
          V504 == '4' ~ 'Pais ou sogros',
          V504 == '5' ~ 'Genro, nora ou outro parente',
          V504 == '6' ~ 'Agregado',
          V504 == '7' ~ 'H\u00f3spede ou pensionista',
          V504 == '8' ~ 'Empregado dom\u00e9stico',
          V504 == '9' ~ 'Parente do empregado dom\u00e9stico'
        )
      )
    }

    # FAMILIA A QUE PERTENCE
    if ('V505' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V505 = dplyr::case_when(
          V505 == '0' ~ '\u00danica',
          V505 == '1' ~ '1\u00aa convivente',
          V505 == '2' ~ '2\u00aa convivente',
          V505 == '3' ~ '3\u00aa convivente',
          V505 == '4' ~ 'Domic\u00edlio coletivo',
          V505 == '5' ~ 'Individual'
        )
      )
    }

    # RELIGIAO
    if ('V508' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V508 = dplyr::case_when(
          V508 == '0' ~ 'Sem religi\u00e3o',
          V508 == '1' ~ 'Cat\u00f3lica romana',
          V508 == '2' ~ 'Protestante tradicional',
          V508 == '3' ~ 'Protestante pentecostal',
          V508 == '4' ~ 'Esp\u00edrita kardecista',
          V508 == '5' ~ 'Esp\u00edrita afro-brasileira',
          V508 == '6' ~ 'Orientais',
          V508 == '7' ~ 'Judaica ou israelita',
          V508 == '8' ~ 'Outras religi\u00f5es',
          V508 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # COR
    if ('V509' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V509 = dplyr::case_when(
          V509 == '2' ~ 'Branca',
          V509 == '4' ~ 'Preta',
          V509 == '6' ~ 'Amarela',
          V509 == '8' ~ 'Parda',
          V509 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # TEM MAE VIVA
    if ('V510' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V510 = dplyr::case_when(
          V510 == '1' ~ 'Sim',
          V510 == '3' ~ 'N\u00e3o',
          V510 == '5' ~ 'N\u00e3o sabe',
          V510 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # NACIONALIDADE. Both sources are followed except on the wording of the
    # naturalised category: the questionnaire reads 'Naturalizado brasileiro',
    # which is used here and in every other census year.
    if ('V511' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V511 = dplyr::case_when(
          V511 == '2' ~ 'Brasileiro nato',
          V511 == '4' ~ 'Naturalizado brasileiro',
          V511 == '6' ~ 'Estrangeiro'
        )
      )
    }

    # NASCEU NESTE MUNICIPIO
    if ('V513' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V513 = dplyr::case_when(
          V513 == '1' ~ 'Sim',
          V513 == '8' ~ 'N\u00e3o'
        )
      )
    }

    # NESTE MUNICIPIO MOROU
    if ('V514' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V514 = dplyr::case_when(
          V514 == '2' ~ 'S\u00f3 na zona urbana',
          V514 == '4' ~ 'S\u00f3 na zona rural',
          V514 == '6' ~ 'Nas zonas urbana e rural',
          V514 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # NO MUNICIPIO EM QUE RESIDIA ANTERIORMENTE MORAVA
    if ('V515' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V515 = dplyr::case_when(
          V515 == '1' ~ 'Na zona urbana',
          V515 == '3' ~ 'Na zona rural',
          V515 == '8' ~ 'Nasceu',
          V515 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # HA QUANTOS ANOS MORA NESTA UF
    if ('V516' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V516 = dplyr::case_when(
          V516 == '0' ~ 'Menos de 1 ano',
          V516 == '1' ~ '1 ano',
          V516 == '2' ~ '2 anos',
          V516 == '3' ~ '3 anos',
          V516 == '4' ~ '4 anos',
          V516 == '5' ~ '5 anos',
          V516 == '6' ~ '6 a 9 anos',
          V516 == '7' ~ '10 anos ou mais',
          V516 == '8' ~ 'Nasceu',
          V516 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # HA QUANTOS ANOS MORA NESTE MUNICIPIO (same categories as V516; stored as
    # a number in this release)
    if ('V517' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V517 = dplyr::case_when(
          V517 == 0 ~ 'Menos de 1 ano',
          V517 == 1 ~ '1 ano',
          V517 == 2 ~ '2 anos',
          V517 == 3 ~ '3 anos',
          V517 == 4 ~ '4 anos',
          V517 == 5 ~ '5 anos',
          V517 == 6 ~ '6 a 9 anos',
          V517 == 7 ~ '10 anos ou mais',
          V517 == 8 ~ 'Nasceu',
          V517 == 9 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # SABE LER E ESCREVER
    if ('V519' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V519 = dplyr::case_when(
          V519 == '2' ~ 'Sim',
          V519 == '4' ~ 'N\u00e3o - j\u00e1 soube',
          V519 == '6' ~ 'N\u00e3o - nunca soube',
          V519 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # SERIE QUE FREQUENTA
    if ('V520' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V520 = dplyr::case_when(
          V520 == '0' ~ 'Nenhuma',
          V520 == '1' ~ '1\u00aa s\u00e9rie',
          V520 == '2' ~ '2\u00aa s\u00e9rie',
          V520 == '3' ~ '3\u00aa s\u00e9rie',
          V520 == '4' ~ '4\u00aa s\u00e9rie',
          V520 == '5' ~ '5\u00aa s\u00e9rie',
          V520 == '6' ~ '6\u00aa s\u00e9rie',
          V520 == '7' ~ '7\u00aa s\u00e9rie',
          V520 == '8' ~ '8\u00aa s\u00e9rie',
          V520 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # GRAU DA SERIE QUE FREQUENTA
    if ('V521' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V521 = dplyr::case_when(
          V521 == '0' ~ 'Nenhum',
          V521 == '1' ~ 'Prim\u00e1rio ou elementar',
          V521 == '2' ~ 'Ginasial ou m\u00e9dio 1\u00ba ciclo',
          V521 == '3' ~ '1\u00ba grau',
          V521 == '4' ~ '2\u00ba grau',
          V521 == '5' ~ 'Colegial ou m\u00e9dio 2\u00ba ciclo',
          V521 == '6' ~ 'Supletivo - 1\u00ba grau',
          V521 == '7' ~ 'Supletivo - 2\u00ba grau',
          V521 == '8' ~ 'Superior',
          V521 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # CURSO NAO SERIADO QUE FREQUENTA
    if ('V522' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V522 = dplyr::case_when(
          V522 == '0' ~ 'Nenhum',
          V522 == '1' ~ 'Pr\u00e9-escolar',
          V522 == '2' ~ 'Curso de alfabetiza\u00e7\u00e3o de adultos',
          V522 == '3' ~ 'Supletivo frequentando escola - 1\u00ba grau',
          V522 == '4' ~ 'Supletivo frequentando escola - 2\u00ba grau',
          V522 == '5' ~ 'Supletivo atrav\u00e9s de r\u00e1dio ou TV - 1\u00ba grau',
          V522 == '6' ~ 'Supletivo atrav\u00e9s de r\u00e1dio ou TV - 2\u00ba grau',
          V522 == '7' ~ 'Vestibular',
          V522 == '8' ~ 'Mestrado ou doutorado',
          V522 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # ULTIMA SERIE QUE CONCLUIU COM APROVACAO (same categories as V520)
    if ('V523' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V523 = dplyr::case_when(
          V523 == '0' ~ 'Nenhuma',
          V523 == '1' ~ '1\u00aa s\u00e9rie',
          V523 == '2' ~ '2\u00aa s\u00e9rie',
          V523 == '3' ~ '3\u00aa s\u00e9rie',
          V523 == '4' ~ '4\u00aa s\u00e9rie',
          V523 == '5' ~ '5\u00aa s\u00e9rie',
          V523 == '6' ~ '6\u00aa s\u00e9rie',
          V523 == '7' ~ '7\u00aa s\u00e9rie',
          V523 == '8' ~ '8\u00aa s\u00e9rie',
          V523 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # GRAU DA ULTIMA SERIE CONCLUIDA COM APROVACAO. The dictionary (VAR 524,
    # CATEG=9) carries its own 9-code list, which agrees with questionnaire item
    # 24 and with the observed distribution.
    if ('V524' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V524 = dplyr::case_when(
          V524 == '0' ~ 'Nenhum',
          V524 == '1' ~ 'Curso de alfabetiza\u00e7\u00e3o de adultos',
          V524 == '2' ~ 'Prim\u00e1rio ou elementar',
          V524 == '3' ~ 'Ginasial ou m\u00e9dio 1\u00ba ciclo',
          V524 == '4' ~ '1\u00ba grau',
          V524 == '5' ~ '2\u00ba grau',
          V524 == '6' ~ 'Colegial ou m\u00e9dio 2\u00ba ciclo',
          V524 == '7' ~ 'Superior',
          V524 == '8' ~ 'Mestrado ou doutorado'
        )
      )
    }

    # ESTADO CONJUGAL
    if ('V526' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V526 = dplyr::case_when(
          V526 == '0' ~ 'Vi\u00favo',
          V526 == '1' ~ 'Casamento civil e religioso',
          V526 == '2' ~ 'S\u00f3 casamento civil',
          V526 == '3' ~ 'S\u00f3 casamento religioso',
          V526 == '4' ~ 'Outra',
          V526 == '5' ~ 'Solteiro',
          V526 == '6' ~ 'Separado',
          V526 == '7' ~ 'Desquitado',
          V526 == '8' ~ 'Divorciado',
          V526 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # TRABALHOU NOS ULTIMOS 12 MESES (01/09/1979 A 31/08/1980)
    if ('V528' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V528 = dplyr::case_when(
          V528 == '1' ~ 'Sim',
          V528 == '3' ~ 'N\u00e3o',
          V528 == '5' ~ 'Frente da seca'
        )
      )
    }

    # OCUPACAO ATUAL
    if ('V529' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V529 = dplyr::case_when(
          V529 == '0' ~ 'Trabalhou',
          V529 == '1' ~ 'Procurando trabalho - j\u00e1 trabalhou',
          V529 == '2' ~ 'Procurando trabalho - nunca trabalhou',
          V529 == '3' ~ 'Aposentado ou pensionista',
          V529 == '4' ~ 'Vive de renda',
          V529 == '5' ~ 'Detento',
          V529 == '6' ~ 'Estudante',
          V529 == '7' ~ 'Doente ou inv\u00e1lido',
          V529 == '8' ~ 'Afazeres dom\u00e9sticos',
          V529 == '9' ~ 'Sem ocupa\u00e7\u00e3o'
        )
      )
    }

    # POSICAO NO ESTABELECIMENTO (OCUPACAO HABITUAL)
    if ('V533' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V533 = dplyr::case_when(
          V533 == '0' ~ 'Sem remunera\u00e7\u00e3o',
          V533 == '1' ~ 'Trabalhador agr\u00edcola volante - com intermedi\u00e1rio',
          V533 == '2' ~ 'Trabalhador agr\u00edcola volante - sem intermedi\u00e1rio',
          V533 == '3' ~ 'Parceiro ou meeiro - empregado',
          V533 == '4' ~ 'Parceiro ou meeiro - empregador',
          V533 == '5' ~ 'Parceiro ou meeiro - conta pr\u00f3pria',
          V533 == '6' ~ 'Empregado',
          V533 == '7' ~ 'Empregador',
          V533 == '8' ~ 'Conta pr\u00f3pria',
          V533 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # E CONTRIBUINTE DE INSTITUTO DE PREVIDENCIA
    if ('V534' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V534 = dplyr::case_when(
          V534 == '2' ~ 'Federal',
          V534 == '4' ~ 'Estadual',
          V534 == '6' ~ 'Municipal',
          V534 == '8' ~ 'N\u00e3o \u00e9',
          V534 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # HORAS HABITUALMENTE TRABALHADAS POR SEMANA NA OCUPACAO PRINCIPAL
    if ('V535' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V535 = dplyr::case_when(
          V535 == '1' ~ 'Menos de 15 horas',
          V535 == '2' ~ 'De 15 a 29 horas',
          V535 == '3' ~ 'De 30 a 39 horas',
          V535 == '4' ~ 'De 40 a 48 horas',
          V535 == '5' ~ 'De 49 horas e mais',
          V535 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # HORAS HABITUALMENTE TRABALHADAS POR SEMANA EM TODAS AS OCUPACOES. The
    # questionnaire (item 36) and the dictionary (VAR 536, CATEG=6) both code the
    # brackets 4, 5, 6, 7 and 0 - the 0 is not a typo - matching the observed
    # distribution. Stored as a number in this release.
    if ('V536' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V536 = dplyr::case_when(
          V536 == 4 ~ 'Menos de 15 horas',
          V536 == 5 ~ 'De 15 a 29 horas',
          V536 == 6 ~ 'De 30 a 39 horas',
          V536 == 7 ~ 'De 40 a 48 horas',
          V536 == 0 ~ 'De 49 horas e mais',
          V536 == 9 ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # QUANTOS SALARIOS RECEBE POR ANO
    if ('V540' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V540 = dplyr::case_when(
          V540 == '0' ~ 'N\u00e3o \u00e9 empregado',
          V540 == '2' ~ '12 sal\u00e1rios',
          V540 == '3' ~ '13 sal\u00e1rios',
          V540 == '4' ~ '14 sal\u00e1rios',
          V540 == '5' ~ '15 sal\u00e1rios',
          V540 == '6' ~ '16 e mais sal\u00e1rios',
          V540 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # NA ULTIMA SEMANA (25 A 31/08/1980) ESTAVA. Wording from questionnaire item
    # 41; codes 1 and 2 render the form's 'a ocupacao do Quesito 30' as 'a
    # ocupacao habitual', which is how item 30 defines itself.
    if ('V541' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V541 = dplyr::case_when(
          V541 == '1' ~ 'S\u00f3 exercendo a ocupa\u00e7\u00e3o habitual',
          V541 == '2' ~ 'Exercendo a ocupa\u00e7\u00e3o habitual e outra(s)',
          V541 == '3' ~ 'S\u00f3 exercendo ocupa\u00e7\u00e3o diferente da habitual',
          V541 == '4' ~ 'Desempregado procurando trabalho',
          V541 == '5' ~ 'Tinha-se aposentado e n\u00e3o trabalhou',
          V541 == '6' ~ 'N\u00e3o tinha trabalho nem estava procurando'
        )
      )
    }

    # POSICAO NO ESTABELECIMENTO (OCUPACAO NAO HABITUAL; same categories as V533)
    if ('V545' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V545 = dplyr::case_when(
          V545 == '0' ~ 'Sem remunera\u00e7\u00e3o',
          V545 == '1' ~ 'Trabalhador agr\u00edcola volante - com intermedi\u00e1rio',
          V545 == '2' ~ 'Trabalhador agr\u00edcola volante - sem intermedi\u00e1rio',
          V545 == '3' ~ 'Parceiro ou meeiro - empregado',
          V545 == '4' ~ 'Parceiro ou meeiro - empregador',
          V545 == '5' ~ 'Parceiro ou meeiro - conta pr\u00f3pria',
          V545 == '6' ~ 'Empregado',
          V545 == '7' ~ 'Empregador',
          V545 == '8' ~ 'Conta pr\u00f3pria',
          V545 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FILHOS TIDOS NASCIDOS VIVOS
    if ('V550' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V550 = dplyr::case_when(
          V550 == '0' ~ 'Sem filho nascido vivo',
          V550 == '1' ~ '1 filho nascido vivo',
          V550 == '2' ~ '2 filhos nascidos vivos',
          V550 == '3' ~ '3 filhos nascidos vivos',
          V550 == '4' ~ '4 filhos nascidos vivos',
          V550 == '5' ~ '5 filhos nascidos vivos',
          V550 == '6' ~ '6 filhos nascidos vivos',
          V550 == '7' ~ '7 filhos nascidos vivos',
          V550 == '8' ~ '8 filhos nascidos vivos',
          V550 == '9' ~ '9 filhos nascidos vivos',
          V550 == '10' ~ '10 filhos nascidos vivos',
          V550 == '11' ~ '11 filhos nascidos vivos',
          V550 == '12' ~ '12 filhos nascidos vivos',
          V550 == '13' ~ '13 filhos nascidos vivos',
          V550 == '14' ~ '14 filhos nascidos vivos',
          V550 == '15' ~ '15 filhos nascidos vivos',
          V550 == '98' ~ 'A ser imputado',
          V550 == '99' ~ 'Ignorado'
        )
      )
    }

    # FILHAS TIDAS NASCIDAS VIVAS
    if ('V551' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V551 = dplyr::case_when(
          V551 == '0' ~ 'Sem filha nascida viva',
          V551 == '1' ~ '1 filha nascida viva',
          V551 == '2' ~ '2 filhas nascidas vivas',
          V551 == '3' ~ '3 filhas nascidas vivas',
          V551 == '4' ~ '4 filhas nascidas vivas',
          V551 == '5' ~ '5 filhas nascidas vivas',
          V551 == '6' ~ '6 filhas nascidas vivas',
          V551 == '7' ~ '7 filhas nascidas vivas',
          V551 == '8' ~ '8 filhas nascidas vivas',
          V551 == '9' ~ '9 filhas nascidas vivas',
          V551 == '10' ~ '10 filhas nascidas vivas',
          V551 == '11' ~ '11 filhas nascidas vivas',
          V551 == '12' ~ '12 filhas nascidas vivas',
          V551 == '13' ~ '13 filhas nascidas vivas',
          V551 == '14' ~ '14 filhas nascidas vivas',
          V551 == '15' ~ '15 filhas nascidas vivas',
          V551 == '98' ~ 'A ser imputado',
          V551 == '99' ~ 'Ignorado'
        )
      )
    }

    # FILHOS TIDOS NASCIDOS MORTOS
    if ('V552' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V552 = dplyr::case_when(
          V552 == '0' ~ 'Sem filho nascido morto',
          V552 == '1' ~ '1 filho nascido morto',
          V552 == '2' ~ '2 filhos nascidos mortos',
          V552 == '3' ~ '3 filhos nascidos mortos',
          V552 == '4' ~ '4 filhos nascidos mortos',
          V552 == '5' ~ '5 filhos nascidos mortos',
          V552 == '6' ~ '6 filhos nascidos mortos',
          V552 == '7' ~ '7 filhos nascidos mortos',
          V552 == '8' ~ '8 filhos nascidos mortos',
          V552 == '9' ~ '9 filhos nascidos mortos',
          V552 == '98' ~ 'A ser imputado',
          V552 == '99' ~ 'Ignorado'
        )
      )
    }

    # FILHAS TIDAS NASCIDAS MORTAS
    if ('V553' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V553 = dplyr::case_when(
          V553 == '0' ~ 'Sem filha nascida morta',
          V553 == '1' ~ '1 filha nascida morta',
          V553 == '2' ~ '2 filhas nascidas mortas',
          V553 == '3' ~ '3 filhas nascidas mortas',
          V553 == '4' ~ '4 filhas nascidas mortas',
          V553 == '5' ~ '5 filhas nascidas mortas',
          V553 == '6' ~ '6 filhas nascidas mortas',
          V553 == '7' ~ '7 filhas nascidas mortas',
          V553 == '8' ~ '8 filhas nascidas mortas',
          V553 == '9' ~ '9 filhas nascidas mortas',
          V553 == '98' ~ 'A ser imputado',
          V553 == '99' ~ 'Ignorado'
        )
      )
    }

    # FILHOS VIVOS NA DATA DA PESQUISA
    if ('V554' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V554 = dplyr::case_when(
          V554 == '0' ~ 'Sem filho vivo',
          V554 == '1' ~ '1 filho vivo',
          V554 == '2' ~ '2 filhos vivos',
          V554 == '3' ~ '3 filhos vivos',
          V554 == '4' ~ '4 filhos vivos',
          V554 == '5' ~ '5 filhos vivos',
          V554 == '6' ~ '6 filhos vivos',
          V554 == '7' ~ '7 filhos vivos',
          V554 == '8' ~ '8 filhos vivos',
          V554 == '9' ~ '9 filhos vivos',
          V554 == '10' ~ '10 filhos vivos',
          V554 == '11' ~ '11 filhos vivos',
          V554 == '12' ~ '12 filhos vivos',
          V554 == '13' ~ '13 filhos vivos',
          V554 == '14' ~ '14 filhos vivos',
          V554 == '15' ~ '15 filhos vivos',
          V554 == '98' ~ 'A ser imputado',
          V554 == '99' ~ 'Ignorado'
        )
      )
    }

    # FILHAS VIVAS NA DATA DA PESQUISA
    if ('V555' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V555 = dplyr::case_when(
          V555 == '0' ~ 'Sem filha viva',
          V555 == '1' ~ '1 filha viva',
          V555 == '2' ~ '2 filhas vivas',
          V555 == '3' ~ '3 filhas vivas',
          V555 == '4' ~ '4 filhas vivas',
          V555 == '5' ~ '5 filhas vivas',
          V555 == '6' ~ '6 filhas vivas',
          V555 == '7' ~ '7 filhas vivas',
          V555 == '8' ~ '8 filhas vivas',
          V555 == '9' ~ '9 filhas vivas',
          V555 == '10' ~ '10 filhas vivas',
          V555 == '11' ~ '11 filhas vivas',
          V555 == '12' ~ '12 filhas vivas',
          V555 == '13' ~ '13 filhas vivas',
          V555 == '14' ~ '14 filhas vivas',
          V555 == '15' ~ '15 filhas vivas',
          V555 == '98' ~ 'A ser imputado',
          V555 == '99' ~ 'Ignorado'
        )
      )
    }

    # MES DE NASCIMENTO DO ULTIMO FILHO NASCIDO VIVO
    if ('V556' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V556 = dplyr::case_when(
          V556 == '0' ~ 'Sem filho nascido vivo',
          V556 == '1' ~ 'Janeiro',
          V556 == '2' ~ 'Fevereiro',
          V556 == '3' ~ 'Mar\u00e7o',
          V556 == '4' ~ 'Abril',
          V556 == '5' ~ 'Maio',
          V556 == '6' ~ 'Junho',
          V556 == '7' ~ 'Julho',
          V556 == '8' ~ 'Agosto',
          V556 == '9' ~ 'Setembro',
          V556 == '10' ~ 'Outubro',
          V556 == '11' ~ 'Novembro',
          V556 == '12' ~ 'Dezembro',
          V556 == '20' ~ 'Presumida',
          V556 == '98' ~ 'A ser imputado',
          V556 == '99' ~ 'Ignorada'
        )
      )
    }

    # CLASSE DE RENDIMENTO BRUTO NA OCUPACAO PRINCIPAL (same categories as V681)
    if ('V680' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V680 = dplyr::case_when(
          V680 == '0' ~ 'Sem renda',
          V680 == '1' ~ 'At\u00e9 1/8 do sal\u00e1rio m\u00ednimo',
          V680 == '2' ~ 'Mais de 1/8 a 1/4 do sal\u00e1rio m\u00ednimo',
          V680 == '3' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V680 == '4' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V680 == '5' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V680 == '6' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V680 == '7' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V680 == '8' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V680 == '9' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V680 == '10' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V680 == '11' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V680 == '12' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V680 == '99' ~ 'Ignorado'
        )
      )
    }

    # CLASSE DE RENDA TOTAL
    if ('V681' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V681 = dplyr::case_when(
          V681 == '0' ~ 'Sem renda',
          V681 == '1' ~ 'At\u00e9 1/8 do sal\u00e1rio m\u00ednimo',
          V681 == '2' ~ 'Mais de 1/8 a 1/4 do sal\u00e1rio m\u00ednimo',
          V681 == '3' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V681 == '4' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V681 == '5' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V681 == '6' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V681 == '7' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V681 == '8' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V681 == '9' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V681 == '10' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V681 == '11' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V681 == '12' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V681 == '99' ~ 'Ignorado'
        )
      )
    }

    # CLASSE DE RENDIMENTO BRUTO EM TODAS AS OCUPACOES (same categories as V681)
    if ('V682' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V682 = dplyr::case_when(
          V682 == '0' ~ 'Sem renda',
          V682 == '1' ~ 'At\u00e9 1/8 do sal\u00e1rio m\u00ednimo',
          V682 == '2' ~ 'Mais de 1/8 a 1/4 do sal\u00e1rio m\u00ednimo',
          V682 == '3' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V682 == '4' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V682 == '5' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V682 == '6' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V682 == '7' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V682 == '8' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V682 == '9' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V682 == '10' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V682 == '11' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V682 == '12' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V682 == '99' ~ 'Ignorado'
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
            .x == '1' ~ 'Tem',
            .x == '8' ~ 'N\u00e3o tem',
            .x == '9' ~ 'Ignorado'
          )
        )
      )
    }
  }

  # YEAR 1991 ------------------------------------------------------------------
  if (year == 1991 & lang == 'pt') {
    # NOTE: labels transcribed from the 1991 microdata dictionary
    # (`data_dictionary(1991, "population")` / `1991_dictionary_microdata.xlsx`,
    # both sheets), normalised to sentence case and cross-checked against the
    # 1991 sample questionnaire (CD 1.02, `questionnaire(1991)`), which agrees
    # with the dictionary throughout. The 1991 population file also carries the
    # household record (V0201-V0227, V1061, V2013, V2014, V2094, V2112, V2122),
    # labelled here with the same strings as in add_labels_households(). Every
    # labelled variable is stored as a string without leading zeros ('1', ...,
    # '15', '20'). Variables whose categories live in auxiliary files (V0346
    # ocupacao, V0347 atividade, V3191/V3211 municipio) are left as codes, as
    # are the numeric variables (ages, counts of children, incomes, V0313/V0317/
    # V0318 anos de moradia, V3152 ano de fixacao de residencia no pais, V3005
    # ordem da mae, V0211-V0213, V0335-V0342, ids, weights), V0099/V0098 record
    # fields, and the geography codes V1101, V1102, V7001, V7002 and V7004,
    # which censobr already provides as names.

    # SITUACAO DO DOMICILIO
    if ('V1061' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V1061 = dplyr::case_when(
          V1061 == '1' ~ '\u00c1rea urbanizada',
          V1061 == '2' ~ '\u00c1rea n\u00e3o urbanizada',
          V1061 == '3' ~ '\u00c1rea urbana isolada',
          V1061 == '4' ~ 'Aglomerado rural de extens\u00e3o urbana',
          V1061 == '5' ~ 'Aglomerado rural isolado ou povoado',
          V1061 == '6' ~ 'Aglomerado rural isolado ou n\u00facleo',
          V1061 == '7' ~ 'Outros aglomerados',
          V1061 == '8' ~ '\u00c1rea rural (exclusive aglomerado rural)'
        )
      )
    }

    # REGIAO METROPOLITANA
    if ('V7003' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V7003 = dplyr::case_when(
          V7003 == '0' ~ 'N\u00e3o metropolitana',
          V7003 == '1' ~ 'Bel\u00e9m',
          V7003 == '2' ~ 'Fortaleza',
          V7003 == '3' ~ 'Recife',
          V7003 == '4' ~ 'Salvador',
          V7003 == '5' ~ 'Belo Horizonte',
          V7003 == '6' ~ 'Rio de Janeiro',
          V7003 == '7' ~ 'S\u00e3o Paulo',
          V7003 == '8' ~ 'Curitiba',
          V7003 == '9' ~ 'Porto Alegre'
        )
      )
    }

    # ESPECIE DO DOMICILIO
    if ('V0201' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0201 = dplyr::case_when(
          V0201 == '1' ~ 'Particular permanente',
          V0201 == '2' ~ 'Particular improvisado',
          V0201 == '3' ~ 'Coletivo'
        )
      )
    }

    # LOCALIZACAO
    if ('V0202' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0202 = dplyr::case_when(
          V0202 == '1' ~ 'Casa isolada ou de condom\u00ednio',
          V0202 == '2' ~ 'Casa em conjunto residencial popular',
          V0202 == '3' ~ 'Casa em aglomerado subnormal',
          V0202 == '4' ~ 'Apartamento isolado ou de condom\u00ednio',
          V0202 == '5' ~ 'Apartamento em conjunto residencial popular',
          V0202 == '6' ~ 'Apartamento em aglomerado subnormal',
          V0202 == '7' ~ 'C\u00f4modos'
        )
      )
    }

    # PAREDES
    if ('V0203' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0203 = dplyr::case_when(
          V0203 == '1' ~ 'Alvenaria',
          V0203 == '2' ~ 'Madeira aparelhada',
          V0203 == '3' ~ 'Taipa n\u00e3o revestida',
          V0203 == '4' ~ 'Material aproveitado',
          V0203 == '5' ~ 'Palha',
          V0203 == '6' ~ 'Outro'
        )
      )
    }

    # COBERTURA
    if ('V0204' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0204 = dplyr::case_when(
          V0204 == '1' ~ 'Laje de concreto',
          V0204 == '2' ~ 'Telha de barro',
          V0204 == '3' ~ 'Telha de cimento-amianto',
          V0204 == '4' ~ 'Zinco',
          V0204 == '5' ~ 'Madeira aparelhada',
          V0204 == '6' ~ 'Palha',
          V0204 == '7' ~ 'Material aproveitado',
          V0204 == '8' ~ 'Outro'
        )
      )
    }

    # ABASTECIMENTO DE AGUA
    if ('V0205' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0205 = dplyr::case_when(
          V0205 == '1' ~ 'Rede geral com canaliza\u00e7\u00e3o interna',
          V0205 == '2' ~ 'Po\u00e7o ou nascente com canaliza\u00e7\u00e3o interna',
          V0205 == '3' ~ 'Outra forma com canaliza\u00e7\u00e3o interna',
          V0205 == '4' ~ 'Rede geral sem canaliza\u00e7\u00e3o interna',
          V0205 == '5' ~ 'Po\u00e7o ou nascente sem canaliza\u00e7\u00e3o interna',
          V0205 == '6' ~ 'Outra forma sem canaliza\u00e7\u00e3o interna'
        )
      )
    }

    # INSTALACAO SANITARIA
    if ('V0206' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0206 = dplyr::case_when(
          V0206 == '0' ~ 'N\u00e3o tem',
          V0206 == '1' ~ 'Rede geral',
          V0206 == '2' ~ 'Fossa s\u00e9ptica ligada \u00e0 rede pluvial',
          V0206 == '3' ~ 'Fossa s\u00e9ptica sem escoadouro',
          V0206 == '4' ~ 'Fossa rudimentar',
          V0206 == '5' ~ 'Vala negra',
          V0206 == '6' ~ 'Outro',
          V0206 == '7' ~ 'N\u00e3o sabe'
        )
      )
    }

    # USO DA INSTALACAO SANITARIA
    if ('V0207' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0207 = dplyr::case_when(
          V0207 == '0' ~ 'N\u00e3o tem',
          V0207 == '1' ~ 'S\u00f3 do domic\u00edlio',
          V0207 == '2' ~ 'Comum a mais de um domic\u00edlio'
        )
      )
    }

    # CONDICAO DE OCUPACAO DO DOMICILIO
    if ('V0208' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0208 = dplyr::case_when(
          V0208 == '1' ~ 'Pr\u00f3prio - a constru\u00e7\u00e3o e o terreno',
          V0208 == '2' ~ 'Pr\u00f3prio - s\u00f3 a constru\u00e7\u00e3o',
          V0208 == '3' ~ 'Alugado',
          V0208 == '4' ~ 'Cedido por empregador',
          V0208 == '5' ~ 'Cedido por particular',
          V0208 == '6' ~ 'Outra'
        )
      )
    }

    # FAIXAS DE ALUGUEL MENSAL
    if ('V2094' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2094 = dplyr::case_when(
          V2094 == '0' ~ 'N\u00e3o paga',
          V2094 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V2094 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V2094 == '3' ~ 'Mais de 1/2 a 1 sal\u00e1rio m\u00ednimo',
          V2094 == '4' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V2094 == '5' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V2094 == '6' ~ 'Mais de 3 a 4 sal\u00e1rios m\u00ednimos',
          V2094 == '7' ~ 'Mais de 4 a 5 sal\u00e1rios m\u00ednimos',
          V2094 == '8' ~ 'Mais de 5 sal\u00e1rios m\u00ednimos',
          V2094 == '9' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # COMBUSTIVEL USADO PARA COZINHAR
    if ('V0210' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0210 = dplyr::case_when(
          V0210 == '0' ~ 'N\u00e3o tem fog\u00e3o ou fogareiro',
          V0210 == '1' ~ 'G\u00e1s canalizado',
          V0210 == '2' ~ 'S\u00f3 g\u00e1s de botij\u00e3o',
          V0210 == '3' ~ 'S\u00f3 lenha',
          V0210 == '4' ~ 'G\u00e1s de botij\u00e3o e lenha',
          V0210 == '5' ~ 'Carv\u00e3o',
          V0210 == '6' ~ 'Outro'
        )
      )
    }

    # FAIXAS DE DENSIDADE DE MORADORES POR COMODO
    if ('V2112' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2112 = dplyr::case_when(
          V2112 == '1' ~ 'At\u00e9 0,5',
          V2112 == '2' ~ 'Mais de 0,5 a 1',
          V2112 == '3' ~ 'Mais de 1 a 1,5',
          V2112 == '4' ~ 'Mais de 1,5 a 2',
          V2112 == '5' ~ 'Mais de 2'
        )
      )
    }

    # FAIXAS DE DENSIDADE DE MORADORES POR DORMITORIO
    if ('V2122' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2122 = dplyr::case_when(
          V2122 == '1' ~ 'At\u00e9 1 morador',
          V2122 == '2' ~ 'Mais de 1 a 1,5 morador',
          V2122 == '3' ~ 'Mais de 1,5 a 2 moradores',
          V2122 == '4' ~ 'Mais de 2 a 2,5 moradores',
          V2122 == '5' ~ 'Mais de 2,5 a 3 moradores',
          V2122 == '6' ~ 'Mais de 3 a 4 moradores',
          V2122 == '7' ~ 'Mais de 4 moradores'
        )
      )
    }

    # DESTINO DO LIXO
    if ('V0214' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0214 = dplyr::case_when(
          V0214 == '1' ~ 'Coletado diretamente',
          V0214 == '2' ~ 'Coletado indiretamente',
          V0214 == '3' ~ 'Queimado',
          V0214 == '4' ~ 'Enterrado',
          V0214 == '5' ~ 'Jogado em terreno baldio',
          V0214 == '6' ~ 'Jogado em rio, lago ou mar',
          V0214 == '7' ~ 'Outro'
        )
      )
    }

    # TELEFONE
    if ('V0217' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0217 = dplyr::case_when(
          V0217 == '0' ~ 'N\u00e3o tem',
          V0217 == '1' ~ 'Uma linha',
          V0217 == '2' ~ 'Duas ou mais linhas'
        )
      )
    }

    # AUTOMOVEL PARTICULAR
    if ('V0218' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0218 = dplyr::case_when(
          V0218 == '0' ~ 'N\u00e3o tem',
          V0218 == '1' ~ 'Um carro',
          V0218 == '2' ~ 'Dois carros',
          V0218 == '3' ~ 'Tr\u00eas ou mais carros'
        )
      )
    }

    # AUTOMOVEL PARA TRABALHO
    if ('V0219' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0219 = dplyr::case_when(
          V0219 == '0' ~ 'N\u00e3o tem',
          V0219 == '1' ~ 'Pr\u00f3prio',
          V0219 == '2' ~ 'Cedido'
        )
      )
    }

    # ILUMINACAO
    if ('V0221' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0221 = dplyr::case_when(
          V0221 == '1' ~ 'El\u00e9trica com medidor',
          V0221 == '2' ~ 'El\u00e9trica sem medidor',
          V0221 == '3' ~ '\u00d3leo ou querosene',
          V0221 == '4' ~ 'Outra'
        )
      )
    }

    # GELADEIRA
    if ('V0222' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0222 = dplyr::case_when(
          V0222 == '0' ~ 'N\u00e3o tem',
          V0222 == '1' ~ 'Uma porta',
          V0222 == '2' ~ 'Mais de uma porta'
        )
      )
    }

    # TELEVISAO EM CORES
    if ('V0224' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0224 = dplyr::case_when(
          V0224 == '0' ~ 'N\u00e3o tem',
          V0224 == '1' ~ 'Um aparelho',
          V0224 == '2' ~ 'Dois aparelhos',
          V0224 == '3' ~ 'Tr\u00eas ou mais aparelhos'
        )
      )
    }

    # FAIXAS DE RENDIMENTO NOMINAL MEDIO MENSAL DOMICILIAR
    if ('V2013' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2013 = dplyr::case_when(
          V2013 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V2013 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V2013 == '3' ~ 'Mais de 1/2 a 1 sal\u00e1rio m\u00ednimo',
          V2013 == '4' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V2013 == '5' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V2013 == '6' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V2013 == '7' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V2013 == '8' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V2013 == '9' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V2013 == '10' ~ 'Mais de 20 a 30 sal\u00e1rios m\u00ednimos',
          V2013 == '11' ~ 'Mais de 30 sal\u00e1rios m\u00ednimos',
          V2013 == '12' ~ 'Sem rendimentos',
          V2013 == '13' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FAIXAS DE RENDIMENTO REAL MEDIO MENSAL DOMICILIAR
    if ('V2014' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2014 = dplyr::case_when(
          V2014 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V2014 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V2014 == '3' ~ 'Mais de 1/2 a 1 sal\u00e1rio m\u00ednimo',
          V2014 == '4' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V2014 == '5' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V2014 == '6' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V2014 == '7' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V2014 == '8' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V2014 == '9' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V2014 == '10' ~ 'Mais de 20 a 30 sal\u00e1rios m\u00ednimos',
          V2014 == '11' ~ 'Mais de 30 sal\u00e1rios m\u00ednimos',
          V2014 == '12' ~ 'Sem rendimentos',
          V2014 == '13' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # SEXO
    if ('V0301' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0301 = dplyr::case_when(
          V0301 == '1' ~ 'Masculino',
          V0301 == '2' ~ 'Feminino'
        )
      )
    }

    # CONDICAO NO DOMICILIO
    if ('V0302' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0302 = dplyr::case_when(
          V0302 == '1' ~ 'Chefe',
          V0302 == '2' ~ 'C\u00f4njuge',
          V0302 == '3' ~ 'Filho(a)',
          V0302 == '4' ~ 'Enteado(a)',
          V0302 == '5' ~ 'Pai ou m\u00e3e',
          V0302 == '6' ~ 'Sogro(a)',
          V0302 == '7' ~ 'Av\u00f4(\u00f3) ou bisav\u00f4(\u00f3)',
          V0302 == '8' ~ 'Neto(a) ou bisneto(a)',
          V0302 == '9' ~ 'Genro ou nora',
          V0302 == '10' ~ 'Irm\u00e3o ou irm\u00e3',
          V0302 == '11' ~ 'Cunhado(a)',
          V0302 == '12' ~ 'Outros parentes',
          V0302 == '13' ~ 'Agregado(a)',
          V0302 == '14' ~ 'Pensionista',
          V0302 == '15' ~ 'Empregado(a) dom\u00e9stico(a)',
          V0302 == '16' ~ 'Parente do(a) empregado(a) dom\u00e9stico(a)',
          V0302 == '20' ~ 'Individual'
        )
      )
    }

    # CONDICAO NA FAMILIA. Code 16 ('parente do empregado domestico') belongs to
    # V0302, not to this variable: the dictionary lists 1-15 and 20 for V0303, and
    # the v0.7.0 file confirms it - V0303 takes no value 16 (V0302 does, 5451 times).
    if ('V0303' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0303 = dplyr::case_when(
          V0303 == '1' ~ 'Chefe',
          V0303 == '2' ~ 'C\u00f4njuge',
          V0303 == '3' ~ 'Filho(a)',
          V0303 == '4' ~ 'Enteado(a)',
          V0303 == '5' ~ 'Pai ou m\u00e3e',
          V0303 == '6' ~ 'Sogro(a)',
          V0303 == '7' ~ 'Av\u00f4(\u00f3) ou bisav\u00f4(\u00f3)',
          V0303 == '8' ~ 'Neto(a) ou bisneto(a)',
          V0303 == '9' ~ 'Genro ou nora',
          V0303 == '10' ~ 'Irm\u00e3o ou irm\u00e3',
          V0303 == '11' ~ 'Cunhado(a)',
          V0303 == '12' ~ 'Outros parentes',
          V0303 == '13' ~ 'Agregado(a)',
          V0303 == '14' ~ 'Pensionista',
          V0303 == '15' ~ 'Empregado(a) dom\u00e9stico(a)',
          V0303 == '20' ~ 'Individual'
        )
      )
    }

    # TIPO DE FAMILIA
    if ('V0304' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0304 = dplyr::case_when(
          V0304 == '1' ~ '\u00danica',
          V0304 == '2' ~ 'Domic\u00edlio coletivo',
          V0304 == '3' ~ '1\u00aa fam\u00edlia convivente',
          V0304 == '4' ~ '2\u00aa fam\u00edlia convivente',
          V0304 == '5' ~ '3\u00aa fam\u00edlia convivente',
          V0304 == '6' ~ '4\u00aa fam\u00edlia convivente',
          V0304 == '7' ~ '5\u00aa fam\u00edlia convivente'
        )
      )
    }

    # ESPECIE DE FAMILIA
    if ('V2011' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V2011 = dplyr::case_when(
          V2011 == '1' ~ 'Nuclear',
          V2011 == '2' ~ 'Estendida',
          V2011 == '3' ~ 'Composta',
          V2011 == '4' ~ 'Unipessoal'
        )
      )
    }

    # FAIXAS DE RENDA DO CASAL
    if ('V3044' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3044 = dplyr::case_when(
          V3044 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V3044 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3044 == '3' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V3044 == '4' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V3044 == '5' ~ 'Mais de 1 a 1 1/4 sal\u00e1rios m\u00ednimos',
          V3044 == '6' ~ 'Mais de 1 1/4 a 1 1/2 sal\u00e1rios m\u00ednimos',
          V3044 == '7' ~ 'Mais de 1 1/2 a 2 sal\u00e1rios m\u00ednimos',
          V3044 == '8' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3044 == '9' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3044 == '10' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3044 == '11' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V3044 == '12' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V3044 == '13' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V3044 == '14' ~ 'Sem rendimentos',
          V3044 == '15' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FAIXAS DE RENDIMENTO NOMINAL MEDIO MENSAL FAMILIAR
    if ('V3046' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3046 = dplyr::case_when(
          V3046 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V3046 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3046 == '3' ~ 'Mais de 1/2 a 1 sal\u00e1rio m\u00ednimo',
          V3046 == '4' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V3046 == '5' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3046 == '6' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3046 == '7' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3046 == '8' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V3046 == '9' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V3046 == '10' ~ 'Mais de 20 a 30 sal\u00e1rios m\u00ednimos',
          V3046 == '11' ~ 'Mais de 30 sal\u00e1rios m\u00ednimos',
          V3046 == '12' ~ 'Sem rendimentos',
          V3046 == '13' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FAIXAS DE RENDIMENTO REAL MEDIO MENSAL FAMILIAR
    if ('V3047' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3047 = dplyr::case_when(
          V3047 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V3047 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3047 == '3' ~ 'Mais de 1/2 a 1 sal\u00e1rio m\u00ednimo',
          V3047 == '4' ~ 'Mais de 1 a 2 sal\u00e1rios m\u00ednimos',
          V3047 == '5' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3047 == '6' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3047 == '7' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3047 == '8' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V3047 == '9' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V3047 == '10' ~ 'Mais de 20 a 30 sal\u00e1rios m\u00ednimos',
          V3047 == '11' ~ 'Mais de 30 sal\u00e1rios m\u00ednimos',
          V3047 == '12' ~ 'Sem rendimentos',
          V3047 == '13' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FAIXAS DE RENDIMENTO NOMINAL MEDIO MENSAL FAMILIAR PER CAPITA
    if ('V3049' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3049 = dplyr::case_when(
          V3049 == '1' ~ 'At\u00e9 1/8 de sal\u00e1rio m\u00ednimo',
          V3049 == '2' ~ 'Mais de 1/8 a 1/4 sal\u00e1rio m\u00ednimo',
          V3049 == '3' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3049 == '4' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V3049 == '5' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V3049 == '6' ~ 'Mais de 1 a 1 1/4 sal\u00e1rios m\u00ednimos',
          V3049 == '7' ~ 'Mais de 1 1/4 a 1 1/2 sal\u00e1rios m\u00ednimos',
          V3049 == '8' ~ 'Mais de 1 1/2 a 2 sal\u00e1rios m\u00ednimos',
          V3049 == '9' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3049 == '10' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3049 == '11' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3049 == '12' ~ 'Mais de 10 sal\u00e1rios m\u00ednimos',
          V3049 == '13' ~ 'Sem rendimento',
          V3049 == '14' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # TIPO DE IDADE
    if ('V3071' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3071 = dplyr::case_when(
          V3071 == '1' ~ 'Idade presumida',
          V3071 == '2' ~ 'Idade declarada'
        )
      )
    }

    # RACA OU COR
    if ('V0309' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0309 = dplyr::case_when(
          V0309 == '1' ~ 'Branca',
          V0309 == '2' ~ 'Preta',
          V0309 == '3' ~ 'Amarela',
          V0309 == '4' ~ 'Parda',
          V0309 == '5' ~ 'Ind\u00edgena',
          V0309 == '9' ~ 'Ignorado'
        )
      )
    }

    # RELIGIAO
    if ('V0310' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0310 = dplyr::case_when(
          V0310 == '0' ~ 'Sem religi\u00e3o',
          V0310 == '11' ~ 'Cat\u00f3lica apost\u00f3lica romana',
          V0310 == '12' ~ 'Cat\u00f3lica apost\u00f3lica brasileira',
          V0310 == '13' ~ 'Cat\u00f3lica ortodoxa',
          V0310 == '21' ~ 'Evang\u00e9lica tradicional luterana',
          V0310 == '22' ~ 'Evang\u00e9lica tradicional presbiteriana',
          V0310 == '23' ~ 'Evang\u00e9lica tradicional metodista',
          V0310 == '24' ~ 'Evang\u00e9lica tradicional batista',
          V0310 == '25' ~ 'Evang\u00e9lica tradicional congregacional',
          V0310 == '26' ~ 'Evang\u00e9lica tradicional adventista',
          V0310 == '27' ~ 'Evang\u00e9lica tradicional episcopal anglicana',
          V0310 == '28' ~ 'Evang\u00e9lica tradicional menonita',
          V0310 == '29' ~ 'Evang\u00e9lica tradicional n\u00e3o determinada',
          V0310 == '30' ~ 'Evang\u00e9lica tradicional outras',
          V0310 == '31' ~ 'Evang\u00e9lica pentecostal Assembl\u00e9ia de Deus',
          V0310 == '32' ~ 'Evang\u00e9lica pentecostal Congrega\u00e7\u00e3o Crist\u00e3 do Brasil',
          V0310 == '33' ~ 'Evang\u00e9lica pentecostal O Brasil para Cristo',
          V0310 == '34' ~ 'Evang\u00e9lica pentecostal Evangelho Quadrangular',
          V0310 == '35' ~ 'Evang\u00e9lica pentecostal Universal do Reino de Deus',
          V0310 == '36' ~ 'Evang\u00e9lica pentecostal Casa da Ben\u00e7\u00e3o',
          V0310 == '37' ~ 'Evang\u00e9lica pentecostal Casa da Ora\u00e7\u00e3o',
          V0310 == '38' ~ 'Evang\u00e9lica pentecostal Deus \u00e9 Amor',
          V0310 == '39' ~ 'Evang\u00e9lica pentecostal Maranata',
          V0310 == '40' ~ 'Evang\u00e9lica pentecostal tradicional renovada',
          V0310 == '41' ~ 'Evang\u00e9lica pentecostal n\u00e3o determinada',
          V0310 == '45' ~ 'Evang\u00e9lica pentecostal outras',
          V0310 == '49' ~ 'Evang\u00e9lica n\u00e3o determinada',
          V0310 == '51' ~ 'Neo-crist\u00e3 m\u00f3rmon',
          V0310 == '52' ~ 'Neo-crist\u00e3 testemunha de Jeov\u00e1',
          V0310 == '53' ~ 'Neo-crist\u00e3 LBV',
          V0310 == '59' ~ 'Neo-crist\u00e3 outra',
          V0310 == '61' ~ 'Medi\u00fanica esp\u00edrita',
          V0310 == '62' ~ 'Medi\u00fanica umbandista',
          V0310 == '63' ~ 'Medi\u00fanica candomblecista',
          V0310 == '71' ~ 'Judaica ou israelita',
          V0310 == '75' ~ 'Oriental budista',
          V0310 == '76' ~ 'Oriental messi\u00e2nica',
          V0310 == '77' ~ 'Oriental Seicho-No-Ie',
          V0310 == '79' ~ 'Oriental outras',
          V0310 == '81' ~ 'Outras - islamismo',
          V0310 == '82' ~ 'Outras - esot\u00e9rica',
          V0310 == '83' ~ 'Outras - ind\u00edgena',
          V0310 == '84' ~ 'Outras - grupos minorit\u00e1rios',
          V0310 == '85' ~ 'N\u00e3o determinada ou mal definida - crist\u00e3',
          V0310 == '86' ~ 'N\u00e3o determinada ou mal definida - crente',
          V0310 == '89' ~ 'N\u00e3o determinada ou mal definida - outras',
          V0310 == '99' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # DEFICIENCIA FISICA OU MENTAL
    if ('V0311' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0311 = dplyr::case_when(
          V0311 == '0' ~ 'Nenhuma das enumeradas',
          V0311 == '1' ~ 'Cegueira',
          V0311 == '2' ~ 'Surdez',
          V0311 == '3' ~ 'Paralisia de um dos lados',
          V0311 == '4' ~ 'Paralisia das pernas',
          V0311 == '5' ~ 'Paralisia total',
          V0311 == '6' ~ 'Falta de membro(s) ou parte dele(s)',
          V0311 == '7' ~ 'Defici\u00eancia mental',
          V0311 == '8' ~ 'Mais de uma',
          V0311 == '9' ~ 'Ignorado'
        )
      )
    }

    # MOROU NESTE MUNICIPIO
    if ('V0312' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0312 = dplyr::case_when(
          V0312 == '1' ~ 'S\u00f3 na zona urbana',
          V0312 == '2' ~ 'S\u00f3 na zona rural',
          V0312 == '3' ~ 'Nas zonas urbana e rural'
        )
      )
    }

    # NASCEU NESTE MUNICIPIO
    if ('V0314' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0314 = dplyr::case_when(
          V0314 == '1' ~ 'Sim e sempre morou neste',
          V0314 == '2' ~ 'Sim, mas j\u00e1 morou em outro',
          V0314 == '3' ~ 'N\u00e3o nasceu'
        )
      )
    }

    # NACIONALIDADE
    if ('V3151' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3151 = dplyr::case_when(
          V3151 == '1' ~ 'Brasileiro nato',
          V3151 == '2' ~ 'Naturalizado brasileiro',
          V3151 == '3' ~ 'Estrangeiro'
        )
      )
    }

    # UNIDADE DA FEDERACAO OU PAIS ESTRANGEIRO DE NASCIMENTO
    if ('V0316' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0316 = dplyr::case_when(
          V0316 == '1' ~ 'Rond\u00f4nia',
          V0316 == '2' ~ 'Acre',
          V0316 == '3' ~ 'Amazonas',
          V0316 == '4' ~ 'Roraima',
          V0316 == '5' ~ 'Par\u00e1',
          V0316 == '6' ~ 'Amap\u00e1',
          V0316 == '7' ~ 'Tocantins',
          V0316 == '8' ~ 'Maranh\u00e3o',
          V0316 == '9' ~ 'Piau\u00ed',
          V0316 == '10' ~ 'Cear\u00e1',
          V0316 == '11' ~ 'Rio Grande do Norte',
          V0316 == '12' ~ 'Para\u00edba',
          V0316 == '13' ~ 'Pernambuco',
          V0316 == '14' ~ 'Alagoas',
          V0316 == '15' ~ 'Sergipe',
          V0316 == '16' ~ 'Bahia',
          V0316 == '17' ~ 'Minas Gerais',
          V0316 == '18' ~ 'Esp\u00edrito Santo',
          V0316 == '19' ~ 'Rio de Janeiro',
          V0316 == '20' ~ 'S\u00e3o Paulo',
          V0316 == '21' ~ 'Paran\u00e1',
          V0316 == '22' ~ 'Santa Catarina',
          V0316 == '23' ~ 'Rio Grande do Sul',
          V0316 == '24' ~ 'Mato Grosso do Sul',
          V0316 == '25' ~ 'Mato Grosso',
          V0316 == '26' ~ 'Goi\u00e1s',
          V0316 == '27' ~ 'Distrito Federal',
          V0316 == '29' ~ 'Brasil sem especifica\u00e7\u00e3o',
          V0316 == '30' ~ 'Argentina',
          V0316 == '31' ~ 'Bol\u00edvia',
          V0316 == '32' ~ 'Canad\u00e1',
          V0316 == '33' ~ 'Chile',
          V0316 == '34' ~ 'Col\u00f4mbia',
          V0316 == '35' ~ 'Costa Rica',
          V0316 == '36' ~ 'Cuba',
          V0316 == '37' ~ 'Equador',
          V0316 == '38' ~ 'Estados Unidos',
          V0316 == '39' ~ 'Guatemala',
          V0316 == '40' ~ 'Guiana Inglesa',
          V0316 == '41' ~ 'Guiana Francesa',
          V0316 == '42' ~ 'Haiti',
          V0316 == '43' ~ 'Honduras',
          V0316 == '44' ~ 'Belize',
          V0316 == '45' ~ 'Jamaica',
          V0316 == '46' ~ 'M\u00e9xico',
          V0316 == '47' ~ 'Nicar\u00e1gua',
          V0316 == '48' ~ 'Panam\u00e1',
          V0316 == '49' ~ 'Paraguai',
          V0316 == '50' ~ 'Peru',
          V0316 == '51' ~ 'Rep\u00fablica Dominicana',
          V0316 == '52' ~ 'El Salvador',
          V0316 == '53' ~ 'Suriname',
          V0316 == '54' ~ 'Uruguai',
          V0316 == '55' ~ 'Venezuela',
          V0316 == '56' ~ 'Outros pa\u00edses da Am\u00e9rica',
          V0316 == '58' ~ 'Alemanha',
          V0316 == '59' ~ '\u00c1ustria',
          V0316 == '60' ~ 'B\u00e9lgica',
          V0316 == '61' ~ 'Bulg\u00e1ria',
          V0316 == '62' ~ 'Dinamarca',
          V0316 == '63' ~ 'Espanha',
          V0316 == '64' ~ 'Finl\u00e2ndia',
          V0316 == '65' ~ 'Fran\u00e7a',
          V0316 == '66' ~ 'Gr\u00e3-Bretanha',
          V0316 == '67' ~ 'Gr\u00e9cia',
          V0316 == '68' ~ 'Holanda',
          V0316 == '69' ~ 'Hungria',
          V0316 == '70' ~ 'Irlanda',
          V0316 == '71' ~ 'It\u00e1lia',
          V0316 == '72' ~ 'Iugosl\u00e1via',
          V0316 == '73' ~ 'Noruega',
          V0316 == '74' ~ 'Pol\u00f4nia',
          V0316 == '75' ~ 'Portugal',
          V0316 == '76' ~ 'Rom\u00eania',
          V0316 == '77' ~ 'Su\u00e9cia',
          V0316 == '78' ~ 'Su\u00ed\u00e7a',
          V0316 == '79' ~ 'Checoslov\u00e1quia',
          V0316 == '80' ~ 'U.R.S.S.',
          V0316 == '81' ~ 'Outros pa\u00edses da Europa',
          V0316 == '82' ~ 'Angola',
          V0316 == '83' ~ 'Egito',
          V0316 == '84' ~ 'Mo\u00e7ambique',
          V0316 == '85' ~ 'Outros pa\u00edses da \u00c1frica',
          V0316 == '86' ~ 'China Continental',
          V0316 == '87' ~ 'China Formosa',
          V0316 == '88' ~ 'Cor\u00e9ia',
          V0316 == '89' ~ '\u00cdndia',
          V0316 == '90' ~ 'Israel',
          V0316 == '91' ~ 'Jap\u00e3o',
          V0316 == '92' ~ 'L\u00edbano',
          V0316 == '93' ~ 'Paquist\u00e3o',
          V0316 == '94' ~ 'S\u00edria',
          V0316 == '95' ~ 'Turquia',
          V0316 == '96' ~ 'Outros pa\u00edses da \u00c1sia',
          V0316 == '97' ~ 'Austr\u00e1lia',
          V0316 == '98' ~ 'Outros pa\u00edses da Oceania',
          V0316 == '99' ~ 'Estrangeiro n\u00e3o especificado'
        )
      )
    }

    # UF OU PAIS ESTRANGEIRO QUE MORAVA ANTES
    if ('V0319' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0319 = dplyr::case_when(
          V0319 == '11' ~ 'Rond\u00f4nia',
          V0319 == '12' ~ 'Acre',
          V0319 == '13' ~ 'Amazonas',
          V0319 == '14' ~ 'Roraima',
          V0319 == '15' ~ 'Par\u00e1',
          V0319 == '16' ~ 'Amap\u00e1',
          V0319 == '17' ~ 'Tocantins',
          V0319 == '21' ~ 'Maranh\u00e3o',
          V0319 == '22' ~ 'Piau\u00ed',
          V0319 == '23' ~ 'Cear\u00e1',
          V0319 == '24' ~ 'Rio Grande do Norte',
          V0319 == '25' ~ 'Para\u00edba',
          V0319 == '26' ~ 'Pernambuco',
          V0319 == '27' ~ 'Alagoas',
          V0319 == '28' ~ 'Sergipe',
          V0319 == '29' ~ 'Bahia',
          V0319 == '31' ~ 'Minas Gerais',
          V0319 == '32' ~ 'Esp\u00edrito Santo',
          V0319 == '33' ~ 'Rio de Janeiro',
          V0319 == '35' ~ 'S\u00e3o Paulo',
          V0319 == '41' ~ 'Paran\u00e1',
          V0319 == '42' ~ 'Santa Catarina',
          V0319 == '43' ~ 'Rio Grande do Sul',
          V0319 == '50' ~ 'Mato Grosso do Sul',
          V0319 == '51' ~ 'Mato Grosso',
          V0319 == '52' ~ 'Goi\u00e1s',
          V0319 == '53' ~ 'Distrito Federal',
          V0319 == '54' ~ 'Brasil n\u00e3o especificado',
          V0319 == '80' ~ 'Pa\u00eds estrangeiro ou mal definido',
          V0319 == '99' ~ 'Ignorado'
        )
      )
    }

    # SITUACAO DO DOMICILIO DE RESIDENCIA ANTERIOR
    if ('V0320' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0320 = dplyr::case_when(
          V0320 == '1' ~ 'Na zona urbana',
          V0320 == '2' ~ 'Na zona rural',
          V0320 == '9' ~ 'Ignorado'
        )
      )
    }

    # UF OU PAIS ESTRANGEIRO EM QUE MORAVA EM 01/09/1986
    if ('V0321' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0321 = dplyr::case_when(
          V0321 == '11' ~ 'Rond\u00f4nia',
          V0321 == '12' ~ 'Acre',
          V0321 == '13' ~ 'Amazonas',
          V0321 == '14' ~ 'Roraima',
          V0321 == '15' ~ 'Par\u00e1',
          V0321 == '16' ~ 'Amap\u00e1',
          V0321 == '17' ~ 'Tocantins',
          V0321 == '21' ~ 'Maranh\u00e3o',
          V0321 == '22' ~ 'Piau\u00ed',
          V0321 == '23' ~ 'Cear\u00e1',
          V0321 == '24' ~ 'Rio Grande do Norte',
          V0321 == '25' ~ 'Para\u00edba',
          V0321 == '26' ~ 'Pernambuco',
          V0321 == '27' ~ 'Alagoas',
          V0321 == '28' ~ 'Sergipe',
          V0321 == '29' ~ 'Bahia',
          V0321 == '31' ~ 'Minas Gerais',
          V0321 == '32' ~ 'Esp\u00edrito Santo',
          V0321 == '33' ~ 'Rio de Janeiro',
          V0321 == '35' ~ 'S\u00e3o Paulo',
          V0321 == '41' ~ 'Paran\u00e1',
          V0321 == '42' ~ 'Santa Catarina',
          V0321 == '43' ~ 'Rio Grande do Sul',
          V0321 == '50' ~ 'Mato Grosso do Sul',
          V0321 == '51' ~ 'Mato Grosso',
          V0321 == '52' ~ 'Goi\u00e1s',
          V0321 == '53' ~ 'Distrito Federal',
          V0321 == '54' ~ 'Brasil n\u00e3o especificado',
          V0321 == '70' ~ 'Neste munic\u00edpio',
          V0321 == '80' ~ 'Pa\u00eds estrangeiro ou mal definido',
          V0321 == '99' ~ 'Ignorado'
        )
      )
    }

    # SITUACAO DO DOMICILIO DE RESIDENCIA EM 01/09/1986
    if ('V0322' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0322 = dplyr::case_when(
          V0322 == '1' ~ 'Na zona urbana',
          V0322 == '2' ~ 'Na zona rural',
          V0322 == '9' ~ 'Ignorado'
        )
      )
    }

    # ALFABETIZACAO
    if ('V0323' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0323 = dplyr::case_when(
          V0323 == '1' ~ 'Sabe ler e escrever',
          V0323 == '2' ~ 'N\u00e3o sabe'
        )
      )
    }

    # SERIE QUE FREQUENTA
    if ('V0324' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0324 = dplyr::case_when(
          V0324 == '0' ~ 'Nenhuma',
          V0324 == '1' ~ '1\u00aa s\u00e9rie',
          V0324 == '2' ~ '2\u00aa s\u00e9rie',
          V0324 == '3' ~ '3\u00aa s\u00e9rie',
          V0324 == '4' ~ '4\u00aa s\u00e9rie',
          V0324 == '5' ~ '5\u00aa s\u00e9rie',
          V0324 == '6' ~ '6\u00aa s\u00e9rie',
          V0324 == '7' ~ '7\u00aa s\u00e9rie',
          V0324 == '8' ~ '8\u00aa s\u00e9rie'
        )
      )
    }

    # GRAU QUE FREQUENTA EM CURSO SERIADO
    if ('V0325' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0325 = dplyr::case_when(
          V0325 == '0' ~ 'Nenhum',
          V0325 == '1' ~ '1\u00ba grau',
          V0325 == '2' ~ '2\u00ba grau',
          V0325 == '3' ~ 'Superior',
          V0325 == '4' ~ 'Supletivo - 1\u00ba grau',
          V0325 == '5' ~ 'Supletivo - 2\u00ba grau'
        )
      )
    }

    # GRAU QUE FREQUENTA EM CURSO NAO SERIADO
    if ('V0326' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0326 = dplyr::case_when(
          V0326 == '0' ~ 'Nenhum',
          V0326 == '1' ~ 'Pr\u00e9-escolar',
          V0326 == '2' ~ 'Curso de alfabetiza\u00e7\u00e3o de adultos',
          V0326 == '3' ~ 'Supletivo n\u00e3o seriado - 1\u00ba grau',
          V0326 == '4' ~ 'Supletivo n\u00e3o seriado - 2\u00ba grau',
          V0326 == '5' ~ 'Pr\u00e9-vestibular',
          V0326 == '6' ~ 'Mestrado ou doutorado'
        )
      )
    }

    # ULTIMA SERIE CONCLUIDA COM APROVACAO
    if ('V0327' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0327 = dplyr::case_when(
          V0327 == '0' ~ 'Nenhuma',
          V0327 == '1' ~ '1\u00aa s\u00e9rie',
          V0327 == '2' ~ '2\u00aa s\u00e9rie',
          V0327 == '3' ~ '3\u00aa s\u00e9rie',
          V0327 == '4' ~ '4\u00aa s\u00e9rie',
          V0327 == '5' ~ '5\u00aa s\u00e9rie',
          V0327 == '6' ~ '6\u00aa s\u00e9rie',
          V0327 == '7' ~ '7\u00aa s\u00e9rie',
          V0327 == '8' ~ '8\u00aa s\u00e9rie',
          V0327 == '9' ~ 'Nunca frequentou'
        )
      )
    }

    # GRAU DA ULTIMA SERIE CONCLUIDA COM APROVACAO
    if ('V0328' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0328 = dplyr::case_when(
          V0328 == '0' ~ 'Nenhum',
          V0328 == '1' ~ 'Curso de alfabetiza\u00e7\u00e3o de adultos',
          V0328 == '2' ~ 'Prim\u00e1rio ou elementar',
          V0328 == '3' ~ 'Ginasial ou m\u00e9dio 1\u00ba ciclo',
          V0328 == '4' ~ '1\u00ba grau',
          V0328 == '5' ~ '2\u00ba grau',
          V0328 == '6' ~ 'Colegial ou m\u00e9dio 2\u00ba ciclo',
          V0328 == '7' ~ 'Superior',
          V0328 == '8' ~ 'Mestrado ou doutorado'
        )
      )
    }

    # ANOS DE ESTUDO
    if ('V3241' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3241 = dplyr::case_when(
          V3241 == '0' ~ 'Sem instru\u00e7\u00e3o',
          V3241 == '1' ~ '1 ano de estudo',
          V3241 == '2' ~ '2 anos de estudo',
          V3241 == '3' ~ '3 anos de estudo',
          V3241 == '4' ~ '4 anos de estudo',
          V3241 == '5' ~ '5 anos de estudo',
          V3241 == '6' ~ '6 anos de estudo',
          V3241 == '7' ~ '7 anos de estudo',
          V3241 == '8' ~ '8 anos de estudo',
          V3241 == '9' ~ '9 anos de estudo',
          V3241 == '10' ~ '10 anos de estudo',
          V3241 == '11' ~ '11 anos de estudo',
          V3241 == '12' ~ '12 anos de estudo',
          V3241 == '13' ~ '13 anos de estudo',
          V3241 == '14' ~ '14 anos de estudo',
          V3241 == '15' ~ '15 anos de estudo',
          V3241 == '16' ~ '16 anos de estudo',
          V3241 == '17' ~ '17 anos ou mais de estudo',
          V3241 == '20' ~ 'N\u00e3o determinado',
          V3241 == '30' ~ 'Alfabetiza\u00e7\u00e3o de adultos'
        )
      )
    }

    # CURSO CONCLUIDO (long labels shortened to the course name)
    if ('V0329' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0329 = dplyr::case_when(
          V0329 == '0' ~ 'Nenhum curso',
          V0329 == '1' ~ 'Prim\u00e1rio ou elementar (ensino geral)',
          V0329 == '2' ~ 'Prim\u00e1rio ou elementar (educa\u00e7\u00e3o especial)',
          V0329 == '3' ~ 'Prim\u00e1rio ou elementar (agr\u00edcola)',
          V0329 == '4' ~ 'Prim\u00e1rio ou elementar (administra\u00e7\u00e3o)',
          V0329 == '5' ~ 'Prim\u00e1rio ou elementar (industrial)',
          V0329 == '6' ~ 'Prim\u00e1rio ou elementar (sa\u00fade)',
          V0329 == '7' ~ 'Prim\u00e1rio ou elementar (militar)',
          V0329 == '8' ~ 'Prim\u00e1rio ou elementar (outros)',
          V0329 == '10' ~ 'Ensino geral - 1\u00ba grau',
          V0329 == '11' ~ 'Educa\u00e7\u00e3o especial - 1\u00ba grau',
          V0329 == '12' ~ 'Agr\u00edcola - 1\u00ba grau',
          V0329 == '13' ~ 'Administra\u00e7\u00e3o - 1\u00ba grau',
          V0329 == '14' ~ 'Contabilidade - 1\u00ba grau',
          V0329 == '15' ~ 'Outro - 1\u00ba grau - comercial',
          V0329 == '16' ~ 'Eletrot\u00e9cnica ou eletr\u00f4nica - 1\u00ba grau',
          V0329 == '17' ~ 'Mec\u00e2nica - 1\u00ba grau',
          V0329 == '18' ~ 'Outro - 1\u00ba grau - industrial',
          V0329 == '19' ~ 'Enfermagem - 1\u00ba grau',
          V0329 == '20' ~ 'Outros - 1\u00ba grau - sa\u00fade',
          V0329 == '21' ~ 'Militar - 1\u00ba grau',
          V0329 == '22' ~ 'Normal - 1\u00ba grau',
          V0329 == '23' ~ 'Outros - 1\u00ba grau',
          V0329 == '24' ~ 'Ensino geral - 2\u00ba grau',
          V0329 == '25' ~ 'Educa\u00e7\u00e3o especial - 2\u00ba grau',
          V0329 == '26' ~ 'Agr\u00edcola - 2\u00ba grau',
          V0329 == '27' ~ 'Administra\u00e7\u00e3o - 2\u00ba grau',
          V0329 == '28' ~ 'Contabilidade - 2\u00ba grau',
          V0329 == '29' ~ 'Estat\u00edstica - 2\u00ba grau',
          V0329 == '30' ~ 'Secretariado - 2\u00ba grau',
          V0329 == '31' ~ 'Outros - 2\u00ba grau - comercial',
          V0329 == '32' ~ 'Desenho - 2\u00ba grau',
          V0329 == '33' ~ 'Eletrot\u00e9cnica ou eletr\u00f4nica - 2\u00ba grau',
          V0329 == '34' ~ 'Mec\u00e2nica - 2\u00ba grau',
          V0329 == '35' ~ 'Qu\u00edmica - 2\u00ba grau',
          V0329 == '36' ~ 'Outros - 2\u00ba grau - industrial',
          V0329 == '37' ~ 'Enfermagem - 2\u00ba grau',
          V0329 == '38' ~ 'Laboratorista de an\u00e1lise cl\u00ednica - 2\u00ba grau',
          V0329 == '39' ~ 'Outros - 2\u00ba grau - sa\u00fade',
          V0329 == '40' ~ 'Militar - 2\u00ba grau',
          V0329 == '41' ~ 'Normal - 2\u00ba grau',
          V0329 == '42' ~ 'Outros - 2\u00ba grau',
          V0329 == '43' ~ 'Biologia',
          V0329 == '44' ~ 'Educa\u00e7\u00e3o f\u00edsica',
          V0329 == '45' ~ 'Enfermagem',
          V0329 == '46' ~ 'Farm\u00e1cia',
          V0329 == '47' ~ 'Medicina',
          V0329 == '48' ~ 'Odontologia',
          V0329 == '49' ~ 'Outros da biologia',
          V0329 == '50' ~ 'Arquitetura e urbanismo',
          V0329 == '51' ~ 'Ci\u00eancias exatas',
          V0329 == '52' ~ 'Ci\u00eancias da computa\u00e7\u00e3o',
          V0329 == '53' ~ 'Engenharia civil',
          V0329 == '54' ~ 'Engenharia el\u00e9trica e eletr\u00f4nica',
          V0329 == '55' ~ 'Engenharia mec\u00e2nica',
          V0329 == '56' ~ 'Engenharia qu\u00edmica e qu\u00edmica industrial',
          V0329 == '57' ~ 'Engenharia n\u00e3o classificada ou mal definida',
          V0329 == '58' ~ 'Estat\u00edstica',
          V0329 == '59' ~ 'F\u00edsica',
          V0329 == '60' ~ 'Geologia',
          V0329 == '61' ~ 'Matem\u00e1tica',
          V0329 == '62' ~ 'Qu\u00edmica',
          V0329 == '63' ~ 'Outros da tecnologia (exclusive engenharia)',
          V0329 == '64' ~ 'Agronomia',
          V0329 == '65' ~ 'Medicina veterin\u00e1ria',
          V0329 == '66' ~ 'Outros - agr\u00e1rias',
          V0329 == '67' ~ 'Administra\u00e7\u00e3o',
          V0329 == '68' ~ 'Biblioteconomia',
          V0329 == '69' ~ 'Ci\u00eancias cont\u00e1beis e atuariais',
          V0329 == '70' ~ 'Ci\u00eancias econ\u00f4micas',
          V0329 == '71' ~ 'Ci\u00eancias e estudos sociais',
          V0329 == '72' ~ 'Comunica\u00e7\u00e3o social',
          V0329 == '73' ~ 'Direito',
          V0329 == '74' ~ 'Filosofia',
          V0329 == '75' ~ 'Geografia',
          V0329 == '76' ~ 'Hist\u00f3ria',
          V0329 == '77' ~ 'Pedagogia',
          V0329 == '78' ~ 'Psicologia',
          V0329 == '79' ~ 'Servi\u00e7o social',
          V0329 == '80' ~ 'Teologia',
          V0329 == '81' ~ 'Outros de humanas',
          V0329 == '82' ~ 'Letras',
          V0329 == '83' ~ 'Artes',
          V0329 == '84' ~ 'Defesa nacional (militar)',
          V0329 == '85' ~ 'Outros cursos de grau superior',
          V0329 == '86' ~ 'Mestrado ou doutorado - medicina',
          V0329 == '87' ~ 'Mestrado ou doutorado - outros (biologia)',
          V0329 == '88' ~ 'Mestrado ou doutorado - engenharia',
          V0329 == '89' ~ 'Mestrado ou doutorado - outros (ci\u00eancias tecnol\u00f3gicas)',
          V0329 == '90' ~ 'Mestrado ou doutorado - ci\u00eancias agr\u00e1rias',
          V0329 == '91' ~ 'Mestrado ou doutorado - administra\u00e7\u00e3o',
          V0329 == '92' ~ 'Mestrado ou doutorado - ci\u00eancias econ\u00f4micas, cont\u00e1beis, etc.',
          V0329 == '93' ~ 'Mestrado ou doutorado - direito',
          V0329 == '94' ~ 'Mestrado ou doutorado - pedagogia',
          V0329 == '95' ~ 'Mestrado ou doutorado - outros (ci\u00eancias humanas e sociais)',
          V0329 == '96' ~ 'Mestrado ou doutorado - letras e artes',
          V0329 == '97' ~ 'Mestrado ou doutorado - (\u00e1rea n\u00e3o especificada)'
        )
      )
    }

    # VIVE OU VIVEU COM CONJUGE
    if ('V0330' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0330 = dplyr::case_when(
          V0330 == '1' ~ 'Sim',
          V0330 == '2' ~ 'N\u00e3o'
        )
      )
    }

    # ESTADO CONJUGAL (NATUREZA DA UNIAO)
    if ('V0332' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0332 = dplyr::case_when(
          V0332 == '1' ~ 'Casamento civil e religioso',
          V0332 == '2' ~ 'S\u00f3 casamento civil',
          V0332 == '3' ~ 'S\u00f3 casamento religioso',
          V0332 == '4' ~ 'Uni\u00e3o consensual',
          V0332 == '9' ~ 'Ignorado'
        )
      )
    }

    # ESTADO CONJUGAL (SITUACAO CONJUGAL)
    if ('V0333' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0333 = dplyr::case_when(
          V0333 == '5' ~ 'Separado(a) n\u00e3o judicialmente',
          V0333 == '6' ~ 'Desquitado(a) ou separado(a) judicialmente',
          V0333 == '7' ~ 'Divorciado(a)',
          V0333 == '8' ~ 'Vi\u00favo(a)',
          V0333 == '9' ~ 'Ignorado'
        )
      )
    }

    # SITUACAO CONJUGAL ATUAL DA PESSOA
    if ('V3342' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3342 = dplyr::case_when(
          V3342 == '1' ~ 'Casada em 1\u00aa uni\u00e3o',
          V3342 == '2' ~ 'Casada em outra uni\u00e3o',
          V3342 == '3' ~ 'Casada com n\u00famero de uni\u00f5es ignorado',
          V3342 == '4' ~ 'Separada, desquitada, divorciada ou vi\u00fava',
          V3342 == '5' ~ 'Solteira'
        )
      )
    }

    # SEXO DO ULTIMO FILHO NASCIDO VIVO
    if ('V0343' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0343 = dplyr::case_when(
          V0343 == '1' ~ 'Homem',
          V0343 == '2' ~ 'Mulher',
          V0343 == '7' ~ 'N\u00e3o tem',
          V0343 == '9' ~ 'Ignorado'
        )
      )
    }

    # TIPO DE IDADE DO ULTIMO FILHO NASCIDO VIVO
    if ('V3444' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3444 = dplyr::case_when(
          V3444 == '1' ~ 'Idade presumida',
          V3444 == '2' ~ 'Idade declarada',
          V3444 == '9' ~ 'Idade ignorada'
        )
      )
    }

    # TRABALHOU EM TODOS OU EM PARTE DOS ULTIMOS 12 MESES
    if ('V0345' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0345 = dplyr::case_when(
          V0345 == '1' ~ 'Habitualmente',
          V0345 == '2' ~ 'Eventualmente',
          V0345 == '3' ~ 'N\u00e3o trabalhou'
        )
      )
    }

    # GRUPO DE OCUPACAO
    if ('V3461' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3461 = dplyr::case_when(
          V3461 == '1' ~ 'Administrativas',
          V3461 == '2' ~ 'T\u00e9cnicas, cient\u00edficas, art\u00edsticas e assemelhadas',
          V3461 == '3' ~ 'Agropecu\u00e1ria e da produ\u00e7\u00e3o extrativa vegetal e animal',
          V3461 == '4' ~ 'Produ\u00e7\u00e3o extrativa mineral',
          V3461 == '5' ~ 'Ind\u00fastrias de transforma\u00e7\u00e3o e constru\u00e7\u00e3o civil',
          V3461 == '6' ~ 'Com\u00e9rcio e atividades auxiliares',
          V3461 == '7' ~ 'Transportes e comunica\u00e7\u00f5es',
          V3461 == '8' ~ 'Presta\u00e7\u00e3o de servi\u00e7os',
          V3461 == '9' ~ 'Defesa nacional e seguran\u00e7a p\u00fablica',
          V3461 == '10' ~ 'Outras ocupa\u00e7\u00f5es, ocupa\u00e7\u00f5es mal definidas ou n\u00e3o declaradas'
        )
      )
    }

    # SETOR DE ATIVIDADE (codes 4, 7, 8, 9 and 10 carry the dictionary's
    # parentheticals, which is what distinguishes 4 from 11; code 11's own
    # parenthetical is a 250-character list and is left out, as for V0329)
    if ('V3471' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3471 = dplyr::case_when(
          V3471 == '1' ~ 'Atividades agropecu\u00e1rias, de extra\u00e7\u00e3o vegetal e pesca',
          V3471 == '2' ~ 'Ind\u00fastria de transforma\u00e7\u00e3o',
          V3471 == '3' ~ 'Ind\u00fastria da constru\u00e7\u00e3o civil',
          V3471 == '4' ~ 'Outras atividades industriais (extra\u00e7\u00e3o mineral e servi\u00e7os industriais de utilidade p\u00fablica)',
          V3471 == '5' ~ 'Com\u00e9rcio de mercadorias',
          V3471 == '6' ~ 'Transporte e comunica\u00e7\u00e3o',
          V3471 == '7' ~ 'Servi\u00e7os auxiliares da atividade econ\u00f4mica (t\u00e9cnico-profissionais e auxiliares das atividades econ\u00f4micas)',
          V3471 == '8' ~ 'Presta\u00e7\u00e3o de servi\u00e7os (alojamento e alimenta\u00e7\u00e3o, repara\u00e7\u00e3o e conserva\u00e7\u00e3o, pessoais, domiciliares e divers\u00f5es)',
          V3471 == '9' ~ 'Social (comunit\u00e1rias, m\u00e9dicas, odontol\u00f3gicas e ensino)',
          V3471 == '10' ~ 'Administra\u00e7\u00e3o p\u00fablica (administra\u00e7\u00e3o p\u00fablica, defesa nacional e seguran\u00e7a p\u00fablica)',
          V3471 == '11' ~ 'Outras atividades'
        )
      )
    }

    # POSICAO NA OCUPACAO
    if ('V0349' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0349 = dplyr::case_when(
          V0349 == '1' ~ 'Trabalhador agr\u00edcola volante',
          V0349 == '2' ~ 'Parceiro ou meeiro - empregado',
          V0349 == '3' ~ 'Parceiro ou meeiro - aut\u00f4nomo ou conta pr\u00f3pria',
          V0349 == '4' ~ 'Trabalhador dom\u00e9stico - empregado',
          V0349 == '5' ~ 'Trabalhador dom\u00e9stico - aut\u00f4nomo ou conta pr\u00f3pria',
          V0349 == '6' ~ 'Empregado do setor privado',
          V0349 == '7' ~ 'Empregado do setor p\u00fablico - servidor p\u00fablico',
          V0349 == '8' ~ 'Empregado do setor p\u00fablico - de empresa estatal',
          V0349 == '9' ~ 'Aut\u00f4nomo ou conta pr\u00f3pria',
          V0349 == '10' ~ 'Empregador',
          V0349 == '11' ~ 'Sem remunera\u00e7\u00e3o'
        )
      )
    }

    # POSSE DE CARTEIRA DE TRABALHO ASSINADA
    if ('V0350' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0350 = dplyr::case_when(
          V0350 == '1' ~ 'Sim',
          V0350 == '2' ~ 'N\u00e3o sabe',
          V0350 == '3' ~ 'N\u00e3o tem',
          V0350 == '4' ~ 'N\u00e3o \u00e9 empregado'
        )
      )
    }

    # NUMERO DE EMPREGADOS NO ESTABELECIMENTO
    if ('V0351' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0351 = dplyr::case_when(
          V0351 == '1' ~ 'Um ou dois',
          V0351 == '2' ~ 'Tr\u00eas ou quatro',
          V0351 == '3' ~ 'Cinco a nove',
          V0351 == '4' ~ 'Dez ou mais',
          V0351 == '5' ~ 'Trabalha sozinho',
          V0351 == '6' ~ 'Com s\u00f3cio ou n\u00e3o remunerado',
          V0351 == '7' ~ 'Trabalhador dom\u00e9stico',
          V0351 == '8' ~ 'N\u00e3o sabe'
        )
      )
    }

    # LOCAL DE TRABALHO
    if ('V0352' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0352 = dplyr::case_when(
          V0352 == '1' ~ 'No domic\u00edlio - sem local exclusivo',
          V0352 == '2' ~ 'No domic\u00edlio - com local exclusivo',
          V0352 == '3' ~ 'Via p\u00fablica - com equipamento pesado',
          V0352 == '4' ~ 'Via p\u00fablica - com equipamento leve ou sem equipamento',
          V0352 == '5' ~ 'Propriedade agropecu\u00e1ria',
          V0352 == '6' ~ 'Empresa ou firma',
          V0352 == '7' ~ 'Em casa do cliente ou patr\u00e3o',
          V0352 == '8' ~ 'Outro'
        )
      )
    }

    # CONTRIBUICAO PARA INSTITUTO DE PREVIDENCIA PUBLICA
    if ('V0353' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0353 = dplyr::case_when(
          V0353 == '1' ~ 'Sim',
          V0353 == '2' ~ 'N\u00e3o sabe',
          V0353 == '3' ~ 'N\u00e3o \u00e9'
        )
      )
    }

    # FAIXAS DE RENDIMENTO NOMINAL TOTAL
    if ('V3562' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3562 = dplyr::case_when(
          V3562 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V3562 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3562 == '3' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V3562 == '4' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V3562 == '5' ~ 'Mais de 1 a 1 1/4 sal\u00e1rios m\u00ednimos',
          V3562 == '6' ~ 'Mais de 1 1/4 a 1 1/2 sal\u00e1rios m\u00ednimos',
          V3562 == '7' ~ 'Mais de 1 1/2 a 2 sal\u00e1rios m\u00ednimos',
          V3562 == '8' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3562 == '9' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3562 == '10' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3562 == '11' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V3562 == '12' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V3562 == '13' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V3562 == '14' ~ 'Sem rendimentos',
          V3562 == '15' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FAIXAS DE RENDIMENTO REAL TOTAL
    if ('V3563' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3563 = dplyr::case_when(
          V3563 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V3563 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3563 == '3' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V3563 == '4' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V3563 == '5' ~ 'Mais de 1 a 1 1/4 sal\u00e1rios m\u00ednimos',
          V3563 == '6' ~ 'Mais de 1 1/4 a 1 1/2 sal\u00e1rios m\u00ednimos',
          V3563 == '7' ~ 'Mais de 1 1/2 a 2 sal\u00e1rios m\u00ednimos',
          V3563 == '8' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3563 == '9' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3563 == '10' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3563 == '11' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V3563 == '12' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V3563 == '13' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V3563 == '14' ~ 'Sem rendimentos',
          V3563 == '15' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FAIXAS DE RENDIMENTO DA OCUPACAO PRINCIPAL
    if ('V3564' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3564 = dplyr::case_when(
          V3564 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V3564 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3564 == '3' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V3564 == '4' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V3564 == '5' ~ 'Mais de 1 a 1 1/4 sal\u00e1rios m\u00ednimos',
          V3564 == '6' ~ 'Mais de 1 1/4 a 1 1/2 sal\u00e1rios m\u00ednimos',
          V3564 == '7' ~ 'Mais de 1 1/2 a 2 sal\u00e1rios m\u00ednimos',
          V3564 == '8' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3564 == '9' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3564 == '10' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3564 == '11' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V3564 == '12' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V3564 == '13' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V3564 == '14' ~ 'Sem rendimentos',
          V3564 == '15' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FAIXAS DE RENDIMENTO DE OUTRAS OCUPACOES
    if ('V3574' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3574 = dplyr::case_when(
          V3574 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V3574 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3574 == '3' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V3574 == '4' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V3574 == '5' ~ 'Mais de 1 a 1 1/4 sal\u00e1rios m\u00ednimos',
          V3574 == '6' ~ 'Mais de 1 1/4 a 1 1/2 sal\u00e1rios m\u00ednimos',
          V3574 == '7' ~ 'Mais de 1 1/2 a 2 sal\u00e1rios m\u00ednimos',
          V3574 == '8' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3574 == '9' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3574 == '10' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3574 == '11' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V3574 == '12' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V3574 == '13' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V3574 == '14' ~ 'Sem rendimentos',
          V3574 == '15' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # CONDICAO DE ATIVIDADE
    if ('V0358' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0358 = dplyr::case_when(
          V0358 == '0' ~ 'Sem ocupa\u00e7\u00e3o',
          V0358 == '1' ~ 'Procurando trabalho - j\u00e1 trabalhou',
          V0358 == '2' ~ 'Procurando trabalho - nunca trabalhou',
          V0358 == '3' ~ 'Aposentado',
          V0358 == '4' ~ 'Pensionista',
          V0358 == '5' ~ 'Vive de rendas',
          V0358 == '6' ~ 'Detento',
          V0358 == '7' ~ 'Estudante',
          V0358 == '8' ~ 'Doente ou inv\u00e1lido',
          V0358 == '9' ~ 'Afazeres dom\u00e9sticos'
        )
      )
    }

    # APOSENTADO OU PENSIONISTA
    if ('V0359' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V0359 = dplyr::case_when(
          V0359 == '0' ~ 'N\u00e3o \u00e9',
          V0359 == '1' ~ 'Aposentado',
          V0359 == '2' ~ 'Pensionista',
          V0359 == '3' ~ 'Aposentado e pensionista'
        )
      )
    }

    # FAIXAS DE RENDIMENTO DE APOSENTADORIA E/OU PENSAO
    if ('V3604' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3604 = dplyr::case_when(
          V3604 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V3604 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3604 == '3' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V3604 == '4' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V3604 == '5' ~ 'Mais de 1 a 1 1/4 sal\u00e1rios m\u00ednimos',
          V3604 == '6' ~ 'Mais de 1 1/4 a 1 1/2 sal\u00e1rios m\u00ednimos',
          V3604 == '7' ~ 'Mais de 1 1/2 a 2 sal\u00e1rios m\u00ednimos',
          V3604 == '8' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3604 == '9' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3604 == '10' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3604 == '11' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V3604 == '12' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V3604 == '13' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V3604 == '14' ~ 'Sem rendimentos',
          V3604 == '15' ~ 'Sem declara\u00e7\u00e3o'
        )
      )
    }

    # FAIXAS DE OUTROS RENDIMENTOS
    if ('V3614' %in% cols) {
      arrw <- dplyr::mutate(
        arrw,
        V3614 = dplyr::case_when(
          V3614 == '1' ~ 'At\u00e9 1/4 de sal\u00e1rio m\u00ednimo',
          V3614 == '2' ~ 'Mais de 1/4 a 1/2 sal\u00e1rio m\u00ednimo',
          V3614 == '3' ~ 'Mais de 1/2 a 3/4 sal\u00e1rio m\u00ednimo',
          V3614 == '4' ~ 'Mais de 3/4 a 1 sal\u00e1rio m\u00ednimo',
          V3614 == '5' ~ 'Mais de 1 a 1 1/4 sal\u00e1rios m\u00ednimos',
          V3614 == '6' ~ 'Mais de 1 1/4 a 1 1/2 sal\u00e1rios m\u00ednimos',
          V3614 == '7' ~ 'Mais de 1 1/2 a 2 sal\u00e1rios m\u00ednimos',
          V3614 == '8' ~ 'Mais de 2 a 3 sal\u00e1rios m\u00ednimos',
          V3614 == '9' ~ 'Mais de 3 a 5 sal\u00e1rios m\u00ednimos',
          V3614 == '10' ~ 'Mais de 5 a 10 sal\u00e1rios m\u00ednimos',
          V3614 == '11' ~ 'Mais de 10 a 15 sal\u00e1rios m\u00ednimos',
          V3614 == '12' ~ 'Mais de 15 a 20 sal\u00e1rios m\u00ednimos',
          V3614 == '13' ~ 'Mais de 20 sal\u00e1rios m\u00ednimos',
          V3614 == '14' ~ 'Sem rendimentos',
          V3614 == '15' ~ 'Sem declara\u00e7\u00e3o'
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
            .x == '0' ~ 'N\u00e3o tem',
            .x == '1' ~ 'Tem'
          )
        )
      )
    }
  }

  return(arrw)
}
