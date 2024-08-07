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
import allProcs
import json
import code
import datetime
import hashlib
import shutil
import stat

parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--project", dest="project", default="Nil" , help = "give the project name")
parser.add_option("-B", "--block", dest="block", default="Nil" , help = "give the block name")
parser.add_option("-V", "--validity", dest="validity", default=3 , type = int, help = "give the eco validity in days")
parser.add_option("-E", "--eco", dest="eco", default="Nil", help = "give the eco file name")
#parser.add_option("-R", "--repo", dest="repo", default="Nil", help = "give the ndm location or tag on which the ECO is generated")
(option, args) = parser.parse_args()

##### script to start
#print("opening terminal with following options ",cmd)
#os.system(cmd)


config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/releaseVclpEco/config.ini')
project = option.project
inputEco = config[project]["ecoLocation"]
outputEco = config[project]["completedEco"]
databaseLocation = config[project]["databaseLoc"]
blockNames = config[project]["blockNames"]
userJson = config[project]["userDetails"]

#####

##### get the default values
if option.validity == "Nil":
    validityTime = config[project]["defaultECOValidDays"]
else:
    validityTime = option.validity
###
if option.block == "Nil":
    print("ERROR: give a block name")
    sys.exit(1)

if option.block not in blockNames.split(","):
    print("ERROR: not a valid block name")
    print("valid block names are "+blockNames)
    sys.exit(1)
###
if option.eco == "Nil":
    print("ERROR: Give the ECO file name")
    sys.exit(1)

if not os.path.exists(option.eco):
    print("ERROR: file name",option.eco," does not exists")
    sys.exit(1)
###

#valutInfo = input("what is the repo location?:")

#print(env)

allProcs.createDatabase(databaseLocation)

####
tableName = "users"
#code.interact(local=locals())
with open(userJson, 'r') as file:
    userData = json.load(file)

### call the proc to delete the users table
allProcs.removeTable(databaseLocation,"users")

for user in userData:
    data = tuple(userData[user].values())
    allProcs.setupUserTable(databaseLocation,tableName,data)
#### we need to insert the data into database location

##### get the date and time information
currentDateTime = datetime.datetime.now().strftime("%d/%m/%Y %H:%M")
##### get the user name
currentUser = os.getlogin()
##### get the hash values
hashValue = allProcs.getFileHash(option.eco)
##### get the user team name
dataNeeded = "userTeam"
condition = "userName = \""+currentUser+"\""
#code.interact(local=locals())
teamName = allProcs.getDataFromTable(databaseLocation,tableName,dataNeeded,condition)
print("user in team "+str(teamName))

### check if same filename ECO is previously released
tableName = "ECOTracker"
dataNeeded = "ecoFileName"
condition = "ecoFileName like \"%"+os.path.basename(option.eco)+"%\" and blockName = \""+option.block+"\""
#code.interact(local=locals())
preExistingEco = allProcs.getDataFromTable(databaseLocation,tableName,dataNeeded,condition)
if preExistingEco != "":
    print("ERROR: ECO filename already released please change the ECO file")
    sys.exit(1)

### check if the same ECO is released in different file name
tableName = "ECOTracker"
dataNeeded = "hash"
condition = "hash = \""+str(hashValue)+"\""
#code.interact(local=locals())
preExistingEco = allProcs.getDataFromTable(databaseLocation,tableName,dataNeeded,condition)
dataNeeded = "ecoFileName"
preExistingEcoFile = allProcs.getDataFromTable(databaseLocation,tableName,dataNeeded,condition)

if preExistingEco != "":
    print("ERROR: ECO contents is same as "+preExistingEcoFile+" please check the ECO file")
    sys.exit(1)

##### processing the data
print("copying the ECO file to release location")
print("checking if the directory structure exists")
dirPath = inputEco +"/"+option.block
if not os.path.isdir(dirPath):
    os.makedirs(dirPath)
    fullPermission = stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO
    os.chmod(dirPath, fullPermission)

shutil.copy(option.eco,dirPath)
fileName = os.path.basename(option.eco)
newFileName = dirPath+"/"+fileName
fullPermission = stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO
os.chmod(newFileName, fullPermission)
#inputEco
#code.interact(local=locals())

tableName = "ECOTracker"
newFileName = newFileName.split("/")[-1]
data = (option.block,newFileName,str(teamName),validityTime,"nil",currentDateTime,hashValue,currentUser)
allProcs.insertEcoData(databaseLocation,tableName,data)


