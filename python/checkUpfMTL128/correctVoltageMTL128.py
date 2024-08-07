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
    file = open(file_name,"r",encoding="utf-8")
    str_file = file.readlines()
    file.close()
  except IOError:
    print ("file "+file+"dosent exist")
  return str_file


parser = optparse.OptionParser("user arg1")
parser.add_option("-U", "--upf", dest="upf", default="Nil", help = "point the upf file")
(option, args) = parser.parse_args()

##### script to start
#print("opening terminal with following options ",cmd)
#os.system(cmd)
correctNdm = 0
correctUpf = 0
error = 0
enableBias = 0
enableBiasErrorActual = 0
blank = ''

if  option.upf == "Nil":
	print("please provide the UPF or NDM path")
	sys.exit(0)

upfFile =  option.upf
lines = read_file(upfFile)
newUPF = []

#for line in lines:
#    print(line)


for line in lines:
    pattern = r'^add_power_state .*'
    match = re.match(pattern, line)
    if match is not None:
        pattern = r'^add_power_state VNNAON_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.85.*-simstate NORMAL }.*'
        match = re.match(pattern, line)
        if match is not None:
            print("line: ",line)
            line = ""
            error = 1

        pattern = r'^add_power_state VCC_INF_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.85.*-simstate NORMAL }.*'
        match = re.match(pattern, line)
        if match is not None:
            print("line: ",line)
            error = 1
            line = ""


        pattern = r'^add_power_state VCC_MEM_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.85.*-simstate NORMAL }.*'
        match = re.match(pattern, line)
        if match is not None:
            print("line: ",line)
            error = 1
            line = ""

        pattern = r'^add_power_state VCC_ADM_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.85.*-simstate NORMAL }.*'
        match = re.match(pattern, line)
        if match is not None:
            print("line: ",line)
            error = 1
            line = ""
    newUPF.append(line)

for line in newUPF:
    #print(line.strip())
    write_file(upfFile+".corrected", line.strip())


print("completed checking")
