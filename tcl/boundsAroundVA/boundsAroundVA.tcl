
namespace eval rcg {
puts "using rcg MV scripts"
}



proc rcg::MVBoundCreate {args} {
## set default values 
set opt(-Verbose) 0

parse_proc_arguments -args ${args} opt
set Distance -$opt(-Distance)
set Verbose $opt(-Verbose)
gui_change_highlight -remove -all_colors
puts "the number of voltage areas are [sizeof_coll [get_voltage_areas *]]\n "
	foreach_in_collection pdVAs [get_voltage_areas *] {
                set pdN [get_object_name $pdVAs]
		if {$Verbose} {puts "rcg(Verbose): workin on [get_object_name $pdVAs]"}
                ### get the bbox of voltage area
                set obj1 [compute_polygons -objects1  [get_voltage_area_shapes -of [get_voltage_areas $pdVAs]] -objects2 [get_voltage_area_shapes -of [get_voltage_areas $pdVAs]] -operation AND]
                set obj2Reduced [resize_polygons -objects [compute_polygons -objects1  [get_voltage_area_shapes -of [get_voltage_areas $pdVAs]] -objects2 [get_voltage_area_shapes -of [get_voltage_areas $pdVAs]] -operation AND] -size "$Distance $Distance $Distance $Distance"]
                set bbox [get_attribute [compute_polygons -objects1 $obj1 -objects2 $obj2Reduced -operation XOR] poly_rects]
                #create_placement_blockage -name temp_${count} -type soft -boundary $bbox
                create_bound -name MV_bound_${pdN} -boundary $bbox -type hard
                if {[sizeof_collection [get_flat_cells -quiet -of [get_voltage_areas $pdVAs] -filter "name =~ *UPF_ISO*"]] > 0} {
                    add_to_bound MV_bound_${pdN} [get_flat_cells -of [get_voltage_areas $pdVAs] -filter "name =~ *UPF_ISO*"]
                }
                if {[sizeof_collection [get_flat_cells -quiet -of [get_voltage_areas $pdVAs] -filter "name =~ *UPF_LS*"]] > 0} {
                    add_to_bound MV_bound_${pdN} [get_flat_cells -of [get_voltage_areas $pdVAs] -filter "name =~ *UPF_LS*"]
                }

	}
}

define_proc_attributes rcg::MVBoundCreate \
    -info "create bounds at boundary of voltage area" \
    -hide_body \
    -define_args {
        {-Distance "give the distance the boundary has to be shinked " "" string required}
        {-Verbose "verbose " "" boolean optional 0}
}







proc rcg::isoPowerCheck {args} {
## set default values 
set opt(-Verbose) 0

parse_proc_arguments -args ${args} opt
set VoltageArea $opt(-VoltageArea)
set Verbose $opt(-Verbose)
gui_change_highlight -remove -all_colors
puts "the number of voltage areas are [sizeof_coll [get_voltage_areas *]]\n "
	foreach_in_collection pdVAs [get_voltage_areas $VoltageArea] {
                catch {unset secondary}
                array set secondary {}
                set pdN [get_object_name $pdVAs]
		if {$Verbose} {puts "rcg(Verbose): workin on [get_object_name $pdVAs]"}
                ### get the bbox of voltage area
                #create_placement_blockage -name temp_${count} -type soft -boundary $bbox
                if {[sizeof_collection [get_flat_cells -quiet -of [get_voltage_areas $pdVAs] -filter "name =~ *UPF_ISO*"]] > 0} {
                    foreach_in_collection isoCell [get_flat_cells -quiet -of [get_voltage_areas $pdVAs] -filter "name =~ *UPF_ISO"] {
                        ## find the secondary pin for the iso cell
                        set pgPin [remove_from_collection [get_flat_pins -of [get_flat_cells $isoCell] -filter "pg_type == primary" -all] [get_flat_pins -of [get_flat_cells $isoCell] -filter "name == VDD" -all]]
                        set pgPin [remove_from_collection [get_flat_pins $pgPin -all] [get_flat_pins -of [get_flat_cells $isoCell] -filter "name == VSS" -all]]
                        foreach_in_collection pgPin $pgPin {
                             set pgName [get_object_name [get_supply_nets  -of $pgPin]]
                             lappend secondary($pgName) [get_object_name $pgPin]
                        }
                    }
                }
                if {[sizeof_collection [get_flat_cells -quiet -of [get_voltage_areas $pdVAs] -filter "name =~ *UPF_LS*"]] > 0} {
                    foreach_in_collection isoCell [get_flat_cells -quiet -of [get_voltage_areas $pdVAs] -filter "name =~ *UPF_LS"] {                    
                        set pgPin [remove_from_collection [get_flat_pins -of [get_flat_cells $isoCell] -filter "pg_type == primary" -all] [get_flat_pins -of [get_flat_cells $isoCell] -filter "name == VDD" -all]]
                        set pgPin [remove_from_collection [get_flat_pins $pgPin -all] [get_flat_pins -of [get_flat_cells $isoCell] -filter "name == VSS" -all]]
                        foreach_in_collection pgPin $pgPin {
                             set pgName [get_object_name [get_supply_nets  -of $pgPin]]
                             lappend secondary($pgName) [get_object_name $pgPin]
                        }
                }
                }
            set colors {red blue green orange purple yellow}
            set colorIndex 0
            foreach arName [array name secondary] {
             # assign color to isolation cells
             set color [lindex $colors $colorIndex]
             puts "cells having secondary connection to $arName are marked in $color within voltage area $VoltageArea"
             puts "[sizeof_collection [get_cells -of $secondary($arName)]]"
             incr colorIndex
             gui_change_highlight -remove -color $color
             gui_change_highlight  -color $color -collection  [get_flat_cells -of $secondary($arName)]
            }
	}
        #return [array get secondary]
}

define_proc_attributes rcg::isoPowerCheck \
    -info "check the isolation and LS secondary PG requirement" \
    -hide_body \
    -define_args {
        {-VoltageArea "give the voltage Areas " "" string required}
        {-Verbose "verbose " "" boolean optional 0}
}




