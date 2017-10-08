import pandas as pd
from pandas import DataFrame, Series
import numpy as np
import scipy.stats as stats
import statsmodels.api as sm

import matplotlib.pyplot as plt
import seaborn as sns


from IPython.display import display
plt.rc('font', family='Verdana')

import warnings
warnings.filterwarnings('ignore')


def set_columns_type(function):
    def wrapper(self, *args, **kwargs):
        function(self, *args, **kwargs)
        for column in self.categorical_columns:
            if column in self.columns:
                self[column] = self[column].astype('str')

    return wrapper


def columns_types(function):
    def wrapper(self, *args, **kwargs):
        function(self, *args, **kwargs)
        self.categorical_columns = np.array([col for col in self.columns if self[col].dtype.name == 'object'])
        self.numerical_columns = np.array([col for col in self.columns if self[col].dtype.name != 'object'])
        self.num_can_be_cat_columns = np.array(
            [col for col in self.numerical_columns if len(self[col].value_counts()) <= 15])

    return wrapper


class Frame(DataFrame):
    @columns_types
    def __init__(self, data, index=None, columns=None, dtype=None, copy=False):

        super().__init__(data=data, index=index, columns=columns, dtype=dtype, copy=copy)

    @columns_types
    @set_columns_type
    def add_cat_columns(self, columns):
        self.categorical_columns = np.append(self.categorical_columns, columns)

    def show_columns_with_missing(self):
        '''
        показать столбцы, где есть пропущенные значения
        :param dataset: датасет
        :return:
        '''

        miss_columns = self.count(axis=0)[self.count(axis=0) < len(self)].index

        if len(miss_columns) == 0:
            print('No missing')
        else:
            missing = [len(self) - len(self[col].dropna()) for col in miss_columns]
            percents = [round((len(self) - len(self[col].dropna())) * 100 / len(self), 2) for col in miss_columns]
            display(DataFrame({'Column': miss_columns, 'Miss count': missing, 'Percent': percents},
                              columns=['Column', 'Miss count', 'Percent']))

    def show_binning(self):

        self.columns_to_enlargment = []

        for column in self.categorical_columns:
            if self[column].value_counts().values[-1] < len(self) / 100:
                self.columns_to_enlargment.append(column)
                print(self[column].value_counts(), '\n')

    def show_qq_plot(self, column='@all', drop=False, size=(10, 10)):

        if column != '@all':

            plt.subplots(figsize=size)

            if type(column) == str:

                if drop == True:
                    stats.probplot(self[column].dropna(), dist="norm", plot=plt)
                else:
                    stats.probplot(self[column], dist="norm", plot=plt)

            else:
                stats.probplot(column, dist="norm", plot=plt)

            plt.show()

        else:

            for column in self.numerical_columns:
                plt.subplots(figsize=size)
                print(column)
                stats.probplot(self[column].dropna(), dist="norm", plot=plt)
                plt.show()
                print()

    def true_num_columns(self, columns):

        for column in columns:
            if column in self.columns:
                self[column] = self[column].str.replace(',', '.').astype('float')