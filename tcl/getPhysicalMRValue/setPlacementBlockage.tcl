proc createBlockage {name instanceName } {
set loc [getCenterBlock $instanceName]
set xloc [lindex [lindex $loc 0] 0]
set yloc [lindex [lindex $loc 0] 1]

set origin [get_attribute $instanceName origin]
set loc "{[lindex $origin 0] [lindex $origin 1]}"

set xloc [lindex $origin 0]
set yloc [lindex $origin 1]

set loc [get_bbox_center -bbox [get_attribute [get_cells $instanceName] bbox]]
set xloc [lindex $loc 0]
set yloc [lindex $loc 1]
set loc "{[lindex $loc 0] [lindex $loc 1]}"

set loc "$loc {[expr $xloc+10] [expr $yloc+10]}"
set locs [SqlLoc $name $instanceName]
if {$locs != 0} {
set loc "{[lindex $locs 0] [lindex $locs 1]}"

set loc "$loc {[lindex $locs 2] [lindex $locs 3]}"
}

set pb [create_placement_blockage -type hard -boundary $loc -name $name]
if {$instanceName == "gtmempipeside0/gtmsnodetop1/gtmsnodetoppar11"} {
move_objects [get_placement_blockage $pb ] -delta {0 -526}
}
if {$instanceName == "gtmempipeside0/gtmsnodetop1/gtmsnodetoppar31"} {
move_objects [get_placement_blockage $pb ] -delta {0 -614}
}
if {$instanceName == "gtmempipeside0/gtmsnodetop1/gtmsnodetoppar51"} {
move_objects [get_placement_blockage $pb ] -delta {0 -374}
}


puts "create_placement_blockage -type hard -boundary $loc -name $name"
set len [llength [get_attribute [get_cells $instanceName] boundary]]
set loc [lindex [get_attribute [get_cells $instanceName] boundary] [expr $len - 1]]
puts "$instanceName"
puts $loc
#move_objects [get_placement_blockages ${name}] -to $loc
puts "move_objects [get_placement_blockages ${name}] -to $loc"

}

proc SqlLoc {repId instanceName} {

set o [sh python /nfs/site/disks/vmisd_vclp_efficiency/rcg/repo/python/sqlGoldenRepeater/getBoundLoc.py -C $repId -D /nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/runs/xe2/timingGenFCData/18p7Data/goldenRepeater.db]
if {$o != "None"} {
regexp {.*\{(\d+.\d+ \d+.\d+)\}\s+\{(\d+.\d+ \d+.\d+)\}.*} $o a bbox1 bbox2

set origin [get_attribute $instanceName origin]

set llx [expr [lindex $bbox1 0] + [lindex $origin 0]]
set lly [expr [lindex $bbox1 1] + [lindex $origin 1]]

set urx [expr [lindex $bbox2 0] + [lindex $origin 0]]
set ury [expr [lindex $bbox2 1] + [lindex $origin 1]]

set bbox1 "$llx $lly"
set bbox2 "$urx $ury"

return "$bbox1 $bbox2"
} else {
return 0
}
}



proc getCenterBlock {instanceName} {

set bbox [get_attribute [get_cells $instanceName] bbox]
set x1 [lindex [lindex $bbox 0] 0]
set y1 [lindex [lindex $bbox 0] 1]

set x2 [lindex [lindex $bbox 1] 0]
set y2 [lindex [lindex $bbox 1] 1]

set xdiff [expr [::tcl::mathfunc::abs [expr $x2 - $x1]]/ 2]
set ydiff [expr [::tcl::mathfunc::abs [expr $y2 - $y1]]/ 2]

set offset [get_attribute [get_cells $instanceName] origin]
set xoffset [lindex $offset 0]
set yoffset [lindex $offset 1]

set diff "{[expr $xoffset + $xdiff] [expr $yoffset + $ydiff]}"


return $diff
}



proc get_bbox_center {args} {
parse_proc_arguments -args $args results
set bbox_list $results(-bbox)
       set x1 [lindex [lindex $bbox_list 0] 0]
       set y1 [lindex [lindex $bbox_list 0] 1]
       set x2 [lindex [lindex $bbox_list 1] 0]
       set y2 [lindex [lindex $bbox_list 1] 1]
       set x [expr $x1+[expr [expr $x2-$x1]/2]]
       set y [expr $y1+[expr [expr $y2-$y1]/2]]
       set center ""
       lappend center $x
       lappend center $y
       return $center
}
define_proc_attributes get_bbox_center -info "To get centre of given bbox " \
-define_args {
      {-bbox  "bbox" name string required}
}


proc getCellName {cell} {
#puts "get the correct name for cell"
set foundCell 0

set count [llength [split $cell "/"]]
#set cell [join [lrange [split $cell "/"] 2 [expr $count - 1 ]] "/"]
set count [llength [split $cell "/"]]

set loopCount 0
    while {$foundCell == 0} {
        if {$loopCount > $count} {
            set foundCell 1
            return 0
        }
        #puts "check for cell "
        if {[sizeof_collection [get_cells $cell -quiet]] == 0} {
            set cell [file dirname $cell]
        } else {
            if {[get_attribute [get_cells $cell] design_type] == "module"} {
                set foundCell 1
                return $cell
            } else {
                set cell [file dirname $cell]
            }
        }
        incr loopCount
    }
}





proc checkRepID {id} {
#set repeater "gtmempipeside0/gtmsnodecom1/gtmsnodecompar11(77d61c9283df20838c0f88d64d86a5e9) -> gtmempipeside0/gtmsnodecom1/gtmsnodecompar31(88e65f29a2afb5b31b6a17365dd676c4) -> gtmempipeside0/gtmsnodebot1/gtmsnodebotpar51(c6614f52b7a4b43659951d839046c899) -> gtmempipeside0/gtmsnodebot1/gtmsnodebotpar71(d31cae96c29a45475b1c5a3b35e3be1c) -> gtmempipeside0/gtmsnodebot1/gtmsnodebotpar71(07cb915f980261968bd7430584763364)"
#set sp "gtmempipeside0/gtmsnodecom1/gtmsnodecompar11"
#set ep "gtmempipeside0/gtmsnodebot1/gtmsnodebotpar41"
cleanAnnotation
set fil [open "/nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/runs/xe2/timingGenFCData/18p7Data/goldenRepeater.csv" r]
set lines [split [read $fil] "\n"]
set con 0
foreach line $lines {
set dataLin $line
if {$con == $id} {
    break
}
incr con
}
set sp [lindex [split $line ","] 0]
set ep [lindex [split $line ","] 1]
set sp [getCellName $sp]
set ep [getCellName $ep]
set repeater [lindex [split $line ","] 2]

set allRepeaters [split $repeater "->"]
set listpb ""
set celNpb ""

foreach rep $allRepeaters {
    if {$rep != {}} {
        set rep [regsub -all " " $rep ""]
        set rep [regsub -all "\n" $rep ""]
        regexp {(.*)\((.*)\)} $rep matched instName repId
        set loc "{0 0} {10 10}"
        if {[sizeof_collection [get_placement_blockage ${repId}]] > 0} {
            remove_placement_blockage ${repId}_pb
            createBlockage ${repId} $instName 
        } else {
            createBlockage ${repId} $instName 
        }
            lappend listpb ${repId}
            lappend celNpb $instName
    }
}
set slack "0.0"

if {$slack < 0} { set color red } else {set color green}
create_annotation_text -text "Name: ${sp} \ntoSlack: ${slack}\nfromSlack: ${slack}" -origin [list [get_cells $sp] bbox_center 5% 5%] -color "yellow"

set cmd2 "gui_add_annotation  -window Layout.1 -width 3 -color red -type line \[list "
#set cmd2 "gui_add_annotation  -window Layout.1 -width 3 -color red -type manhattan_ruler \[list "

lappend cmd2 "\[list \[get_cells  $sp\] center\]"
puts "-> $listpb"

#set cnt 0
#foreach pb $listpb {
#    if {$cnt == 0} {
#        set startPnt $sp
#    }
#    set curPnt $pb
#    if {$cnt == [expr [llength $listpb] - 1]} {
#        set nxtPnt $ep
#    } else {
#    set nxtPnt [lindex $listpb [expr $cnt + 1]]
#    }
#    #puts "$startPnt $curPnt $nxtPnt"
#    puts "select * from goldenRepeater where repid == \"$curPnt\" and senderid like \"%$startPnt%\" and targetid like \"%$nxtPnt%\";"
#    set startPnt $curPnt
#    incr cnt
#}

#select * from goldenRepeater where repid == "31065ffc68d66cbf120c8041f2c30fca" and senderid == "gtaxfeast1/gtaxfms1par11/maxfgtunit1" and targetid == "367f48885cb15952b990917cd6f82d0b";

set cnt 0
foreach cell $listpb instN $celNpb {
    if {$cnt == 0} {
        set startPnt $sp
    }
    set curPnt $cell
    if {$cnt == [expr [llength $listpb] - 1]} {
        set nxtPnt $ep
    } else {
    set nxtPnt [lindex $listpb [expr $cnt + 1]]
    }
    #puts "$startPnt $curPnt $nxtPnt"
    set fil [open "sqlCmd.sql" w]
    #puts $fil "select * from goldenRepeater where repid == \"$curPnt\" and senderid like \"%$startPnt%\" and targetid like \"%$nxtPnt%\";"
    puts $fil "select * from goldenRepeater where repid == \"$curPnt\" ;"
    puts "select * from goldenRepeater where repid == \"$curPnt\" and senderid like \"%$startPnt%\" and targetid like \"%$nxtPnt%\";"
    close $fil
    set sqGD [sh python /nfs/site/disks/vmisd_vclp_efficiency/rcg/repo/python/sqlGoldenRepeater/timingDataDump.py -C "sqlCmd.sql" -D /nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/runs/xe2/timingGenFCData/18p7Data/goldenRepeater.db]
    puts ">>$sqGD"
    #regsub "," $p ""
    if {$sqGD != "None"} {
    set toslack [regsub -all "," [lindex $sqGD 4] ""]
    set toslack [regsub -all "\"" $toslack ""]
    set toslack [regsub -all "'" $toslack ""]
    set slack -999.00
    set matched 0
    regexp {.*?(-?\d+\.\d+.).*} $toslack matched slack
    set toslack $slack

    puts "rcgCheck: $toslack"
    set fromslack [regsub -all "," [lindex $sqGD 5] ""]
    set fromslack [regsub "\"" $fromslack ""]
    set fromslack [regsub -all "'" $fromslack ""]
    set slack -999.00
    regexp {.*?(-?\d+\.\d+.).*} $fromslack matched slack
    set fromslack $slack
    
    
    #puts $sqGD
    set startPnt $curPnt
    incr cnt
    } else {
        set toslack -999.00
        set fromslack -999.00
    }

    puts "location: [lindex $sqGD  6]"

    lappend cmd2 "\[list \[get_placement_blockages ${cell}\] center\]"
    if {($toslack < 0) | ($fromslack < 0)} { set color red } else {set color green}
    create_annotation_text -text "Parent: ${instN} \nName: ${cell} \nfromSlack: $toslack \ntoSlack: $fromslack" -origin [list [get_placement_blockages ${cell}] bbox_center 5% 5%] -color ${color}

}

lappend cmd2 "\[list \[get_cells  $ep\] center\]"
lappend cmd2 "\]"
#puts [join $cmd " "]
set cmd2 [join $cmd2 " "]

regsub { $cmd2 "" cmd2
regsub } $cmd2 "" cmd2
eval $cmd2

}

proc cleanAnnotation {} {
    catch {remove_placement_blockages -all}
    catch {gui_remove_all_annotations -window Layout.1}
    catch {remove_annotation_shapes [get_annotation_shapes]}
}

proc updateRepIDLoc {} {
set sqlFile [open "sqlCmd.sql" w]
foreach_in_collection pb [get_placement_blockages [get_selection]] {
    set pb [get_object_name $pb]
set origin [lindex [get_attribute [get_placement_blockage $pb] bbox] 0]
puts "$pb $origin"
set cmd "update goldenRepeater set location = \"$origin\" where repid = \"$pb\"; "
puts $sqlFile $cmd
#set o [sh python /nfs/site/disks/vmisd_vclp_efficiency/rcg/repo/python/sqlGoldenRepeater/sqlAddGetData.py -C "select * from goldenRepeater;" -D /nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/runs/xe2/goldenRepeater.db]
puts $cmd
#puts $cmd
}
close $sqlFile
sh python /nfs/site/disks/vmisd_vclp_efficiency/rcg/repo/python/sqlGoldenRepeater/sqlAddGetData.py -C "sqlCmd.sql" -D /nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/runs/xe2/timingGenFCData/18p7Data/goldenRepeater.db
#UPDATE ExampleTable SET age = 18 WHERE age = 17

}


proc updateBoundRepIDLoc {instName} {
set sqlFile [open "sqlCmd.sql" w]
foreach_in_collection pb [get_placement_blockages [get_selection]] {
    set pb [get_object_name $pb]
set origin [lindex [get_attribute [get_placement_blockage $pb] bbox] 0]
set bbox [get_attribute [get_placement_blockage $pb] bbox]
set iOrigin [get_attribute [get_cells $instName] origin]
set iOriginx [lindex [get_attribute [get_cells $instName] origin] 0]
set iOriginy [lindex [get_attribute [get_cells $instName] origin] 1]
set llx [expr [lindex [lindex $bbox 0] 0] - $iOriginx]
set lly [expr [lindex [lindex $bbox 0] 1] - $iOriginy]
set urx [expr [lindex [lindex $bbox 1] 0] - $iOriginx]
set ury [expr [lindex [lindex $bbox 1] 1] - $iOriginy]
set bbox "{$llx $lly} {$urx $ury}"



set cmd "INSERT OR replace INTO blockBound (repId, boundBbox) VALUES (\"$pb\",\"$bbox\");"
puts $sqlFile $cmd

set cmd "update blockBound set boundBbox = \"$bbox\" where repid = \"$pb\"; "
puts $sqlFile $cmd


set cmd "insert into repeaterLocation (repid,location) values (\"${instName}/${pb}\",\"$bbox\"); "
puts $sqlFile $cmd

#set o [sh python /nfs/site/disks/vmisd_vclp_efficiency/rcg/repo/python/sqlGoldenRepeater/sqlAddGetData.py -C "select * from goldenRepeater;" -D /nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/runs/xe2/goldenRepeater.db]
puts $cmd
#puts $cmd
}
close $sqlFile
sh python /nfs/site/disks/vmisd_vclp_efficiency/rcg/repo/python/sqlGoldenRepeater/sqlAddGetData.py -C "sqlCmd.sql" -D /nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/runs/xe2/timingGenFCData/18p7Data/goldenRepeater.db
#UPDATE ExampleTable SET age = 18 WHERE age = 17
updateRepIDLoc
}

proc n {} {
    global count
    checkRepID $count
    incr count
}




