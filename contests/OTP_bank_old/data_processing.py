import numpy as np
import pandas as pd
from pandas import DataFrame
from IPython.display import display


class DataProcessing:

    def __init__(self, data):

        self.data = data
        self.categorical_columns = [col for col in self.data.columns if self.data[col].dtype.name == 'object']
        self.categorical_columns = [col for col in self.data.columns if self.data[col].dtype.name != 'object']

    def categories_aggregation(self, columns, n_samples=1, type_aggr='percent'):

        if type(columns) == str:



    # def small_categories_aggregation(column, n_samples, value='Укрупненная категория', dataset=data):
    # '''
    # Укрупняет категории и числовые столбцы в датасете
    # :param column: имя стоблца в датасете data
    # :param n_samples: порог наблюдений, ниже которого категории объединяются в одну
    # :param value: значение, которым будет заполнено
    # :param dataset: датасет для изменения
    # :return:
    # '''
    #
    # tmp_small_columns = dataset[column].value_counts()[dataset[column].value_counts() < n_samples].index
    #
    # for col in tmp_small_columns:
    #     dataset.at[dataset[column] == col, column] = value

