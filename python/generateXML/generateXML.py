#! /usr/intel/bin/python3.6.3a

import UsrIntel.R1
import pandas as pd
import sqlalchemy as sa
import optparse
import sqlite3
import re
import subprocess
import configparser


parser = optparse.OptionParser("user arg1")
parser.add_option("-S", "--sql", dest="sql", default="Nil", help = "give the sql location")
parser.add_option("-T", "--table", dest="table", default="Nil", help="give the table name")
parser.add_option("-P", "--project", dest="project", default="Nil", help="give the project name")

(option, args) = parser.parse_args()


if option.sql == "Nil":
	print("Please give the sql file location")
	sys.exit()

if option.table == "Nil":
	print("Please give the table location")
	sys.exit()

print("reading the sql and dumping the table")

config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/generateXML/config.inf')
project = option.project
Drivers = config[project]["Driver"].split(",")
Destinations = config[project]["Destination"].split(",")
Throughs = config[project]["Through"].split(",")


conn = sqlite3.connect(option.sql)
curr = conn.cursor()
fetchData = "SELECT distinct Driver_Instance,Target_Instance from "+option.table
#curr.execute(fetchData)
#answer = curr.fetchall()
#for data in answer:
#    print(data)

pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)
pd.set_option('display.width', 1000)
pd.set_option('display.height', 1000)
pd.set_option('display.max_colwidth',200)

for (Driver,Destination,Through) in zip(Drivers, Destinations, Throughs):
 print("\n\n\n############################Path from : ",Driver," > to > ",Destination,"##################################\n")
 #print(Destination)
 if Destination=="\"*\"":
  Driver = Driver[1:-1]
  fetchData = "SELECT distinct Driver_Instance,Target_Instance,Driver_Power,Target_Power from "+option.table+" where Driver_Instance like \"%"+Driver+"%\""
 elif Driver=="\"*\"":
  Destination = Destination[1:-1]
  fetchData = "SELECT distinct Driver_Instance,Target_Instance,Driver_Power,Target_Power from "+option.table+" where Target_Instance like \"%"+Destination+"%\""
 else:
  Driver = Driver[1:-1]
  Destination = Destination[1:-1]
  fetchData = "SELECT distinct Driver_Instance,Target_Instance,Driver_Power,Target_Power from "+option.table+" where Target_Instance like %"+Destination+"% and Driver_Instance like %"+Driver+"%"
 print(fetchData)
 curr.execute(fetchData)
 answer = curr.fetchall()
 print("\n\nall the paths have to go through ", Through)
 for data in answer:
     print(data)
 print("\n\n")
 df = pd.DataFrame(answer, columns=['Driver_Instance', 'Target_Instance', 'Driver_Power', 'Target_Power'])
 df["equalSupplies"] = (df['Driver_Power']==df['Target_Power'])
 dfCorrected = df[df["equalSupplies"]==False]
 dfCorrected["equalSupplies"] = Through
 print(dfCorrected)
 print ("\n\nFT should go through : ",Through)
 print("\n##################################################################################################################\n")
  


