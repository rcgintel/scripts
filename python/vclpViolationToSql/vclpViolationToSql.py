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


parser = optparse.OptionParser("user arg1")
parser.add_option("-L", "--location", dest="location", default="Nil" , help = "give the location")
parser.add_option("-B", "--block", dest="block", default="Nil", help = "give the location")
(option, args) = parser.parse_args()

#
#if option.location == "Nil":
# sys.exit(0)
#
#if option.block == "Nil":
# sys.exit(0)
#
#### take the location of the run
location = "/nfs/site/disks/mtl_128_b0_intg_mw_01/rcg/sam_creation/baseRun/builds/gcd.vclpSamGenMarch10/00_verify_upf/"
print(os.listdir())
