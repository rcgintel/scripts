#! /usr/intel/bin/python3.10.8

import sys

sys.path.append('/nfs/site/disks/vmisd_vclp_efficiency/rcg/server/fullServer/venvRcg/lib/python3.11/site-packages')
import UsrIntel.R1
import os
import csv
from sys import stdin
import optparse
import sqlite3
import re
import subprocess
import configparser
import json
import shutil
import pandas as pd
import code

import hashlib

parser = optparse.OptionParser("user arg1")
parser.add_option("-X", "--excel", dest="excel", default="Nil" , help = "give the excel file")
parser.add_option("-S", "--sqilte", dest="sqlite", default="Nil", help="get the sqlite database")
(option, args) = parser.parse_args()

def findFile(name, path):
    for root, dirs, files in os.walk(path):
        if name in files:
            return os.path.join(root, name)




def excel_to_sqlite(excel_file, db_file):
    def create_hash(text):
        # Convert the string to bytes before hashing
        encoded_text = text.encode('utf-8')
        # Create a hash object using SHA-256 algorithm
        hash_object = hashlib.sha256(encoded_text)
        # Get the hexadecimal representation of the hash
        hashed_text = hash_object.hexdigest()
        #hashed_text = base64.b64encode(hash_object.digest())
        return hashed_text

    # Read Excel file into a dictionary of DataFrames, with keys as sheet names
    xls = pd.ExcelFile(excel_file)
    sheet_names = xls.sheet_names
    sheet_names = ["Merged_BI_grip"]
    # Connect to SQLite database
    conn = sqlite3.connect(db_file)
    column = ['hash','instance','sloc','ploc','orient','design','tloc','srcInst','destInst','rowNumber','fromTim','toTim']
    # Iterate over each sheet
    for sheet_name in sheet_names:
        # Read each sheet into a DataFrame
        df = pd.read_excel(xls, sheet_name = "Merged_BI_grip")
        df['rowNumber'] = df.index + 1
        #df = pd.DataFrame(data)
        dfHash = pd.DataFrame(columns=column)
        hashList = []
        # Concatenate 'First Name' and 'Last Name' columns into a single column
        #code.interact(local=locals())
        #for rpts in df[df['grip.RptsPartitions'].notna()].tolist():
        result = df[df['grip.RptsPartitions'].notna()]
        allList = zip(result['grip.RptsPartitions'].tolist(), result['SenderParInst'].tolist(), result['TargetParInst'].tolist(),result['rowNumber'].tolist())
        #for rpts in result['grip.RptsPartitions'].tolist():
        for rpts,senderPar,targetPar,rowNumber in allList:
             count = 0
             length = len(rpts.split("->"))
             senderParT = senderPar
             for rpt in rpts.split("->"):
                  pattern = r"(.*)\((.*?)\)"
                  match = re.search(pattern, rpt)
                  if match:
                    hash = match.group(2)
                    inst = match.group(1)
                    sloc = ""
                    ploc = ""
                    orient = ""
                    des = ""
                    tloc = ""
                    fromTim = ""
                    toTim = ""
                    #srcInst = ""
                    #destInst = ""
                    srcInst = senderParT
                    count +=1
                    if count == length:
                        destInst = targetPar
                    else:
                        destInst = rpts.split("->")[count]
                        pattern = r"(.*)\((.*?)\)"
                        match2 = re.search(pattern, destInst)
                        if match2:
                            destInst = match2.group(2)
                    newData = [hash,inst,sloc,ploc,orient,des,tloc,srcInst,destInst,rowNumber,fromTim,toTim]
                    senderParT = hash
                    hashList.append(newData)
                    print("Data within brackets:", hash , " inst name ", inst)
                  #print(rpt.strip())
        dfHash = pd.DataFrame(hashList, columns=dfHash.columns)
        #df['PreHash'] = df["MO.SenderUnitInst"].astype(str) + ',' + df["MO.SenderBundle"].astype(str) + ',' + df["MO.TargetUnitInst"].astype(str) + ',' + df["MO.TargetBundle"].astype(str)+ ',' + df["rowNumber"].astype(str)
        #df['Hash'] = df['PreHash'].astype(str).apply(create_hash)
        # Write DataFrame to SQLite database with sheet name as table name

        df.to_sql(sheet_name, conn, if_exists='replace', index=False)
        dfHash.to_sql("repeaterHash", conn, if_exists='replace')
    
    # Close connection
    conn.close()
 

#config = configparser.ConfigParser()
#config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/guiRepeaterExtention/config.ini')

if option.excel == "Nil":
	print("please provide a excel name")
	sys.exit(0)

sqliteDatabase = option.sqlite
#SuperSection = config[project]["SuperSection"]
#Section = config[project]["Section"]
#Block = config[project]["Block"]
#Override = config[project]["overrideFile"]
#Milestone = config[project]["Milestone"]

print("excelFile ",option.excel," sqlite database ",option.sqlite)



excel_file = option.excel 
db_file = option.sqlite 


excel_to_sqlite(excel_file, db_file)

### completed generating the database





