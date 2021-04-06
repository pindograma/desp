# 3-consolidate_data.R
# (c) 2021 CincoNoveSeis Jornalismo Ltda.

library(tidyverse)

load('unified_by_area.Rdata')
load('unified_by_area_2.Rdata')

map(ls(), function(x) {
    write.csv(eval(parse(text = x)), paste0('output/', x, '.csv'), row.names = F)
})
