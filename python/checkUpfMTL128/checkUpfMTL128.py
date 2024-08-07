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
parser.add_option("-N", "--ndm", dest="ndm", default="Nil", help = "should ndm be copied")
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

if option.ndm == "Nil" and option.upf == "Nil":
	print("please provide the UPF or NDM path")
	sys.exit(0)

if option.ndm != "Nil":
    correctNdm = 1

if option.upf != "Nil":
    correctUpf = 1
    upfFile = option.upf

if correctUpf and correctNdm:
    print("only 1 can be corrected UPF or NDM")
    sys.exit(0)


if option.ndm != "Nil":
    print("checking the NDM")

if option.upf != "Nil":
    print("checking the UPF")


lines = read_file(upfFile)

for line in lines: 
    pattern = r'^add_power_state .*'
    match = re.match(pattern, line)
    if match is not None:
        pattern = r'^add_power_state VNNAON_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.85.*-simstate NORMAL }.*'
        match = re.match(pattern, line)
        if match is not None:
            print("line: ",line)
            error = 1

        pattern = r'^add_power_state VCC_INF_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.85.*-simstate NORMAL }.*'
        match = re.match(pattern, line)
        if match is not None:
            print("line: ",line)
            error = 1


        pattern = r'^add_power_state VCC_MEM_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.85.*-simstate NORMAL }.*'
        match = re.match(pattern, line)
        if match is not None:
            print("line: ",line)
            error = 1

        pattern = r'^add_power_state VCC_ADM_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.85.*-simstate NORMAL }.*'
        match = re.match(pattern, line)
        if match is not None:
            print("line: ",line)
            error = 1

    if enableBias:
        pattern = r'^create_power_domain.*'
        match = re.match(pattern, line)
        if match is not None:
            enableBiasErrorActual = 1
            enableBias = 0
        else:
            enableBiasErrorActual = 0
            enableBias = 0
        #print("bias is ",enableBiasErrorActual)

    pattern = r'set_design_attributes -elements {.} -attribute enable_bias true'
    match = re.match(pattern, line)
    if match is not None:
        #print("Bias: ",line)
        enableBias = 1

if error:
    print("the supply voltages in the UPF file is wrong")

if enableBiasErrorActual:
    print("bias error in the UPF file")


print("completed checking")
