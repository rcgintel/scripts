proc removeStart {myString} {
    set delimiter "/"
    set data [split $myString "/"]
    set count [llength $data]
    set name [join [lrange $data 1 [expr $count - 1]] "/"]
    return $name
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
            set cell [removeStart $cell]
            #set cell [file dirname $cell]
        } else {
            if {[get_attribute [get_cells $cell] is_active ] == "true"} {
                set foundCell 1
                return $cell
            } else {
                set cell [removeStart $cell]
                #set cell [file dirname $cell]
            }
        }
        incr loopCount
    }
}




set fil [open "/nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/runs/xe2/timingGenFCData/completeData.csv" r]
set fil2 [open "fullTimingStats.csv" w]

set lines [split [read $fil] "\n"]
set count 0
foreach line $lines {
    puts $line
    #string first "/" gtmempipeside0/gtmsnodecom1/gtmssqidi01/msqcwunit1
    set data [split $line ","]
    set id [lindex $data 0]
    set repId [lindex $data 1]
    if {[string first "/" $repId] > -1} {
        set repIdN [getCellName $repId]
        if {$repIdN == 0} {
            set repId $repId
        } else {
            set repId $repIdN
        }
    }

    set fromId [lindex $data 2]
    if {[string first "/" $fromId] > -1} {
        set fromIdN [getCellName $fromId]
        if {$fromIdN == 0} {
            set fromId $fromId
        } else {
            set fromId $fromIdN
        }
    }

    set toId [lindex $data 3]
    if {[string first "/" $toId] > -1} {
        set toIdN [getCellName $toId]
        if {$toIdN == 0} {
            set toId $toId
        } else {
            set toId $toIdN
        }

    }

    set toslack [lindex $data 4]
    set fromslack [lindex $data 5]
    set location [lindex $data 6]
    set lParent [lindex $data 7]
    set pParent [lindex $data 8]

    puts "get_timing_path -to \[get_cells -hierarchical * -filter \"full_name =~ *${repId}* && is_sequential == true\"\] -from \[get_cells -hierarchical * -filter \"full_name =~ *${fromId}* && is_sequential == true\"\]"
    set path [get_timing_path -to [get_cells -hierarchical * -filter "full_name =~ *${repId}* && is_sequential == true"] -from [get_cells -hierarchical * -filter "full_name =~ *${fromId}* && is_sequential == true"]]
    set fromSlack [get_attribute $path slack]
    puts "get_timing_path -from \[get_cells -hierarchical * -filter \"full_name =~ *${repId}* && is_sequential == true\"\] -to \[get_cells -hierarchical * -filter \"full_name =~ *${toId}* && is_sequential == true\"\]"
    set path [get_timing_path -from [get_cells -hierarchical * -filter "full_name =~ *${repId}* && is_sequential == true"] -to [get_cells -hierarchical * -filter "full_name =~ *${toId}* && is_sequential == true"]]
    set toSlack [get_attribute $path slack]
    if {[sizeof_coll [get_cells  -hierarchical * -filter "full_name =~ *${repId}* && is_sequential == true"]] > 0} {
        incr count
    }
    puts "################################################"
    puts "$id,$repId,$fromId,$toId,$toSlack,$fromSlack,$location,$lParent,$pParent"
    puts $fil2 "$id,$repId,$fromId,$toId,$toSlack,$fromSlack,$location,$lParent,$pParent"
    puts "################################################"
    #if {$count > 3} {
    #    break
    #}
}

close $fil
close $fil2
