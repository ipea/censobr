# Add labels to categorical variables of population datasets
#' @keywords internal
add_labels_population <- function(arrw,
                                  year = parent.frame()$year,
                                  lang = 'pt'){

  # check input
  checkmate::assert_string(lang, pattern = 'pt', na.ok = TRUE)
  if (!(year %in% c(2010))) {
    cli::cli_abort("Labels for this data are only available for the year c(2010)")
    }

  # names of columns present in the data
  cols <- names(arrw) # nocov start

  # YEAR 2010 ------------------------------------------------------------------
    if (year == 2010 & lang == 'pt') {

      # YAML-backed pilot: these maps are compiled into one mutate().
      config <- load_label_config(dataset = "population", year = year, lang = lang)
      arrw <- apply_label_config(arrw, config)

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
