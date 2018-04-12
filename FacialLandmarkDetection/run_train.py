# -*- coding: utf-8 -*-
"""
@author: Terada
"""

import read_image as imread_mod
import read_text as txtread_mod
import build_network as net_mod

import numpy as np
import matplotlib.pyplot as plt


import os
from pandas.io.parsers import read_csv
from sklearn.utils import shuffle
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
from collections import OrderedDict

from keras.models import Sequential, model_from_json
from keras.layers import Dense, Activation, Convolution2D, MaxPooling2D, Flatten, Dropout
from keras.optimizers import SGD
from keras.preprocessing.image import ImageDataGenerator
from keras.callbacks import LearningRateScheduler, EarlyStopping, TensorBoard, ModelCheckpoint
from keras.utils import plot_model
from keras.layers import Conv2D
from keras.backend import tensorflow_backend as KTF
import tensorflow as tf


'''
 Image, Textのファイル名チェック
 共通ファイル名のファイルパス出力
'''
def common_filename_check(_fname1, _fname2, _fname1_str = 'Image', _fname2_str = 'land', _fname1_ext = 'jpg', _fname2_ext = 'txt'):
    import re

    _1to2name = [re.sub(_fname1_str, _fname2_str, _fname1[i].split(_fname1_ext)[0]) for i in range(len(_fname1))]
    _com_name = []

    for i in range(len(_1to2name)):
        for j in range(len(_fname2)):
            if _1to2name[i] in _fname2[j]:
                _com_name.append(_1to2name[i].split(_fname2_str)[1])
                break

    iext= np.array([_fname1_ext]*len(_com_name))
    _com_fname1 = np.core.defchararray.add(_com_name, iext)
    _com_fname1 = [re.sub('^', _fname1_str, _com_fname1[i]) for i in range(len(_com_fname1))]

    text= np.array([_fname2_ext]*len(_com_name))
    _com_fname2 = np.core.defchararray.add(_com_name, text)    
    _com_fname2 = [re.sub('^', _fname2_str, _com_fname2[i]) for i in range(len(_com_fname2))]
    
    return _com_fname1, _com_fname2

def load_data(_image_path, _label_path, _io_fname, _img_size, _input_size, data_check = True):

    ## Read image
    X, _iname = imread_mod.main(_image_path, _input_size)
    #print("X.shape == {}; X.min == {:.1f}; X.max == {:.1f}".format(X.shape, X.min(), X.max()))

    ## Read text
    y, _tname = txtread_mod.main(_label_path, _io_fname, _img_size, False)
    #print("y.shape == {}; y.min == {:.3f}; y.max == {:.3f}".format(y.shape, y.min(), y.max()))

    if data_check:
        _iname, _tname = common_filename_check(_iname, _tname)        
        print("Common Files : {0}".format(len(_iname)))            
        _iname_path = []
        _tname_path = []
        for i in range(len(_iname)):
            _iname_path.append(_image_path.split('*')[0] + _iname[i])
            _tname_path.append(_label_path.split('*')[0] + _tname[i])

        X, _ = imread_mod.main(_iname_path, _input_size)
        y, _ = txtread_mod.main(_tname_path, _io_fname, _img_size, False)
   
    return X, y

'''
 y[0/1::2] : 0/1要素からスタート, 次の2つ目
'''
def plot_sample(_x, _y, _img_size):
    img = _x.reshape(_img_size[0], _img_size[1])

    half_size = _img_size.max() / 2
    
    plt.imshow(img, cmap='gray')
    plt.scatter(_y[0::2] * half_size + half_size, _y[1::2] * half_size + half_size, marker='x', s=20)

def plot_2samples(x1, y1, x2, y2, _img_size):
    img1 = x1.reshape(_img_size[0], _img_size[1])
    img2 = x2.reshape(_img_size[0], _img_size[1])

    half_size = _img_size.max() / 2

    plt.figure(figsize=(10, 6)) # figure(縦,横の大きさ)
    
    plt.subplot(1,2,1) # figure内の枠の大きさと配置:subplot(行の数,列の数,配置番目)
    plt.imshow(img1, cmap='gray')
    plt.scatter(y1[0::2] * half_size + half_size, y1[1::2] * half_size + half_size, marker='x', color='b',s=20)
        
    plt.subplot(1,2,2)
    plt.imshow(img2, cmap='gray')
    plt.scatter(y2[0::2] * half_size + half_size, y2[1::2] * half_size + half_size, marker='x', color='r', s=20)

def model_fitting(_X, _y, _model, _comment='sample', nb_epoch = 100):
    
    ## Set Learning Rate
    start = 0.03
    stop = 0.001
    learning_rates = np.linspace(start, stop, nb_epoch)

    ## Save Log and Keep Model
    log_filepath = "./logs/{0}".format(_comment)
    os.makedirs(log_filepath, exist_ok=True)
    
    save_filepath = "./model/{0}/".format(_comment)
    os.makedirs(save_filepath, exist_ok=True)
    save_chekpointpath = save_filepath + 'model-epoch{epoch:04d}-loss{loss:.3f}-vloss{val_loss:.3f}.hdf5'

    ## CallBack
    lr_cb = LearningRateScheduler(lambda epoch: float(learning_rates[epoch]))
    es_cb = EarlyStopping(patience=100)
    tb_cb = TensorBoard(log_dir=log_filepath, histogram_freq=0, write_graph=True)  # ログ可視化/freq=1: each epoch
    cp_cb = ModelCheckpoint(filepath=save_chekpointpath, monitor='val_loss', verbose=1, save_best_only=True, mode='auto')  # モデル保存
    
    ## Fitting
    sgd = SGD(lr=start, momentum=0.9, nesterov=True)
    _model.compile(loss='mean_squared_error', optimizer=sgd)
    hist = _model.fit(_X, _y, epochs=nb_epoch, validation_split=0.2, callbacks=[lr_cb, es_cb, tb_cb])#, cp_cb])
    
    return hist, _model

def display_hist(hist):
    
    plt.figure(figsize=(6, 8))
    plt.plot(hist.history['loss'], linewidth=3, label='train')
    plt.plot(hist.history['val_loss'], linewidth=3, label='valid')
    plt.grid()
    plt.legend()
    plt.xlabel('epoch')
    plt.ylabel('loss')
    plt.ylim(1e-3, 1e-1)
    plt.yscale('log')

def model_save(_model, _architecture_name, _weights_name):
    json_string = _model.to_json()
    open(_architecture_name, 'w').write(json_string)
    _model.save_weights(_weights_name)

def main():
        
    ## Image Data
    #img_size = np.array([400, 360])  #[h, w]
    #input_size = img_size / 4 #4:[100, 90]
    img_size = np.array([227, 227])  #[h, w] alexnet
    input_size = img_size / 1
    
    input_size = input_size.astype(np.int)

    ## Training Data Path
    image_path = 'data/img3dTo2d/before/*.jpg'
    label_path = 'data/txt3dTo2d/before/*.txt'
    io_fname = 'data/label.csv'

    ### データ読み込み
    print("Read File ...")
    X, y = load_data(image_path, label_path, io_fname, img_size, input_size)

    ### 可視化
    print("Plot sample ...")
    plot_sample(X[0],y[0], input_size)
    plot_2samples(X[2], y[2], X[1], y[1], input_size)
    
    ### モデル名
    model_name = 'zfnet_ep10'
    model_path = "./model/{0}/".format(model_name)
    json_name = model_path + 'architecture.json'
    weights_name = model_path + 'weights.h5'
 
    ### モデル生成
    print("Build Model ...")
    hist, model = model_fitting(X, y, net_mod.vgg_16(input_size), model_name, nb_epoch = 10)
    model_save(model, json_name, weights_name)
    display_hist(hist)

if __name__ == "__main__":
    main()