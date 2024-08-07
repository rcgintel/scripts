#! /usr/intel/bin/python

import sys
import os
import optparse
import re
import subprocess

#### opt declaration 

labArea = "/nfs/site/disks/vmisd_vclp_efficiency/rcg/VCLP_TRAINING/database/"
### 
# check if the user has all the group permissions
groupsToHave = ["intelall", "soc", "gmdhw", "n5", "dgn5", "dgn5fe", "dgp", "n5fe", "n5p", "datools"]
listGroups = subprocess.run("groups", stdout=subprocess.PIPE)

availableGroups = listGroups.stdout.decode('utf-8').split("\n")[0].split(" ")
#print(availableGroups)
#print(groupsToHave)
#for grp in availableGroups.split(" "):
#    print(grp)

intersectGroup = set(availableGroups).intersection(groupsToHave)
if (len(intersectGroup)) == 10:
    print("All groups available preparing to copy the files")
    print ("Please wait while we copy the database to your area")
    cmd = "cp -rf "+labArea+"ungfxpar3.ndm ."
    os.system(cmd)
    
    cmd = "cp -rf "+labArea+".solution ."
    os.system(cmd)
else:
    print("Please check for the group permissions")
