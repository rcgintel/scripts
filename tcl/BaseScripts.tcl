
namespace eval rcg {
    puts "using rcg MV scripts"
}


# convert AOB to Normal


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





# convert normal to AOB
# convert ISO to Buffer
# convert ISO to ISOFlavours
# convert Buf to Buf Flavour
