library(mgcv)
library(oddsratio)
library(ggplot2)
library(ROCR)
library(dplyr)
library(mice)
library(caret)

logistic <- function(x) 1/(1+exp(-x))
cap <- function(x) if (x == 0) {
  0
} else {
  1
}
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

tempData <- mice(df,m=10,maxit=50,meth='pmm',seed=500)
df <- complete(tempData,1)
write.csv(df, 'eicu_imputed.csv', row.names=FALSE)

# df <- read.csv('eicu_imputed.csv', stringsAsFactors = TRUE)

train_index <- sample(1:nrow(df), 0.8 * nrow(df))
test_index <- setdiff(1:nrow(df), train_index)
train <- df[train_index,]
test <- df[test_index,]

model <- gam(hosp_mortality ~ 
               correct_age+gender+glucose+creatinine+first_gcs+hypertension+hyperlipidemia+
               atrial_fibrillation+hypertension+diabetes+inotropes+ischemic_heart_disease+ethnicity+
               peripheral_vascular_disease+transient_ischemic_attack+
               heparin_iv+antiplatelets+anticoag+antihtx+s(min_sbp), data=train,family = binomial(link='logit'))
summary <- summary(model)
summary

model <- gam(hosp_mortality ~ 
               correct_age+glucose+first_gcs+hyperlipidemia+
               atrial_fibrillation+s(min_sbp), data=train,family = binomial(link='logit'))
summary <- summary(model)
summary

train_predictions = logistic(predict.gam(model, train))
train_label = train$hosp_mortality
train_pred <- prediction(as.numeric(train_predictions), as.numeric(train_label))
train_perf <- performance(train_pred, measure = "tpr", x.measure = "fpr")
plot(train_perf@x.values[[1]], train_perf@y.values[[1]], col="orange", mgp=c(1.5,0,0),
     xlab = "False Positive Rate",
     ylab = "True Positive Rate",
     cex.lab=0.8, xaxt="n",yaxt="n",type="l")
axis(1, at = seq(0, 1, by = 0.1), las=0, cex.axis=0.5, mgp=c(0,0.2,0))
axis(2, at = seq(0, 1, by = 0.1), las=1, cex.axis=0.5, mgp=c(0,0.8,0))
train_auc_ROCR <- performance(train_pred, measure = "auc")@y.values[[1]]

test_predictions = logistic(predict.gam(model, test))
test_label = test$hosp_mortality
test_pred <- prediction(as.numeric(test_predictions), as.numeric(test_label))
test_perf <- performance(test_pred, measure = "tpr", x.measure = "fpr")
plot(test_perf, add=TRUE, col='red')
abline(a = 0, b = 1, col = 'blue', lty=2)
test_auc_ROCR <- performance(test_pred, measure = "auc")@y.values[[1]]

legend("bottomright",
       c(paste("Train ", round(as.numeric(train_auc_ROCR), digits = 2)),
         paste("Test  ", round(as.numeric(test_auc_ROCR), digits = 2))),
       col = c("orange", 'red'),
       lty = c(1,1), cex=1)

plot_object1 <- plot_gam(model, pred='min_sbp',
                         xlab = 'Min SBP',
                         ylab = 'Partial effect')

plot_object1 + xlim(60,180) + ylim(-1.5,1.5) + geom_hline(yintercept=0, linetype="dashed", color = "red") 
  # geom_vline(xintercept=115, linetype="dashed", color = "purple") + geom_vline(xintercept=130, linetype="dashed", color = "purple")
