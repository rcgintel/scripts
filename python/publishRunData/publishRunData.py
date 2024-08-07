#! /usr/intel/bin/python3.6.3a 

import sys
import os
import UsrIntel.R1
import csv
import optparse
import sqlite3
import re
import subprocess
import json
import mysql.connector


parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--path", dest="path", default="nil", help = "give the path to the json file")
(option, args) = parser.parse_args()

if (option.path == "nil"):
	sys.exit(1)

stages = ["place:/10_pre_cts/020_prects_opt/rpts/metrics.summary.rpt.new.json"]
for stage in stages:
	path = option.path + stage.split(":")[1]
	jsonFile = open(path)
	data = json.load(jsonFile)

	print("stage:",stage.split(":")[0],"->",data["info"]["Design"]["data"])



#db = mysql.connector.connect(host="scysql39.sc.intel.com", user="rcg", passwd ="rcg", db="rcg", port=3306)
#
#mycursor = db.cursor()
#
#mycursor.execute("use rcg")
#
#cmd = "show tables like 'cells'"
#mycursor.execute(cmd)
#results = mycursor.fetchone()
#if results:
#  print("table exists")
#  cmd = "drop table cells"
#  mycursor.execute(cmd)
#else:
#  print("table not present")
#  mycursor.execute("CREATE TABLE  (id int PRIMARY KEY AUTO_INCREMENT, datetime DATETIME NOT NULL, block_name VARCHAR(200))")
#


