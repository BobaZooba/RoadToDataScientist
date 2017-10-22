library(dplyr)

data_train_source <- read.csv2(file = "data/source/Credit_OTP.csv",
                                  stringsAsFactors = FALSE, 
                                  na.strings = c("", "Пропуск"), 
                                  encoding = "windows-1251")
data_test_source <- read.csv2(file = "data/source/Credit_OTP_new.csv", 
                                 stringsAsFactors = FALSE, 
                                 na.strings = c("", "Пропуск"), 
                                 encoding = "windows-1251")

# готовим датасеты
data_train <- data_train_source
data_test <- data_test_source

# готовим датасеты
# преобразуем все переменные типа character, а так же все индикаторные переменные в номинальные
names_to_factor <- c(
  names(Filter(is.character, data_train)),
  names(data_train)[grep(pattern = ".*_FL$", names(data_train))],
  "GENDER"
)
data_train[, names_to_factor] <- lapply(data_train[, names_to_factor], as.factor)
data_test[, names_to_factor] <- lapply(data_test[, names_to_factor], as.factor)

# FAMILY_INCOME преобразуем в порядковую
data_train$FAMILY_INCOME <- factor(
  data_train$FAMILY_INCOME,
  levels = c(
    "до 5000 руб.",
    "от 5000 до 10000 руб.",
    "от 10000 до 20000 руб.",
    "от 20000 до 50000 руб.",
    "свыше 50000 руб."
  ),
  ordered = TRUE
)
data_test$FAMILY_INCOME <- factor(
  data_test$FAMILY_INCOME,
  levels = c(
    "до 5000 руб.",
    "от 5000 до 10000 руб.",
    "от 10000 до 20000 руб.",
    "от 20000 до 50000 руб.",
    "свыше 50000 руб."
  ),
  ordered = TRUE
)

# укрупним EDUCATION
levels(data_train$EDUCATION) <- c(levels(data_train$EDUCATION), "Высшее или несколько высших")
levels(data_test$EDUCATION) <- c(levels(data_test$EDUCATION), "Высшее или несколько высших")
data_train[data_train$EDUCATION %in% c("Высшее", 
                                       "Высшее или несколько высших", 
                                       "Два и более высших образования", 
                                       "Ученая степень"),]$EDUCATION <- "Высшее или несколько высших"
data_test[data_test$EDUCATION %in% c("Высшее", 
                                       "Высшее или несколько высших", 
                                       "Два и более высших образования", 
                                       "Ученая степень"),]$EDUCATION <- "Высшее или несколько высших"
data_train$EDUCATION <- factor(
  data_train$EDUCATION,
  levels = c(
    "Неполное среднее",
    "Среднее",
    "Среднее специальное",
    "Неоконченное высшее",
    "Высшее или несколько высших"
  ),
  ordered = TRUE
)
data_test$EDUCATION <- factor(
  data_test$EDUCATION,
  levels = c(
    "Неполное среднее",
    "Среднее",
    "Среднее специальное",
    "Неоконченное высшее",
    "Высшее или несколько высших"
  ),
  ordered = TRUE
)

# Укрупним GEN_INDUSTRY
names <- c('Маркетинг','Подбор персонала', 'Логистика', 'Управляющая компания', 'Недвижимость',
           'Туризм', 'Страхование', 'СМИ/Реклама/PR-агенства', 'Юридические услуги/нотариальные услуги',
           'Химия/Парфюмерия/Фармацевтика', 'Информационные технологии', 'Салоны красоты и здоровья', 'Информационные услуги',
           'ЧОП/Детективная д-ть',
           'Развлечения/Искусство',
           'Энергетика',
           'Банк/Финансы',
           'Сборочные производства',
           'Нефтегазовая промышленность')

levels(data_train$GEN_INDUSTRY) <- c(levels(data_train$GEN_INDUSTRY), "Другое")
levels(data_test$GEN_INDUSTRY) <- c(levels(data_test$GEN_INDUSTRY), "Другое")
data_train[data_train$GEN_INDUSTRY %in% names,]$GEN_INDUSTRY <- "Другое"
data_test[data_test$GEN_INDUSTRY %in% names,]$GEN_INDUSTRY <- "Другое"

# удалим переменную DL_DOCUMENT_FL, т.к. у нее всего одно значение 0
data_train$DL_DOCUMENT_FL <- NULL
data_test$DL_DOCUMENT_FL <- NULL

# для GEN_INDUSTRY", "GEN_TITLE", "ORG_TP_STATE", "ORG_TP_FCAPITAL", "JOB_DIR", 
# "TP_PROVINCE", "REGION_NM" - просто создадим новую категорию - "Нет данных"
# TODO - добавить переменную индикатор - о том что был пропуск
names_tmp <- c("GEN_INDUSTRY", "GEN_TITLE", "ORG_TP_STATE", "ORG_TP_FCAPITAL", "JOB_DIR", "TP_PROVINCE", "REGION_NM")
for (idx in 1:length(names_tmp)) {
  levels(data_train[, names_tmp[idx]]) <- c(levels(data_train[, names_tmp[idx]]), "Нет данных")
  levels(data_test[, names_tmp[idx]]) <- c(levels(data_train[, names_tmp[idx]]), "Нет данных")
  data_train[is.na(data_train[, names_tmp[idx]]), names_tmp[idx]] <- "Нет данных" 
  data_test[is.na(data_test[, names_tmp[idx]]), names_tmp[idx]] <- "Нет данных" 
}
rm(names_tmp)

# судя по всему NA в WORK_TIME - у пенсионеров, так что можем вместо NA подставить 0 или -1
# индикаторную переменную можно не создавать, -1 хорошо такие наблюдения отделяет
if (nrow(data_train[is.na(data_train$WORK_TIME),]) > 0) data_train[is.na(data_train$WORK_TIME),]$WORK_TIME <- -1
if (nrow(data_test[is.na(data_test$WORK_TIME),]) > 0) data_test[is.na(data_test$WORK_TIME),]$WORK_TIME <- -1

# заменим пропуски в PREVIOUS_CARD_NUM_UTILIZED, в описании полей сказано -
# если пусто - 0
# TODO - добавить признак индикатор
if (nrow(data_train[is.na(data_train$PREVIOUS_CARD_NUM_UTILIZED),]) > 0) data_train[is.na(data_train$PREVIOUS_CARD_NUM_UTILIZED),]$PREVIOUS_CARD_NUM_UTILIZED <- 0
if (nrow(data_test[is.na(data_test$PREVIOUS_CARD_NUM_UTILIZED),]) > 0) data_test[is.na(data_test$PREVIOUS_CARD_NUM_UTILIZED),]$PREVIOUS_CARD_NUM_UTILIZED <- 0


# REG_ADDRESS_PROVINCE приводим levels в соответствие
levels(data_train$REG_ADDRESS_PROVINCE) <- c(levels(data_train$REG_ADDRESS_PROVINCE), "Другое")
levels(data_test$REG_ADDRESS_PROVINCE) <- c(levels(data_test$REG_ADDRESS_PROVINCE), "Другое")

names <- c("Эвенкийский АО", "Усть-Ордынский Бурятский АО")
data_train[data_train$REG_ADDRESS_PROVINCE %in% names,]$REG_ADDRESS_PROVINCE <- "Другое"
data_train$REG_ADDRESS_PROVINCE <- factor(data_train$REG_ADDRESS_PROVINCE)

data_test[!(data_test$REG_ADDRESS_PROVINCE %in% levels(data_train$REG_ADDRESS_PROVINCE)),]$REG_ADDRESS_PROVINCE <- "Другое"
data_test$REG_ADDRESS_PROVINCE <- factor(data_test$REG_ADDRESS_PROVINCE)


# FACT_ADDRESS_PROVINCE приводим levels в соответствие
levels(data_train$FACT_ADDRESS_PROVINCE) <- c(levels(data_train$FACT_ADDRESS_PROVINCE), "Другое")
levels(data_test$FACT_ADDRESS_PROVINCE) <- c(levels(data_test$REG_ADDRESS_PROVINCE), "Другое")

names <- c("Эвенкийский АО", "Усть-Ордынский Бурятский АО")
data_train[data_train$FACT_ADDRESS_PROVINCE %in% names,]$FACT_ADDRESS_PROVINCE <- "Другое"
data_train$FACT_ADDRESS_PROVINCE <- factor(data_train$FACT_ADDRESS_PROVINCE)

data_test[!(data_test$FACT_ADDRESS_PROVINCE %in% levels(data_train$FACT_ADDRESS_PROVINCE)),]$FACT_ADDRESS_PROVINCE <- "Другое"
data_test$FACT_ADDRESS_PROVINCE <- factor(data_test$FACT_ADDRESS_PROVINCE)

# POSTAL_ADDRESS_PROVINCE приводим levels в соответствие
levels(data_train$POSTAL_ADDRESS_PROVINCE) <- c(levels(data_train$POSTAL_ADDRESS_PROVINCE), "Другое")
levels(data_test$POSTAL_ADDRESS_PROVINCE) <- c(levels(data_test$POSTAL_ADDRESS_PROVINCE), "Другое")

names <- c("Эвенкийский АО", "Усть-Ордынский Бурятский АО")
data_train[data_train$POSTAL_ADDRESS_PROVINCE %in% names,]$POSTAL_ADDRESS_PROVINCE <- "Другое"
data_train$POSTAL_ADDRESS_PROVINCE <- factor(data_train$POSTAL_ADDRESS_PROVINCE)

data_test[!(data_test$POSTAL_ADDRESS_PROVINCE %in% levels(data_train$POSTAL_ADDRESS_PROVINCE)),]$POSTAL_ADDRESS_PROVINCE <- "Другое"
data_test$POSTAL_ADDRESS_PROVINCE <- factor(data_test$POSTAL_ADDRESS_PROVINCE)


# TARGET в номинальную, с переименованием меток (для caret)
data_train <- data_train %>% 
  mutate(
    TARGET = ifelse(TARGET == 1, "yes", "no")
  )
data_train$TARGET <- factor(data_train$TARGET)

data_test <- data_test %>% 
  mutate(
    TARGET = ifelse(TARGET == 1, "yes", "no")
  )
data_test$TARGET <- factor(data_test$TARGET)

#удаляем поле AGREEMENT_RK
data_train$AGREEMENT_RK <- NULL
data_test$AGREEMENT_RK <- NULL

# добавим новый признак - когда первый платеж больше чем сумма посл. кредита
data_train <- data_train %>%
  mutate(
    FST_PAYMENT_more_than_credit = ifelse(CREDIT < FST_PAYMENT,1,0)
  )
data_train$FST_PAYMENT_more_than_credit <- as.factor(data_train$FST_PAYMENT_more_than_credit)

data_test <- data_test %>%
  mutate(
    FST_PAYMENT_more_than_credit = ifelse(CREDIT < FST_PAYMENT,1,0)
  )
data_test$FST_PAYMENT_more_than_credit <- as.factor(data_test$FST_PAYMENT_more_than_credit)

# добавим новый признак - процент размера платежа от размера кредита кредита
data_train <- data_train %>%
  mutate(
    FST_PAYMENT_percent = round((FST_PAYMENT / CREDIT)*100)
  )
data_test <- data_test %>%
  mutate(
    FST_PAYMENT_percent = round((FST_PAYMENT / CREDIT)*100)
  )

# добавим новый признак - процент размера платежа в месяц, от личного дохода
data_train <- data_train %>%
  mutate(
    PAYMENT_INCOME_percent = round(((CREDIT/TERM)/PERSONAL_INCOME)*100)
  )
data_test <- data_test %>%
  mutate(
    PAYMENT_INCOME_percent = round(((CREDIT/TERM)/PERSONAL_INCOME)*100)
  )

# соотношение времени проживания в месте пребывания по отношению к длит. работы
data_train <- data_train %>%
  mutate(
    LIVING_WORK_TIME_percent = ifelse(WORK_TIME > 0, round((FACT_LIVING_TERM/WORK_TIME)*100), 0)
  )
data_test <- data_test %>%
  mutate(
    LIVING_WORK_TIME_percent = ifelse(WORK_TIME > 0, round((FACT_LIVING_TERM/WORK_TIME)*100), 0)
  )

# соотношение срока кредита к времени работы
data_train <- data_train %>%
  mutate(
    TERM_WORK_TIME = ifelse(WORK_TIME > 0, TERM/WORK_TIME, -1)
  )
data_test <- data_test %>%
  mutate(
    TERM_WORK_TIME = ifelse(WORK_TIME > 0, TERM/WORK_TIME, -1)
  )

# перекодируем REG_ADDRESS_PROVINCE кол-вом наблюдений c TARGET == yes
tmp_dict <- data_train %>% 
  mutate(
    TARGET = ifelse(TARGET == "yes", 1, 0)
  ) %>%
  group_by(REG_ADDRESS_PROVINCE) %>% 
  summarise(count = sum(TARGET))

#data_train$REG_ADDRESS_PROVINCE <- sapply(X = data_train$REG_ADDRESS_PROVINCE, FUN = function(x) { tmp_dict[tmp_dict$REG_ADDRESS_PROVINCE == x,]$count } )
#data_test$REG_ADDRESS_PROVINCE <- sapply(X = data_test$REG_ADDRESS_PROVINCE, FUN = function(x) { tmp_dict[tmp_dict$REG_ADDRESS_PROVINCE == x,]$count } )
rm(tmp_dict)

# перекодируем FACT_ADDRESS_PROVINCE кол-вом наблюдений c TARGET == yes
tmp_dict <- data_train %>% 
  mutate(
    TARGET = ifelse(TARGET == "yes", 1, 0)
  ) %>%
  group_by(FACT_ADDRESS_PROVINCE) %>% 
  summarise(count = sum(TARGET))

#data_train$FACT_ADDRESS_PROVINCE <- sapply(X = data_train$FACT_ADDRESS_PROVINCE, FUN = function(x) { tmp_dict[tmp_dict$FACT_ADDRESS_PROVINCE == x,]$count } )
#data_test$FACT_ADDRESS_PROVINCE <- sapply(X = data_test$FACT_ADDRESS_PROVINCE, FUN = function(x) { tmp_dict[tmp_dict$FACT_ADDRESS_PROVINCE == x,]$count } )
rm(tmp_dict)


# ranger
require(caret)

crt.control <- trainControl(
  method = "none",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  verboseIter = TRUE,
  savePredictions = TRUE
)

# ловим выбросы для WORK_TIME
work_time_quantiles <- quantile(data_train[data_train$WORK_TIME > 0,]$WORK_TIME,  probs = c(1, 99)/100, names = FALSE)
data_train <- data_train[(data_train$WORK_TIME <= work_time_quantiles[2]),]

fact_living_term_quantiles <- quantile(data_train[data_train$FACT_LIVING_TERM > 0,]$FACT_LIVING_TERM,  probs = c(1, 99)/100, names = FALSE)
#data_train <- data_train[(data_train$FACT_LIVING_TERM <= fact_living_term_quantiles[2]),]

model_weights <- ifelse(data_train$TARGET == "yes",
                        (1/table(data_train$TARGET)[2]) * 0.5,
                        (1/table(data_train$TARGET)[1]) * 0.5)

set.seed(1234)
ranger_model <- train(TARGET ~ ., 
      data = data_train,
      method = "ranger",
      tuneGrid = expand.grid(mtry = 8, splitrule = "gini"),
      #tuneLength = 5,
      metric = "ROC",
      trControl = crt.control,
      weights = model_weights,
      importance = "impurity",
      num.trees = 1000
      , min.node.size = 120
      )

ranger_model

set.seed(1234)
ranger_model_pred_probs <- as.data.frame(predict(ranger_model, data_test, type = "prob"))

require(pROC)
ranger_model_ROC <- roc(predictor = ranger_model_pred_probs$yes,
                      response = data_test$TARGET,
                      levels = rev(levels(data_test$TARGET)))

ranger_model_ROC$auc

plot(ranger_model_ROC,main = "caret ranger ROC", col = 6)

set.seed(1234)
ranger_model_preds <- predict(ranger_model, data_test, type = "raw")
ranger_model_cm <- confusionMatrix(ranger_model_preds, data_test$TARGET, positive = "yes")   
ranger_model_cm

