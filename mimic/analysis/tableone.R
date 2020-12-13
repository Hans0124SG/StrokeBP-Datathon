library(tableone)
library(dplyr)

cap <- function(x) if (x == 0) {
  0
} else {
  1
}
mergeEth <- function(x) if (x == 'WHITE') {
  0
} else if (x == 'ASIAN') {
  1
} else if (x == 'BLACK/AFRICAN AMERICAN') {
  2
} else {
  3
}
setwd("~/Desktop/PhD study/StrokeBP/datathon/MIMIC/analysis/")
df <- read.csv('MIMIC_dataset_v2.csv', stringsAsFactors = TRUE)

df[c('ethnicity')] = apply(df[c('ethnicity')], 1, mergeEth)
df$heparin_iv[is.na(df$heparin_iv)] <- 0
df$antihypertensive_iv_non_tight_control[is.na(df$antihypertensive_iv_non_tight_control)] <- 0
df$antihypertensive_iv_tight_control[is.na(df$antihypertensive_iv_tight_control)] <- 0
df$antiplatelets[is.na(df$antiplatelets)] <- 0
df$anticoag[is.na(df$anticoag)] <- 0
df$antihypertensive_non_iv[is.na(df$antihypertensive_non_iv)] <- 0
df$inotropes[is.na(df$inotropes)] <- 0
df['antihtx_normal'] = as.numeric(unlist(df[c('antihypertensive_iv_non_tight_control')])) + as.numeric(unlist(df['antihypertensive_non_iv']))

df$antihtx <- with(df, ifelse(as.numeric(antihypertensive_iv_tight_control)>1, 2, ifelse(as.numeric(antihtx_normal)>1, 1, 0)))

# df[c('afib', 'hyperlipidemia', 'diabetes', 'hypertension',
#      'cor_art_d', 'peri_vasc_d', 'car_art_stent','smoking',
#      'tia', 'heparin_iv', 'antiplatelets',
#      'anticoag', 'inotropes')] = apply(df[c('afib', 'hyperlipidemia', 'diabetes', 'hypertension',
#                                             'cor_art_d', 'peri_vasc_d', 'car_art_stent','smoking',
#                                             'tia', 'heparin_iv', 'antiplatelets',
#                                             'anticoag', 'inotropes')], c(1,2), cap)

categoricals <- c('ethnicity', 'gender', 'hospital_expire_flag',
                  'afib', 'hyperlipidemia', 'diabetes', 'hypertension',
                  'cor_art_d', 'peri_vasc_d', 'car_art_stent','smoking',
                  'tia', 'heparin_iv', 'antiplatelets',
                  'anticoag', 'antihtx', 'inpatient_stroke', 'inotropes')
continuous <- c('age','avg_mbp_ni', 'min_mbp_ni', 'max_mbp_ni', 'first_gcs',
                'avg_mbp', 'min_mbp', 'max_mbp', 'avg_sbp', 'min_sbp', 'max_sbp',
                'avg_sbp_ni', 'min_sbp_ni', 'max_sbp_ni',
                'first_glu', 'first_cre')
df[categoricals] = lapply(df[categoricals], factor)
df <- df[c(categoricals, continuous)]

tab1 = CreateTableOne(data=df, strata = 'hospital_expire_flag')
tab1Mat <- print(tab1, nonnormal = continuous, exact = "stage", quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
write.csv(tab1Mat, file = "TableOne.csv")


