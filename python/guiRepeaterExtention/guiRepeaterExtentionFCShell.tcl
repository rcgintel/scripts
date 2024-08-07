set ruler 0
set unplanned 0
set resetLocation 0
proc getCorrectCellName {args} {
    parse_proc_arguments -args ${args} opt
    set cell $opt(-cell)
    set foundCell 0
    set count [llength [split $cell "/"]]
    set count [llength [split $cell "/"]]

    set loopCount 0
    while {$foundCell == 0} {
        if {$loopCount > $count} {
            set foundCell 1
            return 0
        }
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


define_proc_attributes getCorrectCellName \
    -info "this proc will correct the cell name by removing the last hierarchy and checking if that exists" \
    -hide_body \
    -define_args {
        {-cell "give the cell name " "" string required}
    }




proc getRepIdInfo {args} {
    parse_proc_arguments -args ${args} opt
    set id $opt(-id)
    set database $opt(-database)
    #puts "the ID that we are running: $id"
    set cmd "select SenderUnitInst from Merged_BI_grip where \"rowNumber\" = $id;"
    #puts $cmd
    set senderInst [getCorrectCellName -cell [correctDatabaseOutput [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmd -D $database]]]
    
    set cmd "select TargetUnitInst from Merged_BI_grip where \"rowNumber\" = $id;"
    set targetInst [getCorrectCellName -cell [correctDatabaseOutput [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmd -D $database]]]
    #puts $cmd

    set cmd "select \"grip.RptsPartitions\" from Merged_BI_grip where \"rowNumber\" = $id;"
    set cmd "select instance from repeaterHash where rowNumber=$id;"
    #puts $cmd
    set repeaters ""
    foreach repeater [split [correctDatabaseOutput [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmd -D $database]] "("] {
        regsub -all {',\),} $repeater "" repeater
        regsub -all {'} $repeater "" repeater
        lappend repeaters [get_object_name [get_cells [getCorrectCellName -cell $repeater]]]
    }
    
    #puts "$senderInst ::: $targetInst :::> $repeaters"
    set cells ""
    foreach cell [concat $senderInst $repeaters $targetInst] {
        #puts $cell
        lappend cells $cell
    }
    highlightSPEP $cells
    return $cells
    #set senderBundle [lindex $data 3]
    #set receiverBundle [lindex $data 3]
}



define_proc_attributes getRepIdInfo \
    -info "this proc will get the full repeater information and add the placement blockage information" \
    -hide_body \
    -define_args {
        {-id "give the id name " "" string required}
        {-database "give the database name " "" string required}
    }



proc getLocationofInstance {inst} {

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



proc annotatePBRepId {args} {
    global resetLocation 
    parse_proc_arguments -args ${args} opt
    global ruler
    set id $opt(-id)
    set database $opt(-database)
    #puts "the ID that we are running: $id"
    cleanAnnotation
    set cmd "select hash from repeaterHash where rowNumber=$id;"
    set cmd2 "select instance from repeaterHash where rowNumber=$id;"
    #puts $cmd
    #puts $cmd2
    set hash [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmd -D $database]
    set instance [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmd2 -D $database]
    

    set cmd "select SenderUnitInst from Merged_BI_grip where \"rowNumber\" = $id;"
    set sp [getCorrectCellName -cell [correctDatabaseOutput [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmd -D $database]]]
    gui_change_highlight  -color  yellow  -collection  [get_cells $sp]

    set cmd "select TargetUnitInst from Merged_BI_grip where \"rowNumber\" = $id;"
    set ep [getCorrectCellName -cell [correctDatabaseOutput [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmd -D $database]]]
    gui_change_highlight  -color  red  -collection  [get_cells $ep]


    regsub -all {^\[|\(|\]|\)|\,|\'} $hash "" hash
    regsub -all {^\[|\(|\]|\)|\,|\'} $instance "" instance

    set hashs [split [regsub -all {\s+} $hash " "] " "]
    set instances [split [regsub -all {\s+} $instance " "] " "]

    
    set loc [get_bbox_center -bbox [get_attribute [get_cells $sp] bbox]]
    set xloc [lindex $loc 0]
    set yloc [lindex $loc 1]
    set loc "{[lindex $loc 0] [lindex $loc 1]}"
    set loc "$loc {[expr $xloc+50] [expr $yloc+50]}"

    set pbs ""
    
    #set pbname "pb_startpoint"
    #set pb [create_placement_blockage -type hard -boundary $loc -name $pbname]
    #lappend pbs $pb

    foreach hash $hashs instance $instances {
        puts "$hash $instance $resetLocation"
        set cmd "SELECT distinct sloc from repeaterHash WHERE hash='$hash';"
        set loc [correctDatabaseOutput [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmd -D $database]]
        regsub -all {^\[|\(|\]|\)|\,|\'} $loc "" loc
        regsub -all {^\s+} $loc "" loc

        if {$resetLocation} {
            set loc ""
        }
        if {$loc == ""} {
            set loc [get_bbox_center -bbox [get_attribute [get_cells $instance] bbox]]
            set xloc [lindex $loc 0]
            set yloc [lindex $loc 1]
            set loc "{[lindex $loc 0] [lindex $loc 1]}"
            set loc "$loc {[expr $xloc+50] [expr $yloc+50]}"
        }
        set pbname "pb_${hash}"
        lappend pbs [create_placement_blockage -type hard -boundary $loc -name $pbname]
    }

    
    set loc [get_bbox_center -bbox [get_attribute [get_cells $ep] bbox]]
    set xloc [lindex $loc 0]
    set yloc [lindex $loc 1]
    set loc "{[lindex $loc 0] [lindex $loc 1]}"
    set loc "$loc {[expr $xloc+50] [expr $yloc+50]}"
    #set pbname "pb_endpoint"
    #set pb [create_placement_blockage -type hard -boundary $loc -name $pbname]
    #lappend pbs $pb
    annotatePBRepList -pb $pbs -sp $sp -ep $ep
    return $pbs
}



define_proc_attributes annotatePBRepId \
    -info "this proc will get the full repeater information and add the placement blockage information" \
    -hide_body \
    -define_args {
        {-id "give the id name " "" string required}
        {-database "give the database name " "" string required}
    }



proc annotatePBRepList {args} {
    set color "red"
    global ruler
    puts "ruler: $ruler"
    parse_proc_arguments -args ${args} opt
    set pb $opt(-pb)
    set sp $opt(-sp)
    set ep $opt(-ep)
    #set cmd "gui_add_annotation  -window Layout.1 -width 3 -color ${color} -type line \[list  "
    #set cmd "gui_add_annotation  -window Layout.1 -width 3 -color ${color} -type line \[list \[list \[get_cells $sp\] center\] "
    if {$ruler} {
        set cmd "gui_add_annotation  -window Layout.1 -width 3 -color ${color} -type manhattan_ruler \[list \[list \[get_cells $sp\] center\] "
    } else {
        set cmd "gui_add_annotation  -window Layout.1 -width 3 -color ${color} -type line \[list \[list \[get_cells $sp\] center\] "
    }

    foreach cel [get_object_name [get_placement_blockage $pb]] {
        lappend cmd "\[list \[get_placement_blockage  $cel\] center\]"
    }
    #lappend cmd "\]"
    lappend cmd "\[list \[get_cells $ep\] center\]\]"
    set cmd [join $cmd " "]
    regsub {\{|\}} $cmd {} cmd
    #puts $cmd
    eval $cmd
}


define_proc_attributes annotatePBRepList \
    -info "this proc will annotate the full placement blockage information and add the placement blockage information" \
    -hide_body \
    -define_args {
        {-pb "give the database name " "" string required}
        {-sp "give the startpoint name " "" string required}
        {-ep "give the endpoint name " "" string required}
    }



proc correctDatabaseOutput {str} {
regsub -all {',\)]$|^\[\('} $str {} data
return $data
}


proc correctDatabaseOutput2 {ids} {
    regsub -all {,\),} $ids {} ids
    regsub -all {\(} $ids {} ids
    regsub -all {^\[} $ids {} ids
    regsub -all {,\)\]} $ids {} ids
    regsub -all {'} $ids {} ids
    regsub -all {\s+} $ids { } ids
    return $ids
}

proc cleanAnnotation {} {
    catch {remove_placement_blockages -all}
    catch {gui_remove_all_annotations -window Layout.1}
    catch {remove_annotation_shapes [get_annotation_shapes]}
    catch {gui_change_highlight -remove -all_colors}
    catch {remove_placement_blockages [get_placement_blockages *]}
}

proc highlightSPEP {cellList} {
    cleanAnnotation
    set sp [lindex [get_object_name [get_cells $cellList]] 0]
    gui_change_highlight  -color  yellow  -collection  [get_cells $sp]
    create_annotation_text -text "SP" -origin [list [get_cells $sp] bbox_center 5% 5%] -color "yellow"
    set count [sizeof_collection [get_cells $cellList]]
    set ep [lindex [get_object_name [get_cells $cellList]] [expr $count -1]]
    gui_change_highlight  -color  red  -collection  [get_cells $ep]
    create_annotation_text -text "EP" -origin [list [get_cells $ep] bbox_center 5% 5%] -color "red"
}

proc annotateCellList {cellList} {
    set color "red"
    set cmd "gui_add_annotation  -window Layout.1 -width 3 -color ${color} -type line \[list "
    foreach cel [get_object_name [get_cells $cellList]] {
        lappend cmd "\[list \[get_cells  $cel\] center\]"
    }
    lappend cmd "\]"
    set cmd [join $cmd " "]
    regsub {\{|\}} $cmd {} cmd
    #puts $cmd
    eval $cmd
}

proc annotateHashCellList {args} {
    set color "red"
    parse_proc_arguments -args ${args} opt
    set id $opt(-id)
    set count 0
    set cmd "gui_add_annotation  -window Layout.1 -width 3 -color ${color} -type line \[list "
    foreach cel [get_object_name [get_cells $cellList]] {
        lappend cmd "\[list \[get_cells  $cel\] center\]"
    }
    lappend cmd "\]"
    set cmd [join $cmd " "]
    regsub {\{|\}} $cmd {} cmd
    #puts $cmd
    eval $cmd
}


define_proc_attributes annotateHashCellList \
    -info "this proc will get the full repeater information and add the placement blockage information" \
    -hide_body \
    -define_args {
        
        {-id "give the id name " "" string required}
        {-database "give the database name " "" string required}
    }

proc findNearest {number list} {
    set nearest [lindex $list 0]
    set min_diff [expr {abs($nearest - $number)}]

    foreach item $list {
        set diff [expr {abs($item - $number)}]
        if {$diff < $min_diff} {
            set min_diff $diff
            set nearest $item
        }
    }
    return $nearest
}

proc MRRpt {args} {
    parse_proc_arguments -args ${args} opt
    set count 0
    global unplanned
    set pattern $opt(-pattern)
    set database $opt(-database)
    set ids $opt(-ids)
    if {$unplanned} {
    set cmds "SELECT rowNumber FROM Merged_BI_grip WHERE `STO Comments` LIKE '%New/Unplanned bundles%' AND SenderParInst <> TargetParInst AND SenderParInst LIKE '%${pattern}%';"
    } else {
    set cmds "SELECT rowNumber FROM Merged_BI_grip WHERE SenderParInst LIKE '%${pattern}%' AND SenderParInst <> TargetParInst;"
    }
    
    set allIds [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmds -D $database]
    set allIds [split [correctDatabaseOutput2 $allIds] " "]
    #findNearest ${ids} ${allIds}
    if {[lsearch $allIds $ids] < 0} {
        return [findNearest ${ids} ${allIds}]
        #return [lindex $allIds 0]
    } else {
        return [lindex $allIds [expr [lsearch $allIds $ids]+1]]
    }
}

define_proc_attributes MRRpt \
    -info "this proc will get the full repeater information and add the placement blockage information" \
    -hide_body \
    -define_args {
        {-database "give the database name " "" string required}
        {-pattern "give the pattern name " "" string required}
        {-ids "give the id name " "" string required}
        {-unPlanned "unplanned"     ""      boolean optional}
    }



proc commitRepeatersLocation {args} {
    parse_proc_arguments -args ${args} opt
    set count 0
    global unplanned
    set database $opt(-database)
    set ids $opt(-ids)
    set cmds "SELECT hash FROM repeaterHash WHERE rowNumber = $ids;"
    
    set allIds [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmds -D $database]

    set cmds "SELECT instance FROM repeaterHash WHERE rowNumber = $ids;"
    set instances [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServerCLI/runSqlCommands.py -C $cmds -D $database]

    set allIds [split [correctDatabaseOutput2 $allIds] " "]
    set instances [split [correctDatabaseOutput2 $instances] " "]

    foreach allId $allIds instance $instances {
        puts $allId
        set sloc [get_attribute [get_placement_blockages pb_${allId}] bbox]
        set orientation [get_attribute [get_cells ${instance}] orientation]
        set design [get_attribute [get_cells ${instance}] ref_name]
        puts "$sloc $orientation $design"
        set cmds "UPDATE repeaterHash SET sloc = \'$sloc\', orient = \'$orientation\', design = \'$design\' WHERE hash = \'$allId\';"
        set commit [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/repo/python/sqlGoldenRepeater/runSqlCommands.py -C $cmds -D $database]
    }
}

define_proc_attributes commitRepeatersLocation \
    -info "this proc will commit full repeater physical information and add the placement blockage information" \
    -hide_body \
    -define_args {
        {-database "give the database name " "" string required}
        {-ids "give the id name " "" string required}
    }


proc RepeaterGUI {args} {
    parse_proc_arguments -args ${args} opt
    global ruler
    toplevel .vladsTop
    frame .vladsTop.frAlles
    wm title .vladsTop "Repeater Planning"
    set database /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/guiRepeaterExtention/sqlite.db
    # create canvas with scrollbars
    canvas .vladsTop.frAlles.c -width 400 -height 400 -xscrollcommand ".vladsTop.frAlles.xscroll set" -yscrollcommand ".vladsTop.frAlles.yscroll set"
    scrollbar .vladsTop.frAlles.xscroll -orient horizontal -command ".vladsTop.frAlles.c xview"
    scrollbar .vladsTop.frAlles.yscroll -command ".vladsTop.frAlles.c yview"
    pack .vladsTop.frAlles.xscroll -side bottom -fill x
    pack .vladsTop.frAlles.yscroll -side right -fill y
    pack .vladsTop.frAlles.c -expand yes -fill both -side top
    
    set cbval ""
    set cbval2 ""
    set infos ""

    set entry1var "get_selection"
    # create frame with widgets
    frame .vladsTop.frAlles.c.frWidgets -borderwidth 1 -relief solid -width 400 -height 400
    
    label .vladsTop.frAlles.c.frWidgets.lbl -text "Repeater planning analysis"
    grid .vladsTop.frAlles.c.frWidgets.lbl -padx 2 -pady 2 -row 0 -column 1 

    # create frame with buttons
    
    label .vladsTop.frAlles.c.frWidgets.lbl3 -text "ID"
    grid .vladsTop.frAlles.c.frWidgets.lbl3 -padx 2 -pady 2 -row 3 -column 1 -columnspan 2

    entry .vladsTop.frAlles.c.frWidgets.entry2 -textvariable entry2var -width 20
    grid .vladsTop.frAlles.c.frWidgets.entry2 -padx 2 -pady 2 -row 3 -column  2 -columnspan 2 -sticky news

    button .vladsTop.frAlles.c.frWidgets.btOK -text "OK" -command { set id $entry2var; set cel [get_cells  [annotatePBRepId -id $id -database $database]]}
    grid .vladsTop.frAlles.c.frWidgets.btOK -padx 2 -pady 2 -row 3 -column 3 -columnspan 1 -sticky news
    button .vladsTop.frAlles.c.frWidgets.btOK2 -text "Analyse" -command {annotateCellList $cel}
    grid .vladsTop.frAlles.c.frWidgets.btOK2 -padx 2 -pady 2 -row 3 -column 4 -columnspan 1 -sticky news

    button .vladsTop.frAlles.c.frWidgets.btOK3 -text "Next" -command {incr entry2var; set id $entry2var; set cel [get_cells  [annotatePBRepId -id $id -database $database]]}
    grid .vladsTop.frAlles.c.frWidgets.btOK3 -padx 2 -pady 2 -row 3 -column 5 -columnspan 1 -sticky news

    button .vladsTop.frAlles.c.frWidgets.btOK4 -text "Back" -command {set entry2var [expr $entry2var - 1]; set id $entry2var; set cel [get_cells  [annotatePBRepId -id $id -database $database]]}
    grid .vladsTop.frAlles.c.frWidgets.btOK4 -padx 2 -pady 2 -row 3 -column 6 -columnspan 1 -sticky news
    
    #entry .vladsTop.frAlles.c.frWidgets.entryRepeater -textvariable entry1var -width 10
    #grid .vladsTop.frAlles.c.frWidgets.entryRepeater -padx 2 -pady 2 -row 4 -column 1 -columnspan 4 -sticky news -ipady 100 

    label .vladsTop.frAlles.c.frWidgets.labelFrom -text "From"
    grid .vladsTop.frAlles.c.frWidgets.labelFrom -padx 2 -pady 2 -row 5 -column 1 -columnspan 2

    entry .vladsTop.frAlles.c.frWidgets.entryFrom -textvariable entry1From -width 10
    grid .vladsTop.frAlles.c.frWidgets.entryFrom -padx 2 -pady 2 -row 5 -column 2 -columnspan 2 -sticky news -ipadx 10 

    checkbutton .vladsTop.frAlles.c.frWidgets.chk1 -text "ignore same ep/adj" -variable occupied1 
    grid .vladsTop.frAlles.c.frWidgets.chk1 -padx 2 -pady 2 -row 5 -column 4 -columnspan 1 -sticky news

    #checkbutton .vladsTop.frAlles.c.frWidgets.chk1 -text "ignore Adjacent" -variable occupied1 
    #grid .vladsTop.frAlles.c.frWidgets.chk1 -padx 2 -pady 2 -row 5 -column 4 -columnspan 1 -sticky news

    button .vladsTop.frAlles.c.frWidgets.btOK5 -text "change selection" -command { set entry1From [get_object_name [get_selection]]}
    grid .vladsTop.frAlles.c.frWidgets.btOK5 -padx 2 -pady 2 -row 5 -column 5 -columnspan 1 -sticky news

    checkbutton .vladsTop.frAlles.c.frWidgets.chk2 -text "unPlanned" -variable unplanned 
    grid .vladsTop.frAlles.c.frWidgets.chk2 -padx 2 -pady 2 -row 6 -column 4 -columnspan 1 -sticky news

    checkbutton .vladsTop.frAlles.c.frWidgets.chk3 -text "showRuler" -variable ruler
    grid .vladsTop.frAlles.c.frWidgets.chk3 -padx 2 -pady 2 -row 6 -column 5 -columnspan 1 -sticky news

    button .vladsTop.frAlles.c.frWidgets.btOK6 -text "MRCheck" -command { puts $occupied1; set pattern $entry1From ;set entry2var [MRRpt -database $database -pattern $pattern -ids $entry2var]; set id $entry2var; set cel [get_cells  [annotatePBRepId -id $id -database $database]]}
    grid .vladsTop.frAlles.c.frWidgets.btOK6 -padx 2 -pady 2 -row 5 -column 6 -columnspan 1 -sticky news


    frame .vladsTop.frAlles.c.frWidgets2 -borderwidth 1 -relief solid -width 400 -height 400

    button .vladsTop.frAlles.c.frWidgets2.btOK7 -text "CommitRepeater" -command { puts "commit repeater"; commitRepeatersLocation -database $database -ids $entry2var}
    grid .vladsTop.frAlles.c.frWidgets2.btOK7 -padx 2 -pady 2 -row 7 -column 1 -columnspan 1 -sticky news


    frame .vladsTop.frAlles.c.frButtons -borderwidth 1 -relief solid -width 240 -height 40
    button .vladsTop.frAlles.c.frButtons.btAbbruch -text "Cancel" -command {destroy .vladsTop}
    pack .vladsTop.frAlles.c.frButtons.btAbbruch -padx 2 -pady 2 -side left
    button .vladsTop.frAlles.c.frButtons.btClear -text "Clear" -command {cleanAnnotation}
    pack .vladsTop.frAlles.c.frButtons.btClear -padx 2 -pady 2 -side left

    # place widgets and buttons
    .vladsTop.frAlles.c create window 0 0 -anchor nw -window .vladsTop.frAlles.c.frWidgets 
    .vladsTop.frAlles.c create window 0 150 -anchor nw -window .vladsTop.frAlles.c.frWidgets2 
    .vladsTop.frAlles.c create window 200 380 -anchor w -window .vladsTop.frAlles.c.frButtons 
    

    # determine the scrollregion
    .vladsTop.frAlles.c configure -scrollregion [.vladsTop.frAlles.c bbox all]
    
    # show the canvas
    pack .vladsTop.frAlles -expand yes -fill both -side top
}

#ConvertBufferAOB  [array get CellInfo]

define_proc_attributes RepeaterGUI \
    -info "this proc will open gui to run repeater analysis" \
    -hide_body 





