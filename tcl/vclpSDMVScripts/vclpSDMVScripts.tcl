

namespace eval UPFSD {
puts "using UPFSD MV scripts"
}


proc UPFSD::InsertLSAtPin {args} {
    parse_proc_arguments -args ${args} opt
    set pinName $opt(-pinName)    
### insert level shifter ungfxpar1_inf_com/plm1_nonscan_visa_plm1_st_nonscan_1_VISA_DBG_LANE[3]
set levelShifterData(src) "LVLLHBUFFSRCCWWDRITLD4BWP143M286H3P48CPDULVTLL"
set levelShifterData(dest) "LVLLHBUFFSNKCWWDRITLD4BWP143M286H3P48CPDULVTLL"
set location "dest"
set newLSName [insert_buffer  $pinName $levelShifterData($location) ]

#### connect supply pin VDD to default supply
#vajith: need to connect pin VDD to default supply of argument pin

#### connect supply pin VDDS/L to driver / receiver supply
  #kdheeraj
# find the actual driver supply 
set driverSupply [get_object_name [get_supply_nets -of [get_attribute [get_flat_pins -of [get_flat_nets -of [get_flat_pins -of [get_cells $newLSName] -filter "direction == in"]] -filter "direction == out"] related_power_pin]]]
    if {$location == "dest"} {
        connect_supply_net $driverSupply -port [get_flat_pins -of [get_cells $newLSName] -all -filter "name == VDDL"]
    } else {
        connect_supply_net $driverSupply -port [get_flat_pins -of [get_cells $newLSName] -all -filter "name == VDDS"]
    }
}


define_proc_attributes UPFSD::InsertLSAtPin \
    -info "this proc will buffer the control signals implementation" \
    -hide_body \
    -define_args {
        {-pinName "give the library cells " "" float required}
    }


#
#proc UPFSD::MoveLSToParent {args} {
#
#
#}
#
#
#define_proc_attributes UPFSD::MoveLSToParent \
#    -info "this proc will buffer the control signals implementation" \
#    -hide_body \
#    -define_args {
#        {-lib_cell "give the library cells " "" string required}
#        {-xDistance "give the library cells " "" float required}
#        {-startPoint "give the origin to start the calculation from " "" string required}
#        {-routeMetal "give the metal routing for control signals" "" string required}
#    }
#

proc getDriver {cell} {

    return [get_object_name [get_flat_cells -of [get_flat_pins -of [get_flat_nets -of [get_flat_pins -of $cell -filter "direction == out"]] -filter "direction == in"]]]

}

proc findLSOnPath {cell} {
    set pinName $cell    
    ### trace from the pin name and check if this is a LS cell
    set count 0
    while {$count < 10} {
        puts "loop $count [get_object_name [get_cells $pinName]]"
            if {[sizeof_coll [get_cells $pinName -filter "is_level_shifter"]] > 0} {
                #puts "[get_object_name [get_cells $pinName]] at location $count"
                return [get_object_name [get_cells $pinName]]
            } else {
                set pinName [getDriver [get_cells $pinName]]
            }
        incr count
    }
}


