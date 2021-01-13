# 1-unify_crime_data.R
# (c) 2021 CincoNoveSeis Jornalismo Ltda.

library(tidyverse)
library(readxl)
library(lubridate)

df_files = list.files('raw_crime_data/df', full.names = T, pattern = 'xls')
ce_files = list.files('raw_crime_data/ce', full.names = T, pattern = 'xls')

parse_df = function(fname, sheet) {
  data = read_excel(fname, sheet)
  
  nn = c(pull(data, 2), names(data)[2])
  
  ra = nn[grepl('RA ', nn) | startsWith(nn, 'SOL NASCENTE') | startsWith(nn, 'ARNIQUEIRA')] %>%
    na.omit() %>%
    as.character() %>%
    str_replace('.*RA ', 'RA ')
  
  if (ra == 'SOL NASCENTE') {
    ra = 'RA XXXII - SOL NASCENTE'
  } else if (ra == 'ARNIQUEIRA') {
    ra = 'RA XXXIII - ARNIQUEIRA'
  }
  
  year = nn[startsWith(nn, 'COMPARATIVO')] %>%
    na.omit() %>%
    as.character() %>%
    str_sub(20, 24) %>%
    str_squish() %>%
    as.numeric()
  
  p = pull(data, 1)
  index = which(p == 'EIXOS INDICADORES') + 1
  
  data %>%
    select(-1) %>%
    filter(row_number() >= index) %>%
    janitor::row_to_names(1) %>%
    janitor::clean_names() %>%
    select(-na_2) %>%
    rename(crime = na) %>%
    filter(!is.na(crime)) %>%
    suppressWarnings() %>%
    mutate(area = ra, year = year)
}

parse_ce = function(fname) {
  data = read_excel(fname)
  
  title = names(data)[1]
  year = as.numeric(word(title, -1))
  crime = word(title, 2, -5)
  
  precleaned = data %>%
    janitor::row_to_names(1) %>%
    janitor::clean_names()
  
  clean_ce = function(x) {
    x %>%
      select(-1) %>%
      filter(!is.na(area_integrada_de_seguranca) & startsWith(area_integrada_de_seguranca, 'AIS')) %>%
      select(-total, -bairro_municipio) %>%
      rename(area = area_integrada_de_seguranca)
  }
  
  if (!grepl('cocaína', title)) {
    clean_ce(precleaned) %>%
      mutate(year = year, crime = crime)
  } else {
    p = pull(data, 1)
    indexes = which(startsWith(p, 'Tabela'))
    
    crime2 = word(p[indexes[1]], 2, -5)
    crime3 = word(p[indexes[2]], 2, -5)
    
    tab1 = precleaned %>%
      filter(row_number() < indexes[1])
    tab2 = precleaned %>%
      filter(row_number() > indexes[1] & row_number() < indexes[2])
    tab3 = precleaned %>%
      filter(row_number() > indexes[2])
    
    bind_rows(
      clean_ce(tab1) %>% mutate(year = year, crime = word(crime, 2, end = -1)),
      clean_ce(tab2) %>% mutate(year = year, crime = word(crime2, 2, end = -1)),
      clean_ce(tab3) %>% mutate(year = year, crime = word(crime3, 2, end = -1))
    )
  }
}

df_data = map_dfr(df_files, function(f) {
  map_dfr(excel_sheets(f), function(s) { parse_df(f, s) })
}) %>%
  filter(crime != 'LOCALIZAÇÃO DE VEICULO FURTADO OU ROUBADO') %>%
  mutate(crime_big = case_when(
    crime == 'ESTUPRO' ~ 'sexuais',
    crime == 'FURTO A TRANSEUNTE' ~ 'furto',
    crime == 'FURTO EM VEÍCULO' ~ 'furto',
    crime == 'HOMICÍDIO' ~ 'cvli',
    crime == 'LATROCÍNIO' ~ 'cvli',
    crime == 'LESÃO CORPORAL SEG. DE MORTE' ~ 'cvli',
    crime == 'POSSE/PORTE DE ARMA' ~ 'posse-porte-arma',
    crime == 'ROUBO A TRANSEUNTE' ~ 'roubo',
    crime == 'ROUBO EM COLETIVO' ~ 'roubo',
    crime == 'ROUBO EM COMÉRCIO *' ~ 'roubo',
    crime == 'ROUBO EM RESIDÊNCIA' ~ 'roubo',
    crime == 'ROUBO DE VEÍCULO' ~ 'roubo',
    crime == 'TENTATIVA DE HOMICÍDIO' ~ 'tentativa-cvli',
    crime == 'TENTATIVA DE LATROCÍNIO' ~ 'tentativa-cvli',
    crime == 'TENTATIVA DE LATROCINIO' ~ 'tentativa-cvli',
    crime == 'TRÁFICO DE DROGAS' ~ 'trafico-drogas',
    crime == 'USO E PORTE DE DROGAS' ~ 'uso-drogas'
  )) %>%
  mutate(crime_small = case_when(
    crime == 'ESTUPRO' ~ 'estupro',
    crime == 'FURTO A TRANSEUNTE' ~ 'furto-transeunte',
    crime == 'FURTO EM VEÍCULO' ~ 'furto-veiculo',
    crime == 'HOMICÍDIO' ~ 'homicidio-doloso',
    crime == 'LATROCÍNIO' ~ 'latrocinio',
    crime == 'LESÃO CORPORAL SEG. DE MORTE' ~ 'lesao-corporal-morte',
    crime == 'POSSE/PORTE DE ARMA' ~ 'posse-porte-arma',
    crime == 'ROUBO A TRANSEUNTE' ~ 'roubo-transeunte',
    crime == 'ROUBO EM COLETIVO' ~ 'roubo-coletivo',
    crime == 'ROUBO EM COMÉRCIO *' ~ 'roubo-comercio',
    crime == 'ROUBO EM RESIDÊNCIA' ~ 'roubo-residencia',
    crime == 'ROUBO DE VEÍCULO' ~ 'roubo-veiculo',
    crime == 'TENTATIVA DE HOMICÍDIO' ~ 'tentativa-homicidio',
    crime == 'TENTATIVA DE LATROCÍNIO' ~ 'tentativa-latrocinio',
    crime == 'TENTATIVA DE LATROCINIO' ~ 'tentativa-latrocinio',
    crime == 'TRÁFICO DE DROGAS' ~ 'trafico-drogas',
    crime == 'USO E PORTE DE DROGAS' ~ 'uso-drogas'
  )) %>%
  mutate(area = as.numeric(as.roman(word(area, 2)))) %>%
  pivot_longer(c(jan, fev, mar, abr, mai, jun, jul, ago, set, out, nov, dez), names_to = 'month') %>%
  mutate(value = as.numeric(value)) %>%
  mutate(month = month(parse_date(paste(month, year), format = '%b %Y', locale = locale('pt')))) %>%
  group_by(crime_big, crime_small, area, year, month) %>%
  summarize(value = sum(value)) %>%
  ungroup()

ceara_data = map_dfr(ce_files, parse_ce) %>%
  filter(!grepl('Apreensão', crime) & !grepl('crack', crime)) %>%
  mutate(crime_big = case_when(
    crime == 'Crimes Violentos Letais Intencionais' ~ 'cvli',
    crime == 'Número de Vítimas de Crimes Sexuais' ~ 'sexuais',
    grepl('Patrimônio', crime) ~ 'roubo',
    grepl('Furto', crime) ~ 'furto'
  ), crime_small = NA) %>%
  mutate(area = as.numeric(word(area, 2))) %>%
  pivot_longer(c(janeiro, fevereiro, marco, abril, maio, junho, julho, agosto,
                 setembro, outubro, novembro, dezembro), names_to = 'month') %>%
  mutate(month = ifelse(month == 'marco', 'março', month)) %>%
  mutate(month = month(parse_date(paste(month, year), format = '%B %Y', locale = locale('pt')))) %>%
  mutate(value = as.numeric(value)) %>%
  group_by(area, year, month, crime_big) %>%
  summarize(value = sum(value)) %>%
  ungroup()

salvador_data = read_csv('raw_crime_data/salvador/salvador_crimes.csv') %>%
  mutate(date = tolower(date)) %>%
  rename(area = aisp, value = occurrences) %>%
  filter(!grepl('período', date)) %>%
  mutate(crime_big = case_when(
    crime == 'Estupro' ~ 'sexuais',
    crime == 'Lesão Corporal Seguida de Morte' ~ 'cvli',
    crime == 'Furto de Veículo' ~ 'furto',
    crime == 'Homicídio Doloso' ~ 'cvli',
    crime == 'Latrocínio' ~ 'cvli',
    crime == 'Roubo a Ônibus' ~ 'roubo',
    crime == 'Roubo de Veículo' ~ 'roubo',
    crime == 'Tentativa de Homicídio' ~ 'tentativa-cvli',
    crime == 'Uso/Porte Entorpecente' ~ 'uso-drogas'
  )) %>%
  mutate(crime_small = case_when(
    crime == 'Estupro' ~ 'estupro',
    crime == 'Lesão Corporal Seguida de Morte' ~ 'lesao-corporal-morte',
    crime == 'Furto de Veículo' ~ 'furto-veiculo',
    crime == 'Homicídio Doloso' ~ 'homicidio-doloso',
    crime == 'Latrocínio' ~ 'latrocinio',
    crime == 'Roubo a Ônibus' ~ 'roubo-coletivo',
    crime == 'Roubo de Veículo' ~ 'roubo-veiculo',
    crime == 'Tentativa de Homicídio' ~ 'tentativa-homicidio',
    crime == 'Uso/Porte Entorpecente' ~ 'uso-drogas'
  )) %>%
  mutate(year = year(parse_date(date, format = '%B/%Y', locale = locale('pt')))) %>%
  mutate(month = month(parse_date(date, format = '%B/%Y', locale = locale('pt')))) %>%
  select(-date)

rio_data = read_csv2('raw_crime_data/rj/BaseDPEvolucaoMensalCisp.csv',
                     col_types = cols(aaapai = col_number(), apf = col_number(),
                                      apreensao_drogas_sem_autor = col_number(),
                                      cmba = col_number(), cmp = col_number(),
                                      furto_bicicleta = col_number(),
                                      roubo_bicicleta = col_number(),
                                      trafico_drogas = col_number(),
                                      posse_drogas = col_number())) %>%
  select(-mes_ano, -AISP, -RISP, -munic, -mcirc, -Regiao) %>%
  rename(month = mes, year = ano, area = CISP) %>%
  select(-letalidade_violenta, -total_roubos, -total_furtos,
         -recuperacao_veiculos, -apf, -aaapai, -cmp, -cmba,
         -pessoas_desaparecidas, -encontro_cadaver, -encontro_ossada,
         -cvli, -registro_ocorrencias, -fase) %>%
  pivot_longer(-c(area, month, year), names_to = 'crime')

save(list = c('rio_data', 'salvador_data', 'df_data', 'ceara_data'), file = 'unified.Rdata')
