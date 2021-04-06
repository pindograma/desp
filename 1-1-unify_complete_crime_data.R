# 1-1-unify_complete_crime_data.R
# (c) 2021 CincoNoveSeis Jornalismo Ltda.

library(tidyverse)
library(readxl)

es_files = list.files('raw_crime_data/es', full.names = T, pattern = 'xls')

parse_es = function(f, s) {
  data = read_excel(f, s, skip = 2) %>%
    janitor::clean_names() %>%
    mutate(date = date(data)) %>%
    mutate(crime = pull(select(., matches('incidente|descricao')))) %>%
    mutate(victim_sex = case_when(
      str_sub(sexo, 1, 1) == 'F' ~ 'F',
      str_sub(sexo, 1, 1) == 'M' ~ 'M',
      T ~ NA_character_
    )) %>%
    mutate(victim_age = suppressWarnings(as.numeric(idade))) %>%
    rename(city = municipio, neighborhood = bairro) %>%
    mutate(address = pull(select(., matches('logradouro|endereco')))) %>%
    select(-data, -hora, -sexo, -idade, -contains('incidente'), -matches('logradouro|endereco'))
}

es_data = map_dfr(es_files, function(f) {
  map_dfr(excel_sheets(f), function(s) { parse_es(f, s) })
}) %>%
  mutate(crime_big = case_when(
    grepl('ESTELIONATO.FRAUDE', crime) ~ 'estelionato-fraude',
    grepl('ROUBO', crime) ~ 'roubo',
    grepl('FURTO', crime) ~ 'furto',
    grepl('DANOS ', crime) ~ 'danos',
    crime == 'CRIMES CONTRA PATRIMÔNIO: INVASÃO PROPRIEDADE ALHEIA' ~ 'invasao-propriedade',
    startsWith(crime, 'CRIMES CONTRA PATRIMÔNIO: APROPRIAÇÃO INDÉBITA') ~ 'apropriacao-indebita',
    startsWith(crime, 'CRIMES CONTRA PATRIMÔNIO: OUTROS CRIMES') ~ 'outros-patrimoniais',
    startsWith(crime, 'CRIMES CONTRA PATRIMÔNIO: EXTORSÃO') ~ 'extorsao',
    crime == 'CRIMES CONTRA PATRIMÔNIO: RECEPTAÇÃO' ~ 'receptacao',
    
    crime == 'LESÃO CORPORAL: SEGUIDA DE MORTE' ~ 'cvli',
    grepl('LATROCÍNIO', crime) ~ 'cvli',
    grepl('FEMINICIDIO', crime) ~ 'cvli',
    crime == 'CRIMES CONTRA PATRIMÔNIO: TENTATIVA DE LATROCÍNIO' ~ 'tentativa-cvli',
    crime == 'HOMICÍDIO: POR AÇÃO DA POLÍCIA' ~ 'morte-intervencao-policial',
  ))
