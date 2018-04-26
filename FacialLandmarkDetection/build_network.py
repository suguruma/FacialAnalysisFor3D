# -*- coding: utf-8 -*-
"""
@author: Terada
"""
from keras.models import Sequential, Model
from keras.layers import Dense, MaxPooling2D, Flatten, Dropout
from keras.layers import Conv2D, BatchNormalization, ZeroPadding2D, MaxPool2D
from keras.layers import Input, Convolution2D, AveragePooling2D, merge, Reshape, Activation
from keras.regularizers import l2

def net(input_size):
    model = Sequential()

    model.add(Conv2D(32, (3, 3), activation='relu', input_shape=(input_size[0], input_size[1], 1)))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Conv2D(64, (2, 2), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Conv2D(128, (2, 2), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Conv2D(256, (2, 2), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))

    model.add(Flatten()) #平滑化 [ex: (None, 64, 32, 32)->(None, 65536)]
    model.add(Dense(1000, activation='relu')) #全結合NNLayer
    model.add(Dense(500, activation='relu'))
    model.add(Dense(28))
    
    return model


def lenet(input_size):
    model = Sequential()

    model.add(Conv2D(20, kernel_size=5, strides=1, activation='relu', input_shape=(input_size[0], input_size[1], 1)))
    model.add(MaxPooling2D(2, strides=2))
    
    model.add(Conv2D(50, kernel_size=5, strides=1, activation='relu'))
    model.add(MaxPooling2D(2, strides=2))
    
    model.add(Flatten())
    model.add(Dense(500, activation='relu'))

    model.add(Dense(28)) #activation='softmax'

    return model


def alexnet(input_size):
    model = Sequential()
 
    model.add(Conv2D(48, 11, strides=3, activation='relu', padding='same', input_shape=(input_size[0], input_size[1], 1)))
    model.add(MaxPooling2D(3, strides=2))
    model.add(BatchNormalization())
    
    model.add(Conv2D(128, 5, strides=3, activation='relu', padding='same'))
    model.add(MaxPooling2D(3, strides=2))
    model.add(BatchNormalization())
    
    model.add(Conv2D(192, 3, strides=1, activation='relu', padding='same'))
    model.add(Conv2D(192, 3, strides=1, activation='relu', padding='same'))
    model.add(Conv2D(128, 3, strides=1, activation='relu', padding='same'))
    model.add(MaxPooling2D(3, strides=2))
    model.add(BatchNormalization())
    
    model.add(Flatten())
    model.add(Dense(2048, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(2048, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(28)) #activation='softmax'

    return model


def vgg16(input_size):
    model = Sequential()

    model.add(ZeroPadding2D((1,1),input_shape=(input_size[0], input_size[1], 1)))
    model.add(Conv2D(64, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(64, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(128, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(128, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(256, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(256, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(256, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(Flatten())
    model.add(Dense(4096, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(4096, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(28)) #1000, activation='softmax'

    return model

def vgg19(input_size):
    model = Sequential()

    model.add(ZeroPadding2D((1,1),input_shape=(input_size[0], input_size[1], 1)))
    model.add(Conv2D(64, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(64, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(128, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(128, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(256, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(256, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(256, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(256, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Conv2D(512, 3, 3, activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(Flatten())
    model.add(Dense(4096, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(4096, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(28)) #1000, activation='softmax'

    return model

'''
def zfnet(input_size):
    
    img_input = Input(shape=(input_size[0], input_size[1], 3))
    # x = ZeroPadding2D((3, 3))(img_input)
    x = Conv2D(96, (7, 7), strides=(2, 2), name='conv1')(img_input)
    # (55, 55, 96)
    x = MaxPool2D(pool_size=(3, 3), strides=(2, 2), padding='same', name='pool1')(x)
    # (27, 27, 96)
    x = BatchNormalization(axis=3, name='bn_conv1')(x)

    x = Conv2D(256, (5, 5), strides=(4, 4), name='conv2')(x)
    x = MaxPool2D(pool_size=(3, 3), strides=(2, 2), padding='same', name='pool2')(x)
    x = BatchNormalization(axis=3, name='bn_conv2')(x)

    x = Conv2D(512, (3, 3), strides=(1, 1), padding=1, name='conv3')(x)
    x = Conv2D(1024, (3, 3), strides=(1, 1), padding=1, name='conv4')(x)
    x = Conv2D(512, (3, 3), strides=(1, 1), padding=1, name='conv5')(x)
    x = MaxPool2D(pool_size=(3, 3), strides=(2, 2), padding='same', name='pool3')(x)

    x = Dense(units=4096)(x)
    x = Dense(units=4096)(x)
    x = Dense(units=28)(x) #32
    #x = Activation('softmax')(x)

    model = Model(inputs=img_input, outputs=x, name='ZFNet Model')
    return model
'''

