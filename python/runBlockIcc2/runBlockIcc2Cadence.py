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
import shutil
import time

parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--project", dest="project", default="Nil" , help = "give the project name")
parser.add_option("-M", "--memory", dest="memory", default="32", help = "give the ammount of memory you need")
parser.add_option("-C", "--cores", dest="cores", default="1", help="give the numbr of cores that you need default 1")
parser.add_option("-N", "--name", dest="name", default="py_terminal", help="give the name of the terminal")
parser.add_option("-T", "--tcl", dest="tcl", default="nil", help="give the tcl file to execute in terminal")
parser.add_option("-B", "--block", dest="block", default="all", help="give the tcl file to execute in terminal")
parser.add_option("-L", "--location", dest="location", default="nil", help="give ndm location directory")
parser.add_option("-S", "--toolName", dest="toolName", default="S", help="give the tool name if it is cadence or synopsys")
(option, args) = parser.parse_args()

##### script to start
#print("opening terminal with following options ",cmd)
#os.system(cmd)

config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/getTerminal/config.ini')
project = option.project
env = config[project]["gtEnv"]
wash = config[project]["wash"]
target = config[project]["target"]
Cores = config[project]["Cores"]
qslot = config[project]["qslot"]
clas = config[project]["clas"]
if option.project == "Nil":
	print("please provide a project name")
	sys.exit(0)

config2 = configparser.ConfigParser()
config2.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/runBlockIcc2/config.ini')


#print("opening terminal with following options ",cmd)
if option.block == "all":
  print("firing for all the blocks")
  blocks = config2[project]["blockName"].split(",")
else:
  blocks = option.block.split(",")

print("blocks:",blocks)

count = 0
for block in blocks:
    count += 1
    if count > int(config2[project]["numberJobFire"]):
        count = 0
        time.sleep(int(config2[project]["waitTime"]))
    if os.path.exists(block):
        shutil.rmtree(block)
    os.mkdir(block)
    cwd = os.getcwd()
    blockPath = cwd +"/"+block
    os.chdir(blockPath)
    ex_file = open("./setup.csh","w")
    ex_file2 = open("./icc2Run.tcl","w")
    env = env.strip()
    ex_file.write(env)
    if option.toolName == "S":
        data = "\n\nfcbe -file ./icc2Run.tcl"
    elif option.toolName == "C":
        data = "\n\ninnovus -file ./icc2Run.tcl -no_gui "
    ex_file.write(data)

    #if option.toolName == "S":
    ex_file2.write("\nsource "+config2[project]["commands"])

    if option.location == "nil":
        ndmLocation = config2[project]["ndmLocation"].strip()
    else:
        ndmLocation = option.location.strip()
    if option.toolName == "S":
        data = "\n\nopen_lib -readonly "+ndmLocation+"/"+block+".ndm; open_block -readonly "+block+"\n\n"
    elif option.toolName == "C":
        data = "\n\nread_db -no_timing "+ndmLocation+"/"+block+".enc; \n\n"

    ex_file2.write("\nset blockName "+block)
    ex_file2.write(data)
    if option.tcl != "nil":
        print("load the tcl file ",option.tcl," in the setup.csh ")
        data = "\nsource "+option.tcl+"\n"
        ex_file2.write(data)
    if option.toolName == "S":
        data = config2[project]["exitCommands"]
    elif option.toolName == "C":
        data = "exit"
    ex_file2.write(data)
    cmd = "nbjob run --target "+target+" --qslot "+qslot+" --wash  --class \'"+clas+""+option.memory+"G&&"+option.cores+"C\' xterm -T \""+block+"\" -e \"source setup.csh\""
    print("opening terminal with following options ",cmd)
    os.system(cmd)
    os.chdir(cwd)

