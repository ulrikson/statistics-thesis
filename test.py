import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler

df = pd.read_csv('clean_sm_day.csv')
df = df.drop(['Unnamed: 0'], axis=1)

# choosing close column
close_diff = np.diff(df['Close'])
close_diff = np.insert(close_diff, 0, 0, axis=0) # inserting 0 as first diff
df['diff'] = close_diff # appending to dataframe

# normalizing data
scaler = MinMaxScaler()
df_norm = pd.DataFrame(scaler.fit_transform(df), columns=df.columns, index=df.index) # potential problem --> we're fitting with test data?

# splitting into train and test
train_size = round(len(df_norm) * 0.9)
test_size = len(df_norm) - train_size
train_data = df_norm.head(train_size)
test_data = df_norm.tail(test_size)

