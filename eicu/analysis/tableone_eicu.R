library(tableone)
library(dplyr)

mergeEth <- function(x) if (x == 'Caucasian') {
  0
} else if (x == 'Native American') {
  0
} else if (x == 'Asian') {
  1
} else if (x == 'African American') {
  2
} else {
  3
}
set.seed(123)
setwd("~/Desktop/PhD study/StrokeBP/datathon/eicu/analysis")
df <- read.csv('eicu_clean_v3.csv', stringsAsFactors = TRUE)

# merge ibp_systolic and nibp_systolic
df$min_mbp <- with(df, coalesce(min_nibp,min_ibp))
df$avg_mbp <- with(df, coalesce(avg_nibp,avg_ibp))
df$max_mbp <- with(df, coalesce(max_nibp,max_ibp))
df$min_sbp <- with(df, coalesce(min_nibp_systolic,min_ibp_systolic))
df$avg_sbp <- with(df, coalesce(avg_nibp_systolic,avg_ibp_systolic))
df$max_sbp <- with(df, coalesce(max_nibp_systolic,max_ibp_systolic))

df[c('ethnicity')] = apply(df[c('ethnicity')], 1, mergeEth)
df$heparin_iv[is.na(df$heparin_iv)] <- 0
df$antihypertensive_iv_non_tight_control[is.na(df$antihypertensive_iv_non_tight_control)] <- 0
df$antihypertensive_iv_tight_control[is.na(df$antihypertensive_iv_tight_control)] <- 0
df$antiplatelets[is.na(df$antiplatelets)] <- 0
df$anticoag[is.na(df$anticoag)] <- 0
df$antihypertensive_non_iv[is.na(df$antihypertensive_non_iv)] <- 0
df$inotropes[is.na(df$inotropes)] <- 0
df$diabetes[is.na(df$diabetes)] <- 0
df$hypertension[is.na(df$hypertension)] <- 0
df$ischemic_heart_disease[is.na(df$ischemic_heart_disease)] <- 0
df$transient_ischemic_attack[is.na(df$transient_ischemic_attack)] <- 0
df$peripheral_vascular_disease[is.na(df$peripheral_vascular_disease)] <- 0
df$previous_stroke[is.na(df$previous_stroke)] <- 0
df$hyperlipidemia[is.na(df$hyperlipidemia)] <- 0
df$atrial_fibrillation[is.na(df$atrial_fibrillation)] <- 0

df$hosp_mortality <- with(df, ifelse(is.na(df$hosp_mortality), 0, df$hosp_mortality))

df['antihtx_normal'] = as.numeric(unlist(df[c('antihypertensive_iv_non_tight_control')])) + as.numeric(unlist(df['antihypertensive_non_iv']))

df$antihtx <- with(df, ifelse(as.numeric(antihypertensive_iv_tight_control)>0, 2, ifelse(as.numeric(antihtx_normal)>0, 1, 0)))

categoricals <- c('ethnicity', 'gender', 'hosp_mortality',
                  'atrial_fibrillation', 'diabetes', 'hypertension',
                  'ischemic_heart_disease','transient_ischemic_attack',
                  'peripheral_vascular_disease', 'previous_stroke',
                  'heparin_iv', 'antiplatelets',
                  'anticoag', 'antihtx', 'inotropes', 'hyperlipidemia')
continuous <- c('correct_age',
                'avg_mbp', 'min_mbp', 'max_mbp',
                'avg_sbp', 'min_sbp', 'max_sbp',
                'glucose', 'creatinine', 'first_gcs')

df[categoricals] = lapply(df[categoricals], factor)
df <- df[c(categoricals, continuous)]

tab1 = CreateTableOne(data=df, strata = 'hosp_mortality')
tab1Mat <- print(tab1, nonnormal = continuous, exact = "stage", quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
write.csv(tab1Mat, file = "TableOne_eicu.csv")