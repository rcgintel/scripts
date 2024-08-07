### find the data 

set current_date [clock format [clock seconds] -format "%Y-%m-%d"]

# Extract the month and year from the current date
set year [lindex [split $current_date "-"] 0]
set month [lindex [split $current_date "-"] 1]
set day [lindex [split $current_date "-"] 2]

# Convert month number to month name
set month_names {
    01 {January}
    02 {February}
    03 {March}
    04 {April}
    05 {May}
    06 {June}
    07 {July}
    08 {August}
    09 {September}
    10 {October}
    11 {November}
    12 {December}
}

# Get the month name
set month_name [dict get $month_names $month]



#1.	First machine rtm shell: Create a rollup_block:
#set ::TEV(verification_tools) "vclp vclp_sam_create"
set top_name gen12p93dl2
#gen12p93dl2.vclpSamGenDirtyNov15

set run_name "Dirty_${year}_${month_name}_${day}_Route"
set samNetlist "/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/baseRun/Dec15VclpFull/builds/gen12p93dl2.vclpSamGenDec15/"
#/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/baseRun/Dec07SamOnly/builds/gen12p93dl2.vclpSamGenDec06/"
#/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/baseRun/Dec02VclpSam/builds/gen12p93dl2.vclpSamGenDec02/"
set dirtyNetlist 0



#############
set overrides_location "/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/netlistRollup/inputs/overrides"
set section_level_netlist_location "/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/netlistRollup/inputs/sectionInputs"
set top_level_netlist_location "/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/netlistRollup/inputs/topInputs"
set block_inputs "/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/netlistRollup/inputs/blockInputs/"
set aprUpfInputs "/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/inputs/blockInputs/"
set block_name ${top_name}.vclpSamGen${run_name}
set run_name "vclpSamGen${run_name}"
set top_level_verilog "$top_level_netlist_location/${top_name}.top.pg.vg"



##### code to copy the sam netlist to the block inputs area

#set block_names [list gtgacspar3 gtsqidi1 gtsqidi0 gtsqbgfpar1 gtsqbgfpar0 gtmcxlpar gtglobalpar2 gtglobalpar1 gtgacspar2 gtgacspar1 gtcgpinf]

set physicalOnlyBlock [list gtphyspar1 gtphyspar2 gtphyspar3 gtphyspar4 gtphyspar5]

set block_names [hier::get_designs * -node_type partition]
set sectionName [hier::get_designs * -node_type section]
set supersectionName [hier::get_designs * -node_type supersection]


######

proc instersectionList {list1 list2} {
	set result {}
	foreach item $list1 {
		if {[lsearch -exact $list2 $item] == -1} {
			lappend result $item
		}
	}
	return $result
}
### this is for testing
#set inputs "/nfs/zsc3/disks/mtl_128_intg_mw_01/inputs/top_netlist_test/"
########


	#get_netlist_from_vault -top_name $top_name -version $version -inputs $inputs
	lynx::create_block $block_name -local -from_template build.section
	lynx::configure_blocks $block_name -var dp,prepare,mode -value copy
	lynx::configure_blocks $block_name -subdesigns [hier::get_designs * -node_type partition] -value {mode copy} 
	# we set the partitios to copy the remove_cells netlists
	#lynx::configure_blocks $block_name -subdesigns "[hier::get_designs -node_type section] [hier::get_designs -node_type supersection]" -value {mode build}
	lynx::configure_blocks $block_name -subdesigns "[hier::get_designs -node_type section]" -value {mode build}
	lynx::configure_blocks $block_name -subdesigns "[hier::get_designs -node_type supersection]" -value {mode build}
	
	###########################
	#lynx::configure_blocks $block_name -subdesigns {gtdssm gtgsc gtl3inf gtmidslgamcc gtsqmain ungfx gtsqidim} -value {mode copy}
	lynx::configure_blocks $block_name -var assembly,enable,pg_rollup -value 1

        
        foreach blk $physicalOnlyBlock {
	    lynx::configure_blocks $block_name -subdesigns $blk -value {mode blackbox}
        }
	#lynx::configure_blocks $block_name -subdesigns {gtdssm} -value {mode blackbox}
	#lynx::configure_blocks $block_name -subdesigns {gtmidslgamcc} -value {mode blackbox}
	#lynx::configure_blocks $block_name -subdesigns {gtl3inf} -value {mode blackbox}
	#lynx::configure_blocks $block_name -subdesigns {ungfx} -value {mode blackbox}
	#lynx::configure_blocks $block_name -subdesigns "[hier::get_designs -node_type section]" -value {mode build}
	#lynx::configure_blocks $block_name -subdesigns "gtsqidim" -value {mode build}

	########################### copy gcd overrides
	if [file exists ${overrides_location}/${top_name}.overrides.tcl] {
		catch {sh cp ${overrides_location}/${top_name}.overrides.tcl builds/${top_name}.${run_name}/scripts_build/}
	} else {
		catch {sh touch builds/${top_name}.${run_name}/scripts_build/${top_name}.overrides.tcl}
	}
     
	############################
	#enable dirty link mode do not use for final runs
        if {$dirtyNetlist} {
	    set SVAR(assembly,dirtylink,mode) fix_all
	    lynx::configure_blocks $block_name -var assembly,dirtylink,mode -value fix_all
        }
	#
	###########################
	set nonPhysBlockName [instersectionList $block_names $physicalOnlyBlock]
	foreach par_name $nonPhysBlockName {
		catch { sh touch builds/${block_name}/inputs/${par_name}.ndm}
                puts "${samNetlist}/00_verify_upf/${par_name}_vclp_sam_create/work/${par_name}.sam/${par_name}/verilog/${par_name}_SNPS_VCSTATIC_INM_abstract.v builds/${block_name}/inputs/${par_name}.pg.vg"
                
                catch {sh cp ${samNetlist}/00_verify_upf/${par_name}_vclp_sam_create/work/${par_name}.sam/${par_name}/verilog/${par_name}_SNPS_VCSTATIC_INM_abstract.v builds/${block_name}/inputs/${par_name}.pg.vg}
                catch {sh cp ${samNetlist}/00_verify_upf/${par_name}_vclp_sam_create/work/${par_name}.sam/${par_name}/verilog/${par_name}_SNPS_VCSTATIC_INM_abstract.v builds/${block_name}/inputs/floorplan/${par_name}.pg.vg}
                sh gzip -f  builds/${block_name}/inputs/${par_name}.pg.vg
                sh gzip -f  builds/${block_name}/inputs/floorplan/${par_name}.pg.vg
		catch { sh cp ${aprUpfInputs}/${par_name}.apr.upf builds/${block_name}/inputs/${par_name}.apr.upf}
		catch { sh cp ${aprUpfInputs}/${par_name}.apr.upf builds/${block_name}/inputs/floorplan/${par_name}.apr.upf}
	}

	#sh ln -s ${inputs}/gcd.top.vg builds/${block_name}/inputs/${top_name}.top.pg.vg
	#sh ln -s ${inputs}/gtdssm.top.vg builds/${block_name}/inputs/gtdssm.top.pg.vg
	#sh ln -s ${inputs}/gtgsc.top.vg builds/${block_name}/inputs/gtgsc.top.pg.vg
	#sh ln -s ${inputs}/gtl3inf.top.vg builds/${block_name}/inputs/gtl3inf.top.pg.vg
	#sh ln -s ${inputs}/gtmidslgamcc.top.vg builds/${block_name}/inputs/gtmidslgamcc.top.pg.vg
	#sh ln -s ${inputs}/gtsqmain.top.vg builds/${block_name}/inputs/gtsqmain.top.pg.vg
	#sh ln -s ${inputs}/ungfx.top.vg builds/${block_name}/inputs/ungfx.top.pg.vg
    foreach section $supersectionName {
	    	sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/${section}.top.pg.vg
	    	sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/floorplan/${section}.top.pg.vg
            sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/${section}.pg.vg
	    	sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/floorplan/${section}.pg.vg
            sh gzip -f builds/${block_name}/inputs/${section}.pg.vg
            sh gzip -f builds/${block_name}/inputs/floorplan/${section}.pg.vg
            sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/${section}.pg.vg
	    	sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/floorplan/${section}.pg.vg
	    catch {sh cp ${overrides_location}/${section}.overrides.tcl builds/${top_name}.${run_name}/scripts_build/}
    }

    foreach section $sectionName {
	    sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/${section}.top.pg.vg
	    sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/floorplan/${section}.top.pg.vg
            sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/${section}.pg.vg
	    sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/floorplan/${section}.pg.vg
            sh gzip -f builds/${block_name}/inputs/${section}.pg.vg
            sh gzip -f builds/${block_name}/inputs/floorplan/${section}.pg.vg
            sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/${section}.pg.vg
	    sh cp -rf ${section_level_netlist_location}/${section}.top.pg.vg builds/${block_name}/inputs/floorplan/${section}.pg.vg
	    catch {sh cp ${overrides_location}/${section}.overrides.tcl builds/${top_name}.${run_name}/scripts_build/}
    }


    sh cp -rf ${top_level_netlist_location}/${top_name}.top.pg.vg builds/${block_name}/inputs/${top_name}.top.pg.vg
	sh cp -rf ${top_level_netlist_location}/${top_name}.top.pg.vg builds/${block_name}/inputs/floorplan/${top_name}.top.pg.vg
#lynx::configure_blocks $block_name -var assembly,enable,link_only_top_modules -value 1

	
	lynx::run_blocks $block_name -target finish/analyze
	
################### gcd rollup










#### when the supersection level runs have stared need to copy the netlist and overrides files 

# foreach section $supersectionName {
# puts "working on super section $section"    
# if [file exists ./builds/${section}.${run_name}/inputs/${section}.top.pg.vg] {
# sh rm ./builds/${section}.${run_name}/inputs/${section}.top.pg.vg
# }
# sh cp ${section_level_netlist_location}/${section}.top.pg.vg ./builds/${section}.${run_name}/inputs/${section}.top.pg.vg

# if [file exists ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg] {
# sh rm ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg
# }
# sh cp ${section_level_netlist_location}/${section}.top.pg.vg ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg

# if [file exists ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg.gz] {
# sh rm ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg.gz
# }
# sh gzip ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg
# catch {sh cp ${overrides_location}/${section}.overrides.tcl builds/${section}.${run_name}/scripts_build/}
# }

# foreach section $sectionName {
# puts "working on section $section"   
# if [file exists ./builds/${section}.${run_name}/inputs/${section}.top.pg.vg] {
# sh rm ./builds/${section}.${run_name}/inputs/${section}.top.pg.vg
# }
# sh cp ${section_level_netlist_location}/${section}.top.pg.vg ./builds/${section}.${run_name}/inputs/${section}.top.pg.vg

# if [file exists ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg] {
# sh rm ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg
# }
# sh cp ${section_level_netlist_location}/${section}.top.pg.vg ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg

# if [file exists ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg.gz] {
# sh rm ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg.gz
# }
# sh gzip ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${section}.top.pg.vg
# catch {sh cp ${overrides_location}/${section}.overrides.tcl builds/${section}.${run_name}/scripts_build/}
# }


# ##### after section blocks completion running section level rollup


# foreach section $supersectionName {
#     foreach subSection $sectionName {
#     puts "working on super section $section and copying subsection $subSection data"    
#         sh cp ./builds/${subSection}.${run_name}/10_assembly/020_rollup/work/${subSection}.pg.vg.gz ./builds/${section}.${run_name}/inputs/floorplan/
#         sh cp ./builds/${subSection}.${run_name}/10_assembly/020_rollup/work/${subSection}.pg.vg.gz ./builds/${section}.${run_name}/10_assembly/010_subblocks/work/${subSection}.pg.vg.gz
#         sh cp ./builds/${subSection}.${run_name}/10_assembly/020_rollup/work/${subSection}.pg.vg.gz ./builds/${section}.${run_name}/00_dp/500_outputs/work/floorplan/${subSection}.pg.vg.gz
#     }
# }


# ## after super section completes
# set sectionCopy {gtsqmcxlinf gtmempipe gtslice}
# #set sectionCopy {gtmempipe gtslice }

# foreach block $sectionCopy {
#     puts "copying completed netlist from ./builds/${block}.${run_name}/10_assembly/020_rollup/work/${block}.pg.vg.gz to ./builds/${top_name}.${run_name}/00_dp/500_outputs/work/floorplan/${block}.pg.vg.gz"
# sh cp ./builds/${block}.${run_name}/10_assembly/020_rollup/work/${block}.pg.vg.gz ./builds/${top_name}.${run_name}/00_dp/500_outputs/work/floorplan/${block}.pg.vg.gz 
#         sh cp ./builds/${block}.${run_name}/10_assembly/020_rollup/work/${block}.pg.vg.gz ./builds/${top_name}.${run_name}/10_assembly/010_subblocks/work/${block}.pg.vg.gz
#         sh cp ./builds/${block}.${run_name}/10_assembly/020_rollup/work/${block}.pg.vg.gz ./builds/${top_name}.${run_name}/00_dp/500_outputs/work/floorplan/${block}.pg.vg.gz

# #sh cp ./builds/${block}.${run_name}/10_assembly/020_rollup/work/${block}.pg.vg.gz ./builds/${top_name}.${run_name}/10_assembly/020_rollup/work/${block}.pg.vg.gz
# }

# sh cp $top_level_verilog ./builds/${block_name}/00_dp/500_outputs/work/floorplan/
# sh gzip ./builds/${block_name}/00_dp/500_outputs/work/floorplan/${top_name}.top.pg.vg



