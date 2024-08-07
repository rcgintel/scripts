
if {[file exists $::env(GTKIT_PATH)/quantum/reference/n3/run_tcic_checker.tcl]} {
source $::env(GTKIT_PATH)/quantum/reference/n3/run_tcic_checker.tcl
fix_floorplan_rules -prefix tCIC_fix
} else {
puts "please check if tcic_checker file is present or the file that fixes the lego location of the macro"
puts "if you have a custom script to place the hip's give the location below "
set data [gets stdin]
source $data
}

set fil [open "[get_object_name [get_designs]].component.tcl" w]
foreach_in_collection hip [all_macro_cells] {
	puts $fil "set cellInst \[get_cells  {[get_object_name $hip]} \]"
	puts $fil "set_attribute -quiet -objects \$cellInst -name orientation -value [get_attribute [get_cells $hip] orientation]"
	puts $fil "set_attribute -quiet -objects \$cellInst -name origin -value { [get_attribute [get_cells $hip] origin ] }"
	puts $fil "set_attribute -quiet -objects \$cellInst -name status -value fixed"
}
close $fil

