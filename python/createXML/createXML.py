#! /usr/intel/bin/python3.6.3a 

import sys
import os
import UsrIntel.R1
import csv
from sys import stdin
import optparse
import sqlite3
import re
import subprocess
import configparser


parser = optparse.OptionParser("user arg1")
parser.add_option("-F", "--file", dest="files", default="Nil" , help = "give the connectivity_power file name")
(option, args) = parser.parse_args()

if option.files == "Nil":
	print("please provide the file path use -help")
	sys.exit(0)

con = sqlite3.connect("data.db")
cur = con.cursor()
a_file = open(option.files)
rows = csv.reader(a_file)

print(rows)
#cur.execute(''' create table if not exists data ([id] INTEGER PRIMARY KEY, [targetInstance] TEXT, [targetPort] TEXT, [targetPortDir] TEXT, [targetPower] TEXT ,[driverInstance] TEXT, [driverPort] TEXT, [driverPortDir[ TEXT, [driverPower] TEXT)''')

cur.executemany('''INSERT INTO data3 (targetInstance, targetPort, targetPortDir, targetPower, driverInstance, driverPort, driverPortDir, driverPower) VALUES (?,?,?,?,?,?,?,?)''', rows)
#cur.execute("SELECT * FROM data")
#print(cur.fetchall())
con.commit()
