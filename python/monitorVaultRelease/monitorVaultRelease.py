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
import glob


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
parser.add_option("-S", "--sql", dest="sql", default="./CheckVault.sql", help = "give the sql location")
(option, args) = parser.parse_args()

##### script to start
#print("opening terminal with following options ",cmd)
#os.system(cmd)

config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/monitorVaultRelease/config.ini')
project = option.project
basic = config[project]["vaultCommandBasic"]
milestone = config[project]["vaultCommandMilestone"]

fireRun = 0

if option.project == "Nil":
	print("please provide a project name")
	sys.exit(0)

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
      blockName = line[4].strip()
      version = line[2].strip()
      location = line[1].strip()
      netlistLocation = location+"/ios/"+"*spyglass_splitbus.pg.vg.gz"
      upfLocation = location+"/reports/"+"*.apr.upf.gz"
      files = glob.glob(netlistLocation)
      filesUpf = glob.glob(upfLocation)
      #print ("blockName ",blockName, " Version ", version, "Netlist Location ", len(files))
      if (len(files) > 0):
          print()
          #print ("blockName ",blockName, " Version ", version, "Netlist Location ", len(files))
      else:
          netlistNotFound = 1
          decrease = 1
          while netlistNotFound:
            #print("netlist file is not available")
            #print("check a version lower")
            basicNew = basic + " -version " + str(int(version) - decrease) + " -block " + blockName
            #print(basicNew)
            cmd = shlex.split(basicNew)
            p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, err = p.communicate()
            #print(output.decode())
            #print(basicNew)
            decrease = decrease + 1
            for line in output.decode().split("\n"):
             pat = "^\| \/p.*"
             if (re.match(pat,line)):
              line = line.split("|")
              if (len(line) > 1):
               blockName = line[4].strip()
               version = line[2].strip()
               location = line[1].strip()
               netlistLocation = location+"/ios/"+"*spyglass_splitbus.pg.vg.gz"
               files = glob.glob(netlistLocation)
               filesUpf = glob.glob(upfLocation)
               #print ("blockName ",blockName, " Version ", version, "Netlist Location ", len(files))
              if (len(files) > 0):
               #print ("blockName ",blockName, " Version ", version, "Netlist Location ", len(files))
               netlistNotFound = 0
            if decrease > 5:
                print("netlist is not available")
                break
      print ("blockName", blockName, "Version ", version, "Netlist Location ", files, " UPF ", filesUpf)



  # netlist = line[1].strip()+"/"+line[4].strip()+".spyglass_splitbus.pg.vg.gz"
  # upf = line[1].strip()+"/"+line[4].strip()+".apr.upf.gz"
  # cmd = "cp -rf "+netlist+" ."
  # os.system(cmd)
  # cmd = "cp -rf "+upf+" ."
  # os.system(cmd)
  # cmd = "gunzip "+line[4].strip()+".apr.upf.gz"
  # os.system(cmd)



