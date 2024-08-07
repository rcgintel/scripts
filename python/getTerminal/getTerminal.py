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


parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--project", dest="project", default="Nil" , help = "give the project name")
parser.add_option("-M", "--memory", dest="memory", default="32", help = "give the ammount of memory you need")
parser.add_option("-C", "--cores", dest="cores", default="1", help="give the numbr of cores that you need default 1")
parser.add_option("-N", "--name", dest="name", default="py_terminal", help="give the name of the terminal")
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



cmd = "nbjob -----"
#print("opening terminal with following options ",cmd)

#cmd = "nbjob run --target "+target+" --qslot "+qslot+" --wash  --class \'"+clas+""+option.memory+"G&&"+option.cores+"C\' xterm -T \""+option.name+"\" "
cmd = "nbjob run --target "+target+" --qslot "+qslot+" --wash  --class \'"+clas+""+option.memory+"G&&"+option.cores+"C\' /nfs/site/disks/vmisd_vclp_efficiency/forall/rcgTerm"
print("opening terminal with following options ",cmd)
os.system(cmd)

ex_file = open("./setup.csh","w")
env = env.strip()
#env = env[:-1]
#env = env[1:]
ex_file.write(env)

#print(env)
