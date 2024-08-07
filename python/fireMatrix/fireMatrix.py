#! /usr/intel/bin/python3.6.3a

import UsrIntel.R1
import sys
import os
import optparse
import re
import pandas as pd
import numpy as np
import openpyxl

#### opt declaration 

parser = optparse.OptionParser("user arg1")
parser.add_option("-F", "--file", dest="file", default="False", help = "give the matrix file as input")
(option, args) = parser.parse_args()

##### script to start
print("using matrix file :",option.file)
csvFile = option.file
df1 = pd.read_csv(csvFile)
#print(df1)
for item in df1.columns[1:]:
    df2 = (df1[['Matrix',item]])
    print(df2)
    #for i in range(len(df2)):
    #    print(df2.iloc[i])
    #    print("###")
