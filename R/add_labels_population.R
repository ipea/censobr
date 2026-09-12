# Add labels to categorical variables of population datasets
#' @keywords internal
add_labels_population <- function(arrw,
                                  year = parent.frame()$year,
                                  lang = 'pt'){

  # check input
  checkmate::assert_string(lang, pattern = 'pt', na.ok = TRUE)
  if (!(year %in% c(2010, 2022))) {
    cli::cli_abort("Labels for this data are only available for the year c(2010, 2022)")
  }

  # names of columns present in the data
  cols <- names(arrw) # nocov start

  # ALL YEARS ------------------------------------------------------------------

  # urban vs rural
  if ('V1006' %in% cols) {
    arrw <- mutate(arrw, V1006 = case_when(
      V1006 == '1' ~'Urbana',
      V1006 == '2' ~'Rural'))
  }


  # YEAR 2022 ------------------------------------------------------------------
  if (year == 2022 & lang == 'pt') { # nocov start

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
      arrw <- mutate(arrw, P0120 = case_when(
        P0120 == '01' ~ '\u00c1rea urbana de alta densidade de edifica\u00e7\u00f5es',
        P0120 == '02' ~ '\u00c1rea urbana de baixa densidade de edifica\u00e7\u00f5es',
        P0120 == '03' ~ 'N\u00facleo urbano',
        P0120 == '05' ~ 'Povoado',
        P0120 == '06' ~ 'N\u00facleo rural',
        P0120 == '07' ~ 'Lugarejo',
        P0120 == '08' ~ '\u00c1rea rural (exclusive aglomerados)'
      ))
    }

    # ESPECIE DA UNIDADE VISITADA
    if ('P0130' %in% cols) {
      arrw <- mutate(arrw, P0130 = case_when(
        P0130 == '01' ~ 'Domic\u00edlio particular permanente ocupado',
        P0130 == '05' ~ 'Domic\u00edlio particular improvisado ocupado',
        P0130 == '06' ~ 'Domic\u00edlio coletivo com morador'
      ))
    }

    # SITUACAO DO DOMICILIO
    if ('P0140' %in% cols) {
      arrw <- mutate(arrw, P0140 = case_when(
        P0140 == '1' ~ 'Urbana',
        P0140 == '2' ~ 'Rural'
      ))
    }

    # SEXO (UNIDADE DOMICILIAR)
    if ('P0150' %in% cols) {
      arrw <- mutate(arrw, P0150 = case_when(
        P0150 == '1' ~ 'Masculino',
        P0150 == '2' ~ 'Feminino',
        P0150 == '9' ~ 'Ignorado'
      ))
    }

    # SEXO
    if ('P0160' %in% cols) {
      arrw <- mutate(arrw, P0160 = case_when(
        P0160 == '1' ~ 'Masculino',
        P0160 == '2' ~ 'Feminino'
      ))
    }

    # CONDICAO NO DOMICILIO DA PESSOA
    if ('P0170' %in% cols) {
      arrw <- mutate(arrw, P0170 = case_when(
        P0170 == '01' ~ 'Pessoa respons\u00e1vel pelo domic\u00edlio',
        P0170 == '02' ~ 'C\u00f4njuge ou companheiro(a) de sexo diferente',
        P0170 == '03' ~ 'C\u00f4njuge ou companheiro(a) do mesmo sexo',
        P0170 == '04' ~ 'Filho(a) do respons\u00e1vel e do c\u00f4njuge',
        P0170 == '05' ~ 'Filho(a) somente do respons\u00e1vel',
        P0170 == '06' ~ 'Enteado(a)',
        P0170 == '07' ~ 'Genro ou nora',
        P0170 == '08' ~ 'Pai, m\u00e3e, padrasto ou madrasta',
        P0170 == '09' ~ 'Sogro(a)',
        P0170 == '10' ~ 'Neto(a)',
        P0170 == '11' ~ 'Bisneto(a)',
        P0170 == '12' ~ 'Irm\u00e3o ou irm\u00e3',
        P0170 == '13' ~ 'Av\u00f4 ou av\u00f3',
        P0170 == '14' ~ 'Outro parente',
        P0170 == '15' ~ 'Agregado(a)',
        P0170 == '16' ~ 'Convivente',
        P0170 == '17' ~ 'Pensionista',
        P0170 == '18' ~ 'Empregado(a) dom\u00e9stico(a)',
        P0170 == '19' ~ 'Parente do(a) empregado(a) dom\u00e9stico(a)',
        P0170 == '20' ~ 'Individual em domic\u00edlio coletivo'
      ))
    }

    # IDADE CALCULADA EM ANOS DA PESSOA, CATEGORIA
    if ('P0180' %in% cols) {
      arrw <- mutate(arrw, P0180 = case_when(
        P0180 == '01' ~ '0 a 4 anos',
        P0180 == '02' ~ '5 a 9 anos',
        P0180 == '03' ~ '10 a 14 anos',
        P0180 == '04' ~ '15 a 19 anos',
        P0180 == '05' ~ '20 a 24 anos',
        P0180 == '06' ~ '25 a 29 anos',
        P0180 == '07' ~ '30 a 34 anos',
        P0180 == '08' ~ '35 a 39 anos',
        P0180 == '09' ~ '40 a 44 anos',
        P0180 == '10' ~ '45 a 49 anos',
        P0180 == '11' ~ '50 a 54 anos',
        P0180 == '12' ~ '55 a 59 anos',
        P0180 == '13' ~ '60 a 64 anos',
        P0180 == '14' ~ '65 a 69 anos',
        P0180 == '15' ~ '70 a 74 anos',
        P0180 == '16' ~ '75 a 79 anos',
        P0180 == '17' ~ '80 anos ou mais',
        P0180 == '99' ~ 'Ignorado'
      ))
    }

    # FORMA DE DECLARACAO DE IDADE
    if ('P0200' %in% cols) {
      arrw <- mutate(arrw, P0200 = case_when(
        P0200 == '1' ~ 'Data de nascimento',
        P0200 == '2' ~ 'Idade declarada'
      ))
    }

    # COR OU RACA DA PESSOA
    if ('P0210' %in% cols) {
      arrw <- mutate(arrw, P0210 = case_when(
        P0210 == '1' ~ 'Branca',
        P0210 == '2' ~ 'Preta',
        P0210 == '3' ~ 'Amarela',
        P0210 == '4' ~ 'Parda',
        P0210 == '5' ~ 'Ind\u00edgena',
        P0210 == '9' ~ 'Ignorado'
      ))
    }

    # PESSOA INDIGENA
    if ('P0220' %in% cols) {
      arrw <- mutate(arrw, P0220 = case_when(
        P0220 == '1' ~ 'Sim',
        P0220 == '0' ~ 'N\u00e3o',
        P0220 == '9' ~ 'Ignorado'
      ))
    }

    # STATUS DE DECLARACAO DE ETNIA
    if ('P0240' %in% cols) {
      arrw <- mutate(arrw, P0240 = case_when(
        P0240 == '1' ~ 'Declarou uma etnia',
        P0240 == '2' ~ 'Declarou duas etnias',
        P0240 == '3' ~ 'Declara\u00e7\u00e3o n\u00e3o-determinada',
        P0240 == '4' ~ 'Declara\u00e7\u00e3o mal definida',
        P0240 == '5' ~ 'N\u00e3o sabe',
        P0240 == '6' ~ 'N\u00e3o declarou'
      ))
    }

    # STATUS DE DECLARACAO DE LINGUA INDIGENA
    if ('P0250' %in% cols) {
      arrw <- mutate(arrw, P0250 = case_when(
        P0250 == '1' ~ 'Declarou uma l\u00edngua ind\u00edgena',
        P0250 == '2' ~ 'Declarou duas l\u00ednguas ind\u00edgenas',
        P0250 == '3' ~ 'Declarou tr\u00eas l\u00ednguas ind\u00edgenas',
        P0250 == '4' ~ 'Declara\u00e7\u00e3o n\u00e3o-determinada',
        P0250 == '5' ~ 'Declara\u00e7\u00e3o mal definida',
        P0250 == '6' ~ 'N\u00e3o sabe',
        P0250 == '7' ~ 'N\u00e3o fala l\u00edngua ind\u00edgena no domic\u00edlio'
      ))
    }

    # EXISTENCIA E TIPO DE REGISTRO DE NASCIMENTO DA PESSOA
    if ('P0270' %in% cols) {
      arrw <- mutate(arrw, P0270 = case_when(
        P0270 == '1' ~ 'Do cart\u00f3rio',
        P0270 == '2' ~ 'Registro Administrativo de Nascimento Ind\u00edgena (RANI)',
        P0270 == '3' ~ 'N\u00e3o tem',
        P0270 == '4' ~ 'N\u00e3o sabe',
        P0270 == '9' ~ 'Ignorado'
      ))
    }

    # CONVIVENCIA COM CONJUGE OU COMPANHEIRO DA PESSOA
    if ('P0280' %in% cols) {
      arrw <- mutate(arrw, P0280 = case_when(
        P0280 == '1' ~ 'Sim',
        P0280 == '2' ~ 'N\u00e3o, j\u00e1 viveu antes',
        P0280 == '3' ~ 'N\u00e3o, nunca viveu'
      ))
    }

    # NATUREZA DA UNIAO
    if ('P0290' %in% cols) {
      arrw <- mutate(arrw, P0290 = case_when(
        P0290 == '1' ~ 'Casamento civil e religioso',
        P0290 == '2' ~ 'S\u00f3 casamento civil',
        P0290 == '3' ~ 'S\u00f3 casamento religioso',
        P0290 == '4' ~ 'Uni\u00e3o consensual'
      ))
    }

    # IDADE CALCULADA DO ULTIMO FILHO NASCIDO VIVO DA PESSOA, CATEGORIA
    if ('P0380' %in% cols) {
      arrw <- mutate(arrw, P0380 = case_when(
        P0380 == '01' ~ '0 a 4 anos',
        P0380 == '02' ~ '5 a 9 anos',
        P0380 == '03' ~ '10 a 14 anos',
        P0380 == '04' ~ '15 a 19 anos',
        P0380 == '05' ~ '20 a 24 anos',
        P0380 == '06' ~ '25 a 29 anos',
        P0380 == '07' ~ '30 a 34 anos',
        P0380 == '08' ~ '35 a 39 anos',
        P0380 == '09' ~ '40 a 44 anos',
        P0380 == '10' ~ '45 a 49 anos',
        P0380 == '11' ~ '50 a 54 anos',
        P0380 == '12' ~ '55 a 59 anos',
        P0380 == '13' ~ '60 a 64 anos',
        P0380 == '14' ~ '65 a 69 anos',
        P0380 == '15' ~ '70 a 74 anos',
        P0380 == '16' ~ '75 a 79 anos',
        P0380 == '17' ~ '80 anos ou mais',
        P0380 == '99' ~ 'Ignorado'
      ))
    }

    # FORMA DE DECLARACAO DE IDADE DO ULTIMO FILHO TIDO NASCIDO VIVO
    if ('P0390' %in% cols) {
      arrw <- mutate(arrw, P0390 = case_when(
        P0390 == '1' ~ 'Data de nascimento',
        P0390 == '2' ~ 'Idade declarada'
      ))
    }

    # RELIGIAO OU CULTO
    if ('P0410' %in% cols) {
      arrw <- mutate(arrw, P0410 = case_when(
        P0410 == '1' ~ 'Cat\u00f3lica Apost\u00f3lica Romana',
        P0410 == '2' ~ 'Evang\u00e9licas',
        P0410 == '3' ~ 'Esp\u00edrita',
        P0410 == '4' ~ 'Umbanda e Candombl\u00e9',
        P0410 == '5' ~ 'Tradi\u00e7\u00f5es ind\u00edgenas',
        P0410 == '6' ~ 'Outras religiosidades',
        P0410 == '7' ~ 'Sem religi\u00e3o',
        P0410 == '8' ~ 'N\u00e3o sabe',
        P0410 == '9' ~ 'Sem declara\u00e7\u00e3o'
      ))
    }

    # RELIGIAO OU CULTO, CATEGORIA DETALHADA (SOMENTE ACESSO CONTROLADO)
    if ('P0411' %in% cols) {
      arrw <- mutate(arrw, P0411 = case_when(
        P0411 == '1' ~ 'Cat\u00f3lica Apost\u00f3lica Romana',
        P0411 == '2' ~ 'Cat\u00f3lica Apost\u00f3lica Brasileira',
        P0411 == '3' ~ 'Cat\u00f3lica Ortodoxa',
        P0411 == '4' ~ 'Evang\u00e9licas de Miss\u00e3o',
        P0411 == '5' ~ 'Evang\u00e9licas de origem pentecostal',
        P0411 == '6' ~ 'Igrejas evang\u00e9licas ind\u00edgenas',
        P0411 == '7' ~ 'Evang\u00e9lica n\u00e3o determinada',
        P0411 == '8' ~ 'Outras religiosidades crist\u00e3s',
        P0411 == '9' ~ 'Igreja de Jesus Cristo dos Santos dos \u00daltimos Dias',
        P0411 == '10' ~ 'Testemunhas de Jeov\u00e1',
        P0411 == '11' ~ 'Espiritualista',
        P0411 == '12' ~ 'Esp\u00edrita',
        P0411 == '13' ~ 'Umbanda',
        P0411 == '14' ~ 'Candombl\u00e9',
        P0411 == '15' ~ 'Outras declara\u00e7\u00f5es de religiosidades afrobrasileira',
        P0411 == '16' ~ 'Juda\u00edsmo',
        P0411 == '17' ~ 'Hindu\u00edsmo',
        P0411 == '18' ~ 'Budismo',
        P0411 == '19' ~ 'Igreja Messi\u00e2nica Mundial',
        P0411 == '20' ~ 'Outras novas religi\u00f5es orientais',
        P0411 == '21' ~ 'Outras religi\u00f5es orientais',
        P0411 == '22' ~ 'Islamismo',
        P0411 == '23' ~ 'Tradi\u00e7\u00f5es esot\u00e9ricas',
        P0411 == '24' ~ 'Tradi\u00e7\u00f5es ind\u00edgenas',
        P0411 == '25' ~ 'Religi\u00f5es Ayahuasqueiras',
        P0411 == '26' ~ 'LBV',
        P0411 == '27' ~ 'Sem religi\u00e3o - Sem religi\u00e3o',
        P0411 == '28' ~ 'Sem religi\u00e3o - Ateu',
        P0411 == '29' ~ 'Sem religi\u00e3o - Agn\u00f3stico',
        P0411 == '30' ~ 'M\u00faltiplo pertencimento',
        P0411 == '31' ~ 'N\u00e3o determinada',
        P0411 == '32' ~ 'N\u00e3o sabe',
        P0411 == '33' ~ 'Sem declara\u00e7\u00e3o'
      ))
    }

    # EXISTENCIA DE DEFICIENCIA (VISUAL, AUDITIVA, MOTORA, DE PEGAR OBJETOS, MENTAL/INTELECTUAL)
    pd_vars_2022 <- c('P0420', 'P0430', 'P0440', 'P0450', 'P0460')
    pd_vars_2022 <- pd_vars_2022[pd_vars_2022 %in% cols]
    arrw <- dplyr::mutate(arrw, dplyr::across(all_of(pd_vars_2022),
                                              ~ case_when(
                                                .x == '1' ~ 'Tem, n\u00e3o consegue de modo algum',
                                                .x == '2' ~ 'Tem muita dificuldade',
                                                .x == '3' ~ 'Tem alguma dificuldade',
                                                .x == '4' ~ 'N\u00e3o tem dificuldade',
                                                .x == '9' ~ 'Ignorado'
                                              )))

    # VARIAVEL INDICADORA DA EXISTENCIA DE DEFICIENCIA
    if ('P0470' %in% cols) {
      arrw <- mutate(arrw, P0470 = case_when(
        P0470 == '1' ~ 'Pessoa COM Defici\u00eancia',
        P0470 == '2' ~ 'Pessoa SEM Defici\u00eancia',
        P0470 == '9' ~ 'N\u00e3o aplic\u00e1vel - Pessoa com menos de 2 anos de idade'
      ))
    }

    # LOCAL DE NASCIMENTO DA PESSOA
    if ('P0480' %in% cols) {
      arrw <- mutate(arrw, P0480 = case_when(
        P0480 == '1' ~ 'Neste munic\u00edpio',
        P0480 == '2' ~ 'Em outro munic\u00edpio do Brasil',
        P0480 == '3' ~ 'Em outro pa\u00eds',
        P0480 == '9' ~ 'Ignorado'
      ))
    }

    # NACIONALIDADE DA PESSOA
    if ('P0520' %in% cols) {
      arrw <- mutate(arrw, P0520 = case_when(
        P0520 == '1' ~ 'Brasileiro nato',
        P0520 == '2' ~ 'Naturalizado brasileiro',
        P0520 == '3' ~ 'Estrangeiro'
      ))
    }

    # UF E MUNICIPIO OU PAIS ESTRANGEIRO DE MORADIA ANTERIOR DA PESSOA
    if ('P0560' %in% cols) {
      arrw <- mutate(arrw, P0560 = case_when(
        P0560 == '1' ~ 'Estado/Munic\u00edpio',
        P0560 == '2' ~ 'Pa\u00eds estrangeiro',
        P0560 == '9' ~ 'Ignorado'
      ))
    }

    # UF E MUNICIPIO OU PAIS ESTRANGEIRO DE MORADIA HA 5 ANOS DA PESSOA
    if ('P0600' %in% cols) {
      arrw <- mutate(arrw, P0600 = case_when(
        P0600 == '1' ~ 'Neste munic\u00edpio',
        P0600 == '2' ~ 'Outro munic\u00edpio do Brasil',
        P0600 == '3' ~ 'Outro pa\u00eds',
        P0600 == '9' ~ 'Ignorado'
      ))
    }

    # FREQUENCIA ESCOLAR DA PESSOA
    if ('P0650' %in% cols) {
      arrw <- mutate(arrw, P0650 = case_when(
        P0650 == '1' ~ 'Sim',
        P0650 == '2' ~ 'N\u00e3o, mas j\u00e1 frequentou',
        P0650 == '3' ~ 'N\u00e3o, nunca frequentou'
      ))
    }

    # CURSO FREQUENTADO PELA PESSOA
    if ('P0660' %in% cols) {
      arrw <- mutate(arrw, P0660 = case_when(
        P0660 == '01' ~ 'Creche',
        P0660 == '02' ~ 'Pr\u00e9 escola',
        P0660 == '03' ~ 'Alfabetiza\u00e7\u00e3o de jovens e adultos',
        P0660 == '04' ~ 'Regular do ensino fundamental',
        P0660 == '05' ~ 'Educa\u00e7\u00e3o de jovens e adultos (EJA) do ensino fundamental',
        P0660 == '06' ~ 'Regular do ensino m\u00e9dio',
        P0660 == '07' ~ 'Educa\u00e7\u00e3o de jovens e adultos (EJA) do ensino m\u00e9dio',
        P0660 == '08' ~ 'Superior de gradua\u00e7\u00e3o',
        P0660 == '09' ~ 'Especializa\u00e7\u00e3o de n\u00edvel superior (dura\u00e7\u00e3o m\u00ednima de 360 horas)',
        P0660 == '10' ~ 'Mestrado',
        P0660 == '11' ~ 'Doutorado',
        P0660 == '99' ~ 'Ignorado'
      ))
    }

    # ANO DO CURSO FREQUENTADO PELA PESSOA
    if ('P0670' %in% cols) {
      arrw <- mutate(arrw, P0670 = case_when(
        P0670 == '01' ~ 'Primeiro',
        P0670 == '02' ~ 'Segundo',
        P0670 == '03' ~ 'Terceiro',
        P0670 == '04' ~ 'Quarto',
        P0670 == '05' ~ 'Quinto',
        P0670 == '06' ~ 'Sexto',
        P0670 == '07' ~ 'S\u00e9timo',
        P0670 == '08' ~ 'Oitavo',
        P0670 == '09' ~ 'Nono',
        P0670 == '10' ~ 'Curso n\u00e3o classificado em anos',
        P0670 == '99' ~ 'Ignorado'
      ))
    }

    # SERIE DO CURSO FREQUENTADO PELA PESSOA
    if ('P0680' %in% cols) {
      arrw <- mutate(arrw, P0680 = case_when(
        P0680 == '01' ~ 'Primeira',
        P0680 == '02' ~ 'Segunda',
        P0680 == '03' ~ 'Terceira',
        P0680 == '04' ~ 'Quarta',
        P0680 == '05' ~ 'Quinta',
        P0680 == '06' ~ 'Sexta',
        P0680 == '07' ~ 'S\u00e9tima',
        P0680 == '08' ~ 'Oitava',
        P0680 == '09' ~ 'Nona',
        P0680 == '10' ~ 'Curso n\u00e3o classificado em s\u00e9ries',
        P0680 == '99' ~ 'Ignorado'
      ))
    }

    # CURSO MAIS ELEVADO FREQUENTADO ANTERIORMENTE DA PESSOA
    if ('P0700' %in% cols) {
      arrw <- mutate(arrw, P0700 = case_when(
        P0700 == '01' ~ 'Creche',
        P0700 == '02' ~ 'Pr\u00e9 escola',
        P0700 == '03' ~ 'Classe de alfabetiza\u00e7\u00e3o',
        P0700 == '04' ~ 'Alfabetiza\u00e7\u00e3o de jovens e adultos',
        P0700 == '05' ~ 'Antigo prim\u00e1rio (elementar)',
        P0700 == '06' ~ 'Antigo ginasial (m\u00e9dio 1\u00ba ciclo)',
        P0700 == '07' ~ 'Regular do ensino fundamental ou do 1\u00ba grau',
        P0700 == '08' ~ 'Educa\u00e7\u00e3o de jovens e adultos (EJA) do ensino fundamental ou supletivo do 1\u00ba grau',
        P0700 == '09' ~ 'Antigo cient\u00edfico, cl\u00e1ssico, etc. (m\u00e9dio 2\u00ba ciclo)',
        P0700 == '10' ~ 'Regular do ensino m\u00e9dio ou do 2\u00ba grau',
        P0700 == '11' ~ 'Educa\u00e7\u00e3o de jovens e adultos (EJA) do ensino m\u00e9dio ou supletivo do 2\u00ba grau',
        P0700 == '12' ~ 'Superior de gradua\u00e7\u00e3o',
        P0700 == '13' ~ 'Especializa\u00e7\u00e3o de n\u00edvel superior (dura\u00e7\u00e3o m\u00ednima de 360 horas)',
        P0700 == '14' ~ 'Mestrado',
        P0700 == '15' ~ 'Doutorado',
        P0700 == '99' ~ 'Ignorado'
      ))
    }

    # DURACAO DO CURSO FREQUENTADO ANTERIORMENTE DA PESSOA
    if ('P0710' %in% cols) {
      arrw <- mutate(arrw, P0710 = case_when(
        P0710 == '1' ~ '8 s\u00e9ries',
        P0710 == '2' ~ '9 anos',
        P0710 == '9' ~ 'Ignorado'
      ))
    }

    # ULTIMO ANO CONCLUIDO COM APROVACAO NO CURSO FREQUENTADO ANTERIORMENTE
    if ('P0720' %in% cols) {
      arrw <- mutate(arrw, P0720 = case_when(
        P0720 == '01' ~ 'Nenhum',
        P0720 == '02' ~ 'Primeiro',
        P0720 == '03' ~ 'Segundo',
        P0720 == '04' ~ 'Terceiro',
        P0720 == '05' ~ 'Quarto',
        P0720 == '06' ~ 'Quinto',
        P0720 == '07' ~ 'Sexto',
        P0720 == '08' ~ 'S\u00e9timo',
        P0720 == '09' ~ 'Oitavo',
        P0720 == '10' ~ 'Nono',
        P0720 == '11' ~ 'Curso n\u00e3o era classificado em anos',
        P0720 == '99' ~ 'Ignorado'
      ))
    }

    # ULTIMA SERIE CONCLUIDA COM APROVACAO NO CURSO FREQUENTADO ANTERIORMENTE
    if ('P0730' %in% cols) {
      arrw <- mutate(arrw, P0730 = case_when(
        P0730 == '01' ~ 'Nenhuma',
        P0730 == '02' ~ 'Primeira',
        P0730 == '03' ~ 'Segunda',
        P0730 == '04' ~ 'Terceira',
        P0730 == '05' ~ 'Quarta',
        P0730 == '06' ~ 'Quinta',
        P0730 == '07' ~ 'Sexta',
        P0730 == '08' ~ 'S\u00e9tima',
        P0730 == '09' ~ 'Oitava',
        P0730 == '10' ~ 'Nona',
        P0730 == '11' ~ 'Curso n\u00e3o classificado em s\u00e9ries',
        P0730 == '99' ~ 'Ignorado'
      ))
    }

    # MORADOR, NIVEL DE INSTRUCAO DE ENSINO
    if ('P0760' %in% cols) {
      arrw <- mutate(arrw, P0760 = case_when(
        P0760 == '1' ~ 'Sem instru\u00e7\u00e3o e menos de 1 ano',
        P0760 == '2' ~ 'Ensino fundamental incompleto ou equivalente',
        P0760 == '3' ~ 'Ensino fundamental completo ou equivalente',
        P0760 == '4' ~ 'Ensino m\u00e9dio incompleto ou equivalente',
        P0760 == '5' ~ 'Ensino m\u00e9dio completo ou equivalente',
        P0760 == '6' ~ 'Superior incompleto ou equivalente',
        P0760 == '7' ~ 'Superior completo',
        P0760 == '8' ~ 'N\u00e3o determinado',
        P0760 == '9' ~ 'Ignorado "se frequenta curso"',
        P0760 == '901' ~ 'Ignorado "curso que frequenta"',
        P0760 == '902' ~ 'Ignorado "ano/s\u00e9rie que frequenta"',
        P0760 == '903' ~ 'Ignorado "se concluiu outro curso de gradua\u00e7\u00e3o"',
        P0760 == '911' ~ 'Ignorado "curso que frequentou"',
        P0760 == '912' ~ 'Ignorado "se concluiu o curso que frequentou"',
        P0760 == '913' ~ 'Ignorado "ano/s\u00e9rie que frequentou"',
        P0760 == '914' ~ 'Ignorado "dura\u00e7\u00e3o do curso regular de Ensino Fundamental"'
      ))
    }

    # MORADOR, NIVEL DE INSTRUCAO DE ENSINO, COMPATIVEL COM O CENSO DEMOGRAFICO DE 2010
    if ('P0770' %in% cols) {
      arrw <- mutate(arrw, P0770 = case_when(
        P0770 == '1' ~ 'Sem instru\u00e7\u00e3o e fundamental incompleto',
        P0770 == '2' ~ 'Fundamental completo e m\u00e9dio incompleto',
        P0770 == '3' ~ 'M\u00e9dio completo e superior incompleto',
        P0770 == '4' ~ 'Superior completo',
        P0770 == '5' ~ 'N\u00e3o determinado'
      ))
    }

    # VARIAVEL INDICADORA DE FREQUENCIA ESCOLAR EM NIVEL ADEQUADO A IDADE
    if ('P0780' %in% cols) {
      arrw <- mutate(arrw, P0780 = case_when(
        P0780 == '1' ~ 'Adequado',
        P0780 == '2' ~ 'N\u00e3o adequado',
        P0780 == '9' ~ 'N\u00e3o aplic\u00e1vel - Pessoa com menos de 6 anos ou maior que 24 anos de idade'
      ))
    }

    # UF E MUNICIPIO OU PAIS ESTRANGEIRO DA ESCOLA DA PESSOA
    if ('P0800' %in% cols) {
      arrw <- mutate(arrw, P0800 = case_when(
        P0800 == '1' ~ 'Neste munic\u00edpio',
        P0800 == '2' ~ 'Em outro munic\u00edpio do Brasil',
        P0800 == '3' ~ 'Em outro pa\u00eds',
        P0800 == '9' ~ 'Ignorado'
      ))
    }

    # TRABALHOS DA PESSOA
    if ('P0900' %in% cols) {
      arrw <- mutate(arrw, P0900 = case_when(
        P0900 == '1' ~ 'Um',
        P0900 == '2' ~ 'Dois',
        P0900 == '3' ~ 'Tr\u00eas ou mais',
        P0900 == '9' ~ 'Ignorado'
      ))
    }

    # PESSOA DE 10 ANOS OU MAIS DE IDADE, CATEGORIA
    if ('P0910' %in% cols) {
      arrw <- mutate(arrw, P0910 = case_when(
        P0910 == '0' ~ 'Pessoa de menos de 10 anos de idade',
        P0910 == '1' ~ 'Pessoa de 10 anos ou mais de idade'
      ))
    }

    # PESSOA DE 14 ANOS OU MAIS DE IDADE, CATEGORIA
    if ('P0920' %in% cols) {
      arrw <- mutate(arrw, P0920 = case_when(
        P0920 == '0' ~ 'Pessoa de menos de 14 anos de idade',
        P0920 == '1' ~ 'Pessoa de 14 anos ou mais de idade'
      ))
    }

    # PESSOA DE 14 ANOS OU MAIS DE IDADE NA FORCA DE TRABALHO, CATEGORIA
    if ('P0930' %in% cols) {
      arrw <- mutate(arrw, P0930 = case_when(
        P0930 == '0' ~ 'Pessoa de 14 anos ou mais de idade FORA da for\u00e7a de trabalho',
        P0930 == '1' ~ 'Pessoa de 14 anos ou mais de idade na for\u00e7a de trabalho'
      ))
    }

    # PESSOA DE 14 ANOS OU MAIS, OCUPADA, CONTRIBUINTE DE INSTITUTO DE PREVIDENCIA NO TRABALHO PRINCIPAL, CATEGORIA
    if ('P0940' %in% cols) {
      arrw <- mutate(arrw, P0940 = case_when(
        P0940 == '0' ~ 'Pessoa de 14 anos ou mais de idade ocupada N\u00c3O contribuinte de instituto de previd\u00eancia no trabalho principal',
        P0940 == '1' ~ 'Pessoa de 14 anos ou mais de idade ocupada contribuinte de instituto de previd\u00eancia no trabalho principal'
      ))
    }

    # PESSOAS DE 14 ANOS OU MAIS OCUPADA, CATEGORIA
    if ('P0950' %in% cols) {
      arrw <- mutate(arrw, P0950 = case_when(
        P0950 == '0' ~ 'Desocupada',
        P0950 == '1' ~ 'Ocupada'
      ))
    }

    # PESSOAS DE 10 ANOS OU MAIS OCUPADA, CATEGORIA
    if ('P0960' %in% cols) {
      arrw <- mutate(arrw, P0960 = case_when(
        P0960 == '0' ~ 'N\u00e3o ocupada',
        P0960 == '1' ~ 'Ocupada'
      ))
    }

    # POSICAO NA OCUPACAO DO TRABALHO PRINCIPAL DA PESSOA
    if ('P0990' %in% cols) {
      arrw <- mutate(arrw, P0990 = case_when(
        P0990 == '01' ~ 'Trabalhador dom\u00e9stico (inclusive diarista)',
        P0990 == '02' ~ 'Militar do ex\u00e9rcito, da marinha, da aeron\u00e1utica, da pol\u00edcia militar ou do corpo de bombeiros militar',
        P0990 == '03' ~ 'Empregado do setor privado',
        P0990 == '04' ~ 'Empregado do setor p\u00fablico - funcion\u00e1rio estatut\u00e1rio',
        P0990 == '05' ~ 'Empregado do setor p\u00fablico - empregado n\u00e3o estatut\u00e1rio',
        P0990 == '06' ~ 'Empregado de empresas estatais',
        P0990 == '07' ~ 'Empregador (com pelo menos um empregado)',
        P0990 == '08' ~ 'Conta pr\u00f3pria (sem empregados)',
        P0990 == '09' ~ 'Trabalhador n\u00e3o remunerado em ajuda a morador do domic\u00edlio ou parente',
        P0990 == '99' ~ 'Ignorado'
      ))
    }

    # POSICAO NA OCUPACAO NO TRABALHO PRINCIPAL, SEMANA DE REFERENCIA, PESSOAS DE 10 ANOS OU MAIS
    if ('P1020' %in% cols) {
      arrw <- mutate(arrw, P1020 = case_when(
        P1020 == '01' ~ 'Empregado no setor privado COM carteira de trabalho assinada',
        P1020 == '02' ~ 'Empregado no setor privado SEM carteira de trabalho assinada',
        P1020 == '03' ~ 'Trabalhador dom\u00e9stico COM carteira de trabalho assinada',
        P1020 == '04' ~ 'Trabalhador dom\u00e9stico SEM carteira de trabalho assinada',
        P1020 == '05' ~ 'Empregado no setor p\u00fablico COM carteira de trabalho assinada',
        P1020 == '06' ~ 'Empregado no setor p\u00fablico SEM carteira de trabalho assinada',
        P1020 == '07' ~ 'Militar e servidor estatut\u00e1rio',
        P1020 == '08' ~ 'Empregador',
        P1020 == '09' ~ 'Conta pr\u00f3pria',
        P1020 == '10' ~ 'Trabalhador familiar auxiliar'
      ))
    }

    # ATIVIDADE PRINCIPAL, NO TRABALHO PRINCIPAL, SEMANA DE REFERENCIA, PESSOAS DE 10 ANOS OU MAIS (SOMENTE ACESSO CONTROLADO)
    if ('P1030' %in% cols) {
      arrw <- mutate(arrw, P1030 = case_when(
        P1030 == '01' ~ 'Agricultura, pecu\u00e1ria, produ\u00e7\u00e3o florestal, pesca e aquicultura',
        P1030 == '02' ~ 'Ind\u00fastrias extrativas',
        P1030 == '03' ~ 'Ind\u00fastrias de transforma\u00e7\u00e3o',
        P1030 == '04' ~ 'Eletricidade e g\u00e1s',
        P1030 == '05' ~ '\u00c1gua, esgoto, atividades de gest\u00e3o de res\u00edduos e descontamina\u00e7\u00e3o',
        P1030 == '06' ~ 'Constru\u00e7\u00e3o',
        P1030 == '07' ~ 'Com\u00e9rcio, repara\u00e7\u00e3o de ve\u00edculos automotores e motocicletas',
        P1030 == '08' ~ 'Transporte, armazenagem e correio',
        P1030 == '09' ~ 'Alojamento e alimenta\u00e7\u00e3o',
        P1030 == '10' ~ 'Informa\u00e7\u00e3o e comunica\u00e7\u00e3o',
        P1030 == '11' ~ 'Atividades financeiras, de seguros e servi\u00e7os relacionados',
        P1030 == '12' ~ 'Atividades imobili\u00e1rias',
        P1030 == '13' ~ 'Atividades profissionais, cient\u00edficas e t\u00e9cnicas',
        P1030 == '14' ~ 'Atividades administrativas e servi\u00e7os complementares',
        P1030 == '15' ~ 'Administra\u00e7\u00e3o p\u00fablica, defesa e seguridade social',
        P1030 == '16' ~ 'Educa\u00e7\u00e3o',
        P1030 == '17' ~ 'Sa\u00fade humana e servi\u00e7os sociais',
        P1030 == '18' ~ 'Artes, cultura, esporte e recrea\u00e7\u00e3o',
        P1030 == '19' ~ 'Outras atividades de servi\u00e7os',
        P1030 == '20' ~ 'Servi\u00e7os dom\u00e9sticos',
        P1030 == '21' ~ 'Organismos internacionais e outras institui\u00e7\u00f5es extraterritoriais',
        P1030 == '22' ~ 'Atividades mal definidas ou n\u00e3o especificadas (biscate)'
      ))
    }

    # GRANDES GRUPOS OCUPACIONAIS, TRABALHO PRINCIPAL, SEMANA DE REFERENCIA, PESSOAS DE 10 ANOS OU MAIS (SOMENTE ACESSO CONTROLADO)
    if ('P1040' %in% cols) {
      arrw <- mutate(arrw, P1040 = case_when(
        P1040 == '01' ~ 'Diretores e gerentes',
        P1040 == '02' ~ 'Profissionais das ci\u00eancias e intelectuais',
        P1040 == '03' ~ 'T\u00e9cnicos e profissionais de n\u00edvel m\u00e9dio',
        P1040 == '04' ~ 'Trabalhadores de apoio administrativo',
        P1040 == '05' ~ 'Trabalhadores dos servi\u00e7os, vendedores dos com\u00e9rcios e mercados',
        P1040 == '06' ~ 'Trabalhadores qualificados da agropecu\u00e1ria, florestais, da ca\u00e7a e da pesca',
        P1040 == '07' ~ 'Trabalhadores qualificados, oper\u00e1rios e artes\u00f5es da constru\u00e7\u00e3o, das artes mec\u00e2nicas e outros of\u00edcios',
        P1040 == '08' ~ 'Operadores de instala\u00e7\u00f5es e m\u00e1quinas e montadores',
        P1040 == '09' ~ 'Ocupa\u00e7\u00f5es elementares',
        P1040 == '10' ~ 'Membros das for\u00e7as armadas, policiais e bombeiros militares',
        P1040 == '11' ~ 'Ocupa\u00e7\u00f5es maldefinidas'
      ))
    }

    # TIPO DE RENDIMENTO BRUTO MENSAL HABITUALMENTE RECEBIDO EM TODOS OS TRABALHOS
    if ('P1070' %in% cols) {
      arrw <- mutate(arrw, P1070 = case_when(
        P1070 == '1' ~ 'Valor em dinheiro, produtos ou mercadorias',
        P1070 == '2' ~ 'Outra forma (Moradia, Alimenta\u00e7\u00e3o, Treinamento, etc.)'
      ))
    }

    # UF E MUNICIPIO OU PAIS ESTRANGEIRO DO LOCAL DE TRABALHO DA PESSOA
    if ('P1120' %in% cols) {
      arrw <- mutate(arrw, P1120 = case_when(
        P1120 == '1' ~ 'Em casa ou na propriedade',
        P1120 == '2' ~ 'Fora de casa e da propriedade',
        P1120 == '3' ~ 'Em outro munic\u00edpio do Brasil',
        P1120 == '4' ~ 'Em outro pa\u00eds',
        P1120 == '5' ~ 'Em mais de um munic\u00edpio ou pa\u00eds',
        P1120 == '9' ~ 'Ignorado'
      ))
    }

    # MEIO DE TRANSPORTE DE DESLOCAMENTO PARA O LOCAL DE TRABALHO DA PESSOA
    if ('P1170' %in% cols) {
      arrw <- mutate(arrw, P1170 = case_when(
        P1170 == '01' ~ 'A p\u00e9',
        P1170 == '02' ~ 'Bicicleta',
        P1170 == '03' ~ 'Motocicleta',
        P1170 == '04' ~ 'Motot\u00e1xi',
        P1170 == '05' ~ 'Autom\u00f3vel',
        P1170 == '06' ~ 'T\u00e1xi ou assemelhados',
        P1170 == '07' ~ 'Van, perua ou assemelhados',
        P1170 == '08' ~ '\u00d4nibus',
        P1170 == '09' ~ 'BRT ou \u00f4nibus de tr\u00e2nsito r\u00e1pido',
        P1170 == '10' ~ 'Trem ou metr\u00f4',
        P1170 == '11' ~ 'Caminhonete ou caminh\u00e3o adaptado (pau de arara)',
        P1170 == '12' ~ 'Embarca\u00e7\u00e3o de m\u00e9dio e grande porte (acima de 20 pessoas)',
        P1170 == '13' ~ 'Embarca\u00e7\u00e3o de pequeno porte (at\u00e9 20 pessoas)',
        P1170 == '14' ~ 'Outros',
        P1170 == '99' ~ 'Ignorado'
      ))
    }

    # TEMPO ENTRE A CASA E O LOCAL DE TRABALHO, CATEGORIA
    if ('P1180' %in% cols) {
      arrw <- mutate(arrw, P1180 = case_when(
        P1180 == '0' ~ 'N\u00e3o se desloca para local de trabalho',
        P1180 == '1' ~ 'At\u00e9 cinco minutos',
        P1180 == '2' ~ 'De seis minutos at\u00e9 quinze minutos',
        P1180 == '3' ~ 'Mais de quinze minutos at\u00e9 meia hora',
        P1180 == '4' ~ 'Mais de meia hora at\u00e9 uma hora',
        P1180 == '5' ~ 'Mais de uma hora at\u00e9 duas horas',
        P1180 == '6' ~ 'Mais de duas horas at\u00e9 quatro horas',
        P1180 == '7' ~ 'Mais de quatro horas',
        P1180 == '9' ~ 'Tempo n\u00e3o informado (ignorado)'
      ))
    }

    # QUEM PRESTOU AS INFORMACOES DA PESSOA
    if ('P1210' %in% cols) {
      arrw <- mutate(arrw, P1210 = case_when(
        P1210 == '1' ~ 'A pr\u00f3pria pessoa',
        P1210 == '2' ~ 'Outro morador',
        P1210 == '3' ~ 'N\u00e3o morador',
        P1210 == '9' ~ 'Ignorado'
      ))
    }

    # VARIAVEIS SIM(1) / NAO(2), SEM CATEGORIA "IGNORADO"
    vars_sim_nao_2022 <- c('P0260', 'P0300', 'P0310', 'P0400', 'P0640', 'P1010', 'P1200')
    vars_sim_nao_2022 <- vars_sim_nao_2022[vars_sim_nao_2022 %in% cols]
    arrw <- dplyr::mutate(arrw, dplyr::across(all_of(vars_sim_nao_2022),
                                              ~ case_when(
                                                .x == '1' ~ 'Sim',
                                                .x == '2' ~ 'N\u00e3o'
                                              )))

    # VARIAVEIS SIM(1) / NAO(2) / IGNORADO(9)
    vars_sim_nao_ignorado_2022 <- c('P0230', 'P0530', 'P0690', 'P0740', 'P0840',
                                    'P0850', 'P0860', 'P0870', 'P0880', 'P0890',
                                    'P1000', 'P1050', 'P1060', 'P1090', 'P1160')
    vars_sim_nao_ignorado_2022 <- vars_sim_nao_ignorado_2022[vars_sim_nao_ignorado_2022 %in% cols]
    arrw <- dplyr::mutate(arrw, dplyr::across(all_of(vars_sim_nao_ignorado_2022),
                                              ~ case_when(
                                                .x == '1' ~ 'Sim',
                                                .x == '2' ~ 'N\u00e3o',
                                                .x == '9' ~ 'Ignorado'
                                              )))
  } # nocov end


  # YEAR 2010 ------------------------------------------------------------------
    if (year == 2010 & lang == 'pt') {

      # RELACAO DE PARENTESCO OU DE CONVIVENCIA COM A PESSOA RESPONSAVEL PELO DOMICILIO
      if ('V0502' %in% cols) {
        arrw <- mutate(arrw, V0502 = case_when(
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
          V0502 == '20' ~ 'Individual em domic\u00edlio coletivo'))
          }

      # sex
      if ('V0601' %in% cols) {
        arrw <- arrw |> mutate(V0601 = case_when(
          V0601 == '1' ~ 'Masculino',
          V0601 == '2' ~ 'Feminino',
          V0601==  '9' ~ 'Ignorado'))
      }

      # FORMA DE DECLARACAO DA IDADE:
      if ('V6040' %in% cols) {
        arrw <- arrw |> mutate(V6040 = case_when(
          V6040 == '1' ~ 'Data de nascimento',
          V6040 == '2' ~ 'Idade declarada'))
      }

      # COR OU RACA
      if ('V0606' %in% cols) {
        arrw <- mutate(arrw, V0606 = case_when(
          V0606 == '1' ~ 'Branca',
          V0606 == '2' ~ 'Preta',
          V0606 == '3' ~ 'Amarela',
          V0606 == '4' ~ 'Parda',
          V0606 == '5' ~ 'Ind\u00edgena',
          V0606 == '9' ~ 'Ignorado'))
        }

      # REGISTRO DE NASCIMENTO
      if ('V0613' %in% cols) {
        arrw <- mutate(arrw, V0613 = case_when(
          V0613 == '1' ~ 'Do cart\u00f3rio',
          V0613 == '2' ~ 'Declara\u00e7\u00e3o de nascido vivo (DNV) do hospital ou da maternidade',
          V0613 == '3' ~ 'Registro administrativo de nascimento ind\u00edgena (RANI)',
          V0613 == '4' ~ 'N\u00e3o tem',
          V0613 == '5' ~ 'N\u00e3o sabe',
          V0613 == '9' ~ 'Ignorado'))
        }

      # physical disabilities
      pd_vars <- c('V0614', 'V0615', 'V0616')
      pd_vars <- pd_vars[pd_vars %in% cols]
      arrw <- dplyr::mutate(arrw, dplyr::across(all_of(pd_vars),
                                                ~ case_when(
                                                  .x == '1' ~ 'Sim, n\u00e3o consegue de modo algum',
                                                  .x == '2' ~ 'Sim, grande dificuldade',
                                                  .x == '3' ~ 'Sim, alguma dificuldade',
                                                  .x == '4' ~ 'N\u00e3o, nenhuma dificuldade')))

      # NASCEU NESTE MUNICIPIO
      if ('V0618' %in% cols) {
        arrw <- mutate(arrw, V0618 = case_when(
          V0618 == '1' ~ 'Sim, e sempre morou',
          V0618 == '2' ~ 'Sim mas morou em outro munic\u00edpio ou pa\u00eds estrangeiro',
          V0618 == '3' ~ 'N\u00e3o'))
        }

      # NASCEU NESTA UNIDADE DA FEDERACAO
      if ('V0619' %in% cols) {
        arrw <- mutate(arrw, V0619 = case_when(
          V0619 == '1' ~ 'Sim, e sempre morou',
          V0619 == '2' ~ 'Sim, mas morou em outra UF ou pa\u00eds estrangeiro',
          V0619 == '3' ~ 'N\u00e3o'))
        }

      # NACIONALIDADE
      if ('V0620' %in% cols) {
        arrw <- mutate(arrw, V0620 = case_when(
          V0620 == '1' ~ 'Brasileiro nato',
          V0620 == '2' ~ 'Naturalizado brasileiro',
          V0620 == '3' ~ 'Estrangeiro'))
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
        arrw <- mutate(arrw, V0628 = case_when(
          V0628 == '1' ~ 'Sim, p\u00fablica ',
          V0628 == '2' ~ 'Sim, particular',
          V0628 == '3' ~ 'N\u00e3o, j\u00e1 frequentou',
          V0628 == '4' ~ 'N\u00e3o, nunca frequentou'))
        }

      # CURSO QUE FREQUENTA
      if ('V0629' %in% cols) {
        arrw <- mutate(arrw, V0629 = case_when(
          V0629 == '01' ~ "Creche",
          V0629 == '02' ~ "Pr\u00e9-escolar (maternal e jardim da inf\u00e2ncia)",
          V0629 == '03' ~ "Classe de alfabetiza\u00e7\u00e3o - CA",
          V0629 == '04' ~ "Alfabetiza\u00e7\u00e3o de jovens e adultos",
          V0629 == '05' ~ "Regular do ensino fundamental",
          V0629 == '06' ~ "Educa\u00e7\u00e3o de jovens e adultos - EJA - ou supletivo do ensino fundamental",
          V0629 == '07' ~ "Regular do ensino m\u00e9dio",
          V0629 == '08' ~ "Educa\u00e7\u00e3o de jovens e adultos - EJA - ou supletivo do ensino m\u00e9dio",
          V0629 == '09' ~ "Superior de gradua\u00e7\u00e3o",
          V0629 == '10' ~ "Especializa\u00e7\u00e3o de n\u00edvel superior ( m\u00ednimo de 360 horas )",
          V0629 == '11' ~ "Mestrado",
          V0629 == '12' ~ "Doutorado"))
        }

      # SERIE / ANO QUE FREQUENTA
      if ('V0630' %in% cols) {
        arrw <- mutate(arrw, V0630 = case_when(
          V0630 == '01' ~ 'Primeiro ano',
          V0630 == '02' ~ 'Primeira s\u00e9rie - Segundo ano',
          V0630 == '03' ~ 'Segunda s\u00e9rie - Terceiro ano',
          V0630 == '04' ~ 'Terceira s\u00e9rie - Quarto ano',
          V0630 == '05' ~ 'Quarta s\u00e9rie - Quinto ano',
          V0630 == '06' ~ 'Quinta s\u00e9rie - Sexto ano',
          V0630 == '07' ~ 'Sexta s\u00e9rie - S\u00e9timo ano',
          V0630 == '08' ~ 'S\u00e9tima s\u00e9rie - Oitavo ano',
          V0630 == '09' ~ 'Oitava s\u00e9rie - Nono ano',
          V0630 == '10' ~ 'N\u00e3o seriado'))
        }

      # SERIE QUE FREQUENTA
      if ('V0631' %in% cols) {
        arrw <- mutate(arrw, V0631 = case_when(
          V0631 == '1' ~ 'Primeira s\u00e9rie',
          V0631 == '2' ~ 'Segunda s\u00e9rie',
          V0631 == '3' ~ 'Terceira s\u00e9rie',
          V0631 == '4' ~ 'Quarta s\u00e9rie',
          V0631 == '5' ~ 'N\u00e3o seriado'))
        }

      # CURSO MAIS ELEVADO QUE FREQUENTOU
      if ('V0633' %in% cols) {
        arrw <- mutate(arrw, V0633 = case_when(
          V0633 == '01' ~ "Creche, pr\u00e9-escolar (maternal e jardim de inf\u00e2ncia), classe de alfabetiza\u00e7\u00e3o - CA",
          V0633 == '02' ~ "Alfabetiza\u00e7\u00e3o de jovens e adultos",
          V0633 == '03' ~ "Antigo prim\u00e1rio (elementar)",
          V0633 == '04' ~ "Antigo gin\u00e1sio (m\u00e9dio 1\u00ba ciclo)",
          V0633 == '05' ~ "Ensino fundamental ou 1\u00ba grau (da 1\u00aa a 3\u00aa s\u00e9rie/ do 1\u00ba ao 4\u00ba ano)",
          V0633 == '06' ~ "Ensino fundamental ou 1\u00ba grau (4\u00aa s\u00e9rie/ 5\u00ba ano)",
          V0633 == '07' ~ "Ensino fundamental ou 1\u00ba grau (da 5\u00aa a 8\u00aa s\u00e9rie/ 6\u00ba ao 9\u00ba ano)",
          V0633 == '08' ~ "Supletivo do ensino fundamental ou do 1\u00ba grau",
          V0633 == '09' ~ "Antigo cient\u00edfico, cl\u00e1ssico, etc.....(m\u00e9dio 2\u00ba ciclo)",
          V0633 == '10' ~ "Regular ou supletivo do ensino m\u00e9dio ou do 2\u00ba grau",
          V0633 == '11' ~ "Superior de gradua\u00e7\u00e3o",
          V0633 == '12' ~ "Especializa\u00e7\u00e3o de n\u00edvel superior ( m\u00ednimo de 360 horas )",
          V0633 == '13' ~ "Mestrado",
          V0633 == '14' ~ "Doutorado"))
        }

      # ESPECIE DO CURSO MAIS ELEVADO CONCLUIDO
      if ('V0635' %in% cols) {
        arrw <- mutate(arrw, V0635 = case_when(
          V0635 == '1' ~ 'Superior de gradua\u00e7\u00e3o',
          V0635 == '2' ~ 'Mestrado',
          V0635 == '3' ~ 'Doutorado'))
        }

      # NIVEL DE INSTRUCAO
      if ('V6400' %in% cols) {
        arrw <- mutate(arrw, V6400 = case_when(
          V6400 == '1' ~ "Sem instru\u00e7\u00e3o e fundamental incompleto",
          V6400 == '2' ~ "Fundamental completo e m\u00e9dio incompleto",
          V6400 == '3' ~ "M\u00e9dio completo e superior incompleto",
          V6400 == '4' ~ "Superior completo"))
        }

      # V6352 curso superior de graduacao
      # V6354 curso superior de mestrado
      # V6356 curso superior de doutorado

      # MUNICIPIO E UNIDADE DA FEDERACAO OU PAIS ESTRANGEIRO QUE FREQUENTAVA ESCOLA (OU CRECHE):
      if ('V0636' %in% cols) {
        arrw <- mutate(arrw, V0636 = case_when(
          V0636 == '1' ~ 'Neste munic\u00edpio',
          V0636 == '2' ~ 'Em outro munic\u00edpio',
          V0636 == '3' ~ 'Em pa\u00eds estrangeiro'))
        }

      # V6362 municipio q frequenta escola
      # V6364 uf q frequenta escola
      # V6366 pais q frequenta escola

      # VIVE EM COMPANHIA DE CONJUGE OU COMPANHEIRO(A):
      if ('V0637' %in% cols) {
        arrw <- mutate(arrw, V0637 = case_when(
          V0637 == '1' ~ 'Sim',
          V0637 == '2' ~ 'N\u00e3o, mas viveu',
          V0637 == '3' ~ 'N\u00e3o, nunca viveu'))
        }


      # NATUREZA DA UNIAO
      if ('V0639' %in% cols) {
        arrw <- mutate(arrw, V0639 = case_when(
          V0639 == '1' ~ 'Casamento civil e religioso',
          V0639 == '2' ~ 'S\u00f3 casamento civil',
          V0639 == '3' ~ 'S\u00f3 casamento religioso',
          V0639 == '4' ~ 'Uni\u00e3o consensual'))
        }

      # ESTADO CIVIL
      if ('V0640' %in% cols) {
        arrw <- mutate(arrw, V0640 = case_when(
          V0640 == '1' ~ 'Casado(a)',
          V0640 == '2' ~ 'Desquitado(a) ou separado(a) judicialmente',
          V0640 == '3' ~ 'Divorciado(a)',
          V0640 == '4' ~ 'Vi\u00favo(a)',
          V0640 == '5' ~ 'Solteiro(a)'))
        }

      # QUANTOS TRABALHOS TINHA
      if ('V0645' %in% cols) {
        arrw <- mutate(arrw, V0645 = case_when(
          V0645 == '1' ~ 'Um',
          V0645 == '2' ~ 'Dois ou mais'))
        }

      # V6461 codigo ocupacao
      # V6471 codigo atividade

      # NESSE TRABALHO ERA
      if ('V0648' %in% cols) {
        arrw <- mutate(arrw, V0648 = case_when(
          V0648 == '1' ~ "Empregado com carteira de trabalho assinada ",
          V0648 == '2' ~ "Militar do ex\u00e9rcito, marinha, aeron\u00e1utica, policia militar ou corpo de bombeiros",
          V0648 == '3' ~ "Empregado pelo regime jur\u00eddico dos funcion\u00e1rios p\u00fablicos",
          V0648 == '4' ~ "Empregado sem carteira de trabalho assinada",
          V0648 == '5' ~ "Conta pr\u00f3pria",
          V0648 == '6' ~ "Empregador",
          V0648 == '7' ~ "N\u00e3o remunerado"))
        }

      # QUANTAS PESSOAS EMPREGAVA NESSE TRABALHO
      if ('V0649' %in% cols) {
        arrw <- mutate(arrw, V0649 = case_when(
          V0649 == '1' ~ "1 a 5 pessoas",
          V0649 == '2' ~ "6 ou mais pessoas"))
        }

      # ERA CONTRIBUINTE DE INSTITUTO DE PREVIDENCIA
      if ('V0650' %in% cols) {
        arrw <- mutate(arrw, V0650 = case_when(
          V0650 == '1' ~ "Sim, no trabalho principal",
          V0650 == '2' ~ "Sim, em outro trabalho",
          V0650 == '3' ~ "N\u00e3o"))
        }

      # V0651
      # V0652

      # EM QUE MUNICIPIO E UNIDADE DA FEDERACAO OU PAIS ESTRANGEIRO TRABALHA:
      if ('V0660' %in% cols) {
        arrw <- mutate(arrw, V0660 = case_when(
          V0660 == '1' ~ "No pr\u00f3prio domic\u00edlio",
          V0660 == '2' ~ "Apenas neste munic\u00edpio, mas n\u00e3o no pr\u00f3prio domic\u00edlio",
          V0660 == '3' ~ "Em outro munic\u00edpio",
          V0660 == '4' ~ "Em pa\u00eds estrangeiro",
          V0660 == '5' ~ "Em mais de um munic\u00edpio ou pa\u00eds"))
        }

      # V6602 em que municipio trbalhava
      # V6604 em que uf trbalhava
      # V6606 em que pais trbalhava

      # QUAL E O TEMPO HABITUAL GASTO DE DESLOCAMENTO DE SUA CASA ATE O TRABALHO
      if ('V0662' %in% cols) {
        arrw <- mutate(arrw, V0662 = case_when(
          V0662 == '1' ~ "At\u00e9 05 minutos",
          V0662 == '2' ~ "De 06 minutos at\u00e9 meia hora",
          V0662 == '3' ~ "Mais de meia hora at\u00e9 uma hora",
          V0662 == '4' ~ "Mais de uma hora at\u00e9 duas horas",
          V0662 == '5' ~ "Mais de duas horas"))
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
        arrw <- mutate(arrw, V0670 = case_when(
          V0670 == '1' ~ "A pr\u00f3pria pessoa",
          V0670 == '2' ~ "Outro morador",
          V0670 == '3' ~ "N\u00e3o morador"))
        }

      # CONDICAO DE OCUPACAO NA SEMANA DE REFERENCIA
      if ('V6910' %in% cols) {
        arrw <- mutate(arrw, V6910 = case_when(
          V6910 == '1' ~ "Ocupadas",
          V6910 == '2' ~ "Desocupadas"))
        }

      # SITUACAO DE OCUPACAO NA SEMANA DE REFERENCIA
      if ('V6920' %in% cols) {
        arrw <- mutate(arrw, V6920 = case_when(
          V6920 == '1' ~ "Ocupadas",
          V6920 == '2' ~ "Desocupadas"))
      }

      # POSICAO NA OCUPACAO E CATEGORIA DO EMPREGO NO TRABALHO PRINCIPAL
      if ('V6930' %in% cols) {
        arrw <- mutate(arrw, V6930 = case_when(
          V6930 == '1' ~ "Empregados com carteira de trabalho assinada",
          V6930 == '2' ~ "Militares e funcion\u00e1rios p\u00fablicos estatut\u00e1rios",
          V6930 == '3' ~ "Empregados sem carteira de trabalho assinada",
          V6930 == '4' ~ "Conta pr\u00f3pria",
          V6930 == '5' ~ "Empregadores",
          V6930 == '6' ~ "N\u00e3o remunerados",
          V6930 == '7' ~ "Trabalhadores na produ\u00e7\u00e3o para o pr\u00f3prio consumo"))
        }

      # SUBGRUPO E CATEGORIA DO EMPREGO NO TRABALHO PRINCIPAL
      if ('V6940' %in% cols) {
        arrw <- mutate(arrw, V6940 = case_when(
          V6940 == '1' ~ "Trabalhadores dom\u00e9sticos com carteira de trabalho assinada",
          V6940 == '2' ~ "Trabalhadores dom\u00e9sticos sem carteira de trabalho assinada",
          V6940 == '3' ~ "Demais empregados com carteira de trabalho assinada",
          V6940 == '4' ~ "Militares e funcion\u00e1rios p\u00fablicos estatut\u00e1rios",
          V6940 == '5' ~ "Demais empregados sem carteira de trabalho assinada"))
        }

      # V6121 religiao ou culto

      # TEM MAE VIVA
      if ('V0604' %in% cols) {
        arrw <- mutate(arrw, V0604 = case_when(
          V0604 == '1' ~ "Sim e mora neste domic\u00edlio",
          V0604 == '2' ~ "Sim e mora em outro domic\u00edlio",
          V0604 == '3' ~ "N\u00e3o",
          V0604 == '4' ~ "N\u00e3o sabe"))
        }

      # V6462 ocupacao
      # V6472 atividade


      # TIPO DE UNIDADE DOMESTICA
      if ('V5030' %in% cols) {
        arrw <- mutate(arrw, V5030 = case_when(
          V5030 == '1' ~ "Unipessoal",
          V5030 == '2' ~ "Duas pessoas ou mais sem parentesco",
          V5030 == '3' ~ "Duas pessoas ou mais com parentesco"))
        }

      ## family block
      # V5040
      # V5090
      # V5100


      ### Yes (1) or No (2) columns
      vars_sim_nao <- c('V0617', 'V0627', 'V0632', 'V0634', 'V0641', 'V0642',
                        'V0643', 'V0644', 'V0654', 'V0655', 'V0661', 'V6664',

                        # 1 (yes), (0) no, (9) ignored
                        'V0656', 'V0657', 'V0658', 'V0659')

      # mutate only colnames present
      vars_sim_nao_present <- vars_sim_nao[vars_sim_nao %in% cols]
      arrw <- dplyr::mutate(arrw, dplyr::across(all_of(vars_sim_nao_present),
                                                ~ if_else(.x == '1', 'Sim', 'N\u00e3o')
                                                ))

      # census tract type
      if ('V1005' %in% cols) {
        arrw <- mutate(arrw, V1005 = case_when(
          V1005 == '1' ~ '\u00c1rea urbanizada',
          V1005 == '2' ~ '\u00c1rea n\u00e3o urbanizada',
          V1005 == '3' ~ '\u00c1rea urbanizada isolada',
          V1005 == '4' ~ '\u00c1rea rural de extens\u00e3o urbana',
          V1005 == '5' ~ 'Aglomerado rural (povoado)',
          V1005 == '6' ~ 'Aglomerado rural (n\u00facleo)',
          V1005 == '7' ~ 'Aglomerado rural (outros)',
          V1005 == '8' ~ '\u00c1rea rural exclusive aglomerado rural'))
        }

    } # nocov end

  # YEAR 2000----------------------------------------------------------------

  # to be done.....

  return(arrw)
}
