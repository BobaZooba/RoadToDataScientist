install.packages('dplyr')

library(dplyr)
require(pROC)

set.seed(42)

data <- read.csv2(file = "/Users/boriszubarev/Desktop/RoadToDataScientist/contests/OTP_bank/data/data_for_h2o_gbm.csv",
                  stringsAsFactors = FALSE,
                  na.strings = c("", "Пропуск"),
                  encoding = "windows-1251", sep=',')

summary(data)

data$X <- NULL

cats <- c('TARGET',
          'SOCSTATUS_WORK_FL',
          'SOCSTATUS_PENS_FL',
          'GENDER',
          'CHILD_TOTAL',
          'DEPENDANTS',
          'EDUCATION',
          'MARITAL_STATUS',
          'GEN_INDUSTRY',
          'GEN_TITLE',
          'ORG_TP_STATE',
          'ORG_TP_FCAPITAL',
          'JOB_DIR',
          'FAMILY_INCOME',
          'REGION_NM',
          'REG_FACT_FL',
          'FACT_POST_FL',
          'REG_POST_FL',
          'REG_FACT_POST_FL',
          'REG_FACT_POST_TP_FL',
          'FL_PRESENCE_FL',
          'OWN_AUTO',
          'AUTO_RUS_FL',
          'HS_PRESENCE_FL',
          'COT_PRESENCE_FL',
          'GAR_PRESENCE_FL',
          'LAND_PRESENCE_FL',
          'GPF_DOCUMENT_FL',
          'FACT_PHONE_FL',
          'REG_PHONE_FL',
          'GEN_PHONE_FL',
          'LOAN_NUM_TOTAL',
          'LOAN_NUM_CLOSED',
          'LOAN_DLQ_NUM',
          'PREVIOUS_CARD_NUM_UTILIZED',
          'DELAY')

nums <- c('AGE',
          'PERSONAL_INCOME',
          'REG_ADDRESS_PROVINCE',
          'FACT_ADDRESS_PROVINCE',
          'POSTAL_ADDRESS_PROVINCE',
          'TP_PROVINCE',
          'CREDIT',
          'TERM',
          'FST_PAYMENT',
          'FACT_LIVING_TERM',
          'WORK_TIME',
          'LOAN_NUM_PAYM',
          'LOAN_AVG_DLQ_AMT',
          'LOAN_MAX_DLQ_AMT',
          'SOLVENCY')

data[, cats] <- lapply(data[, cats], as.factor)
data[, nums] <- lapply(data[, nums], as.numeric)

summary(data)

data$EDUCATION <- ordered(data$EDUCATION, c('Среднее', 'Неполное среднее', 'Среднее специальное', 
                                            'Неоконченное высшее', 'Высшее'))

data$FAMILY_INCOME <- ordered(data$FAMILY_INCOME, c('до 5000 руб.', 'от 5000 до 10000 руб.',
                                                    'от 10000 до 20000 руб.', 'от 20000 до 50000 руб.',
                                                    'свыше 50000 руб.'))

data$CHILD_TOTAL <- ordered(data$CHILD_TOTAL, c('0', '1', '2', '3', '4'))
data$DEPENDANTS <- ordered(data$DEPENDANTS, c('0', '1', '2', '3', '4'))


data <- data %>% mutate(
    TARGET = ifelse(TARGET == 1, "yes", "no")
  )
data$TARGET <- factor(data$TARGET)


smp_size <- floor(0.7 * nrow(data))

train_ind <- sample(seq_len(nrow(data)), size = smp_size)

train <- data[train_ind, ]
test <- data[-train_ind, ]

library(CHAID)
model.chaid  <- chaid(TARGET ~ ., 
                      control = chaid_control
                      (minprob = 0.005,
                        minsplit = 500, minbucket = 250),
                      train[, cats])

# plot(model.chaid)
# print(model.chaid)

chaid_preds <- as.data.frame(predict(model.chaid, test, type = "prob"))
chaid_ROC <- roc(predictor = chaid_preds$yes,
                 response = test$TARGET,
                 levels = rev(levels(test$TARGET)), ci=T)

chaid_ROC$auc

plot(chaid_ROC, main = "CHAID ROC", col = 6)



require(caret)

crt.control <- trainControl(
  method = "none",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  verboseIter = TRUE,
  savePredictions = TRUE
)

model_weights <- ifelse(train$TARGET == "yes",
                        (1/table(train$TARGET)[2]) * 0.5,
                        (1/table(train$TARGET)[1]) * 0.5)

ranger_model <- train(TARGET ~ ., 
                      data = train,
                      method = "ranger",
                      tuneGrid = expand.grid(mtry = 8, splitrule = "gini"),
                      #tuneLength = 5,
                      metric = "ROC",
                      trControl = crt.control,
                      weights = model_weights,
                      importance = "impurity",
                      num.trees = 500
                      , min.node.size = 120
                      )


ranger_model

ranger_model_pred_probs <- as.data.frame(predict(ranger_model, test, type = "prob"))


install.packages("pROC")
ranger_model_ROC <- roc(predictor = ranger_model_pred_probs$yes,
                        response = test$TARGET,
                        levels = rev(levels(test$TARGET)), ci=T)

ranger_model_ROC$auc

plot(ranger_model_ROC,main = "caret ranger ROC", col = 6)

roc2 <- plot.roc(test$TARGET, test$TARGET,
                 main="ROC-кривая для модели дерева Ranger",  
                 percent=TRUE, ci=TRUE, # вычислить AUC
                 print.auc=TRUE) # напечатать значение AUC (вместе с довер. интервалом)

plt.roc

ranger_model_preds <- predict(ranger_model, test, type = "raw")
ranger_model_cm <- confusionMatrix(ranger_model_preds, test$TARGET, positive = "yes")   
ranger_model_cm




install.packages("drat", repos="https://cran.rstudio.com")
drat:::addRepo("dmlc")
install.packages("xgboost")

require(xgboost)

data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
train <- agaricus.train
test <- agaricus.test

bstSparse <- xgboost(data = train, label = train$TARGET, max.depth = 2, eta = 1,
                     nthread = -1, nround = 100, objective = "binary:logistic")


bstDense <- xgboost(data = as.matrix(train_xgb$data), label = train_xgb$label, max.depth = 2, eta = 1,
                    nthread = -1, nround = 2, objective = "binary:logistic")

dtrain <- xgb.DMatrix(data = train, label = 'TARGET')
bstDMatrix <- xgboost(data = dtrain, max.depth = 2, eta = 1, nthread = -4, nround = 2,
                      objective = "binary:logistic")

xgboost_pred_prob <- predict(bstSparse, test_xgb$data)

xgboost_pred <- ifelse(as.numeric(xgboost_pred_prob > 0.5), 1, 0)

xgboost_ROC <- roc(predictor = xgboost_pred,
                   response = test_xgb$label,
                   levels = rev(levels(test_xgb$label)), ci=T)

xgboost_ROC <- roc(predictor = xgboost_pred,
                   response = test_xgb$label, ci=T)

xgboost_ROC$auc

plot(xgboost_ROC, main = "CHAID ROC", col = 6)


xgboost_pred
test_xgb$label


chaid_ROC$auc

plot(chaid_ROC, main = "CHAID ROC", col = 6)





require(smbinning)
str(train)

nums

result=smbinning (df=train, y="TARGET", x="SOLVENCY")

result
smbinning.sql(result)
smbinning.plot(ivout=result, option="WoE", 
               sub="Переменная age")
result2=smbinning.sumiv(df=train, y="TARGET")
result2
smbinning.sumiv.plot(sumivt=result2, cex=0.9)



data=smbinning.gen(df=train,ivout=result,
                   chrname="agebin")
