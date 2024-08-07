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
(option, args) = parser.parse_args()

##### script to start
#print("opening terminal with following options ",cmd)
#os.system(cmd)

if option.block == "Nil" or option.upf == "Nil":
    print("give the correct inputs")
    sys.exit(0)

blockName = option.block.strip()
blockUpf = option.upf.strip()

lines = read_file(blockUpf)
pstStates = []

pstTableCount = 0

print("########################")
print("Working on block ",blockName)
newUPF = []
for line in lines:
   pattern = r'^add_power_state .*'
   match = re.match(pattern, line)
   if match is not None:
       pattern = r'^add_power_state VNNAON_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.75.*-simstate NORMAL }.*'
       match = re.match(pattern, line)
       if match is not None:
           print("line: ",line)
           line = ""
       pattern = r'^add_power_state VCC_INF_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.75.*-simstate NORMAL }.*'
       match = re.match(pattern, line)
       if match is not None:
           print("line: ",line)
           line = ""
       pattern = r'^add_power_state VCC_MEM_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.75.*-simstate NORMAL }.*'
       match = re.match(pattern, line)
       if match is not None:
           print("line: ",line)
           line = ""
       pattern = r'^add_power_state VCC_ADM_ss -state GT_ON.* -supply_expr {power ==.*FULL_ON, 0.75.*-simstate NORMAL }.*'
       match = re.match(pattern, line)
       if match is not None:
           print("line: ",line)
           line = ""
   if blockName == "gtl3toprc" :
      pattern = r'create_pst gtl3toprc_vccmem_wrap_gen12p73d2x4x16_pst -supplies .*'
      match = re.match(pattern, line)
      if match is not None:
       datas = ["create_pst gtl3toprc_vccmem_wrap_gen12p73d2x4x16_pst -supplies \{VCCGT_ss.ground VCCGT_ss.power VCC_MEM_ss.power VNNAON_ss.power\}", \
       "add_pst_state state_0 -pst gtl3toprc_vccmem_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_OFF GT_OFF GT_OFF}", \
       "add_pst_state state_1 -pst gtl3toprc_vccmem_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_OFF GT_OFF GT_ON1}", \
       "add_pst_state state_2 -pst gtl3toprc_vccmem_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_OFF GT_ON1 GT_ON1}", \
       "add_pst_state state_3 -pst gtl3toprc_vccmem_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_ON1 GT_OFF GT_ON1}", \
       "add_pst_state state_4 -pst gtl3toprc_vccmem_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_ON2 GT_OFF GT_ON1}", \
       "add_pst_state state_5 -pst gtl3toprc_vccmem_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_ON1 GT_ON1 GT_ON1}", \
       "add_pst_state state_6 -pst gtl3toprc_vccmem_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_ON2 GT_ON1 GT_ON1}"]
       for data in datas:
          #print(data)
          newUPF.append(data)
      elif re.match(r'create_pst gtl3toprc_vccgt_wrap_gen12p73d2x4x16_pst -supplies .*', line) is not None:
       datas = ["create_pst gtl3toprc_vccgt_wrap_gen12p73d2x4x16_pst -supplies {VCCGT_ss.ground VCCGT_ss.power VCC_MEM_ss.power}", \
       "add_pst_state state_0 -pst gtl3toprc_vccgt_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_OFF GT_OFF}", \
       "add_pst_state state_1 -pst gtl3toprc_vccgt_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_OFF GT_ON1}", \
       "add_pst_state state_2 -pst gtl3toprc_vccgt_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_ON1 GT_OFF}", \
       "add_pst_state state_3 -pst gtl3toprc_vccgt_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_ON2 GT_OFF}", \
       "add_pst_state state_4 -pst gtl3toprc_vccgt_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_ON1 GT_ON1}", \
       "add_pst_state state_5 -pst gtl3toprc_vccgt_wrap_gen12p73d2x4x16_pst -state {GT_ON GT_ON2 GT_ON1}"]
       for data in datas:
          #print(data)
          newUPF.append(data)
      elif re.match(r'create_pst gtl3toprc_gen12p73d2x4x16_pst -supplies .*', line) is not None:
       datas = ["create_pst gtl3toprc_gen12p73d2x4x16_pst -supplies {VCCGT_ss.ground VCCGT_ss.power VCC_MEM_ss.power VNNAON_ss.power}", \
       "add_pst_state state_0 -pst gtl3toprc_gen12p73d2x4x16_pst -state {GT_ON GT_OFF GT_OFF GT_OFF}", \
       "add_pst_state state_1 -pst gtl3toprc_gen12p73d2x4x16_pst -state {GT_ON GT_OFF GT_OFF GT_ON1}", \
       "add_pst_state state_2 -pst gtl3toprc_gen12p73d2x4x16_pst -state {GT_ON GT_OFF GT_ON1 GT_ON1}", \
       "add_pst_state state_3 -pst gtl3toprc_gen12p73d2x4x16_pst -state {GT_ON GT_ON1 GT_OFF GT_ON1}", \
       "add_pst_state state_4 -pst gtl3toprc_gen12p73d2x4x16_pst -state {GT_ON GT_ON2 GT_OFF GT_ON1}", \
       "add_pst_state state_5 -pst gtl3toprc_gen12p73d2x4x16_pst -state {GT_ON GT_ON1 GT_ON1 GT_ON1}", \
       "add_pst_state state_6 -pst gtl3toprc_gen12p73d2x4x16_pst -state {GT_ON GT_ON2 GT_ON1 GT_ON1}"]
       for data in datas:
          #print(data)
          newUPF.append(data)
      else:
        pattern = "add_pst_state.*"
        match = re.match(pattern, line)
        if match is not None:
            line = ""
            newUPF.append(line)
        else:
            newUPF.append(line)


for line in newUPF:
   write_file(blockName+".upf.corrected", line.strip())

