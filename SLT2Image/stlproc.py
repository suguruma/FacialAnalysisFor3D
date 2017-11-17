import numpy as np
import matplotlib
matplotlib.use('Qt5Agg')
matplotlib.use('Agg')
#from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt

import stl
print ('stl file', stl.__file__)
from stl import mesh
print ('mesh file', mesh.__file__)
from mpl_toolkits import mplot3d

#import math
#from stl_tools import numpy2stl
import pandas as pd

def DrawSTL(filename):

    # Create a new plot
    figure = plt.figure()
    axes = mplot3d.Axes3D(figure)

    # Load the STL files and add the vectors to the plot
    your_mesh = mesh.Mesh.from_file(filename)
    axes.add_collection3d(mplot3d.art3d.Poly3DCollection(your_mesh.vectors))

    # Auto scale to the mesh size
    scale = your_mesh.points.flatten(-1)
    axes.auto_scale_xyz(scale, scale, scale)

    # Show the plot to the screen
    plt.show()

def GetVertex(src_fname, dst_fname):
    input_mesh = mesh.Mesh.from_file(src_fname)
    points_vec = np.array(input_mesh.vectors).reshape(len(input_mesh.vectors)*3, 3) #face = 3, xyz = 3
    df = pd.DataFrame(points_vec, columns=["x","y","z"])
    unique_df = df.drop_duplicates()
    unique_df.to_csv(dst_fname, index=None)
    #unique_points = np.array(unique_df.values)

    print(unique_df)


if __name__ == '__main__':
    DrawSTL("data/R72.stl")
    GetVertex("data/R72.stl", "csv/R72.csv")