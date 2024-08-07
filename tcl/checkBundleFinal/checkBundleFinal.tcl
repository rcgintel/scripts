namespace import ::tcl::mathfunc::*


proc getDistanceDiff {cell port} {
set portCenterX [lindex [lindex [get_attribute [get_ports $port] bbox] 0] 0]
set portCenterY [lindex [lindex [get_attribute [get_ports $port] bbox] 0] 1]

set cellBox [get_attribute [get_cells $cell] bbox]
set cellBoxX1 [lindex [lindex $cellBox 0] 0]
set cellBoxY1 [lindex [lindex $cellBox 0] 1]
set cellBoxX2 [lindex [lindex $cellBox 1] 0]
set cellBoxY2 [lindex [lindex $cellBox 1] 1]


set portXBoxX1 [abs [expr $portCenterX - $cellBoxX1]]
set portXBoxX2 [abs [expr $portCenterX - $cellBoxX2]]

set portXBoxY1 [abs [expr $portCenterY - $cellBoxY1]]
set portXBoxY2 [abs [expr $portCenterY - $cellBoxY2]]

### now find which edge the port aligns to
if {$portXBoxX1 < $portXBoxX2} {
set xCloser $portXBoxX1
} else {
set xCloser $portXBoxX2
}

if {$portXBoxY1 < $portXBoxY2} {
set yCloser $portXBoxY1
} else {
set yCloser $portXBoxY2
}

if {$xCloser < $yCloser} {
    #puts "aligns to vertical"
    set distCheckVal $xCloser
    set toCheckVal "Y"
} else {
    #puts "aligns to horizontal"
    set distCheckVal $yCloser
    set toCheckVal "X"
}

if {$toCheckVal == "X"} {
   if {[abs [ expr $portCenterX - $cellBoxX1]] < [abs [ expr $portCenterX - $cellBoxX2]]} {
       set dist [abs [ expr $portCenterX - $cellBoxX1]]
   } else {
       set dist [abs [ expr $portCenterX - $cellBoxX2]]
   }
} else {
   if {[abs [ expr $portCenterY - $cellBoxY1]] < [abs [ expr $portCenterY - $cellBoxY2]]} {
       set dist [ expr $portCenterY - $cellBoxY1]
   } else {
       set dist [ expr $portCenterY - $cellBoxY2]
   }
}
return $dist
}

proc rcgGenSplitPinVio {prefix &current_full_nets} {

    upvar 1 ${&current_full_nets} current_full_nets
    set size($prefix) [sd_get_rc_size -coll $current_full_nets($prefix)]

        puts "the size of the prefix is $size($prefix)"
        set ports [get_object_name [get_ports -of_objects $current_full_nets($prefix)]]
        set intersectingCells ""
        foreach port $ports {
            set cellInterSect [get_object_name [get_cells -intersect [get_attribute $port bbox]]]
            puts "port $port intersects with $cellInterSect"
            if {$cellInterSect in $intersectingCells} {
                incr count($cellInterSect)
                append portParent($cellInterSect) "$port "
            } else {
                lappend intersectingCells $cellInterSect
                set count($cellInterSect) 1
                set portParent($cellInterSect) "$port "
            }
        }


    if {[llength $intersectingCells] > 1} {
        parray count
        set maxParent [lindex [lsort -decreasing -stride 2 -integer -index 1 [array get count]] 0]
        puts "need to move all the port to $maxParent edge"
        set invalidCells [get_object_name [remove_from_collection [get_cells [array names count] ] [get_cells $maxParent]]]
        set invCellReturn ""
        foreach invalidCell $invalidCells {
            puts "these ports $portParent($invalidCell) are present on edge of $invalidCell needs to be moved to $maxParent edge"
            set maxViolation 0
            foreach port $portParent($invalidCell) {
                lappend invCellReturn $port
                set portCellDistance [abs [getDistanceDiff $maxParent $port]]
                if {$portCellDistance > $maxViolation} {
                    set maxViolation $portCellDistance
                }
                puts "port $port violating by $portCellDistance dist"
            }
            puts "the maximum violation is $maxViolation"
        }
        gui_change_highlight -remove -all_colors
        gui_change_highlight -toggle -collection [get_ports -of_objects $current_full_nets($prefix)]
        #return "$maxParent:$maxViolation:$portParent($invalidCell)"
        return "$maxParent:$maxViolation:$invCellReturn"
    } else {
        return "0:0:nil"
    }
}

###################################### MAIN ######################
set prefix ",INTERNAL=gtmsnodecompar11/bmcbunit1,EXTERNAL=gtmempipecenter2/gtmcnodecom1/gtmcgacspar11:PORT,MFO=0,PORT=1"
set prefixs [list ",INTERNAL=gtmsnodecompar11/lngpunit1,EXTERNAL=gtmempipeside0/gtmsnodebot1/gtmsnodebotpar31:PORT,MFO=0,PORT=1" ",INTERNAL=gtmsnodecompar11/lngpunit1,EXTERNAL=gtaxfeast1/gtglobalpar21:gtaxfwest1/gtscmi0par11:PORT,MFO=0,PORT=1"]
source /nfs/site/disks/elg_x2_a0_msnodecom_fp_01/gjothy/gtmsnodecom_ww03p3_run1/builds/gtmsnodecom.ww05p2_run2/00_dp/130_pushdown/work/rcg/rcgCheckVio
source /nfs/site/disks/elg_x2_a0_msnodecom_fp_01/rcg/gtmsnodecom_auto_prefix_collection/prefixs

set fil [open "incorrectPin.html" w]

puts $fil ""
puts $fil "<!DOCTYPE html>\n<html>\n<style>\n
table, th, td {\n
  border:1px solid black;\n
}\n
   img {\n
        border: 2px solid #C0C0C0;\n
        padding: 5px;\n
      }\n
</style>\n
<body>\n
<h2>Pin split issues in nodecom</h2>\n
<table style=\"width:100%\">\n
<tr id=\"header-row\">
    <td>ID</td>
    <td>Correct Block</td>
    <td>No vio pins</td>
    <td>Max vio dist</td>
    <td>pin names</td>
    <td>image</td>
</tr>
"
set countRcg 0
if [file exists "pngInfo"] {
puts "png directory exists"
sh rm -rf pngInfo
}
sh mkdir pngInfo
set currentPWD [pwd]
foreach prefix $prefixs {
     set datas [split [rcgGenSplitPinVio $prefix current_full_nets] ":"]
     puts $datas
     set maxParent [lindex $datas 0]
     set data [lindex $datas 1]
     set portMismatch [lindex $datas 2]
     set lPortMismatch [expr [llength [split $portMismatch " "]] - 1]
     if {$portMismatch != "nil"} {
        gui_write_window_image -window Layout.1 -file ${currentPWD}/pngInfo/check${countRcg}.png
        puts $fil "<tr>\n <td>$countRcg</td>\n <td>${maxParent}</td>\n <td>${lPortMismatch}</td>\n <td>${data}</td>\n <td>${portMismatch}</td>\n <td><a target=\"_blank\" href=\"${currentPWD}/pngInfo/check${countRcg}.png\"><img src=\"${currentPWD}/pngInfo/check${countRcg}.png\" alt=\"Autumn\" width=\"200\"></a></td>\n </tr>\n"
        incr countRcg
     }

}
puts $fil "</table>\n
</body>\n
</html>"
close $fil


