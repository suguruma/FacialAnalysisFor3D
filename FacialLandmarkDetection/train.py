# -*- coding: utf-8 -*-
"""
@author: Terada
"""

import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import os
import random as rn
import shutil
import datetime
import csv
import glob
import re
from configparser import ConfigParser, ExtendedInterpolation

from pandas.io.parsers import read_csv
from sklearn.utils import shuffle
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
from collections import OrderedDict

from keras.models import Sequential, model_from_json
from keras.layers import Dense, Activation, Conv2D, MaxPooling2D, Flatten, Dropout
from keras.optimizers import SGD, Adadelta, Adagrad, Adam, Adamax, RMSprop, Nadam
from keras.preprocessing.image import ImageDataGenerator
from keras.callbacks import LearningRateScheduler, EarlyStopping, TensorBoard, ModelCheckpoint, CSVLogger, TerminateOnNaN
from keras.utils import np_utils, plot_model
from keras.backend import tensorflow_backend as KTF
from keras import backend as K

import tensorflow as tf

import generate_label as gl
import build_network as net
import common as cmn
import read_image as imread_mod
import read_text as txtread_mod

def init_random_seed(_seed = 0):
    os.environ['PYTHONHASHSEED'] = '0'
    np.random.seed(_seed)
    rn.seed(_seed)
    session_conf = tf.ConfigProto(intra_op_parallelism_threads=1, inter_op_parallelism_threads=1)
    tf.set_random_seed(_seed)
    sess = tf.Session(graph=tf.get_default_graph(), config=session_conf)
    K.set_session(sess)

class DatasetGeneration():
    def __init__(self):
        self.filename1_str = 'Image'
        self.filename2_str = 'land'
        self.filename3_str = 'R'
        self.filename = None

    def shuffleDataset(self, data1, data2):
        # shuffle
        l = list(zip(data1, data2))
        np.random.shuffle(l)
        data1, data2 = zip(*l)
        data1 = np.array(data1)
        data2 = np.array(data2)
        return data1, data2

    def common_filename_check(self, _fname1, _fname2, _fname1_str='Image', _fname2_str='land', _fname1_ext='jpg', _fname2_ext='txt'):
        import re

        _1to2name = [re.sub(_fname1_str, _fname2_str, _fname1[i].split(_fname1_ext)[0]) for i in range(len(_fname1))]
        _com_name = []

        for i in range(len(_1to2name)):
            for j in range(len(_fname2)):
                if _1to2name[i] in _fname2[j]:
                    _com_name.append(_1to2name[i].split(_fname2_str)[1])
                    break

        iext = np.array([_fname1_ext] * len(_com_name))
        _com_fname1 = np.core.defchararray.add(_com_name, iext)
        _com_fname1 = [re.sub('^', _fname1_str, _com_fname1[i]) for i in range(len(_com_fname1))]

        text = np.array([_fname2_ext] * len(_com_name))
        _com_fname2 = np.core.defchararray.add(_com_name, text)
        _com_fname2 = [re.sub('^', _fname2_str, _com_fname2[i]) for i in range(len(_com_fname2))]
        return _com_fname1, _com_fname2

    def load_data(self, _image_path, _label_path, _io_fname, _img_size, _input_size, data_check=True):
        X, iname = imread_mod.main(_image_path, _input_size) # read image
        y, tname = txtread_mod.main(_label_path, _io_fname, _img_size, False) # read text

        if data_check:
            iname, tname = self.common_filename_check(iname, tname, self.filename1_str, self.filename2_str)
            print("Common Files : {0}".format(len(iname)))
            _iname_path = []
            _tname_path = []
            for i in range(len(iname)):
                _iname_path.append(os.path.dirname(_image_path) + "//" + iname[i])
                _tname_path.append(os.path.dirname(_label_path) + "//" + tname[i])
            X, iname = imread_mod.main(_iname_path, _input_size)
            y, tname = txtread_mod.main(_tname_path, _io_fname, _img_size, False)

        self.filename = tname
        return X, y

    def load_label(self):

        fp = open("data/attribute.csv")
        data = fp.read()
        fp.close()
        gen_dict = {}
        age_dict = {}
        lines = data.split('\n')
        for i, line in enumerate(lines):
            if i == 0:  # header
                continue
            if line == "":
                break
            vals = line.split(',')
            id = int(vals[0].split('R')[1])
            gen_dict[id] = int(vals[1]) - 1
            age_dict[id] = int(vals[2]) - 2

        gen_list = []
        age_list = []
        pattern = '([+-]?[0-9]+\.?[0-9]*)'
        for i in range(len(self.filename)):
            num = re.findall(pattern, os.path.basename(self.filename[i]))[0]
            num = int(num.split('.')[0])
            gen_list.append(gen_dict[num])
            age_list.append(age_dict[num])
        gen_list.insert(0, 1)  # max value
        age_list.insert(0, 4)  # max value
        one_hot_y1 = np_utils.to_categorical(gen_list)
        one_hot_y2 = np_utils.to_categorical(age_list)
        one_hot_y1 = np.delete(one_hot_y1, 0, 0)  # delete max value
        one_hot_y2 = np.delete(one_hot_y2, 0, 0)  # delete max value

        return  one_hot_y1, one_hot_y2

    def load_data2_(self, _path, _input_size, _output):
        # set
        file_path = _path
        label_name = _output + "label.csv"

        # label function
        if not os.path.isfile(label_name):
            gl.mergeLabel(file_path, label_name)
        name, pos2d, confidence = gl.getLabel(label_name)

        # shuffle
        l = list(zip(name, pos2d, confidence))
        np.random.shuffle(l)
        name, pos2d, confidence = zip(*l)
        name = np.array(name)
        pos2d = np.array(pos2d)
        confidence = np.array(confidence)

        # image function
        images = gl.getImage(name, _input_size)
        cmn.saveMeanData(images, _output + 'mean.csv')

        return images, pos2d, confidence

class Train():
    def __init__(self):
        self.gd = DatasetGeneration()
        self.config = ConfigParser(interpolation=ExtendedInterpolation())

    def model_evaluation(self, _model, _X_test, _y_test):
        if _X_test is None:
            return 0
        score = _model.evaluate(_X_test, _y_test, batch_size=self.batch_size, verbose=1)
        results = list(zip(_model.metrics_names, score))
        with open(self.save_score, 'w', newline='') as f:
            writer = csv.writer(f, lineterminator='\n')
            writer.writerow(list(['', self.model_path]))
            print("")
            for ret in results:
                print(ret)
                writer.writerow(ret)

    def plot_history_multi(self, _history, _path):
        keys = _history.history.keys()
        # accuracy log
        plt.figure()
        for key in keys:
            if 'acc' in key:
                plt.plot(_history.history[key], "o-", label=key)
        plt.title('model accuracy')
        plt.xlabel('epoch')
        plt.ylabel('accuracy')
        plt.legend(loc="lower right")
        plt.savefig(_path + 'figure_accuracy.png')
        # loss log
        plt.figure()
        for key in keys:
            if 'loss' in key:
                plt.plot(_history.history[key], "o-", label=key)
        plt.title('model loss')
        plt.xlabel('epoch')
        plt.ylabel('loss')
        plt.legend(loc='lower right')
        plt.savefig(_path + 'figure_loss.png')

    def plot_history(self, _history, _path, _val_flag=None):
        # accuracy log
        plt.figure()
        plt.plot(_history.history['acc'], "o-", label="accuracy")
        if not _val_flag is None:
            plt.plot(_history.history['val_acc'], "o-", label="val_acc")
        plt.title('model accuracy')
        plt.xlabel('epoch')
        plt.ylabel('accuracy')
        plt.legend(loc="lower right")
        plt.savefig(_path + 'figure_accuracy.png')
        # loss log
        plt.figure()
        plt.plot(_history.history['loss'], "o-", label="loss", )
        if not _val_flag is None:
            plt.plot(_history.history['val_loss'], "o-", label="val_loss")
        plt.title('model loss')
        plt.xlabel('epoch')
        plt.ylabel('loss')
        plt.legend(loc='lower right')
        plt.savefig(_path + 'figure_loss.png')

    def selectOptimizer(self, _optimizer):
        if _optimizer == "SGD":
            return SGD()
        if _optimizer == "Adadelta":
            return Adadelta()
        if _optimizer == "Adagrad":
            return Adagrad()
        if _optimizer == "Adam":
            return Adam()
        if _optimizer == "Adamax":
            return Adamax()
        if _optimizer == "RMSprop":
            return RMSprop()
        if _optimizer == "Nadam":
            return Nadam()

    def model_fitting_multi(self, _X, _y, _model, _X_val=None, _y_val=None):
        ## CallBack
        callback_list = []
        tb_cb = TensorBoard(log_dir=self.model_path, histogram_freq=0, write_graph=True)
        callback_list.append(tb_cb)
        lr_cb = LearningRateScheduler(lambda epoch: float(self.learning_rates[epoch]))
        callback_list.append(lr_cb)
        es_cb = EarlyStopping(monitor='loss', min_delta=0, patience=self.patient, verbose=1, mode='auto')
        callback_list.append(es_cb)
        tn_cb = TerminateOnNaN()
        callback_list.append(tn_cb)
        cp_cb = ModelCheckpoint(filepath=self.save_weights_checkpoint, monitor='val_loss', save_weights_only=True, save_best_only=True, mode='auto', verbose=1)
        callback_list.append(cp_cb)
        cl_cb = CSVLogger(filename=self.save_train_log, separator=',', append=False)
        callback_list.append(cl_cb)

        ## Fitting
        val_data = None
        if not _X_val is None:
            val_data = (_X_val, _y_val)
        _model.compile( optimizer=self.selectOptimizer(self.optimizer),
                                   #'sub1': self.selectOptimizer(self.optimizer)},
                                   #'sub2': self.selectOptimizer(self.optimizer)},
                        loss={'main':'mean_squared_error',
                              'sub1':'categorical_crossentropy',
                              'sub2':'categorical_crossentropy'},
                        loss_weights={'main': 100, 'sub1': 0.1, 'sub2': 0.1},
                        metrics=['accuracy'])
        hist = _model.fit(_X, _y, epochs=self.nb_epoch, batch_size=self.batch_size,
                          validation_data=val_data, shuffle=True, callbacks=callback_list)

        return hist, _model

    def model_fitting(self, _X, _y, _model, _X_val=None, _y_val=None):
        ## CallBack
        callback_list = []
        tb_cb = TensorBoard(log_dir=self.model_path, histogram_freq=0, write_graph=True)
        callback_list.append(tb_cb)
        lr_cb = LearningRateScheduler(lambda epoch: float(self.learning_rates[epoch]))
        callback_list.append(lr_cb)
        es_cb = EarlyStopping(monitor='loss', min_delta=0, patience=self.patient, verbose=1, mode='auto')
        callback_list.append(es_cb)
        tn_cb = TerminateOnNaN()
        callback_list.append(tn_cb)
        cp_cb = ModelCheckpoint(filepath=self.save_weights_checkpoint, monitor='val_loss', save_weights_only=True, save_best_only=True, mode='auto', verbose=1)
        callback_list.append(cp_cb)
        cl_cb = CSVLogger(filename=self.save_train_log, separator=',', append=False)
        callback_list.append(cl_cb)

        ## Fitting
        val_data = None
        if not _X_val is None:
            val_data = (_X_val, _y_val)
        _model.compile(optimizer=self.selectOptimizer(self.optimizer), loss='mean_squared_error', metrics=['accuracy'])
        hist = _model.fit(_X, _y, epochs=self.nb_epoch, batch_size=self.batch_size, validation_data=val_data, shuffle=True, callbacks=callback_list)

        return hist, _model


    def run(self, _validation = True):
        ## Read Data
        print("Read File ...")
        #X, y1, y2 = self.gd.load_data(_path, input_size, model_path)
        #X = X - cmn.loadMeanData(model_path + 'mean.csv')
        #X = cmn.changeImageScale(X, input_size)
        #y1 = cmn.encodeKeypointsScale(y1, input_size.max())
        #print(X.shape, y1.shape, y2.shape)

        # learning data
        X, y = self.gd.load_data(self.image_path, self.label_path, self.save_labelset, self.img_size, self.input_size)
        y1, y2 = self.gd.load_label()

        # validation data
        X_val = y_val = None
        if _validation:
            X_val, y_val = self.gd.load_data(self.val_image_path, self.val_label_path, self.save_labelset_val, self.img_size, self.input_size)
            y1_val, y2_val = self.gd.load_label()
        #X, y = self.gd.shuffleDataset(X, y)

        ## Build Model
        print("Build Model ...")
        model = net.select(self.network, self.input_size, self.output_size)  # select network
        # save architecture of model
        open(self.save_architecture, 'w').write(model.to_json()) # save json of network
        # save figure of model
        plot_model(model, to_file = self.save_model_figure) # save picture of network

        ## Fit Model
        print("Fit Model ...")
        if not self.isMultiTask:
            hist, model = self.model_fitting(X, y, model, X_val, y_val)
            # save model weights
            model.save_weights(self.save_weights)
            # draw acc graph and loss from history
            self.plot_history(hist, self.model_path)
            self.model_evaluation(model, X_val, y_val)
        else:
            hist, model = self.model_fitting_multi(X, [y, y1, y2], model, X_val, [y_val, y1_val, y2_val])
            # save model weights
            model.save_weights(self.save_weights)
            # draw acc graph and loss from history
            self.plot_history_multi(hist, self.model_path)
            self.model_evaluation(model, X_val, [y_val, y1_val, y2_val])

    def setParameter(self, _conf_file):
        self.config.read(_conf_file)

        ## Image Data
        conf_io = self.config['IO']
        self.img_size = np.array([conf_io.getint('image_height'),conf_io.getint('image_width')])
        self.input_size = np.array([conf_io.getint('input_height'),conf_io.getint('input_width')])
        self.input_size = self.input_size.astype(np.int)
        self.output_size = conf_io.getint('output_size')

        ## Dataset
        conf_d = self.config['Dataset']
        datasetName = conf_d['base']
        datasetOther = conf_d['base_plus']
        self.image_path = '{0}//{1}{2}//*.jpg'.format(conf_d['image_path'], datasetName, datasetOther)
        self.label_path = '{0}//{1}{2}//*.txt'.format(conf_d['label_path'], datasetName, datasetOther)
        validationName = conf_d['base_validation']
        validationOther = conf_d['base_validation_plus']
        self.val_image_path = '{0}//{1}{2}//*.jpg'.format(conf_d['image_path'], validationName, validationOther)
        self.val_label_path = '{0}//{1}{2}//*.txt'.format(conf_d['label_path'], validationName, validationOther)
        comment = conf_d['comment']
        targetPath = conf_d['target_path']

        ## Parameter
        conf_p = self.config['Parameter']
        self.network = conf_p.get('network')
        self.nb_epoch = conf_p.getint('epoch') #100
        self.batch_size = conf_p.getint('batch_size') #128
        self.learning_rates = np.linspace(float(conf_p.getfloat('learning_rates_start')),
                                          float(conf_p.getfloat('learning_rates_stop')), self.nb_epoch)
        self.optimizer = conf_p.get('optimizer')

        ## Callback
        conf_c = self.config['Callback']
        self.patient = conf_c.getint('earlystopping')

        ## Model
        now = datetime.datetime.now()
        time = "{0:02d}{1:02d}{2:02d}{3:02d}".format(now.month, now.day, now.hour, now.minute)
        self.model_path = './model/{0}/{1}_{2}_{3}_{4}/'.format(targetPath, datasetName, self.network, comment, time)
        os.makedirs(self.model_path, exist_ok=True)

        ## Malti-Task
        conf_m = self.config['MaltiTask']
        self.isMultiTask = conf_m.getboolean('multi_task_on')

        ## Filename
        conf_s = self.config['Save']
        self.save_model_figure = self.model_path + conf_s['model_figure'] #'figure_model.png'
        self.save_architecture = self.model_path + conf_s['architecture'] #'architecture.json'
        self.save_weights = self.model_path + conf_s['weights'] #'weights.h5'
        self.save_weights_checkpoint = self.model_path + conf_s['weights_checkpoint'] #'weights_checkpoint.h5'
        self.save_train_log = self.model_path + conf_s['train_log'] #'train_log.csv'
        self.save_labelset = self.model_path + conf_s['labelset'] #'label.csv'
        self.save_labelset_val = self.model_path + conf_s['labelset_val'] #'val_labelset.csv'
        shutil.copyfile("./build_network.py", self.model_path + conf_s['network_py']) # copy network.py
        shutil.copyfile(_conf_file, self.model_path + os.path.basename(_conf_file)) # copy conf.ini
        self.save_score = self.model_path + conf_s['score'] #'score.csv'

if __name__ == "__main__":
    init_random_seed()
    tr = Train()
    config_files = glob.glob("./param//batch//*.ini")
    #config_files = ["./param//train.ini"]
    validation = True
    for conf in config_files:
        tr.setParameter(conf)
        tr.run(validation)