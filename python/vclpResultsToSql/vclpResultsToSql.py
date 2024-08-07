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


def read_file(file_name):
  try:
    file = open(file_name,"r")
    str_file = file.readlines()
    file.close()
  except IOError:
    print ("file ", file ,"dosent exist")
  return str_file

def write_file (out_file, information):
  out_file = open(out_file, "a")
  out_file.write (information)
  out_file.write ("\n")
  out_file.close()

def createConnection(db_file):
    """ create a database connection to the SQLite database
        specified by db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
    except Error as e:
        print(e)

    return conn

def insertData(conn, task, table):



    sql = ''' INSERT INTO '''+table+'''(runLocation,blockName,violationCount,waivedCount,checksViolation,comments,projectName,violationStage,violationName)
              VALUES(?,?,?,?,?,?,?,?,?) '''
    cur = conn.cursor()
    cur.execute(sql, task)
    conn.commit()

    return cur.lastrowid

def insertBlockSummary(projectSqlLocation,table,data):
    conn = createConnection(projectSqlLocation)

    with conn:
        sql = ''' INSERT INTO '''+table+'''(blockName,violationCount,color,numberOfEco,projectName) VALUES(?,?,?,?,?) '''
        cur = conn.cursor()
        cur.execute(sql, data)
        conn.commit()
        return cur.lastrowid

def insertBlockDetails(projectSqlLocation,table,data):
    conn = createConnection(projectSqlLocation)

    with conn:

        sql = ''' INSERT INTO '''+table+'''(blockName,violationName,runLocation,projectName) VALUES(?,?,?,?) '''
        cur = conn.cursor()
        cur.execute(sql, data)
        conn.commit()
        return cur.lastrowid

parser = optparse.OptionParser("user arg1")
#parser.add_option("-B", "--block", dest="block", default="Nil" , help = "give the block name")
parser.add_option("-P", "--project", dest="project", default="Nil", help="give the name of the project")
(option, args) = parser.parse_args()

##### script to start
#print("opening terminal with following options ",cmd)
#os.system(cmd)

config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/vclpResultsToSql/config.ini')
project = option.project
projectSqlLocation = config[project]["sqlLocation"]
projectSqlTable = config[project]["sqlTable"]
blocks = config[project]["blockName"]
flag = 0
flagCheck = 0

if option.project == "Nil":
	print("please provide a project name")
	sys.exit(0)

#if option.block == "Nil":
#    print("Please provide the block name")
#    sys.exit(0)


print("get the violations for the blocks")
conn = createConnection(projectSqlLocation)

with conn:
    print(blocks)
    sql = "delete from "+config[project]["sqlTableDetail"]
    cur = conn.cursor()
    cur.execute(sql)
    sql = "delete from "+config[project]["sqlTable"]
    cur = conn.cursor()
    cur.execute(sql)

    for block in blocks.split(","):
        cwd = os.getcwd()
        #fileName = cwd+"/"+block+".check_lp.rpt"
        fileName = cwd+"/00_verify_upf/"+block+"/work/"+block+".check_lp.rpt"
        if (os.path.exists(fileName)):
            lines = read_file(fileName)

            for line in lines:

                #print(line)
                pat = "\s+(error|warning)\s+(UPF|PG|Design)\s+(.*?)\s+(\d+?)\s+(\d+).*"
                if (re.match(pat,line)):
                    datas = re.match(pat,line)
                    line = line.strip()
                    #print(line)
                    data = (cwd.split("/")[-1],block,datas.groups()[3],datas.groups()[4],"checkViolations","comments",option.project,datas.groups()[1],datas.groups()[2])
                    print(data)
                    insertData(conn,data,projectSqlTable)

                pat = "\s+Total\s+(\d+)\s+(\d+)$"
                if (re.match(pat,line)):
                    datas = re.match(pat,line)
                    print("For a block "+block+" Total number of violations = ",datas.groups()[0])
                    violationCount = datas.groups()[0]
                    color = "MediumSeaGreen"
                    #if (violationCount > 0):
                    #    color = "Red"
                    numberOfEco = 0
                    data = (block,violationCount,color,numberOfEco,option.project)
                    projectSqlTableSummary = config[project]["sqlTableSummary"]
                    insertBlockSummary(projectSqlLocation,projectSqlTableSummary,data)
                    flag = 1

                if flag==1:
                    line = line.strip()
                    #print(line)
                    pat = "(.*)\(\d+ error.*"
                    if (re.match(pat,line)):
                        datas = re.match(pat,line)
                        print(datas.groups()[0])
                        flagCheck = 1
                        vioName = datas.groups()[0]

                    if flagCheck==1:
                        pat = "\d+..*"
                        if (re.match(pat,line)):
                            print(vioName ," : ", line)
                            data = (block,vioName,line,option.project)
                            projectSqlTableDetail = config[project]["sqlTableDetail"]
                            insertBlockDetails(projectSqlLocation,projectSqlTableDetail,data)
