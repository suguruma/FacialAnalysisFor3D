# -*- coding: utf-8 -*-

import coordtrans
import stlproc


def main():

    in_fname = "data/R72.stl"
    out_fname = "csv/R72.csv"
    #stlproc.GetVertex(in_fname, out_fname)

    cylinder = coordtrans.CoordinateTransformation()
    csv_name = out_fname
    cylinder.run(csv_name)

if __name__ == "__main__":
     main()
