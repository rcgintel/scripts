



proc decodeTracePath {lines} {
 set flag 0
 set allData ""
 set supList ""
 if {[info exists a]} {
  unset a
 }
 foreach line [split $lines "\n"] {
   if $flag {
    if {[regexp {(.*?)\s+(.*?)\s+(.*?)\s+(.*?).*} $line ]} {
      regexp " (gt.*) VSS" $line match a
      if {[info exists a]} {
       regsub -all { +} $a { } b
       set lis [split $b " "]
       #puts "[lindex $lis 0] [file tail [lindex $lis 1]] [file tail [lindex $lis 2]]"
       lappend allData "[lindex $lis 0] [file tail [lindex $lis 1]] [file tail [lindex $lis 2]]"
       lappend supList [file tail [lindex $lis 2]]
       unset a
      }
    }
   }
   if {[regexp { ---.*} $line]} {
    set flag 1
   }
 }
set sup_len [llength [lsort -u $supList]]
puts $allData
puts $sup_len
return [list $allData $sup_len]
}





proc decodeTracePath {lines} {
 set flag 0
 set allData ""
 set supList ""
 if {[info exists a]} {
  unset a
 }
 foreach line [split $lines "\n"] {
   if $flag {
    if {[regexp {(.*?)\s+(.*?)\s+(.*?)\s+(.*?).*} $line ]} {
      regexp " (.*) VSS" $line match a
      if {[info exists a]} {
       regsub -all { +} $a { } b
       set lis [split $b " "]
       #puts "[lindex $lis 0] [file tail [lindex $lis 1]] [file tail [lindex $lis 2]]"
       lappend allData "[lindex $lis 0] [file tail [lindex $lis 1]] [file tail [lindex $lis 2]]"
       lappend supList [file tail [lindex $lis 2]]
       unset a
      }
    }
   }
   if {[regexp { ---.*} $line]} {
    set flag 1
   }
 }
set sup_len [llength [lsort -u $supList]]
puts $allData
puts $sup_len
return [list $allData $sup_len]
}






set tag "ISO_INST_MISSING"
set count 0
foreach ids [get_violation_ids  $tag ] {
  set source_name [get_violation_field $ids LogicSource:PinName]
  set sink_name [get_violation_field $ids LogicSink]
  if {[regexp "ungfxpar2/*" $source_name] && [regexp "ungfxpar1/*" $sink_name] } {
        puts "$ids : $source_name -> $sink_name"
  }
}


