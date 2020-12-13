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
mergeEth <- function(x) if (x == 'WHITE') {
    0
  } else if (x == 'ASIAN') {
    1
  } else if (x == 'BLACK/AFRICAN AMERICAN') {
    2
  } else {
    3
  }
set.seed(123)
setwd("~/Desktop/PhD study/StrokeBP/datathon/MIMIC/analysis")
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

df$antihtx <- with(df, ifelse(as.numeric(antihypertensive_iv_tight_control)>0, 2, ifelse(as.numeric(antihtx_normal)>0, 1, 0)))

# df[c('afib', 'hyperlipidemia', 'diabetes', 'hypertension',
#      'cor_art_d', 'peri_vasc_d', 'car_art_stent','smoking',
#      'tia', 'heparin_iv', 'antiplatelets',
#      'anticoag', 'inotropes')] = apply(df[c('afib', 'hyperlipidemia', 'diabetes', 'hypertension',
#                    'cor_art_d', 'peri_vasc_d', 'car_art_stent','smoking',
#                    'tia', 'heparin_iv', 'antiplatelets',
#                    'anticoag', 'inotropes')], c(1,2), cap)

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

tempData <- mice(df,m=10,maxit=50,meth='pmm',seed=500)
df <- complete(tempData,1)

train_index <- sample(1:nrow(df), 0.8 * nrow(df))
test_index <- setdiff(1:nrow(df), train_index)
train <- df[train_index,]
test <- df[test_index,]

# afib+hyperlipidemia+diabetes+hypertension+cor_art_d+peri_vasc_d+
# car_art_stent+smoking+tia+heparin_iv+antihypertensive+antiplatelets+anticoag
model <- gam(hospital_expire_flag ~ 
               s(age)+gender+first_glu+first_cre+first_gcs+hypertension+inpatient_stroke+
               afib+hyperlipidemia+diabetes+inotropes+ethnicity+
               cor_art_d+peri_vasc_d+car_art_stent+smoking+tia+heparin_iv+antiplatelets+anticoag+
               s(min_sbp)
             , data=train,family = binomial(link='logit'))
summary <- summary(model)
summary

model <- gam(hospital_expire_flag ~ 
               age+first_glu+first_cre+first_gcs+ethnicity+hyperlipidemia+s(min_sbp)
             , data=train,family = binomial(link='logit'))
summary <- summary(model)
summary

train_predictions = logistic(predict.gam(model, train))
train_label = train$hospital_expire_flag
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
test_label = test$hospital_expire_flag
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

# ------------------
# 
# train_scores <- list()
# train_props <- list()
# train_length <- list()
# test_scores <- list()
# test_props <- list()
# test_length <- list()
# i <- 1
# train_deciles <- ntile(train_predictions, 10)
# for (val in seq(1,10,1)) {
#   qt = which(train_deciles == val)
#   prop = sum(as.numeric(train_label[qt])) / length(train_label[qt]) - 1
#   score = mean(train_predictions[train_deciles == val])
#   train_scores[[i]] <- score
#   train_props[[i]] <- prop
#   train_length[[i]] <- length(train_label[qt])
#   i <- i + 1
# }
# 
# i <- 1
# test_deciles <- ntile(test_predictions, 10)
# for (val in seq(1,10,1)) {
#   qt = which(test_deciles == val)
#   prop = sum(as.numeric(test_label[qt])) / length(test_label[qt]) - 1
#   score = mean(test_predictions[test_deciles == val])
#   test_scores[[i]] <- score
#   test_props[[i]] <- prop
#   test_length[[i]] <- length(test_label[qt])
#   i <- i + 1
# }
# 
# plot(train_scores, train_props, xlim = c(0,1), ylim = c(0,1)
#      , xaxt="n", yaxt="n"
#      , xlab="Mean Predicted Risk Score"
#      , ylab="Fraction of Positives", type='o',col='orange'
#      , cex = 1, cex.lab=0.8, mgp=c(1.5,0,0))
# lines(test_scores, test_props, cex = 1,col='red')
# points(test_scores, test_props, cex = 1, pch=2,col='red')
# axis(1, at = seq(0, 1, by = 0.1), las=0, cex.axis=0.5, mgp=c(0,0.2,0))
# axis(2, at = seq(0, 1, by = 0.1), las=1, cex.axis=0.5, mgp=c(0,0.8,0))
# abline(a = 0, b = 1, col = 'blue', lty=2)
# legend("bottomright",
#        c(paste("Train", round(mean((as.numeric(train_predictions) - as.numeric(train_label))^2), digits=2)),
#          paste("Test ", round(mean((as.numeric(test_predictions) - as.numeric(test_label))^2), digits=2))),
#        col = c('orange', 'red'),
#        pch = c(1,2), cex=0.3)

### GAM plots
# dev.off()

plot_object1 <- plot_gam(model, pred='min_sbp',
                         xlab = 'Min SBP',
                         ylab = 'Partial effect')
# or_object1 <- or_gam(
#   data = train, model = model,
#   pred = "avg_mbp_ni", values = c(80,90)
# )

# plot1 <- insert_or(plot_object1, or_object1,
#                    or_yloc = 3,
#                    arrow_length = 0.02,
#                    arrow_col = "red",
#                    arrow_yloc = 1)
plot_object1 + xlim(60,180) + ylim(-1.5,1.5) + geom_hline(yintercept=0, linetype="dashed", color = "red") + 
  geom_vline(xintercept=115, linetype="dashed", color = "purple") + geom_vline(xintercept=130, linetype="dashed", color = "purple")

