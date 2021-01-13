# 2-mergemaps.R
# (c) 2021 CincoNoveSeis Jornalismo Ltda.

library(tidyverse)
library(sf)
library(mapalib)

load('unified.Rdata')

rj_shape = st_read('shapes/rj/lm_dp_2019.shp') %>%
  select(dp)

ce_shape = st_read('shapes/ce/fortaleza.geojson')

df_shape = st_read('shapes/df/mancha_urbana_df.shp') %>%
  group_by(ra_num) %>%
  summarize()

rio_data_fmt = rio_data %>%
  pivot_wider(names_from = crime, values_from = value) %>%
  select(-month) %>%
  group_by(area, year, munic) %>%
  summarize_all(sum)

df_data_fmt = df_data %>%
  select(-crime_big) %>%
  pivot_wider(names_from = crime_small, values_from = value)

ce_data_fmt = ceara_data %>%
  pivot_wider(names_from = crime_big, values_from = value) %>%
  filter(area <= 10)

rio_joined = st_as_sf(left_join(rio_data_fmt, rj_shape, c('area' = 'dp'))) %>%
  st_transform(31983)

df_joined = left_join(df_data_fmt, df_shape, c('area' = 'ra_num'))
ce_joined = left_join(ce_data_fmt, ce_shape, c('area' = 'ais'))

rio_pref = get_map_points(2020, 11, c(3304557), 31983, aggregate_all_candidates, with_blank_null = T, turno = 1)

rio_crossed_19 = st_join(rio_joined %>% filter(year == 2019 & munic == 'Rio de Janeiro'), rio_pref, st_contains) %>%
  st_drop_geometry() %>%
  group_by_at(colnames(st_drop_geometry(rio_joined))) %>%
  summarize(across(starts_with('abs_votes'), sum)) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(total = sum(c_across(starts_with('abs_votes')), na.rm = T)) %>%
  mutate(pct_crivella = abs_votes_10/total, pct_paes = abs_votes_25/total) %>%
  ungroup() %>%
  left_join(rj_shape, c('area' = 'dp')) %>%
  st_as_sf()

rio_crossed_20 = st_join(rio_joined %>% filter(year == 2020 & munic == 'Rio de Janeiro'), rio_pref, st_contains) %>%
  st_drop_geometry() %>%
  group_by_at(colnames(st_drop_geometry(rio_joined))) %>%
  summarize(across(starts_with('abs_votes'), sum)) %>%
  ungroup() %>%
  left_join(rj_shape, c('area' = 'dp')) %>%
  st_as_sf()
