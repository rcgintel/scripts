#! /usr/intel/bin/python3.10.8

import sys
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


parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--project", dest="project", default="Nil" , help = "give the project name")
parser.add_option("-N", "--name", dest="name", default="py_terminal", help="give the name of the terminal")
parser.add_option("-B", "--block", dest="block", action="store_false", default=False, help="get all block data")
parser.add_option("-S", "--supers", dest="ssection", action="store", default=False, help="get all supersection data")
(option, args) = parser.parse_args()

def findFile(name, path):
    for root, dirs, files in os.walk(path):
        if name in files:
            return os.path.join(root, name)

######
##### script to start
#print("opening terminal with following options ",cmd)
#os.system(cmd)

config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/getAllDataFromVault/config.ini')

if option.project == "Nil":
	print("please provide a project name")
	sys.exit(0)

if option.name == "Nil":
    blockName == "All"

project = option.project
SuperSection = config[project]["SuperSection"]
Section = config[project]["Section"]
Block = config[project]["Block"]
Override = config[project]["overrideFile"]
Milestone = config[project]["Milestone"]

#vault query -column location -milestone sd1p0 -block gtsc

dataNetlist = {}
if option.ssection:
    for l in SuperSection.split(" "):
        #print(l)
        cmd = "vault query -column location version -milestone "+ Milestone + " -block "+l
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        version = 0
        location = ""
        for line in p.stdout.readlines():
            line = line.decode().strip()
            #print(line)
            result = re.match(r"\| (\/.*)\|(.*)\|", line)
            if "LV" in Milestone :
                filName = l.strip()+".pg.vg.gz"
            else :
                filName = l.strip()+".top.pg.vg.gz"
            if (result):
                #print(result.group(1).strip())
                filName = findFile(filName,result.group(1).strip())
                if filName != None :
                    location = filName
                    if ((version != int(result.group(2).strip())) and (version < int(result.group(2).strip()))):
                        #print(filName,":",result.group(2).strip())
                        dataNetlist[l] = filName+":"+result.group(2).strip()
            else:
                continue
else:
    for l in Section.split(" "):
        #print(l)
        cmd = "vault query -column location version -milestone "+ Milestone + " -block "+l
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        version = 0
        location = ""
        for line in p.stdout.readlines():
            line = line.decode().strip()
            #print(line)
            result = re.match(r"\| (\/.*)\|(.*)\|", line)
            if "LV" in Milestone :
                filName = l.strip()+".pg.vg.gz"
            else :
                filName = l.strip()+".top.pg.vg.gz"

            if (result):
                #print(result.group(1).strip())
                filName = findFile(filName,result.group(1).strip())
                if filName != None :
                    location = filName
                    if ((version != int(result.group(2).strip())) and (version < int(result.group(2).strip()))):
                        #print(filName,":",result.group(2).strip())
                        dataNetlist[l] = filName+":"+result.group(2).strip()
            else:
                continue

for key, value in dataNetlist.items():
    #print(f'{key}: {value}')
    netlist = value.split(":")[0]
    version = value.split(":")[1]
    print(netlist)
    if not "top.pg.vg.gz" in netlist:
        result = re.match(r"(\/.*)(\/.*?).pg.vg.gz",netlist)
        #print("group1::  ",result.group(1))
        filName = os.getcwd()+"/"+result.group(2).strip()+".top.pg.vg.gz"
        #print("group2:: ",filName)
        shutil.copy2(netlist, filName)
    else:
        shutil.copy2(netlist, os.getcwd())

with open('version.txt', 'w') as file:
    json.dump(dataNetlist, file, indent=4)

### copy the override files

overrideDir = os.getcwd()+"/../overrides/"
print(Override,":",overrideDir)
#Override
for t in os.listdir(Override):
    #shutil.copy2(os.path.join(Override,t),overrideDir)
    print (os.path.join(Override,t), " copy to " , os.path.join(overrideDir,t))
    shutil.copy2(os.path.join(Override,t),os.path.join(overrideDir,t))


### 
