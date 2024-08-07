#! /usr/intel/bin/python3.6.3a

import UsrIntel.R1
import pandas as pd
import sqlalchemy as sa
import optparse
import sqlite3
import re
import subprocess
import configparser
import sys

parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--project", dest="project", default="Nil", help = "give the project name")
parser.add_option("-C", "--sql", dest="sql", default="Nil", help = "give the sql location")

(option, args) = parser.parse_args()

pd.options.display.max_rows
pd.set_option('display.max_colwidth', -1)


if option.sql == "Nil":
	print("Please give the sql file location")
	sys.exit()

print("reading the sql and dumping the table")

config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/generateXML/config2.inf')
project = option.project
Drivers = config[project]["Driver"].split(",")
Destinations = config[project]["Destination"].split(",")
Throughs = config[project]["Through"].split(",")

df = pd.read_csv(option.sql)
load = "gen12p93dl2"
driver =  df[df["load"] == load]
#print(driver[['driver','load']])
removeDuplicates = driver.drop_duplicates(subset=['driver', 'load'])
#removeDuplicates = driver
#print(removeDuplicates[["driver","outPin","outSupply","load","inPin","inSupply"]].to_string())
print(removeDuplicates[["driver","outSupply","load","inSupply"]].to_string())

for Driver in zip(Drivers):
 print("\n\n\n############################Path from : ",Driver," > to >""##################################\n")




driver =  df[df["driver"] == load]
#print(driver[['driver','load']])
removeDuplicates = driver.drop_duplicates(subset=['driver', 'load'])
#removeDuplicates = driver
#print(removeDuplicates[["driver","outSupply","load","inSupply"]].to_string())
#print(removeDuplicates[["driver","outPin","outSupply","load","inPin","inSupply"]].to_string())
print(removeDuplicates[["driver","outSupply","load","inSupply"]].to_string())


for Driver in zip(Drivers):
 print("\n\n\n############################Path from : ",Driver," > to >""##################################\n")

# driver =  df[df["load"] == Driver]
# #print(driver[['driver','load']])
# removeDuplicates = driver.drop_duplicates(subset=['driver', 'load'])
# print(removeDuplicates[["driver","load"]].to_string())


