
######################################

namespace eval rcg {
puts "using rcg MV scripts"
}

#proc rcg::change_hierarchy {args} {
#parse_proc_arguments -args ${args} opt
#set cell $opt(-cell)
#set hier $opt(-hier)
#
#if {[info exists opt(-power)]} {
#set power $opt(-power)
#}
#
#set in_pin [get_object_name [get_pins -of $cell -filter "direction == in"]]
#set in_pin_name [get_attribute [get_pins $in_pin] name]
#set in_net [get_object_name [get_nets -of [get_pins -of $cell -filter "direction == in"]]]
#
#set out_pin [get_object_name [get_pins -of $cell -filter "direction == out"]]
#set out_pin_name [get_attribute [get_pins $out_pin] name]
#set out_net [get_object_name [get_nets -of $out_pin]]
#
#set ref_cell [get_attribute [get_cells $cell] ref_name]
#
#set psec_pg [sizeof_collection [get_flat_pins -of [get_cells $cell] -all -filter "name == VDDR" -quiet]]
#if {$psec_pg > 0} {
#set pg_sec [get_attribute [all_connected [get_flat_pins -of [get_cells $cell] -all -filter "name == VDDR" -quiet]] name ]
#set pg_sec $power
#}
#
#
#set origin [get_attribute [get_cells $cell] origin]
#set x_origin [lindex $origin 0]
#set y_origin [lindex $origin 1]
#
#if {[llength [split $cell "/"]] == 1} {
#create_cell ${hier}/${cell} $ref_cell 
#
#remove_cell $cell
#connect_net $in_net ${hier}/${cell}/${in_pin_name}
#connect_net $out_net ${hier}/${cell}/${out_pin_name}
#if {$psec_pg > 0} {
#connect_supply_net $pg_sec -port ${hier}/${cell}/VDDR
#}
#
#
#move_objects [get_cells ${hier}/${cell}] -to "$x_origin $y_origin" -from {0 0}
#}
#
#}





proc rcg::change_hierarchy {args} {
parse_proc_arguments -args ${args} opt
set cell $opt(-cell)
set hier $opt(-hier)

if {[info exists opt(-power)]} {
set power $opt(-power)
} else {
set power VNNAON
}

set in_pin [get_object_name [get_pins -of $cell -filter "direction == in"]]
set in_pin_name [get_attribute [get_pins $in_pin] name]
set in_net [get_object_name [get_nets -of [get_pins -of $cell -filter "direction == in"]]]

set out_pin [get_object_name [get_pins -of $cell -filter "direction == out"]]
set out_pin_name [get_attribute [get_pins $out_pin] name]
set out_net [get_object_name [get_nets -of $out_pin]]

set sink [add_to_collection [get_flat_pins -quiet -of [get_flat_net -of $out_pin] -filter "direction == in"] [get_ports -quiet -of [get_flat_net -of $out_pin]]]
set driver [add_to_collection [get_flat_pins -quiet -of [get_flat_nets -of [get_flat_pins -of [get_cells $cell] -filter "direction == in"]] -filter "direction == out"] [get_ports -of [get_flat_nets -of [get_flat_pins -of [get_cells $cell] -filter "direction == in"]] -quiet]]

set ref_cell [get_attribute [get_cells $cell] ref_name]

set psec_pg [sizeof_collection [get_flat_pins -of [get_cells $cell] -all -filter "name == VDDR" -quiet]]
if {$psec_pg > 0} {
set pg_sec [get_attribute [all_connected [get_flat_pins -of [get_cells $cell] -all -filter "name == VDDR" -quiet]] name ]
set pg_sec $power
}


set origin [get_attribute [get_cells $cell] origin]
set x_origin [lindex $origin 0]
set y_origin [lindex $origin 1]

if {[llength [split $cell "/"]] == 1} {

if {$hier == "top"} {
create_cell [file tail ${cell}] $ref_cell 
} else {
create_cell ${hier}/${cell} $ref_cell 
}

remove_cell $cell

if {$hier == "top"} {
set new_out_pin [get_flat_pin -of [file tail ${cell}] -filter "direction == out"]
set new_in_pin [get_flat_pin -of  [file tail ${cell}] -filter "direction == in"]
} else {
set new_out_pin [get_flat_pin -of  ${hier}/${cell} -filter "direction == out"]
set new_in_pin [get_flat_pin -of  ${hier}/${cell} -filter "direction == in"]
}

connect_pin -driver $new_out_pin $sink -port_name fix_mv_rcg
connect_pin -driver $driver $new_in_pin -port_name fix_mv_rcg
if {$psec_pg > 0} {
connect_supply_net $pg_sec -port ${hier}/${cell}/VDDR
}


move_objects [get_cells ${hier}/${cell}] -to "$x_origin $y_origin" -from {0 0}
}

}


define_proc_attributes rcg::change_hierarchy \
    -info "this is teh push cells to hierarchy" \
    -define_args {
        {-cell "give the cell name for a hier fix" "" string required}
        {-hier "give the hier name for the push" "" string required}
        {-power "give the supply name for secondary pg pin" "" string optional}
    }





proc rcg::add_buffer_on_route_surgical {args} {
parse_proc_arguments -args ${args} opt
set port $opt(-port)
set hier $opt(-hier)
set lib_cell "ts05nxqvlogl06hdp051f_customdg_frame_timing_ccs_all|ts05nxqvlogl06hdp051f_customdg_frame_timing_ccs/HDPULT06_BUF_CAQPNRBY2M2_2"
puts "working on port $port"

set sink_supply [get_attribute [get_related_supply_net [remove_from_collection [all_fanout  -from [get_ports $port] -flat -endpoints_only] [get_pins -of [get_cells -hier diode*]]]] name]

set flag 1
if {[llength $sink_supply] > 1} {
	puts "hectro supplies check properly"
	set flag 0
}

if {[sizeof_collection [get_pins -quiet [remove_from_collection [all_fanout  -from [get_ports $port] -flat -endpoints_only] [get_pins -of [get_cells -hier diode*]]] ]] > 0} {
set flag 2
}

if {[get_attribute  [get_ports $port] direction] == "out"} {
set flag 3
}

if {$flag == 1} {
if {[get_object_name [get_related_supply_nets [get_ports -quiet [all_fanout  -from [get_ports $port] -flat -endpoints_only]]]] == [get_object_name [get_related_supply_net [get_ports $port] ]] } {
	foreach_in_collection cel [get_cells [remove_from_collection [get_cells [all_fanout -from [get_ports $port] -only_cells -flat]] [get_cells -hier *diode*]]] {
		set cel [get_object_name $cel]
		if {[llength [split $cel "/"]] == 1} {
			puts "change hierarchy of $cel to $hier"
			rcg::change_hierarchy -cell $cel -hier $hier 
		}
	}
	}
}


if {$flag == 2} {
if {$sink_supply == [get_object_name [get_related_supply_net [get_ports $port] ]] } {
	foreach_in_collection cel [get_cells [remove_from_collection [get_cells [all_fanout -from [get_ports $port] -only_cells -flat]] [get_cells -hier *diode*]]] {
		set cel [get_object_name $cel]
		if {[llength [split $cel "/"]] == 1} {
			puts "check port [get_object_name $port] and cell [get_object_name $cel] might have to fix it manually"
			#rcg::change_hierarchy -cell $cel -hier $hier 
			remove_buffer $cel
		}
	}
	}
}


if {$flag == 3} {
if {[get_object_name [get_related_supply_nets [get_ports -quiet [all_fanin  -to [get_ports $port] -flat -startpoints_only]]]] == [get_object_name [get_related_supply_net [get_ports $port] ]] } {
	foreach_in_collection cel [get_cells [remove_from_collection [get_cells [all_fanin -to [get_ports $port] -only_cells -flat]] [get_cells -hier *diode*]]] {
		set cel [get_object_name $cel]
		if {[llength [split $cel "/"]] == 1} {
			puts "change hierarchy of $cel to $hier"
			rcg::change_hierarchy -cell $cel -hier $hier 
		}
	}
	}
}




}


define_proc_attributes rcg::add_buffer_on_route_surgical \
    -info "this script is to get the netlist from vault and copy it to inputs" \
    -define_args {
        {-port "give the port name for a surgical fix" "" string required}
        {-hier "give the hier name for a surgical fix" "" string required}
    }









proc rcg::convert_normal_to_aob {args} {
    parse_proc_arguments -args $args opts

set cell $opts(-cell)
set lib_cell $opts(-lib_cell)
set power $opts(-power)
set hier $opts(-hier)

if {[get_attribute [get_cells $cell] physical_status] != "fixed"} {
puts "converting cell $cell to always on buffer connecting vcc_in to power $power"
set input_net [get_nets -of [get_pins -of ${cell} -filter "direction == in && port_type == signal"]]
set output_net [get_nets -of [get_pins -of ${cell} -filter "direction == out"]]

set x_cor [lindex [lindex [get_attribute [get_cells $cell] bbox] 0] 0]
set y_cor [lindex [lindex [get_attribute [get_cells $cell] bbox] 0] 1]

if {[llength [split $cell "/"]] == 1} {
puts "change hierarchy of $cell to $hier"
#remove_cell $cell 
#create_cell $cell $lib_cell
#
#connect_net $input_net [get_pins -of $cell -filter "direction == in && port_type == signal"]
#connect_net $output_net [get_pins -of $cell -filter "direction == out"]
#connect_supply_net  $power -port ${cell}/VDDR
set_reference -to_block $lib_cell $cell -verbose
connect_supply_net  $power -port ${cell}/VDDR
puts "rcg :: connect supply net"
if {$hier != "."} {
puts "before changing hierarchy"
rcg::change_hierarchy -cell $cell -hier $hier -power $power
puts "after changing hierarchy"
}
#move_object -to "$x_cor $y_cor" [get_cell ${hier}/$cell]
}

if {$hier == "."} {
puts "no change in hierarchy of $cell"
set_reference -to_block $lib_cell $cell -verbose
connect_supply_net  $power -port ${cell}/VDDR
}
}
}


define_proc_attributes rcg::convert_normal_to_aob \
    -info "convert normal buffer or inverter to AOB/AOI."\
    -define_args {
        {-cell  "master name of cell" "" string required}
        {-lib_cell  "master name of cell" "" string required}
        {-power  "master name of cell" "" string required}
        {-hier  "hierarchy of cell" "" string required}
        {-verbose "verbose" "" int optional}
    }









proc rcg::convert_aob_to_normal {args} {
    parse_proc_arguments -args $args opts

set cell $opts(-cell)
set lib_cell $opts(-lib_cell)
set power $opts(-power)
set hier $opts(-hier)

if {[get_attribute [get_cells $cell] physical_status] != "fixed"} {
puts "converting cell $cell to always on buffer connecting vcc_in to power $power"
set input_net [get_nets -of [get_pins -of ${cell} -filter "direction == in && port_type == signal"]]
set output_net [get_nets -of [get_pins -of ${cell} -filter "direction == out"]]

set x_cor [lindex [lindex [get_attribute [get_cells $cell] bbox] 0] 0]
set y_cor [lindex [lindex [get_attribute [get_cells $cell] bbox] 0] 1]

if {[llength [split $cell "/"]] == 1} {
puts "change hierarchy of $cell to $hier"
set_reference -to_block $lib_cell $cell -verbose
puts "rcg :: connect supply net"
if {$hier != "."} {
puts "before changing hierarchy"
rcg::change_hierarchy -cell $cell -hier $hier
puts "after changing hierarchy"
}

#move_object -to "$x_cor $y_cor" [get_cell ${hier}/$cell]
}

if {$hier == "."} {
puts "no change in hierarchy of $cell"
set_reference -to_block $lib_cell $cell -verbose -pin_rebind force
}

}
}


define_proc_attributes rcg::convert_aob_to_normal \
    -info "convert normal buffer or inverter to AOB/AOI."\
    -define_args {
        {-cell  "master name of cell" "" string required}
        {-lib_cell  "master name of cell" "" string required}
        {-power  "master name of cell" "" string required}
        {-hier  "hierarchy of cell" "" string required}
        {-verbose "verbose" "" int optional}
    }



####################### proc to remove isolation cell






proc rcg::swap_isolation_to_buffer {args} {
    parse_proc_arguments -args $args opts

set cell $opts(-cell)
set lib_cell $opts(-lib_cell)
set power $opts(-power)

set iso_data [get_object_name [get_pins -of [get_cells $cell] -filter "name == A"]]
set iso_data_net [get_nets -of [get_object_name [get_pins -of [get_cells $cell] -filter "name == A"]]]
set iso_enable [get_object_name [get_pins -of [get_cells $cell] -filter "name == EN"]]
set iso_out [get_object_name [get_pins -of [get_cells $cell] -filter "direction == out"]]
set iso_out_net [get_nets -of [get_object_name [get_pins -of [get_cells $cell] -filter "direction == out"]]]

set data_driver [get_object_name [get_flat_pins -of [get_nets -of $iso_data] -filter "direction == out"]]
set data_load [get_object_name [get_flat_pins -of [get_nets -of ${iso_out}] -filter "direction == in"]]

create_cell ${cell}_CONVERTED_BUF ${lib_cell}
set iso_x [lindex [get_attribute [get_cells $cell] origin] 0]
set iso_y [lindex [get_attribute [get_cells $cell] origin] 1]

remove_cell $cell

connect_net -net $iso_data_net ${cell}_CONVERTED_BUF/A
connect_net -net $iso_out_net ${cell}_CONVERTED_BUF/X

#connect_pins -driver $data_driver ${cell}_CONVERTED_BUF/A
#connect_pins -driver ${cell}_CONVERTED_BUF/X $data_load

move_object -to "$iso_x $iso_y" [get_cell ${cell}_CONVERTED_BUF]

}


define_proc_attributes rcg::convert_aob_to_normal \
    -info "convert normal buffer or inverter to AOB/AOI."\
    -define_args {
        {-cell  "master name of cell" "" string required}
        {-lib_cell  "master name of cell" "" string required}
        {-verbose "verbose" "" int optional}
    }



#####################################



proc rcg::hectro_scan_fix {args} {
    parse_proc_arguments -args $args opts

set cell $opts(-cell)

set iso_data [get_object_name [get_pins -of [get_cells $cell] -filter "name == A"]]
set iso_enable [get_object_name [get_pins -of [get_cells $cell] -filter "name == EN"]]
set iso_out [get_object_name [get_pins -of [get_cells $cell] -filter "direction == out"]]

set data_driver [get_object_name [get_flat_pins -of [get_nets -of $iso_data] -filter "direction == out"]]
set data_load [get_object_name [get_flat_pins -of [get_nets -of ${iso_out}] -filter "direction == in"]]
set correct_pin ""
	
	if {[sizeof_collection [get_related_supply_nets [get_pins $data_load]]] > 1} {
		set source_rsn [get_related_supply_net $data_driver]
		foreach pin $data_load {
			if {[get_object_name [get_related_supply_net $pin]] == [get_object_name $source_rsn]} {
				lappend correct_pin $pin
			}
		}
	} else {
	puts "check for a different solution for cell $cell"
	}
	
	puts "correcting connection\n"
	if {[sizeof_collection [get_pins $correct_pin]] > 0} {
		connect_pin -incremental -driver $data_driver $correct_pin
	}

}


define_proc_attributes rcg::hectro_scan_fix \
    -info "fix hectrogenus isolation cells connections."\
    -define_args {
        {-cell  "master name of cell" "" string required}
        {-verbose "verbose" "" int optional}
    }


##################################### insert isolation cells



proc rcg::insert_isolation_cells {args} {
    parse_proc_arguments -args $args opts

set pin $opts(-pin)
set libCell $opts(-lib_cell)
set crtlSig $opts(-control_signal)
set isoName $opts(-iso_name)

#set libCell "ts05nxqllogl06hdp051f_customdg_frame_timing_ccs_all|ts05nxqllogl06hdp051f_customdg_frame_timing_ccs/HDPLVT06_ISOS1CL0_CA3QPY2_2"
#set pin "cdtglue_inf/CMI0_FBIST_TAP_CMI_lba[0]"
#set crtlSig "dpmaaunit/st_powergood_rst_b"

set driver [get_flat_pins -of [get_flat_nets -of $pin] -filter "direction == out" -quiet]

set hier [file dirname $pin]

if {$hier != "."} {
set newCellName ${hier}/snps_[get_object_name [get_power_domains -of [file dirname $pin]]]_${isoName}_[file tail $pin]_UPF_ISO
} else {
set newCellName snps_[get_object_name [get_power_domains -of DEFAULT_VA]]_${isoName}_[file tail $pin]_UPF_ISO
set hier "/"
}
if {[sizeof_coll [get_cells $newCellName -quiet]] > 0} {
	puts "Iso cell already exists with this name stopping script execution further"
	return
} else {
	puts "inserting a new isolation cell on pin $pin using $libCell and control signals $crtlSig"
	create_cell $newCellName $libCell 	
	set_scope $hier
	set cellInHier [file tail $newCellName]
	set sink [get_ports [file tail $pin]]
	set net [get_nets -of [get_ports  [file tail $pin]]]
	set_scope
	if {$hier != "/"} {
	edit_module [get_modules [get_attribute [get_cells $hier] ref_name] ] {
		disconnect_net  [file tail $pin]
        	connect_pin -driver [get_pins -of [file tail ${newCellName}] -filter "direction == out"] [get_ports [file tail $pin] ]
        }
	} else {
		disconnect_net  [file tail $pin]
		connect_pin -driver [get_pins -of [file tail ${newCellName}] -filter "direction == out"] [get_ports [file tail $pin] ]
	}
	if {[sizeof_coll [get_pins -all ${newCellName}/VDDR]] > 0} {
		connect_supply_net VNNAON -ports ${newCellName}/VDDR
		#connect_pg_net -automatic
	}	
	if {[sizeof_collection [get_flat_pins $driver -quiet]] > 0} {
		connect_pin -incremental -driver $driver [get_flat_pins -of ${newCellName} -filter "direction == in && name != EN"]
	}
		connect_pin -incremental -driver $crtlSig ${newCellName}/EN

}
}


define_proc_attributes rcg::insert_isolation_cells \
    -info "insert isolation cells and connect to control signal."\
    -define_args {
        {-pin  "hierarchical pin" "" string required}
        {-lib_cell  "isolation cell" "" string required}
        {-control_signal  "control signal" "" string required}
        {-iso_name  "iso name postfix" "" string required}
        {-verbose "verbose" "" int optional}
    }


########################


proc driver_load_srsn {} {

set fil [open "details.rpt" w]
foreach_in_collection net [get_flat_nets -filter "dr_length >=200"] {


set driver [get_flat_pins -of $net -filter "direction == out"]
set supernet [create_supernet -name temp_sn $driver]


set loads [remove_from_collection [get_flat_pins -of $net -filter "direction == in"] [get_pins -hier *diode*]]
set loads [add_to_collection [get_pins $loads ] [get_ports -of $net -filter "direction == out"]]

set loads [get_attribute [get_supernet $supernet] loads]
set driver [get_attribute [get_supernet $supernet] drivers]

puts "[get_object_name [get_related_supply_net $driver]] [get_object_name $net] [get_object_name [get_related_supply_net $loads]]"
if {[get_object_name [get_related_supply_net $driver]] == "VCC_ST"} {
#puts "[get_object_name [get_related_supply_net $driver]] [get_object_name $net] [get_object_name [get_related_supply_net $loads]]"
puts $fil "[get_object_name [get_attribute [get_flat_nets $net] dr_length]] [get_object_name [get_related_supply_net $driver]] [get_object_name $net] [get_object_name [get_related_supply_net $loads]]"
}
remove_supernets [get_supernets -hier *]
}
close $fil
}

#################### Port load supplies #####################
 proc check_all_connection {port} {
	 set snet [create_supernet -name test [get_ports $port]]
	 set drsn [get_related_supply_net [get_attribute [get_supernet $snet] drivers]]
 	 set lrsn [get_related_supply_net [get_attribute [get_supernet $snet] loads]]
 
	 puts "[get_object_name $drsn] :: [get_object_name $lrsn]"
 	remove_supernet [get_supernet -hier *]
 
 }






############################3



proc rcg::convert_aob_to_normal2 {args} {
    parse_proc_arguments -args $args opts

set cell $opts(-cell)
set lib_cell $opts(-lib_cell)
set hier [file dirname $cell]

if {[get_attribute [get_cells $cell] physical_status] != "fixed"} {
puts "converting cell $cell to always on buffer connecting vcc_in to power "
set input_net [get_nets -of [get_pins -of ${cell} -filter "direction == in && port_type == signal"]]
set output_net [get_nets -of [get_pins -of ${cell} -filter "direction == out"]]

set x_cor [lindex [lindex [get_attribute [get_cells $cell] bbox] 0] 0]
set y_cor [lindex [lindex [get_attribute [get_cells $cell] bbox] 0] 1]

if {[llength [split $cell "/"]] == 1} {
puts "change hierarchy of $cell to $hier"
set_reference -to_block $lib_cell $cell -verbose
puts "rcg :: connect supply net"
if {$hier != "."} {
puts "before changing hierarchy"
rcg::change_hierarchy2 -cell $cell -hier $hier
puts "after changing hierarchy"
}

#move_object -to "$x_cor $y_cor" [get_cell ${hier}/$cell]
}

if {$hier == "."} {
puts "no change in hierarchy of $cell"
set_reference -to_block $lib_cell $cell -verbose -pin_rebind force
}

}
}


define_proc_attributes rcg::convert_aob_to_normal2 \
    -info "convert normal buffer or inverter to AOB/AOI."\
    -define_args {
        {-cell  "master name of cell" "" string required}
        {-lib_cell  "master name of cell" "" string required}
        {-power  "master name of cell" "" string required}
        {-hier  "hierarchy of cell" "" string required}
        {-verbose "verbose" "" int optional}
    }







proc rcg::change_hierarchy2 {args} {
parse_proc_arguments -args ${args} opt
set cell $opt(-cell)
set hier $opt(-hier)

if {[info exists opt(-power)]} {
set power $opt(-power)
} else {
set power VNNAON
}

set in_pin [get_object_name [get_pins -of $cell -filter "direction == in"]]
set in_pin_name [get_attribute [get_pins $in_pin] name]
set in_net [get_object_name [get_nets -of [get_pins -of $cell -filter "direction == in"]]]

set out_pin [get_object_name [get_pins -of $cell -filter "direction == out"]]
set out_pin_name [get_attribute [get_pins $out_pin] name]
set out_net [get_object_name [get_nets -of $out_pin]]

set sink [add_to_collection [get_flat_pins -quiet -of [get_flat_net -of $out_pin] -filter "direction == in"] [get_ports -quiet -of [get_flat_net -of $out_pin]]]
set driver [add_to_collection [get_flat_pins -quiet -of [get_flat_nets -of [get_flat_pins -of [get_cells $cell] -filter "direction == in"]] -filter "direction == out"] [get_ports -of [get_flat_nets -of [get_flat_pins -of [get_cells $cell] -filter "direction == in"]] -quiet]]

set ref_cell [get_attribute [get_cells $cell] ref_name]

set psec_pg [sizeof_collection [get_flat_pins -of [get_cells $cell] -all -filter "name == VDDR" -quiet]]
if {$psec_pg > 0} {
set pg_sec [get_attribute [all_connected [get_flat_pins -of [get_cells $cell] -all -filter "name == VDDR" -quiet]] name ]
set pg_sec $power
}


set origin [get_attribute [get_cells $cell] origin]
set x_origin [lindex $origin 0]
set y_origin [lindex $origin 1]

remove_cell $cell
create_cell ${cell} $ref_cell 

#connect_net $in_net ${hier}/${cell}/${in_pin_name}
#connect_net $out_net ${hier}/${cell}/${out_pin_name}
set new_out_pin [get_flat_pin -of  ${cell} -filter "direction == out"]
set new_in_pin [get_flat_pin -of  ${cell} -filter "direction == in"]

connect_pin -driver $new_out_pin $sink -port_name fix_mv_rcg
connect_pin -driver $driver $new_in_pin -port_name fix_mv_rcg
set psec_pg [sizeof_collection [get_flat_pins -of [get_cells $cell] -all -filter "name == VDDR" -quiet]]

if {$psec_pg > 0} {
connect_supply_net $pg_sec -port ${hier}/${cell}/VDDR
}


move_objects [get_cells ${hier}/${cell}] -to "$x_origin $y_origin" -from {0 0}

}


define_proc_attributes rcg::change_hierarchy2 \
    -info "this is teh push cells to hierarchy" \
    -define_args {
        {-cell "give the cell name for a hier fix" "" string required}
        {-hier "give the hier name for the push" "" string required}
        {-power "give the supply name for secondary pg pin" "" string optional}
    }















#############################################

proc change_hierarchy_to_top_buffer {cell} {

set in_pin [get_object_name [get_pins -of $cell -filter "direction == in"]]
set in_pin_name [get_attribute [get_pins $in_pin] name]
set in_net [get_object_name [get_nets -of [get_pins -of $cell -filter "direction == in"]]]

set out_pin [get_object_name [get_pins -of $cell -filter "direction == out"]]
set out_pin_name [get_attribute [get_pins $out_pin] name]
set out_net [get_object_name [get_nets -of $out_pin]]

set sink [add_to_collection [get_flat_pins -quiet -of [get_flat_net -of $out_pin] -filter "direction == in"] [get_ports -quiet -of [get_flat_net -of $out_pin]]]
set driver [add_to_collection [get_flat_pins -quiet -of [get_flat_nets -of [get_flat_pins -of [get_cells $cell] -filter "direction == in"]] -filter "direction == out"] [get_ports -of [get_flat_nets -of [get_flat_pins -of [get_cells $cell] -filter "direction == in"]] -quiet]]

set ref_cell [get_attribute [get_cells $cell] ref_name]

set psec_pg [sizeof_collection [get_flat_pins -of [get_cells $cell] -all -filter "name == VDDR" -quiet]]
if {$psec_pg > 0} {
set pg_sec [get_attribute [all_connected [get_flat_pins -of [get_cells $cell] -all -filter "name == VDDR" -quiet]] name ]
set pg_sec $power
}


set origin [get_attribute [get_cells $cell] origin]
set x_origin [lindex $origin 0]
set y_origin [lindex $origin 1]

if {[llength [split $cell "/"]] == 1} {

if {$hier == "top"} {
create_cell [file tail ${cell}] $ref_cell 
} else {
create_cell ${hier}/${cell} $ref_cell 
}

remove_cell $cell

if {$hier == "top"} {
set new_out_pin [get_flat_pin -of [file tail ${cell}] -filter "direction == out"]
set new_in_pin [get_flat_pin -of  [file tail ${cell}] -filter "direction == in"]
} else {
set new_out_pin [get_flat_pin -of  ${hier}/${cell} -filter "direction == out"]
set new_in_pin [get_flat_pin -of  ${hier}/${cell} -filter "direction == in"]
}

connect_pin -driver $new_out_pin $sink -port_name fix_mv_rcg
connect_pin -driver $driver $new_in_pin -port_name fix_mv_rcg
if {$psec_pg > 0} {
connect_supply_net $pg_sec -port ${hier}/${cell}/VDDR
}


move_objects [get_cells ${hier}/${cell}] -to "$x_origin $y_origin" -from {0 0}
}

}


