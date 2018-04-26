# -*- coding: utf-8 -*-
"""
Created on Sun Nov  5 12:08:23 2017

@author: Terada
"""

import numpy as np
import glob
import pandas as pd

## 顔器官ID
landmark_dict = {'0':'left_eye_outer_corner_x',
                 '1':'left_eye_outer_corner_y',
                 '2':'left_eye_inner_corner_x',
                 '3':'left_eye_inner_corner_y',
                 '4':'right_eye_inner_corner_x',
                 '5':'right_eye_inner_corner_y',
                 '6': 'right_eye_outer_corner_x',
                 '7': 'right_eye_outer_corner_y',
                 '8': 'left_nose_top_x',
                 '9': 'left_nose_top_y',
                 '10': 'left_nose_bottom_x',
                 '11': 'left_nose_bottom_y',
                 '12': 'right_nose_top_x',
                 '13': 'right_nose_top_y',
                 '14': 'right_nose_bottom_x',
                 '15': 'right_nose_bottom_y',
                 '16': 'nose_root_x',
                 '17': 'nose_root_y',
                 '18': 'mouth_center_top_lip_x',
                 '19': 'mouth_center_top_lip_y',
                 '20': 'mouth_left_corner_x',
                 '21': 'mouth_left_corner_y',
                 '22': 'mouth_center_bottom_lip_x',
                 '23': 'mouth_center_bottom_lip_y',
                 '24': 'mouth_right_corner_x',
                 '25': 'mouth_right_corner_y',
                 '26': 'mouth_center_lip_x',
                 '27': 'mouth_center_lip_y'}

## 2D点クラス
class Point2D():
    def __init__(self, _x, _y):
        self.x = _x;
        self.y = _y;

## 特徴点群
class LandmarkData():
    def __init__(self):
        self.idx = []
        self.Point = []
    
    def add_parts_index(self, _parts_idx):
        self.idx.append(_parts_idx)

    def add_Point(self, _Point):
        self.Point.append(_Point)

def extract_filename(filepath, ext = None):
    _name = filepath.split('\\')[len(filepath.split('\\'))-1]
    
    if ext == None:
        filename = _name
    else:
        filename = _name.split(ext)[0]
        
    return filename

'''
 テキストファイル読み込み
'''       
def read_landmark(_data_path, _format = 1):

    files = None
    if type(_data_path) == str:
        files = glob.glob(_data_path)
    elif type(_data_path) == list:
        files = _data_path
        
    filename_dict = {}
    landmarks_list = []

    for i, filename in enumerate(files):
        ## make file ID : ファイルID生成
        fname = extract_filename(filename, None) #.txt
        filename_dict[i] = fname

        ## for Landmark
        fp = open(filename)
        data = fp.read()
        fp.close()

        if _format == 1:
            landmarks = LandmarkData()
            flag_of_start = False
            lines = data.split('\n')
            for line in lines:
                if "ID" in line:
                    flag_of_start = True
                elif flag_of_start and len(line) > 0:
                    #[No][ID][X][Y]
                    vals = line.split(',')
                    landmarks.add_parts_index(1) # start zero(0)
                    landmarks.add_Point( Point2D( int(vals[2]), int(vals[3]) ))
            landmarks_list.append(landmarks)
        else:
            landmarks = LandmarkData()
            flag_of_start = False
            lines = data.split('\n')
            for line in lines:
                if "Format" in line:
                    flag_of_start = True
                elif '#' in line and flag_of_start:
                    #[Area_Number][Index_Numer_in_Area][Index_Numer][X][Y]
                    vals = line.split(' ')
                    landmarks.add_parts_index(int(vals[4]) + 1) # start zero(0)
                    landmarks.add_Point( Point2D( int(vals[5]), int(vals[6]) ))
            landmarks_list.append(landmarks)

        
    return filename_dict, landmarks_list

'''
 lmlist[ff].Point[lmlist[oo].idx[yy]].(x/y)
 [ff] -> ファイルIDを指定する
 [oo] -> 顔器官IDを指定する
 (x/y) -> x か yで座標値を取得する
''' 
def make_landmark_df(_lm_list, _fname_dict, _landmark_dict):
    lmptlist = []
    for i in range(len(_lm_list)):
        lmpt = np.arange(0)
        for j in range(len(_lm_list[i].idx)):
            lmpt = np.append(lmpt, _lm_list[i].Point[j].x)
            lmpt = np.append(lmpt, _lm_list[i].Point[j].y)
        lmptlist.append(lmpt)
        
    ## ファイル名を列indexとして設定する
    fn_label = [_fname_dict[i] for i in range(len(_fname_dict))]

    ## 器官名を行indexとして設定する
    lm_label = [_landmark_dict[str(i)] for i in range(len(_landmark_dict))]
    df = pd.DataFrame(np.array(lmptlist), index = fn_label, columns = lm_label)

    return df

'''
 出力     
'''
def write_landmark_df(_df_list, _save_fname):
    _df_list.to_csv(_save_fname)

'''
 -1から1の値に変換 
'''
def landmark_change_scale(_df_lm, _img_size):
    np_lmptlist = np.array(_df_lm).astype(np.float32)
    np_lmptlist = (np_lmptlist - _img_size/2) / (_img_size/2)
    return np_lmptlist


'''
 メイン
'''
def main(filename_path, io_fname, img_size, READ_CSV = False):
    
    fname_dict = None
    ### ラベル入力 ###
    if(READ_CSV):
        ### ラベルデータ読み込み
        lm_df = pd.read_csv(io_fname, index_col=0)
    else:
        ### ファイル名、特徴点の読み込み (リスト化)
        fname_dict, lm_list = read_landmark(filename_path)
        print("Read Landmark Texts : {0}".format(len(fname_dict)))
    
        ### ラベル整形    
        lm_df = make_landmark_df(lm_list, fname_dict, landmark_dict)

        ### ラベル出力 (CSV)
        save_fname = io_fname
        write_landmark_df(lm_df, save_fname)
        print("Write Landmark Dataset : OK")
        
    ### ラベル変換 
    y = landmark_change_scale(lm_df, img_size.max())

    return y, fname_dict

def convertNewFormat(fname_dict, lm_list):
    import csv
    for i in range(len(lm_list)):
        with open(".//convert//" + fname_dict[i], 'w', newline='') as f:
            writer = csv.writer(f, lineterminator='\n')
            lm_label = ["No.", "ID", "POS(X)", "POS(Y)"]
            writer.writerow(lm_label)
            for j in range(len(lm_list[i].idx)):
                row = [j + 1, 0, lm_list[i].Point[j].x, lm_list[i].Point[j].y]
                writer.writerow(row)

if __name__ == "__main__":
    ### ラベル入力 ###
    READ_CSV = False
    input_fname = 'data//label.csv'
    img_size = np.array([400, 360])  #[h, w]

    if(READ_CSV):
        ### ラベルデータ読み込み
        lm_df = pd.read_csv(input_fname, index_col=0)
        print("Read CSV: {0}".format(input_fname))
        
    else:
        ### ファイル名、特徴点の読み込み (リスト化)
        filename_path = 'data//txt3dTo2d//before//*.txt'
        fname_dict, lm_list = read_landmark(filename_path)
        print("Read Files: {0}".format(filename_path))
        convertNewFormat(fname_dict, lm_list)

        ### ラベル整形    
        lm_df = make_landmark_df(lm_list, fname_dict, landmark_dict)

        ### ラベル出力 (CSV)
        #save_fname = input_fname
        #write_landmark_df(lm_df, save_fname)

    ### ラベル変換 
    y = landmark_change_scale(lm_df, img_size.max())
    print("y.shape == {}; y.min == {:.3f}; y.max == {:.3f}".format(y.shape, y.min(), y.max()))
    
