#! /usr/intel/bin/python3.10.8

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
from datetime import datetime


parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--project", dest="project", default="Nil" , help = "give the project name")
parser.add_option("-M", "--memory", dest="memory", default="32", help = "give the ammount of memory you need")
parser.add_option("-C", "--cores", dest="cores", default="1", help="give the numbr of cores that you need default 1")
parser.add_option("-N", "--name", dest="name", default="py_terminal", help="give the name of the terminal")
parser.add_option("-T", "--tcl", dest="tcl", default="nil", help="give the tcl file to execute in terminal")
parser.add_option("-B", "--block", dest="block", default="all", help="give the tcl file to execute in terminal")
parser.add_option("-L", "--location", dest="location", default="nil", help="give ndm location directory")
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
configFile = os.path.join(os.getcwd(),'config.ini')
config2.read(configFile)


#print("opening terminal with following options ",cmd)
cwd = os.getcwd()
today = datetime.today()
month = datetime.now().strftime('%B')

# Extract the date and month components
current_date = datetime.now().day
current_month = today.month
current_hour = datetime.now().hour
current_minute = datetime.now().minute

if option.location == "sam":
    runPath = cwd +"/samCreation/baseRun/"+month+"_"+str(current_date)+"_"+str(current_hour)
if option.location == "netlist":
     runPath = cwd + "/netlistRollup/runs/"+month+"_"+str(current_date)+"_"+str(current_hour)
#+current_month+"_"+str(current_date)
if os.path.exists(runPath):
    shutil.rmtree(runPath)
    
os.mkdir(runPath)
os.chdir(runPath)
ex_file = open("./setup.csh","w")
env = env.strip()
ex_file.write(env)
if option.location == "sam":
    data = "\n\nlynx_setup -quiet; if(! $?) \\rtm_shell -x \"source scripts_global/kit/setup.tcl; source ../../scripts/generate_sam_from_rtm.tcl\""
if option.location == "netlist":
    data = "\n\nlynx_setup -quiet; if(! $?) \\rtm_shell -x \"source scripts_global/kit/setup.tcl; source ../../scripts/rtm_netlistRollup.tcl\""

ex_file.write(data)
cmd = "nbjob run --target "+target+" --qslot "+qslot+" --wash  --class \'"+clas+""+option.memory+"G&&"+option.cores+"C\' xterm -T \""+option.project+"\" -e \"source setup.csh\""
print("opening terminal with following options ",cmd)
os.system(cmd)
os.chdir(cwd)

