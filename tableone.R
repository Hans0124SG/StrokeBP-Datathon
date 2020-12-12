library(tableone)
library(dplyr)

setwd("~/Desktop/PhD study/StrokeBP/datathon/")
df <- read.csv('MIMIC_dataset_v2.csv', stringsAsFactors = TRUE)

df[c('ethnicity')] = apply(df[c('ethnicity')], 1, mergeEth)
df$heparin_iv[is.na(df$heparin_iv)] <- 0
df$antihypertensive_iv_non_tight_control[is.na(df$antihypertensive_iv_non_tight_control)] <- 0
df$antihypertensive_iv_tight_control[is.na(df$antihypertensive_iv_tight_control)] <- 0
df$antiplatelets[is.na(df$antiplatelets)] <- 0
df$anticoag[is.na(df$anticoag)] <- 0
df$antihypertensive_non_iv[is.na(df$antihypertensive_non_iv)] <- 0
df['antihtx_normal'] = as.numeric(unlist(df[c('antihypertensive_iv_non_tight_control')])) + as.numeric(unlist(df['antihypertensive_non_iv']))

df$antihtx <- with(df, ifelse(as.numeric(antihypertensive_iv_tight_control)>1, 2, ifelse(as.numeric(antihtx_normal)>1, 1, 0)))

df[c('afib', 'hyperlipidemia', 'diabetes', 'hypertension',
     'cor_art_d', 'peri_vasc_d', 'car_art_stent','smoking',
     'tia', 'heparin_iv', 'antiplatelets',
     'anticoag')] = apply(df[c('afib', 'hyperlipidemia', 'diabetes', 'hypertension',
                               'cor_art_d', 'peri_vasc_d', 'car_art_stent','smoking',
                               'tia', 'heparin_iv', 'antiplatelets',
                               'anticoag')], c(1,2), cap)

