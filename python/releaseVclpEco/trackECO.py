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
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--project", dest="project", default="Nil" , help = "give the project name")
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
blockOwner = config[project]["blockDetails"]

tableName = "ECOTracker"
data = "blockName,ecoFileName,status,hash,ecoOwner"
data = "*"
condition = "status == \"running\""
with open(blockOwner, 'r') as file:
    userData = json.load(file)

filename = 'msg.txt'
if os.path.exists(filename):
    os.remove(filename)

mailId = ""
# Write data to file in JSON format
with open(filename, 'w') as file:
    data = "ECO Message \n"
    file.write(data)
    data = "please run the below commands to get the ECO status for project "+project+" in Fusion Compiler\n \
    source /nfs/site/disks/vmisd_vclp_efficiency/forall/rcgProcs.tbc;\n \
    if {[get_app_var in_gui_session]} {\nECOTrackerGUI\n}\n \
    click on showEco and select the ECO that needs to be sourced and commitECO this will dump eco.tcl file use the file as is\n\n"
    file.write(data)
    data = "*"
    #code.interact(local=locals())
    fullData = allProcs.getMultiDataFromTable(databaseLocation,tableName,data)
    blkName = ""
    ECOCount = 0
    for data in fullData:
        if not blkName == data[1]:
            blkName = data[1]
            ECOCount = 1

            file.write("\n##########################################")
            #code.interact(local=locals())
            #mailId = mailId 
            owner = userData[data[1]]['owner'].replace(":", " ")
            file.write("\nBlock Name : "+data[1]+" Block Owner : "+owner+"\n\n")
            #file.write("ECOFile\tECOTeam\tStatus\tSubmit Time\tECO Owner\n")

        #file.write(data[2]+",\t"+data[3]+",\t"+data[6]+",\t"+data[8]+",\t"+data[11]+"\n")
        if not data[6] == "loaded":
            file.write(str(ECOCount)+". ECO File : "+data[2]+"\n\n")
            file.write("\ta. ECO Team : "+data[3]+"\n")
            file.write("\tb. Status : "+data[6]+"\n")
            file.write("\tc. Date generated : "+data[8]+"\n")
            file.write("\td. ECO Owner : "+data[11]+"\n\n\n")
            ECOCount += 1
            mailId = mailId +" "+ owner
    mailId = mailId.strip()

#code.interact(local=locals())

allProcs.send_mail(
    subject='ECOTracker Details for project',
    recipients=mailId.split(" "),
    body_file_path='msg.txt'
)

