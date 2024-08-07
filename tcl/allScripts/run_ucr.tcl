source $env(GTKIT_PATH)/rlsbuild/scripts_global/kit/standalone.tcl
library::set_library_attributes
caliber::init_collection
set design_name [get_object_name [current_design]]
set state "preCTS"
if {[info exists ::POSTCTS] && $::POSTCTS} { set state "postCTS" }
caliber::caliber_run_rule_list -rules 5_2 -rpt_dir .
sh $env(CALIBER_WAIVER_SCRIPT) -f 5_2.xml -x 5_2_post_waived.xml -waiver Post
source /nfs/zsc3/disks/elg_448_a0_gen12p93dx3_scratch_01/vinodhp/scripts/ucr_analysis_section/get_unclocked_details.tcl
unclocked_analysis -in_xml 5_2_post_waived.xml -op_file $design_name\_ucr_$state.csv
sh mail -a $design_name\_ucr_$state.csv -s "UCR analysis for $design_name $state PV" vinodhp $::env(USER) < ucr_debug.log
