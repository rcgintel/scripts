#! /usr/intel/bin/python3.6.3a

import UsrIntel.R1

import sys
import os
import optparse
import re


#### opt declaration 

parser = optparse.OptionParser("user arg1")
parser.add_option("-N", "--repo", dest="newRepoName", default="False", help="give the repo name to be created")
parser.add_option("-T", "--scriptType", dest="type", default="False", help="give the type of script supported python, csh, tcl")
(option, args) = parser.parse_args()

##### script to start

if option.newRepoName == "False":
 print("give the correct Repo name to be created")
 sys.exit()

if option.type == "False":
 print("give the type of project that is to be created supported 1, python 2, tcl 3, csh.")
 sys.exit()

types = option.type.strip()

validTypes = ["python","tcl","csh"]
if (types not in validTypes):
 print ("give the valid input to type")
 sys.exit()

baseRepoLocation = "/nfs/site/disks/vmisd_vclp_efficiency/rcg/repo/"
actualRepoLocation = baseRepoLocation + option.type.strip() +"/"+option.newRepoName
print ("creating repo in location ",actualRepoLocation)

if (os.path.exists(actualRepoLocation)):
 print ("project already created please do a git clone or give a new project name")
 sys.exit()

 
cmd = "git init "+actualRepoLocation
os.system(cmd)

#cmd = "cd "+actualRepoLocation
#os.system(cmd)
#os.system("git config receive.denyCurrentBranch ignore")
#os.system("git config receive.denyCurrentBranch=updateInstead")
#os.system("git config --bool core.bare true")
#cmd = "cd "+baseRepoLocation

cmd = "mkdir "+option.newRepoName
os.system(cmd)

cmd = "git clone "+actualRepoLocation +" "+option.newRepoName
os.system(cmd)

cmd = "cd "+actualRepoLocation
os.system(cmd)
os.chdir(actualRepoLocation)
os.system("which git")
os.system("git config receive.denyCurrentBranch ignore")
print("git config receive.denyCurrentBranch ignore")

