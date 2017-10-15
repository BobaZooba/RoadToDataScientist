def process_data(data):

    # указано в условии
    data['PREVIOUS_CARD_NUM_UTILIZED'].fillna(0, inplace=True)

    # удаляем id
    data.drop('AGREEMENT_RK', axis=1, inplace=True)

    # одно уникальное значение
    data.drop('DL_DOCUMENT_FL', axis=1, inplace=True)

    categorical_columns = ['TARGET', 'SOCSTATUS_WORK_FL', 'SOCSTATUS_PENS_FL', 'GENDER', 'EDUCATION', 'MARITAL_STATUS',
                           'GEN_INDUSTRY', 'GEN_TITLE', 'ORG_TP_STATE', 'ORG_TP_FCAPITAL', 'JOB_DIR',
                           'REG_ADDRESS_PROVINCE', 'FACT_ADDRESS_PROVINCE', 'POSTAL_ADDRESS_PROVINCE', 'TP_PROVINCE',
                           'REGION_NM', 'REG_FACT_FL', 'FACT_POST_FL', 'REG_POST_FL', 'REG_FACT_POST_FL',
                           'REG_FACT_POST_TP_FL', 'FL_PRESENCE_FL', 'AUTO_RUS_FL', 'HS_PRESENCE_FL',
                           'COT_PRESENCE_FL', 'GAR_PRESENCE_FL', 'LAND_PRESENCE_FL', 'DL_DOCUMENT_FL',
                           'GPF_DOCUMENT_FL', 'FACT_PHONE_FL', 'REG_PHONE_FL', 'GEN_PHONE_FL']

    for i in categorical_columns:
        if i in data.columns:
            data[i] = data[i].astype('str')

    # если человек нигде не работает, то WORK_TIME = 0
    data.at[(data['GEN_INDUSTRY'] == 'nan') & (data['GEN_TITLE'] == 'nan'), 'WORK_TIME'] = 0

    # максимальное значение, после которого значения считаются "неправильными"
    maxy_work_time = max(data['WORK_TIME'].dropna().sort_values()[:heu_const_work_time])

    # считаем значения больше maxy_work_time - пропущенными
    data.at[data['WORK_TIME'] > maxy_work_time, 'WORK_TIME'] = np.NaN

    true_median = data[data['WORK_TIME'] != 0]['WORK_TIME'].dropna().sort_values()[:heu_const_work_time].median()
    data['WORK_TIME'].fillna(true_median, inplace=True)

    data.at[data['FACT_LIVING_TERM'] < 0, 'FACT_LIVING_TERM'] = 0

    maxy_live_term = max(data['FACT_LIVING_TERM'].sort_values()[:heu_const_work_time])

    # считаем значения больше maxy_work_time - пропущенными
    data.at[data['FACT_LIVING_TERM'] > maxy_live_term, 'FACT_LIVING_TERM'] = np.NaN

    true_median_live_term = data[data['FACT_LIVING_TERM'] != 0]['FACT_LIVING_TERM'].dropna().sort_values()[
                            :heu_const_work_time].median()
    data['FACT_LIVING_TERM'].fillna(true_median, inplace=True)

    for i in ['PERSONAL_INCOME', 'CREDIT', 'FST_PAYMENT', 'LOAN_AVG_DLQ_AMT', 'LOAN_MAX_DLQ_AMT']:
        if i in data.columns:
            data[i] = data[i].str.replace(',', '.').astype('float')

    cat_columns, num_columns = columns()

    data.at[data['EDUCATION'] == 'Ученая степень', 'EDUCATION'] = 'Высшее'
    data.at[data['EDUCATION'] == 'Два и более высших образования', 'EDUCATION'] = 'Высшее'

    data.at[data['GEN_INDUSTRY'] == 'Маркетинг', 'GEN_INDUSTRY'] = 'СМИ/Реклама/PR-агенства'
    small_categories_aggregation(column='GEN_INDUSTRY', n_samples=20, value='Другие сферы')

    data.at[data['ORG_TP_STATE'] == 'Частная ком. с инос. капиталом', 'ORG_TP_STATE'] = 'Частная компания'

    data.at[data['REG_ADDRESS_PROVINCE'] == 'Эвенкийский АО', 'REG_ADDRESS_PROVINCE'] = 'Красноярский край'
    data.at[data['REG_ADDRESS_PROVINCE'] == 'Агинский Бурятский АО', 'REG_ADDRESS_PROVINCE'] = 'Красноярский край'
    data.at[data['REG_ADDRESS_PROVINCE'] == 'Усть-Ордынский Бурятский АО', 'REG_ADDRESS_PROVINCE'] = 'Красноярский край'
    data.at[data['REG_ADDRESS_PROVINCE'] == 'Дагестан', 'REG_ADDRESS_PROVINCE'] = 'Северная Осетия'

    data.at[data['FACT_ADDRESS_PROVINCE'] == 'Эвенкийский АО', 'FACT_ADDRESS_PROVINCE'] = 'Красноярский край'
    data.at[data['FACT_ADDRESS_PROVINCE'] == 'Агинский Бурятский АО', 'FACT_ADDRESS_PROVINCE'] = 'Красноярский край'
    data.at[data['FACT_ADDRESS_PROVINCE'] == 'Усть-Ордынский Бурятский АО', 'FACT_ADDRESS_PROVINCE'] = 'Красноярский край'
    data.at[data['FACT_ADDRESS_PROVINCE'] == 'Дагестан', 'FACT_ADDRESS_PROVINCE'] = 'Северная Осетия'

    data.at[data['POSTAL_ADDRESS_PROVINCE'] == 'Эвенкийский АО', 'POSTAL_ADDRESS_PROVINCE'] = 'Красноярский край'
    data.at[data['POSTAL_ADDRESS_PROVINCE'] == 'Агинский Бурятский АО', 'POSTAL_ADDRESS_PROVINCE'] = 'Красноярский край'
    data.at[
        data['POSTAL_ADDRESS_PROVINCE'] == 'Усть-Ордынский Бурятский АО', 'POSTAL_ADDRESS_PROVINCE'] = 'Красноярский край'
    data.at[data['POSTAL_ADDRESS_PROVINCE'] == 'Дагестан', 'POSTAL_ADDRESS_PROVINCE'] = 'Северная Осетия'

    # потому что соседи
    data.at[data['TP_PROVINCE'] == 'Кабардино-Балкария', 'TP_PROVINCE'] = 'Ставропольский край'

    data.at[data['REGION_NM'] == 'nan', 'REGION_NM'] = 'ЮЖНЫЙ'

    # просрачивал ли клиент когда-либо оплату кредита
    data['DELAY'] = '0'
    data.at[data['LOAN_DLQ_NUM'] == 0, 'DELAY'] = '0'
    data.at[data['LOAN_DLQ_NUM'] > 0, 'DELAY'] = '1'

    cat_columns, num_columns = columns()

    data['REG_ADDRESS_PROVINCE'] = data['REG_ADDRESS_PROVINCE'].map(data['REG_ADDRESS_PROVINCE'].value_counts())
    data['FACT_ADDRESS_PROVINCE'] = data['FACT_ADDRESS_PROVINCE'].map(data['FACT_ADDRESS_PROVINCE'].value_counts())
    data['POSTAL_ADDRESS_PROVINCE'] = data['POSTAL_ADDRESS_PROVINCE'].map(data['POSTAL_ADDRESS_PROVINCE'].value_counts())
    data['TP_PROVINCE'] = data['TP_PROVINCE'].map(data['TP_PROVINCE'].value_counts())

    columns_to_category = ['CHILD_TOTAL', 'DEPENDANTS', 'OWN_AUTO', 'LOAN_NUM_TOTAL', 'LOAN_NUM_CLOSED', 'LOAN_DLQ_NUM']

    data.drop('LOAN_MAX_DLQ', axis=1, inplace=True)

    # переводим в категориальные значения
    for i in columns_to_category:
        if i in data.columns:
            data[i] = data[i].astype('str')

    data.at[data['CHILD_TOTAL'] == '5', 'CHILD_TOTAL'] = '4'
    data.at[data['CHILD_TOTAL'] == '6', 'CHILD_TOTAL'] = '4'
    data.at[data['CHILD_TOTAL'] == '7', 'CHILD_TOTAL'] = '4'
    data.at[data['CHILD_TOTAL'] == '10', 'CHILD_TOTAL'] = '4'
    data.at[data['CHILD_TOTAL'] == '8', 'CHILD_TOTAL'] = '4'

    data.at[data['DEPENDANTS'] == '5', 'DEPENDANTS'] = '4'
    data.at[data['DEPENDANTS'] == '6', 'DEPENDANTS'] = '4'
    data.at[data['DEPENDANTS'] == '7', 'DEPENDANTS'] = '4'

    data.at[data['OWN_AUTO'] == '2', 'OWN_AUTO'] = '1'

    data.at[data['LOAN_NUM_TOTAL'] == '8', 'LOAN_NUM_TOTAL'] = '7'
    data.at[data['LOAN_NUM_TOTAL'] == '11', 'LOAN_NUM_TOTAL'] = '7'

    data.at[data['LOAN_NUM_CLOSED'] == '8', 'LOAN_NUM_CLOSED'] = '7'
    data.at[data['LOAN_NUM_CLOSED'] == '11', 'LOAN_NUM_CLOSED'] = '7'

    data.at[data['LOAN_NUM_CLOSED'] == '9', 'LOAN_NUM_CLOSED'] = '7'
    data.at[data['LOAN_NUM_CLOSED'] == '8', 'LOAN_NUM_CLOSED'] = '7'
    data.at[data['LOAN_NUM_CLOSED'] == '10', 'LOAN_NUM_CLOSED'] = '7'
    data.at[data['LOAN_NUM_CLOSED'] == '13', 'LOAN_NUM_CLOSED'] = '7'
    data.at[data['LOAN_NUM_CLOSED'] == '11', 'LOAN_NUM_CLOSED'] = '7'
    data.at[data['LOAN_NUM_CLOSED'] == '11', 'LOAN_NUM_CLOSED'] = '7'
    data.at[data['LOAN_NUM_CLOSED'] == '11', 'LOAN_NUM_CLOSED'] = '7'

    cats, nums = columns()

    dum_data = pd.get_dummies(data)