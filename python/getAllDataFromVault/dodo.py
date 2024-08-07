import sys
sys.path.append('/nfs/site/disks/vmisd_vclp_efficiency/rcg/server/fullServer/venvRcg/lib/python3.11/site-packages')
from doit.tools import run_once
import os
from subprocess import check_output

def task_setup_vclp():
    rcg_project_name = os.environ.get('rcgProjectName')
    return {'actions': ['/usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/vclpCreateFullRepo/vclpCreateFullRepo.py -P '+str(rcg_project_name)],
            'targets': ['netlistRollup upfRollup samCreation topVclp ndm'],
            'doc':'this is for setting up vclp directory',
            'uptodate': [run_once],
            'targets':['samCreation'],
            }

def task_setup_config():
    return {'actions': ['ln -s /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/getAllDataFromVault/config.ini .'],
            'doc':'this is to link the config file to modify the configuration of execution',
            'uptodate': [run_once],
            'targets': ['config.ini']}

def task_get_vault():
    rcg_project_name = os.environ.get('rcgProjectName')
    input_dir = 'netlistRollup/inputs/sectionInputs/'
    #input_dir2 = 'netlistRollup/inputs/SuperSection/'
    if os.path.exists(input_dir):
        files = os.listdir(input_dir)
        for file in files:
            input_file = os.path.join(input_dir,file)
        return {'actions': ['cd netlistRollup/inputs/SuperSection ; /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/getAllDataFromVault/getAllDataFromVault.py -P '+str(rcg_project_name)+' -S True ; gzip *; cd ../../../ ; cd netlistRollup/inputs/sectionInputs ; /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/getAllDataFromVault/getAllDataFromVault.py -P '+str(rcg_project_name)+' ; gzip *; cd ../../../ ; '],
            'doc':'get all the super and section data from the vault',
            'verbosity': 2,
            'clean': True,
            }

def task_get_block_vault():
    input_dir = 'samCreation/inputs/'
    if os.path.exists(input_dir):
        files = os.listdir(input_dir)
        cmd = 'tcsh samCreation/inputs/checkoutNetlist.csh '
        for file in files: 
            input_file = os.path.join(input_dir,file)
        return {'actions': [(check_output, [cmd], {'shell':True, 'universal_newlines':True})],\
            'verbosity': 2,
            'doc':'get all the block level data from the vault incomplete',
            'clean': True,
            'targets': [input_file],
            }

def task_get_block_ndm():
    input_dir = 'samCreation/inputs/'
    if os.path.exists(input_dir):
        files = os.listdir(input_dir)
        return {'actions': ['cd ndm; /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/getAllDataFromVault/getLatestNdm.py'],\
            'verbosity': 2,
            'doc':'get all the block level ndm data from the vault',
            'clean': True,
            }

def task_fire_block_ndm():
    rcg_project_name = os.environ.get('rcgProjectName')
    input_dir = 'samCreation/inputs/'
    if os.path.exists(input_dir):
        files = os.listdir(input_dir)
        return {'actions': ['cd ndm; /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/runBlockIcc2/runBlockIcc2.py -P '+str(rcg_project_name)+' -M 32 -C 1 -N test -T /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/runBlockIcc2/dumpNetlistUpf.tcl -B all -L '+os.path.abspath(os.getcwd())+'/ndm'],\
            'verbosity': 2,
            'doc':'fire all  the block to get the netlist and upf',
            'clean': True,
            }


def task_generate_sam_netlist():
    rcg_project_name = os.environ.get('rcgProjectName')
    input_dir = 'samCreation/inputs/blockInputs'
    if os.path.exists(input_dir):
        files = os.listdir(input_dir)
        for file in files: 
            input_file = os.path.join(input_dir,file)
        return {'actions': ['/usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/runBlockIcc2/runBlockRTM.py -P '+str(rcg_project_name)+' -M 32 -L sam'],
            'doc':'create sam netlist for all the blocks',
            'file_dep': [input_file],
            }


def task_generate_upf_rollup():
    rcg_project_name = os.environ.get('rcgProjectName')
    input_dir = 'samCreation/inputs/blockInputs'
    if os.path.exists(input_dir):
        files = os.listdir(input_dir)
        for file in files: 
            input_file = os.path.join(input_dir,file)
        return {'actions': ['/usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/runBlockIcc2/runOpenIcc2.py -D doit -P '+str(rcg_project_name)+' -M 32 -B upfRollup -T ./scripts/upfRollup'],
            'doc':'create upf rollup for all the blocks',
            'file_dep': [input_file],
            }


def task_generate_netlist_rollup():
    rcg_project_name = os.environ.get('rcgProjectName')
    input_dir = 'samCreation/inputs/blockInputs'
    if os.path.exists(input_dir):
        files = os.listdir(input_dir)
        for file in files: 
            input_file = os.path.join(input_dir,file)
        return {'actions': ['/usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/runBlockIcc2/runBlockRTM.py -P '+str(rcg_project_name)+' -M 32 -L netlist'],
            'doc':'create netlist rollup for top level',
            'file_dep': [input_file],
            }
