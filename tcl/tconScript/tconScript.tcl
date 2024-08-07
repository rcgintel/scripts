proc inferData {ports} {
	set eval_start_time [clock seconds]
	if {[get_attribute [get_ports $ports] direction] == "out"} {
		set all_fanin_regs [lsort -u [get_object_name [get_attribute [get_pins -quiet -of_obj [get_cells -quiet -of_obj  [all_fanin -to $ports -flat]]] clocks]]]
	} else {
		set all_fanin_regs [lsort -u [get_object_name [get_attribute [get_flat_pins -quiet -of_obj [get_cells -quiet -of_obj [all_fanout -from $ports -flat]]] clocks]]]
	}
	if {$all_fanin_regs == ""} {
		set_attribute -objects [get_ports $ports] -name relClocks -value "TCON-ERROR"

	} else {
			set_attribute -objects [get_ports -quiet $ports] -name relClocks -value [get_object_name $all_fanin_regs ]
			set_attribute -objects [get_ports -quiet $ports] -name tranEvalTime -value [expr [clock seconds ] - $eval_start_time]
	}
}

proc getPortDrvRec {args} {
    parse_proc_arguments -args ${args} opt
	set delay [expr $opt(-delay) * 1]
	set fileName $opt(-fileName) 
	set feedthDelay [expr $opt(-feedthDelay) * 1]

	set fil [open $fileName w]

	set start_time [clock seconds]
	update_timing 
	puts "Done update timing in [expr [clock seconds ] - $start_time] sec"
	define_user_attribute -class {port} -type string -name relClocks 
	define_user_attribute -class {port} -type int -name tranEvalTime
	set count 0
	set totalCount 1
	foreach_in_collection outPort [remove_from_collection [get_ports [all_outputs] ]  [get_ports *FEEDTH*]] {
		if {$count > 100} {
			puts "ports processed is [expr $count * $totalCount] out of [sizeof_coll [get_ports [remove_from_collection [all_outputs] [get_ports *FEEDTH*]]]] "
			incr totalCount
			set count 0
		}
			incr count
			inferData $outPort
	}
	set count 0
	set totalCount 1

	foreach_in_collection outPort [remove_from_collection [get_ports [all_inputs] ] [get_ports *FEEDTH*]] {
			if {$count > 100} {
				puts "ports processed is [expr $count * $totalCount] out of [sizeof_coll [get_ports [remove_from_collection [all_inputs] [get_ports *FEEDTH*]]]] "
				incr totalCount
				set count 0
			}
				incr count
				#puts "process ports [get_object_name $outPort]"
				inferData $outPort
	}

	foreach clockName [get_object_name [get_clocks *]] {
		set ports [get_object_name [filter_collection [get_ports * -filter "direction == out"] "relClocks == $clockName"]]
		#puts $ports
		set clockPeriod [get_attribute $clockName period]
		set delay [expr $clockPeriod  * $delay]
		puts "processing for clock $clockName"
		if {[llength $ports] > 0} {
			puts $fil "set_output_delay $delay -add_delay -clock $clockName -max -rise \[get_object_name \[get_ports \[ list $ports \]\]\]"
			puts $fil "set_output_delay $delay -add_delay -clock $clockName -max -fall \[get_object_name \[get_ports \[ list $ports \]\]\]"
			puts $fil "set_output_delay $delay -add_delay -clock $clockName -min -rise \[get_object_name \[get_ports \[ list $ports \]\]\]"  
			puts $fil "set_output_delay $delay -add_delay -clock $clockName -min -fall \[get_object_name \[get_ports \[ list $ports \]\]\]"  

		}
		
		set ports [get_object_name [filter_collection [get_ports * -filter "direction == in"] "relClocks == $clockName"]]
		if {[llength $ports] > 0} {
			puts $fil "set_input_delay $delay -add_delay -clock $clockName -max -rise \[get_object_name \[get_ports \[ list $ports \]\]\]"
			puts $fil "set_input_delay $delay -add_delay -clock $clockName -max -fall \[get_object_name \[get_ports \[ list $ports \]\]\]"  
			puts $fil "set_input_delay $delay -add_delay -clock $clockName -min -rise \[get_object_name \[get_ports \[ list $ports \]\]\]"  
			puts $fil "set_input_delay $delay -add_delay -clock $clockName -min -fall \[get_object_name \[get_ports \[ list $ports \]\]\]"  

		}
		#puts $ports

	}
	### set the feedth delay
	foreach_in_collection fthPort [get_ports *FEEDTH* -filter "direction == out"]  {
		create_supernet [get_ports $fthPort ] -name temp
		puts $fil "set_max_delay $feedthDelay -to [get_object_name [get_ports $fthPort]] -from [get_object_name [get_attribute [get_supernet temp] drivers]]"
		#set_max_delay $feedthDelay -to [get_object_name [get_ports $fthPort]] -from [get_object_name [get_attribute [get_supernet temp] drivers]]
		remove_supernet *
	}
	close $fil
	source $fileName
	puts "Done port data Generation in [expr [clock seconds ] - $start_time] sec"
}



define_proc_attributes getPortDrvRec \
    -info "this proc will set the IO delays for the design" \
    -hide_body \
    -define_args {
        {-delay "give the iodelay " "" string required}
        {-fileName "give the fileName " "" string required}
	{-feedthDelay "give the max delay for feedth ports " "" string required}
    }




set current_scenario [current_scenario]
set all_scenarios [get_attribute [get_scenarios ] full_name]
foreach scen $all_scenarios {
	current_scenario $scen
	set cur_file ${scen}_tcon_file.tcl
	puts "Generating the tcons in $scen "
	getPortDrvRec -delay "0.5" -fileName $cur_file -feedthDelay "2"
}

current_scenario $current_scenario

