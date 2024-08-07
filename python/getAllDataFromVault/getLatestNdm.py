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
import code
import subprocess

def findFile(name, path):
    #code.interact(local=locals())
    for root, dirs, files in os.walk(path):
        if name in dirs:
            return os.path.join(root, name)


config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/getAllDataFromVault/config.ini')

rcg_project_name = str(os.environ.get('rcgProjectName'))
blocks = config[rcg_project_name]["Block"]
Milestone = config[rcg_project_name]["BlockMilestone"]
Tag = config[rcg_project_name]["Tag"]

#breakpoint()
dataNetlist = {}
for block in blocks.split(" "):
    print ("working on block ", block)
    if Tag != "":
        cmd = "vault query -column location version -milestone "+ Milestone + " -block "+block+" -tag "+Tag
    else :
        cmd = "vault query -column location version -milestone "+ Milestone + " -block "+block
    print (cmd)
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    version = 0
    location = ""
    for line in p.stdout.readlines():
        line = line.decode().strip()
        result = re.match(r"\| (\/.*)\|(.*)\|", line)
        if "LV" in Milestone :
            filName = block.strip()+".pg.vg.gz"
        else :
            filName = block.strip()+".spyglass_splitbus.pg.vg.gz"
            filName = block.strip()+".ndm"
        if (result):
            filName = findFile(filName,result.group(1).strip())

            #code.interact(local=locals())
            if filName != None :
                location = filName
                #print(location)
                if ((version != int(result.group(2).strip())) and (version < int(result.group(2).strip()))):
                    dataNetlist[block] = filName+":"+result.group(2).strip()
                    version = int(result.group(2).strip())
                    print(dataNetlist[block])
        else:
            continue

for key, value in dataNetlist.items():
    netlist = value.split(":")[0]
    version = value.split(":")[1]
    print(netlist)
    print(version)
    dest = os.getcwd()
    dest_path = os.path.join(dest, os.path.basename(netlist))
    shutil.copytree(netlist, dest_path)

with open('version.txt', 'w') as file:
    json.dump(dataNetlist, file, indent=4)

