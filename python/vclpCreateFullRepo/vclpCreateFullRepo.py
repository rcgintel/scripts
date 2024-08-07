#! /usr/intel/bin/python3.10.8

import sys
import os
import optparse
import re
import configparser

### defs all


def create_recursive_directories(path):
  """Creates a recursive directory structure.
  Args:
    path: The path to the directory structure to create.
  """
  if not os.path.exists(path):
    os.makedirs(path)
    for child in os.listdir(path):
      create_recursive_directories(os.path.join(path, child))


#### opt declaration 

parser = optparse.OptionParser("user arg1")
parser.add_option("-P", "--project", dest="project", default="Nil" , help = "give the project name")
parser.add_option("-S", "--script", dest="script", default="Nil" , help = "setup the scripts only")
(option, args) = parser.parse_args()


config = configparser.ConfigParser()
config.read('/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/getAllDataFromVault/config.ini')

if option.project == "Nil":
	print("please provide a project name")
	sys.exit(0)

project = option.project

##### script to start

#os.system("touch te")
cwd = os.getcwd()
dirLists = {"scripts","samCreation/inputs","samCreation/scripts","samCreation/baseRun","netlistRollup/inputs","netlistRollup/scripts","netlistRollup/runs","upfRollup/scripts","topVclp/scripts","topVclp/inputs","netlistRollup/inputs/overrides","netlistRollup/inputs/topInputs","netlistRollup/inputs/SuperSection","netlistRollup/inputs/sectionInputs","ndm"}
print ("creating all directories")
if option.script == "Nil":
  for dirList in dirLists:
    create_recursive_directories(dirList)

repo_url = "/nfs/site/disks/vmisd_vclp_efficiency/rcg/repo/tcl/vclpAllScripts"
repo_dir = "scripts"
cmd = "git clone "+repo_url+" "+repo_dir
os.system(cmd)

### now we have all the scripts in the scripts directory
## correct the scripts so that it works for the project
# read tdb file and get the design name
tdbHier = os.getenv("PROJ_TDB_HIER_FILE")
pattern = "^0\s+.*\((.*)\).*"
with open(tdbHier, "r") as f:
  lines = []
  for line in f:
    match = re.search(pattern, line)
    if match:
      projectName = match.group(1).lstrip()
      print("project name is",projectName)
      break

## correcting the sam generation script
fil = "scripts/generate_sam_from_rtm.tcl"
correctedFil = "scripts/generate_sam_from_rtm.tcl.bak"
with open(fil, "r") as f:
  lines = []
  pattern1 = "set block_name "
  pattern2 = "set run_loc "
  with open(correctedFil, "w") as fo:
      for line in f:
        match = re.search(pattern1, line)
        if match:
            line = "set block_name "+projectName+".vclpSamGen"
        match = re.search(pattern2, line)
        if match:
            runLoc = ""
            line = "set run_loc \""+cwd+"/samCreation/inputs/blockInputs/\"\n"
        fo.write(line)
  fo.close()
cmd = "mv scripts/generate_sam_from_rtm.tcl.bak scripts/generate_sam_from_rtm.tcl"
os.system(cmd)
cmd = "cp scripts/generate_sam_from_rtm.tcl samCreation/scripts/generate_sam_from_rtm.tcl"
os.system(cmd)




correctedFil = "scripts/upfRollup.tcl"
with open(correctedFil, "w") as fo:
    data = "sh mkdir upf_rollup\n"
    fo.write(data)
    data = "sh mkdir upf_rollup/apr_upfs\n"
    fo.write(data)
    data = "set sections {"+projectName+"}\n\n"
    fo.write(data)
    data = "foreach section $sections {\n"
    fo.write(data)
    data = "\tcatch {sh rm -rf ./upf_rollup/work_${section}}\n"
    fo.write(data)
    data = "\tcatch {redirect -file ${section}_rollup_upf.log -tee {upf::rollup -top $section -apr_upfs_dir "+cwd+"/samCreation/inputs/blockInputs/ -work_dir ./upf_rollup/work_${section}}}\n exit"
    fo.write(data)
    data = "}\n"
    fo.write(data)



cmd = "cp scripts/upfRollup.tcl upfRollup/scripts/upfRollup"
os.system(cmd)

### dumping physical only sam files for physical blocks
physBlocks = config[project]["physicalOnlyBlocks"]
for physBlock in physBlocks.split(" "):
    print("the physical only blocks are ",physBlock)
    loc = cwd+"/topVclp/inputs/"+physBlock+".pg.vg"
    with open(loc, "w") as fo:
        line = "// Verilog for (Full) Design:"+physBlock+"\n\n"
        fo.write(line)
        line = "(* SNPS_VCSTATIC_INM_abstract = 1 *)\n"
        fo.write(line)
        line = "module "+physBlock+"();\n"
        fo.write(line)
        line = "endmodule\n"
        fo.write(line)
    fo.close()


fil = "scripts/runVCLPTop.csh"
correctedFil = "scripts/runVCLPTop.csh.bak"
with open(fil, "r") as f:
  lines = []
  pattern1 = "cd /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/topVclp/inputs/"
  pattern2 = "set cels = "
  pattern3 = "set location = "
  pattern4 = "set netlist = "
  pattern5 = "set upfLoc =  "
  pattern6 = "cd /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/topVclp/runs"
  pattern7 = "-design gen12p93dl2"
  pattern8 = "-work Jun2TopVclp"
  pattern9 = "-sam_list_file /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/topVclp/scripts/sam_verilog_files.list"
  

  with open(correctedFil, "w") as fo:
    for line in f:
      match = re.search(pattern1, line)
      if match:
          line = "cd "+cwd+"/topVclp/inputs/\n"
      match = re.search(pattern2, line)
      if match:
          line = "set cels = ("+config[project]["Block"]+")\n set pcels = ("+config[project]["physicalOnlyBlocks"]+")\n"
      match = re.search(pattern3, line)
      if match:
          line = "set location = "+cwd+"/samCreation/baseRun/<give complete location ex : Jun02VclpFull/builds/gen12p93dl2.vclpSamGenJun02>\n"
      match = re.search(pattern4, line)
      if match:
          line = "set netlist = "+cwd+"/netlistRollup/runs/<give complete location ex : Jun02VclpFull/builds/gen12p93dl2.vclpSamGenJun02>/10_assembly/020_rollup/work/"+projectName+".pg.vg.gz\n"
      match = re.search(pattern5, line)
      if match:
          line = "set upfLoc = "+cwd+"/upfRollup/<give complete location ex : Jun02VclpFull/>/upf_rollup/work_"+projectName+"/"+projectName+".upf\n"
      match = re.search(pattern6, line)
      if match:
          line = "cd "+cwd+"/topVclp/runs\n"
      match = re.search(pattern7, line)
      if match:
          line = " -design "+projectName+" \\ \n"
      match = re.search(pattern8, line)
      if match:
          line = " -work TopVCLP \\ \n"
      match = re.search(pattern9, line)
      if match:
          line = " -sam_list_file "+cwd+"/topVclp/scripts/sam_verilog_files.list \\ \n"
      fo.write(line)
  fo.close()
cmd = "mv scripts/runVCLPTop.csh.bak scripts/runVCLPTop.csh"
os.system(cmd)
cmd = "cp scripts/runVCLPTop.csh topVclp/scripts/runVCLPTop.csh"
os.system(cmd)

cmd = "cp "+config[project]["overrideFile"].strip()+"/* netlistRollup/inputs/overrides/"
os.system(cmd)

fil = "scripts/rtm_netlistRollup.tcl"
correctedFil = "scripts/rtm_netlistRollup.tcl.bak"
with open(fil, "r") as f:
  lines = []
  pattern1 = "set top_name "
  pattern2 = "set run_name "
  pattern3 = "set samNetlist "
  pattern4 = "set overrides_location "
  pattern5 = "set section_level_netlist_location "
  pattern6 = "set top_level_netlist_location "
  pattern7 = "set block_inputs "
  pattern8 = "set aprUpfInputs "
  pattern9 = "set physicalOnlyBlock "

  with open(correctedFil, "w") as fo:
      for line in f:
        match = re.search(pattern1, line)
        if match:
            line = "set top_name "+projectName+"\n"
        match = re.search(pattern2, line)
        if match:
            runLoc = ""
            #line = "set run_name \"Dirty${current_date}${month_name}\"\n"
        match = re.search(pattern3, line)
        if match:
            line = "set samNetlist \""+cwd+"/samCreation/baseRun/blockRun/builds/"+projectName+".vclpSamGen\"\n"
        match = re.search(pattern4, line)
        if match:
            line = "set overrides_location \""+cwd+"/netlistRollup/inputs/overrides\"\n"
        match = re.search(pattern5, line)
        if match:
            line = "set section_level_netlist_location \""+cwd+"/netlistRollup/inputs/sectionInputs\"\n"
        match = re.search(pattern6, line)
        if match:
            line = "set top_level_netlist_location \""+cwd+"/netlistRollup/inputs/topInputs\"\n"
        match = re.search(pattern7, line)
        if match:
            line = "set block_inputs \""+cwd+"/netlistRollup/inputs/blockInputs/\"\n"
        match = re.search(pattern8, line)
        if match:
            line = "set aprUpfInputs $block_inputs \n"
        match = re.search(pattern9, line)
        if match:
            line = "set physicalOnlyBlock \""+config[project]["physicalOnlyBlocks"]+"\"\n"
        fo.write(line)
  fo.close()
cmd = "mv scripts/rtm_netlistRollup.tcl.bak scripts/rtm_netlistRollup.tcl"
os.system(cmd)
cmd = "cp scripts/rtm_netlistRollup.tcl netlistRollup/scripts/rtm_netlistRollup.tcl"
os.system(cmd)





cmd = "cp scripts/checkoutNetlist.csh samCreation/inputs/"
os.system(cmd)
### make all changes to inputs
with open('samCreation/inputs/checkoutNetlist.csh', 'r') as file:
    file_content = file.read()

correctedContent = ""
for line in file_content.split("\n"):
    pattern1 = "set blocks "
    match = re.search(pattern1, line)
    print (line,pattern1)
    if match:
            line = "set blocks = ("+config[project]["Block"]+")"
    pattern1 = "vault checkout -domain sd -subset upf -tag FV -milestone A0_LV"
    match = re.search(pattern1, line)
    if match:
            line = " vault checkout -domain sd -subset upf -tag FV -milestone "+config[project]["BlockMilestone"]+" -block $block"
    correctedContent += line + "\n"

file_content = correctedContent
print(file_content)

data = "#!/usr/intel/bin/tcsh \ncd "+os.getcwd()+"/samCreation/inputs/"
with open('samCreation/inputs/checkoutNetlist.csh', 'w') as file:
    # Add the new line at the beginning
    new_line = "\n"
    file.write(data)

    # Write back the original contents after the new line
    file.write(file_content)

cmd = "rm -rf scripts"
os.system(cmd)
