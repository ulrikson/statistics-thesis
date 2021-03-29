import numpy as np
import pandas as pd
import math
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error

from datetime import datetime
from matplotlib import pyplot
import matplotlib.pyplot as plt


data = pd.read_csv(r'C:\Users\Erik\Desktop\eriktest.csv', index_col='Date', parse_dates=True, sep=";", decimal=",")
#print(data.head())

close = data[['Close']]
df = data[['Logreturn']]
#print(df.head())
#print(close.head())

df = df.astype('float32')
close = close.astype('float32')
#print(df.head())

#print(data.head())
data[["Open", "High", "Low", "Close"]].describe()




#### Time serie plot logged #####
df.plot(color='blue')
plt.xlabel('Datum')
plt.ylabel('Logaritmerad avkastning')
plt.grid(color='grey', linestyle='-', linewidth=0.25)
#pyplot.show()

#### Time serie plot close prices #####
close.plot(color='green')
plt.xlabel('Datum')
plt.ylabel('Daglig stängningskurs')
plt.grid(color='grey', linestyle='-', linewidth=0.25, alpha=0.5)
#pyplot.show()


df.plot.hist(grid=True, bins=50, rwidth=0.8, color='grey')
plt.xlabel('Logaritmerad avkastning')
plt.ylabel('Frekvens')
plt.grid(color='grey', linestyle='-', linewidth=0.25, alpha=0.5)
#plt.show()
