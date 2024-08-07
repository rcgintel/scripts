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
parser.add_option("-B", "--block", dest="block", default="Nil", help = "give the block name")
parser.add_option("-U", "--upf", dest="upf", default="Nil", help = "point the upf file")
parser.add_option("-R", "--rtlupf", dest="rtlupf", default="Nil", help = "point the rtl upf directory")
(option, args) = parser.parse_args()

##### script to start
#print("opening terminal with following options ",cmd)
#os.system(cmd)

if option.rtlupf == "Nil" or option.block == "Nil" or option.upf == "Nil":
    print("give the correct inputs")
    sys.exit(0)

blockName = option.block.strip()
blockUpf = option.upf.strip()

rtlUpf = option.rtlupf.strip() + "/" + blockName + ".upf"

lines = read_file(blockUpf)
linesRtlUpf = read_file(rtlUpf)
pstStates = []

pstTableCount = 0

print("########################")
print("Working on block ",blockName)

for line in linesRtlUpf:
    pattern = r'^add_power_state .*'
    match = re.match(pattern, line)
    if match is not None:
        pstStates.append(line.strip())

    pattern = r'^create_pst .*'
    match = re.match(pattern, line)
    if match is not None:
        pstStates.append(line.strip())
        pstTableCount += 1

    pattern = r'^add_pst_state .*'
    match = re.match(pattern, line)
    if match is not None:
        pstStates.append(line.strip())

#for pstState in pstStates:
#    print(pstState)

if pstTableCount == 1:
    newUPF = []
    for line in lines:
        pattern = r'^create_pst .*'
        match = re.match(pattern, line)
        if match is not None:
            #for pstState in pstStates:
            #    newUPF.append(pstState)
            line = ""
        pattern = r'^add_pst_state .*'
        match = re.match(pattern, line)
        if match is not None:
            line = ""

        pattern = r'^add_power_state .*'
        match = re.match(pattern, line)
        if match is not None:
            line = ""

        newUPF.append(line)

    for line in newUPF:
        #print(line.strip())
        write_file(blockName+".upf.corrected", line.strip())
    for line in pstStates:
        write_file(blockName+".upf.corrected", line.strip())


else:
    print("block ",blockName," has multiple pst states work with RCG to fix the same")
print("########################")
