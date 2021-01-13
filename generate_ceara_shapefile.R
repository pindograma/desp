# generate_ceara_shapefile.R
# (c) 2021 CincoNoveSeis Jornalismo Ltda.

library(tidyverse)
library(sf)

fortaleza_neighborhoods = maptools::readShapePoly('base_files/fortaleza/BAIRROS DE FORTALEZA.shp') %>%
  cleangeo::clgeo_Clean() %>%
  st_as_sf() %>%
  select(Name)

# Source: https://www.sspds.ce.gov.br/ais/
ais_1_bairros = c(
  'CAIS DO PORTO', 'VICENTE PIZON', 'MUCURIPE', 'VARJOTA', 'MEIRELES',
  'ALDEOTA', 'PRAIA DE IRACEMA'
)

ais_2_bairros = c(
  'SIQUEIRA', 'GRANJA LISBOA', 'BOM JARDIM', 'GRANJA PORTUGAL',
  'CONJUNTO CEARA I', 'CONJUNTO CEARA II', 'GENIBAU'
)

ais_3_bairros = c(
  'PEDRAS', 'PAUPINA', 'COACU', 'ANCURI',
  'PALMEIRAS', 'JANGURUSSU', 'BARROSO', 'MESSEJANA', 'CURIO',
  'GUAJERU', 'LAGOA REDONDA'
)

ais_4_bairros = c(
  'CENTRO', 'MOURA BRASIL', 'JACARECANGA', 'FARIAS BRITO', 'SAO GERARDO',
  'MONTE CASTELO', 'CARLITO PAMPLONA', 'ALVARO WEYNE', 'VILA ELLERY'
)

ais_5_bairros = c(
  'JOSE BONIFACIO', 'BENFICA', 'FATIMA', 'JARDIM AMERICA', 'DAMAS',
  'BOM FUTURO', 'PARREAO', 'VILA UNIAO', 'AEROPORTO', 'MONTESE',
  'ITAOCA', 'SERRINHA', 'ITAPERI', 'DENDE', 'VILA PERY', 'PARANGABA',
  'DEMOCRITO ROCHA', 'COUTO FERNANDES', 'VILA AMERICANO', 'PAN AMERICANO'
)

ais_6_bairros = c(
  'QUINTINO CUNHA', 'ANTONIO BEZERRA', 'AUTRAN NUNES', 'HENRIQUE JORGE',
  'JOAO XXIII', 'BONSUCESSO', 'JOQUEI CLUBE', 'PICI', 'DOM LUSTOSA',
  'PADRE ANDRADE', 'PRESIDENTE KENNEDY', 'PARQUELANDIA', 'AMADEU FURTADO',
  'BELA VISTA', 'RODOLFO TEOFILO', 'PARQUE ARAXA'
)

ais_7_bairros = c(
  'PARQUE DOIS IRMAOS', 'PASSARE', 'CASTELAO', 'DIAS MACEDO', 'CAJAZEIRAS',
  'PARQUE IRACEMA', 'CIDADE DOS FUNCIONARIOS', 'JARDIM DAS OLIVEIRAS',
  'AEROLANDIA', 'ALTO DA BALANCA', 'CAMBEBA', 'PARQUE MANIBURA',
  'ALAGADICO NOVO', 'SAPIRANGA/COITE', 'EDSON QUEIROZ', 'SABIAGUABA',
  'MATA GALINHA'
)

ais_8_bairros = c(
  'VILA VELHA', 'JARDIM GUANABARA', 'JARDIM IRACEMA', 'FLORESTA',
  'BARRA DO CEARA', 'CRISTO REDENTOR', 'PIRAMBU'
)

ais_9_bairros = c(
  'PREFEITO JOSE WALTER', 'MONDUBIM I', 'MONDUBIM II',
  'CANINDEZINHO', 'PARQUE SAO JOSE', 'PARQUE PRES. VARGAS',
  'PARQUE SANTA ROSA', 'CONJUNTO ESPERANCA', 'VILA MANOEL SATIRO',
  'MARAPONGA', 'JARDIM CEARENSE'
)

ais_10_bairros = c(
  'PRAIA DO FUTURO I', 'PRAIA DO FUTURO II', 'CIDADE 2000',
  'COCO', 'PAPICU', 'LUCIANO CAVALCANTE', 'SALINAS',
  'GUARARAPES', 'SAO JOAO DO TAUAPE', 'JOAQUIM TAVORA', 'DIONISIO TORRES', 'DUNAS'
)

output = fortaleza_neighborhoods %>%
  mutate(ais = case_when(
    Name %in% ais_1_bairros ~ 1,
    Name %in% ais_2_bairros ~ 2,
    Name %in% ais_3_bairros ~ 3,
    Name %in% ais_4_bairros ~ 4,
    Name %in% ais_5_bairros ~ 5,
    Name %in% ais_6_bairros ~ 6,
    Name %in% ais_7_bairros ~ 7,
    Name %in% ais_8_bairros ~ 8,
    Name %in% ais_9_bairros ~ 9,
    Name %in% ais_10_bairros ~ 10
  )) %>%
  group_by(ais) %>%
  summarize() %>%
  nngeo::st_remove_holes()

st_write(output, 'shapes/ce/fortaleza.geojson')
