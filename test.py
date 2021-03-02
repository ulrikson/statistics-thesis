import numpy as np
import pandas as pd
import math
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error

#! see lstm.ipynb for updated

np.random.seed(7)

# load dat
dataframe = pd.read_csv('clean_sm_day.csv', usecols=['Close'])
dataset = dataframe.values
dataset = dataset.astype('float32')

# normalize the dataset
scaler = MinMaxScaler(feature_range=(0, 1))
dataset = scaler.fit_transform(dataset)

# split into train and test sets
train_size = int(len(dataset) * 0.8)
test_size = len(dataset) - train_size
train =dataset[0:train_size,:]
test = dataset[train_size:len(dataset),:]

# convert an array of values into a dataset matrix with X=t, Y=t+1
def create_dataset(dataset, look_back=1):
	dataX, dataY = [], []
	for i in range(len(dataset)-look_back-1):
		a = dataset[i:(i+look_back), 0]
		dataX.append(a)
		dataY.append(dataset[i + look_back, 0])
	return np.array(dataX), np.array(dataY)

# reshape into X=t and Y=t+1
look_back = 1
trainX, trainY = create_dataset(train, look_back)
testX, testY = create_dataset(test, look_back)

# reshape input to be [samples, time steps, features]
trainX = np.reshape(trainX, (trainX.shape[0], 1, trainX.shape[1]))
testX = np.reshape(testX, (testX.shape[0], 1, testX.shape[1]))

# train and fit the LSTM network
model = Sequential()
model.add(LSTM(4, input_shape=(1, look_back))) #* what does 4 and input_shape do?
model.add(Dense(1)) #* what does Dense do?
model.compile(loss='mean_squared_error', optimizer='adam') #* adam?
model.fit(trainX, trainY, epochs=10, batch_size=1, verbose=2) #* epochs? verbose?

# make predictions
forecast_normalized = model.predict(testX)

# inverting the normalization => original scale
forecast = scaler.inverse_transform(forecast)
testY = scaler.inverse_transform([testY])

print(forecast)

# calculate root mean squared error
# trainScore = math.sqrt(mean_squared_error(trainY[0], trainPredict[:,0]))
# print('Train Score: %.2f RMSE' % (trainScore))
# testScore = math.sqrt(mean_squared_error(testY[0], testPredict[:,0]))
# print('Test Score: %.2f RMSE' % (testScore))