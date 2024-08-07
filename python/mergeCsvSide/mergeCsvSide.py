import UsrIntel.R1
import pandas as pd
import sqlalchemy as sa
import optparse
import sqlite3
import re
import subprocess
import configparser

import csv


parser = optparse.OptionParser("user arg1")
parser.add_option("-F", "--first", dest="first", default="Nil", help = "give the first csv file location")
parser.add_option("-S", "--second", dest="second", default="Nil", help="give the second file location")
parser.add_option("-O", "--output", dest="output", default="Nil", help="give the output file name")

(option, args) = parser.parse_args()


with open(option.first,'r') as t1, open(option.second,'r') as t2, open(option.output,'w') as output:
 r1 = csv.reader(t1,delimiter=",")
 r2 = csv.reader(t2,delimiter=",")
 w = csv.writer(output,delimiter=",")
 print(r1)
 print(r2)
 #for row in r1:
 # print(row)
 count = 0
 for a,b in zip(r1,r2):
  count += 1
  if count == 10000:
   print(count)
   print(a,b)
   count = 0
  #print(a)
  #print(b)
  w.writerow(a+b)

