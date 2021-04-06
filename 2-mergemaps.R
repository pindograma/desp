# 2-mergemaps.R
# (c) 2021 CincoNoveSeis Jornalismo Ltda.

library(tidyverse)
library(sf)

load('unified_by_area.Rdata')
load('unified_by_area2.Rdata')

rj_shape = st_read('shapes/rj/lm_dp_2019.shp') %>%
  select(dp)

ce_shape = st_read('shapes/ce/fortaleza.geojson')

df_shape = st_read('shapes/df/mancha_urbana_df.shp') %>%
  group_by(ra_num) %>%
  summarize()

ba_shape = st_read('shapes/ba/SSP_AISP_SSA_2021.shp') %>%
  rename(area = OBJECTID) %>%
  select(area)

rio_data_fmt = rio_data %>%
  pivot_wider(names_from = crime, values_from = value) %>%
  select(-month, -crime_big) %>%
  group_by(area, year, munic) %>%
  summarize_all(sum, na.rm = T) %>%
  ungroup()

df_data_fmt = df_data %>%
  select(-crime_big, -crime) %>%
  pivot_wider(names_from = crime_small, values_from = value) %>%
  select(-month) %>%
  group_by(area, year) %>%
  summarize_all(sum)

ce_data_fmt = ceara_data %>%
  pivot_wider(names_from = crime_big, values_from = value) %>%
  filter(area <= 10) %>%
  select(-month) %>%
  group_by(area, year) %>%
  summarize_all(sum, na.rm = T)

ba_data_fmt = salvador_data %>%
  select(-crime_big, -crime) %>%
  pivot_wider(names_from = crime_small, values_from = value) %>%
  select(-month) %>%
  group_by(area, year) %>%
  summarize_all(sum, na.rm = T)

rio_joined = st_as_sf(left_join(rio_data_fmt, rj_shape, c('area' = 'dp'))) %>%
  st_transform(4326)

df_joined = st_as_sf(left_join(df_data_fmt, df_shape, c('area' = 'ra_num'))) %>%
  st_transform(4326)

ce_joined = st_as_sf(left_join(ce_data_fmt, ce_shape, c('area' = 'ais'))) %>%
  st_transform(4326)

ba_joined = st_as_sf(left_join(ba_data_fmt, ba_shape, c('area' = 'area'))) %>%
  st_transform(4326)
