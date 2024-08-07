proc dumpSRSNBlock {} {
    set fil [open "blockSRSN.tcl" w]
    puts "dumping the SRSN for the block [get_object_name [get_designs]]"
  
     foreach_in_collection ports  [get_ports * -filter "direction == in"] {
        set SRSN [lsort -u [get_object_name [get_related_supply_net [remove_from_collection [get_flat_pins -of [get_flat_nets -of [get_ports $ports ]] -filter "direction == in"] [get_pins -of [get_cells -hier *diode*]]]]]]

        
        if {[llength $SRSN] == 0}  {
            continue
        }


        if {[llength $SRSN] > 1} {
          if {[lsearch $SRSN "VNNAON"]} {
            set SRSN [get_object_name [get_supply_sets *VNNAON*]]
          } else {
            puts $fil "### debug port $ports multiple supplies are associated"
          }
        } else {
            set SRSN [get_object_name [get_supply_sets *${SRSN}*]]
        }
        
        set cell [remove_from_collection [get_flat_pins -of [get_flat_nets -of [get_ports $ports ]] ] [get_pins -of [get_cells -hier *diode*]]]
        if {[sizeof_collection [get_pins $cell]] > 0} {
            puts $fil "#set_related_supply_net [get_object_name $ports] -power $SRSN"
            puts $fil "set_port_attributes  -ports {[get_object_name $ports]} -driver_supply $SRSN"
        } else {
            puts $fil "# SRSN undterministic for in port [get_object_name $ports]"
        }
    }




    foreach_in_collection ports  [get_ports * -filter "direction == out"] {
        set SRSN [lsort -u [get_object_name [get_related_supply_net [remove_from_collection [get_flat_pins -of [get_flat_nets -of [get_ports $ports ]] -filter "direction == out"] [get_pins -of [get_cells -hier *diode*]]]]]]

        if {[llength $SRSN] == 0}  {
            continue
        }

        if {[llength $SRSN] > 1} {
          if {[lsearch $SRSN "VNNAON"]} {
            set SRSN [get_object_name [get_supply_sets *VNNAON*]]
          } else {
            puts $fil "### debug port $ports multiple supplies are associated"
          }
        } else {
            set SRSN [get_object_name [get_supply_sets *${SRSN}*]]
        }

        set cell [remove_from_collection [get_flat_pins -of [get_flat_nets -of [get_ports $ports ]] ] [get_pins -of [get_cells -hier *diode*]]]
        if {[sizeof_collection [get_pins $cell]] > 0} {
            puts $fil "#set_related_supply_net [get_object_name $ports] -power $SRSN"
            puts $fil "set_port_attributes  -ports {[get_object_name $ports]} -receiver_supply $SRSN"
        } else {
            puts $fil "# SRSN undterministic for out port [get_object_name $ports]"
        }
    }

    close $fil

}

dumpSRSNBlock
#set_port_attributes  -ports  {generic_ramdftin_6} -literal_supply VNNAON
