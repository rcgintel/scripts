#! /usr/intel/bin/python

import sys
import os
proc_path="/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/python/procs"
sys.path.append(os.path.abspath(proc_path))
import procs
import optparse
import re


#### opt declaration 

parser = optparse.OptionParser("user arg1")
parser.add_option("-V", "--verbose", action="store_true", dest="verbose",
  default="False", help = "verbose")
parser.add_option("-L", "--logfile", dest="log_file", default="False",
  help="give the log file details")
(option, args) = parser.parse_args()

print ("complete base.py")
##### script to start

os.system("touch te")
