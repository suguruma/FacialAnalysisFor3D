# -*- coding: utf-8 -*-

import numpy as np
import matplotlib
matplotlib.use('Qt5Agg')
import matplotlib.pyplot as plt
#from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D
#import seaborn as sns

import warnings
warnings.simplefilter("ignore")

import csv
#import gr
import cv2
import copy
from scipy import ndimage
from collections import deque

MAX_VALUE = 255

class CoordinateTransformation(object):

    def __init__(self):

        self.horizontal_num = 360
        self.vertical_num = 400
        self.theta_num = 360
        self.theta_max = 180

    def Rectangle2Cylinder(self, np_data):

        x = np_data[:,0]
        y = np_data[:,1]
        z = np_data[:,2]

        radius = np.sqrt(x * x + y * y)
        theta = np.arctan2(y, x) * (180 / np.pi)

        #conv_data = [[None for i in range(3)] for j in range(len(np_data))]
        conv_data = [radius, theta, z]

        return conv_data

    def NormalizationRTZ(self, np_data):

        # normalize radius : 0 ~ 255
        radius_arr = np_data[:,0]
        radius_min = radius_arr.min()
        radius_max = radius_arr.max()
        radius_norm = ((radius_arr - radius_min).astype(float) / (radius_max - radius_min).astype(float) * MAX_VALUE).astype(int)

        # normalize theta : 0 ~ 360
        theta_arr = np_data[:,1]
        theta_min = theta_arr.min()
        theta_max = theta_arr.max()
        theta_norm = ((theta_arr - theta_min).astype(float) / (theta_max - theta_min).astype(float) * self.horizontal_num).astype(int)

        # normalize z : 0 ~ 400
        z_arr = np_data[:,2]
        z_min = z_arr.min()
        z_max = z_arr.max()
        z_norm = ((z_arr - z_min).astype(float) / (z_max - z_min).astype(float) * self.vertical_num).astype(int)

        return (radius_norm, theta_norm, z_norm)

    def DrawCylindicalPoints(self, np_data):

        fig = plt.figure()
        ax = Axes3D(fig)
        ax.scatter(np_data[:,1], np_data[:,0], np_data[:,2])
        ax.set_xlabel("x:horizontal angle")
        ax.set_ylabel("y:value")
        ax.set_zlabel("z:vertical angle")
        ax.set_xlim3d(self.horizontal_num, 0) # + -
        ax.set_ylim3d(MAX_VALUE, 0) # + -
        ax.set_zlim3d(0, self.vertical_num) # - +
        ax.grid(True)

    def CylindericalCoordinateSystem(self, data):

        ### cylinderical coordinate system
        conv_data = self.Rectangle2Cylinder(data)
        np_conv_data = np.array(conv_data).T

        ### delete theta : 0 ~ 180 (x is frontal face but side face : -90 ~ 90)
        np_conv_data = np.delete(np_conv_data, np.where((np_conv_data[:,1] > 180) | (np_conv_data[:,1] < 0)), 0)

        ### normalize data
        norm_data = self.NormalizationRTZ(np_conv_data)
        norm_conv_data = np.array(norm_data).T
        self.DrawCylindicalPoints(norm_conv_data)
        plt.pause(0.01)

        ### sampling converted data
        img = np.zeros((self.vertical_num, self.horizontal_num), dtype='uint8')

        for i in range(len(norm_conv_data)):
            x = norm_conv_data[i][1]
            y = norm_conv_data[i][2]
            if self.horizontal_num <= x:
                x = self.horizontal_num - 1
            if self.vertical_num <= y:
                y = self.vertical_num - 1
            if x != 0 and y != 0:
                img[y,x] = copy.copy(norm_conv_data[i][0])

        ### O(0,0)TopLeft to BottomRight
        img_rot = ndimage.rotate(img, 180, reshape=False)
        cv2.imshow("2D image display", img_rot)
        cv2.waitKey(0)

    def DisplaySamplingPointsXZ(self, np_data):

        x_arr = np_data[:, 0]
        y_arr = np_data[:, 1]
        z_arr = np_data[:, 2]

        # normalize x : 0 ~ 360 - 1
        x_min = x_arr.min()
        x_max = x_arr.max()
        x_norm = ((x_arr - x_min).astype(float) / (x_max - x_min).astype(float) * (self.horizontal_num-1)).astype(int)

        # normalize z : 0 ~ 400 - 1
        z_min = z_arr.min()
        z_max = z_arr.max()
        z_norm = ((z_arr - z_min).astype(float) / (z_max - z_min).astype(float) * (self.vertical_num-1)).astype(int)

        # normalize y : 0 ~ 255
        y_min = y_arr.min()
        y_max = y_arr.max()
        y_norm = ((y_arr - y_min).astype(float) / (y_max - y_min).astype(float) * (255)).astype(int)

        ### sampling converted data
        img = np.zeros((self.vertical_num, self.horizontal_num), dtype='uint8')
        for i in range(len(np_data)):
            x = x_norm[i]
            y = z_norm[i]
            if self.horizontal_num <= x:
                x = self.horizontal_num - 1
            if self.vertical_num <= y:
                y = self.vertical_num - 1
            img[y,x] = copy.copy(y_norm[i])

        ### O(0,0)TopLeft to BottomRight
        img_rot = ndimage.rotate(img, 180, reshape=False)
        cv2.imshow("2D image display", img_rot)
        cv2.waitKey(0)

    ##### Main #####
    def Read3DCSV(self, in_fname, r1, r2, r3):
        reader = csv.reader(open(in_fname, 'r'))
        header = next(reader)
        num_lines = np.sum(1 for line in open(in_fname, 'r')) - 1
        org_data = [[None for i in range(3)] for j in range(num_lines)]
        line_counter = 0

        # right hand & z-up
        for row in reader:
            x = float(row[r1]) # x
            y = float(row[r2]) # z->y
            z = float(row[r3]) # y->z
            org_data[line_counter] = [x, y, z]
            line_counter += 1

        return np.array(org_data)

    def CutXYZDistance(self, data, threshold):

        x = data[:, 0]
        y = data[:, 1]
        z = data[:, 2]

        y_max = np.array(y).max()

        distance = np.sqrt(x * x + (y - y_max) * (y - y_max) + z * z)
        bool_flag = distance < threshold
        return data[bool_flag]

    def RandomChoice(self, data, num):
        idx = np.random.choice(len(data), num, replace=False)
        rc_data = data[idx,:]

        return rc_data

    def DrawRectaglerPoints(self, np_data):

        fig = plt.figure()
        ax = Axes3D(fig)
        ax.set_xlabel("x:frontal face")
        ax.set_ylabel("y:side face")
        ax.set_zlabel("z:vertical angle")
        ax.set_xlim3d(150, -150) # + -
        ax.set_ylim3d(150, -150) # + -
        ax.set_zlim3d(-150, 150) # - +
        #ax.axis([150, -150, -150, 150])
        ax.scatter3D(np_data[:,0], np_data[:,1], np_data[:,2])
        ax.grid(True)
        #ax.plot_surface(0, 0, 400, rstride=1, cstride=1, cmap=cm.coolwarm)

        plt.show()

    def VerticalSampling(self, data):

        x = data[:, 0]
        y = data[:, 1]
        z = data[:, 2]

        # normalize z : 0 ~ 400
        z_min = z.min()
        z_max = z.max()
        z_norm = ((z - z_min).astype(float) / (z_max - z_min).astype(float) * (self.vertical_num - 1)).astype(int)
        z_sampling = [deque([]) for j in range(self.vertical_num)]

        for i in range(len(z_norm)):
            z_sampling[z_norm[i]].append([x[i], y[i]])

        return np.array(z_sampling)

    def NormalVectorDistance(self, x, y, theta):
        #ax + by + c = 0
        a = np.tan(theta)
        b = -1
        c = 0
        d = np.abs(a * x + b * y + c) / np.sqrt(a*a + b*b)
        return d

    def PointsDistance(self, d, d_err ,x, y):

        distance = 0
        for i in range(len(d)):
            if (d[i] < d_err):
                distance = np.sqrt(x[i] * x[i] + y[i] * y[i])
                #print("Find point:No.{0}  Distance:{1}".format(i, distance))

        return distance

    def ThetaLine(self, x, theta):
        y = x * np.tan(theta)
        return (y)

    def DisplayThetaLine(self, x, y, radian, xlim_num, ylim_num, wait_time):

        plt.scatter(x, y)
        plt.scatter(0, 0)

        x_line_range = np.arange(xlim_num * -1, xlim_num)
        y_line_range = self.ThetaLine(x_line_range, radian)
        plt.plot(x_line_range, y_line_range)

        plt.xlim(xlim_num * -1, xlim_num)
        plt.ylim(ylim_num * -1, ylim_num)
        plt.pause(wait_time)
        plt.clf()

    def MeanComplementation(self, radius):

        idx_flag = True
        idx_start = 0
        idx_end = 0
        range_num = 0
        for i in range(len(radius)):
            # 0 or other number
            if radius[i] == 0:
                range_num += 1
            else:
                idx_start = idx_end
                idx_end = i

                # only first number
                if (idx_flag):
                    range_num = 0
                    idx_flag = False

            # start complementation
            if range_num > 0 and radius[i] > 0:

                # calc mean value
                phi_average = ((radius[idx_start] + radius[idx_end]) / 2)
                for k in range(range_num):
                    radius[i - k - 1] = phi_average
                range_num = 0
            # end complementation

        return np.array(radius)


    def run(self, in_fname):

        ### read data
        points_data = self.Read3DCSV(in_fname, 0, 2, 1)

        ### faical data
        points_data = self.CutXYZDistance(points_data, 120)

        ### random choice data
        #points_data = self.RandomChoice(points_data, 5000)

        ### display rectangler points
        #self.DrawRectaglerPoints(points_data)
        #self.CylindericalCoordinateSystem(points_data)
        self.DisplaySamplingPointsXZ(points_data)

        ### vertical sampling data
        v_sampling_data = self.VerticalSampling(points_data)

        ### define
        sampling_2D = [[] for j in range(self.vertical_num)]
        theta_plus = self.theta_max / self.theta_num

        for i in range(self.vertical_num):
            x_list = deque([])
            y_list = deque([])
            for j in range(len(v_sampling_data[i])):
                x_list.append(v_sampling_data[i][j][0])
                y_list.append(v_sampling_data[i][j][1])

            radius = [None for j in range(self.theta_num)]
            counter = 0
            theta = 0

            x_arr = np.array(x_list)
            y_arr = np.array(y_list)

            while (True):

                ## calc NormalVector Distance
                radian = theta / (180 / np.pi)
                d_arr = self.NormalVectorDistance(x_arr, y_arr, radian)

                ## calc XY Points Distance
                distance = self.PointsDistance(d_arr, 0.3, x_arr, y_arr)

                # display current value (animation)
                #self.DisplayThetaLine(x_arr, y_arr, radian, 100, 100, 0.001)

                # input value
                if radius[counter] == None:
                    radius[counter] = distance
                elif radius[counter] < distance:
                    radius[counter] = distance

                # next value
                counter += 1
                if counter >= len(radius) or theta >= self.theta_max:
                    break
                theta += theta_plus

            ### end while
            #plt.plot(np.arange(len(radius)), radius)
            sampling_2D[i] = self.MeanComplementation(radius)
            plt.title("Z:{0}".format(i))
            plt.scatter(x_arr, y_arr)
            #plt.plot(np.arange(len(sampling_2D[i])), sampling_2D[i])
            plt.xlim(-200, 200)
            plt.ylim(-200, 200)
            plt.pause(0.001)
            plt.clf()

        ### end for (i)
        sampling_2D_arr = np.array(sampling_2D)

        ### sampling converted data
        img = np.zeros((self.vertical_num, self.horizontal_num), dtype='uint8')

        ### convert to image
        for y in range(self.vertical_num):
            for x in range(self.horizontal_num):
                if self.horizontal_num <= x:
                    x = self.horizontal_num - 1
                if self.vertical_num <= y:
                    y = self.vertical_num - 1
                if x != 0 and y != 0:
                    img[y,x] = copy.copy(sampling_2D_arr[y][x])

        val_max = img.max()
        val_min = img.min()
        norm_img = (img - val_min) * (val_max - val_min) * 255

        img_rot = ndimage.rotate(norm_img, 180, reshape=False)
        cv2.imshow("2Dimage", img_rot)
        cv2.waitKey(0)

if __name__ == "__main__":
    CoordinateTransformation = CoordinateTransformation()
    CoordinateTransformation.run()