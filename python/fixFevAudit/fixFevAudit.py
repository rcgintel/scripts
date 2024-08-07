#! /usr/intel/bin/python

import sys
import timeit
start = timeit.default_timer()
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


#### opt declaration 

parser = optparse.OptionParser("user arg1")
parser.add_option("-F", "--file", dest="file",
  default="False", help = "verbose")
(option, args) = parser.parse_args()

print ("start checking power intent in FEV reports ",option.file)
##### script to start

start = timeit.default_timer()
start2 = timeit.default_timer()

if option.file == "Nil":
	print("please provide a file name for checking")
	sys.exit(0)


print('Time: ', start2 - start)  


lines = read_file(option.file)

stop = timeit.default_timer()

print ("reading the file in ",option.file)

for line in lines: 
    pattern = r'.*Attribute \'UPF_clamp_value\'.*'
    match = re.match(pattern, line)
    if match is not None:
        print(line)
        #pattern = r'^add_power_state VNNAON_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.85.*-simstate NORMAL }.*'
        #match = re.match(pattern, line)
        #if match is not None:
            #print("line: ",line)
            #error = 1


print('Total Run Time: ', stop - start)  


