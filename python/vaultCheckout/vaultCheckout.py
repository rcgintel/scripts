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
import shlex



def write_file (out_file, information):
  out_file = open(out_file, "a")
  out_file.write (information)
  out_file.write ("\n")
  out_file.close()

def read_file(file_name):
  try: 
    file = open(file_name,"r")
    str_file = file.readlines()
    file.close()
  except IOError:
    print ("file "+file+"dosent exist")
  return str_file


parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--project", dest="project", default="Nil" , help = "give the project name")
parser.add_option("-M", "--milestone", dest="milestone", default="Nil", help = "give the milestone")
parser.add_option("-N", "--ndm", dest="ndm", default="Nil", help = "should ndm be copied")
parser.add_option("-F", "--fire", dest="fire", default="Nil", help = "fire the runs for the copied ndm")
(option, args) = parser.parse_args()

##### script to start
#print("opening terminal with following options ",cmd)
#os.system(cmd)

config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/vaultCheckout/config.ini')
project = option.project
basic = config[project]["vaultCommandBasic"]
milestone = config[project]["vaultCommandMilestone"]

ndmCopy = 1
fireRun = 0

if option.project == "Nil":
	print("please provide a project name")
	sys.exit(0)

if option.ndm == "Nil":
    print("NDM not copied")
    ndmCopy = 0

if option.fire == "Nil":
    print("not firing the NDM")
    ndmFire = 1

#res = subprocess.run(basic, capture_output=True, text=True)
#process = subprocess.Popen(basic, stdout=subprocess.PIPE)

#print(process)

cmd = shlex.split(basic)
p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
output, err = p.communicate()
#print(output.decode())
os.system("rm -rf versionInfo.list")
write_file ("versionInfo.list", output.decode())

#rc = p.returncode
for line in output.decode().split("\n"):
 pat = "^\| \/p.*"
 if (re.match(pat,line)):
  line = line.split("|")
  if (len(line) > 1):
   if ndmCopy:
       ndm = line[1].strip()+"/ndm/*.ndm"
       cmd = "cp -rf "+ndm+" ."
       os.system(cmd)
   netlist = line[1].strip()+"/"+line[4].strip()+".spyglass_splitbus.pg.vg.gz"
   upf = line[1].strip()+"/"+line[4].strip()+".apr.upf.gz"
   cmd = "cp -rf "+netlist+" ."
   os.system(cmd)
   cmd = "cp -rf "+upf+" ."
   os.system(cmd)
   cmd = "gunzip "+line[4].strip()+".apr.upf.gz"
   os.system(cmd)



