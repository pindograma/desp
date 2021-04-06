# Dados Espaciais de Segurança Pública

Alguns estados brasileiros disponibilizam dados de segurança pública a nível
sub-municipal. Isso permite análises territoriais muito interessantes acerca
dos padrões de criminalidade.

Este projeto organiza estes dados e os transforma em planilhas que podem ser
facilmente processadas por analistas em softwares como R, Python e QGIS.

Atualmente, há dados disponíveis para as seguintes áreas:

| Estado | Abrangência | Nível de Agregação                  |
| ---    | ---         | ---                                 |
| RJ     | Estado      | Distrito Policial                   |
| BA     | Capital     | Área Integrada de Segurança Pública |
| CE     | Capital     | Área Integrada de Segurança Pública |
| ES     | Estado      | Endereço da Ocorrência              |
| DF     | Estado      | Distrito Policial                   |

Os dados da Secretaria de Segurança Pública de São Paulo têm um formato
diferente dos dados de outros estados, e já são distribuídos em formato
legível por máquina. Por isso, embora disponíveis, este projeto não lida com
eles.

## Outputs

Você não precisa se preocupar com os scripts deste projeto se você quer apenas
os dados de segurança pública consolidados. Os arquivos tratados para download
se encontram [aqui][1].

## Documentação

Este projeto tem a seguinte estrutura:

###### Diretórios

* **base_files/**: Arquivos diversos que subsidiam o processamento de dados.
* **shapes/** Shapefiles das áreas relevantes de segurança pública.
* **raw_crime_data/**: Arquivos com informações de crimes fornecidos pelos
  órgãos estaduais -- ora através de transparência ativa, ora através de
  pedidos através da Lei de Acesso à Informação.

###### Código

* **1-generate_ceara_shapefile.R**: Gera a _shapefile_ de áreas de segurança
  pública de Fortaleza.
* **1-get_sp_files.sh**: Limpa os arquivos de crimes da Secretaria de Segurança
  Pública de São Paulo.
* **1-unify_crime_data.R**: Trata os dados de diversos órgãos estaduais e os
  unifica em um único formato (se aplica para órgãos que divulgam estatísticas
  _agregadas_).
* **1-1-unify_complete_crime_data.R**: Trata os dados de diversos órgãos estaduais e os
  unifica em um único formato (se aplica para órgãos que divulgam estatísticas
  _desagregadas_).
* **2-mergemaps.R**: Cruza os dados anteriormente tratados com informações
  geográficas, e exporta _shapefiles_.

[1]: https://pindograma-dados.s3.amazonaws.com
