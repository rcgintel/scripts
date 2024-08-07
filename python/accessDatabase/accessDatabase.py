#! /usr/intel/bin/python

import sys
import os
import optparse
import re


#### opt declaration 

parser = optparse.OptionParser("user arg1")
parser.add_option("-C", "--cmd", dest="command", default="False", help="sql command")
(option, args) = parser.parse_args()

print ("complete base.py")
##### script to start

os.system("touch te")

