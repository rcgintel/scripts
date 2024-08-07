

set fil [open "MVTable.rpt" w]
#set supNet {VCCFPGM_GCD VCCGT VCCIO VCCST VCC_D2D_CFI VCC_D2D_COM VCC_D2D_DFX VCC_INF_COM VCC_INF_GT VNNAON}
set supNet [ get_object_name [remove_from_collection [get_supply_nets -root ] [get_supply_nets VSS]]]
    puts -nonewline $fil "drv/snk "
foreach sn $supNet {
    puts -nonewline $fil "$sn "
}
puts $fil ""

foreach supNetDriver $supNet {
    puts -nonewline $fil "$supNetDriver "
    foreach supNetLoad $supNet {
        set supN "$supNetDriver $supNetLoad"
        redirect -variable rpt {report_system_pst -supplies  [get_supply_nets $supN]}
        set flag 1
        set MVCell ""
        puts $rpt
        foreach lin $rpt {
            if {$flag == 0} {
                set driver [lindex [split $lin ","] 0]
                set loads [lindex [split $lin ","] 1]
                #puts "$driver $loads"
                if {$loads == "*" || $driver == "*"} {
                    continue
                }
                if {$loads == "OFF"} {
                    lappend MVCell "nil"
                    continue
                }

                if {$driver == "OFF" && $loads == "OFF"} {
                    lappend MVCell "nil"
                } elseif {$driver == "OFF" && $loads != "OFF"} {
                    lappend MVCell "iso"
                } elseif {$driver == $loads} {
                    lappend MVCell "nil"
                } elseif {$driver > $loads} {
                    lappend MVCell "ls"
                } elseif {$driver < $loads} {
                    lappend MVCell "ls"
                }
            }
            if {$flag == 1} {
                set driverSup [lindex [split $lin ","] 0]
                set loadSup [lindex [split $lin ","] 1]
                set flag 0
            }
        }
        #puts $MVCell
        if {[lsearch -exact $MVCell "iso"] != -1 && [lsearch -exact $MVCell "ls"] != -1} {
            set MVUseCell "ELS"
        } elseif {[lsearch -exact $MVCell "iso"] != -1} {
            set MVUseCell "ISO"
        } elseif {[lsearch -exact $MVCell "ls"] != -1} {
            set MVUseCell "LS"
        } else {
            set MVUseCell "NIL"
        }
        puts "$supNetDriver $supNetLoad $MVUseCell"
        puts -nonewline $fil "$MVUseCell "
        #puts "#######################"
    }
    puts $fil ""
}

close $fil

