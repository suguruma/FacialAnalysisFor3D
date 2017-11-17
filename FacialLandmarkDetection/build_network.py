# -*- coding: utf-8 -*-
"""
@author: Terada
"""
from keras.models import Sequential
from keras.layers import Dense, MaxPooling2D, Flatten, Dropout
from keras.layers import Conv2D

def net(input_size):
    model = Sequential()

    model.add(Conv2D(32, (3, 3), activation='relu', input_shape=(input_size[0], input_size[1], 1)))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    #model.add(Dropout(0.1, seed=1))

    model.add(Conv2D(64, (2, 2), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    #model.add(Dropout(0.2, seed=1))

    model.add(Conv2D(128, (2, 2), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    #model.add(Dropout(0.3, seed=1))

    model.add(Conv2D(256, (2, 2), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    #model.add(Dropout(0.3, seed=1))

    model.add(Flatten()) #平滑化 [ex: (None, 64, 32, 32)->(None, 65536)]
    model.add(Dense(1000, activation='relu')) #全結合NNLayer
    #model.add(Dropout(0.5, seed=1)) #更新値0をランダムにセット(rate, seed)
    model.add(Dense(1000, activation='relu'))
    model.add(Dense(28))
    
    return model