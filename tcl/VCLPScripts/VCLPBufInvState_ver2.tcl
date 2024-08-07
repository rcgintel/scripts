



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




#set tags "ISO_BUFINV_STATE ISO_BUFINV_FUNC"

set waiverTagCount 54321
set tag "ISO_ELSINPUT_FUNC"
set count 0
sh rm -rf dump_iso_bufinv_state
sh mkdir dump_iso_bufinv_state
set fil2 [open "dump_iso_bufinv_state/all_violations.rpt" w]
foreach ids [get_violation_ids  $tag ] {
  set source_name [get_violation_field $ids LogicSource:PinName]
  set sink_name [get_violation_field $ids LogicSink]
  if {[info exists s_n]} {
   unset s_n
  }
  if {[info exists d_n]} {
   unset d_n
  }
  if {[lindex [split $source_name "/"] 0] == "gt"} { 
    set d_n [lindex [split $source_name "/"] 2]
  } else {
    set d_n [lindex [split $source_name "/"] 1]
  }

  if {[lindex [split $sink_name "/"] 0] == "gt"} { 
    set s_n [lindex [split $sink_name "/"] 2]
  } else {
    set s_n [lindex [split $sink_name "/"] 1]
  }
  puts $fil2 "violateion id : $ids"

  
     redirect -variable rpt {report_trace_paths [get_trace_paths -from $source_name -to $sink_name]  -lp}
     set datas [decodeTracePath $rpt]
     set data [lindex $datas 0]
     set sup_count ""
     set pre_sup "NA"
       incr count
       set waiveData ""
    foreach lin $data {
       if {[regexp {.*input.*} [lindex $lin 1]] | [regexp {.*output.*} [lindex $lin 1]]} {
        continue
       }
       puts $fil2 "$lin"
       puts $lin
       set type [lindex $lin 1]
       if {![regexp {.*boundary.*} $type]} {
         puts "match :[lindex $lin 2]: $pre_sup val : [string match [lindex $lin 2] $pre_sup]"
         if {![string match [lindex $lin 2] $pre_sup]} {
          if {[string match [lindex $lin 1] "ISOLATION"]} {
          	lappend sup_count "ISO([lindex $lin 2])"
          	set pre_sup "ISO([lindex $lin 2])"
          } else {
          	lappend sup_count [lindex $lin 2]
          	set pre_sup [lindex $lin 2]
          }
          puts "$pre_sup ::add:: $sup_count"
         }
         set waiveData [lindex $lin 0]
       }
     }
      puts "#########################"
       #set sup_count [lsort -u $sup_count]

       puts $fil2 "supply length: [llength $sup_count] : supsrcg $sup_count"
       puts $fil2 "path numer: $count : supply length: [llength $sup_count] : sups $sup_count ::> msg id: $ids"
       if {[get_attribute [get_pins $sink_name] is_hierarchical]} {
        puts $fil2 "waiver needed: waive_lp -add ${tag}_${waiverTagCount} -tag \"ISO_BUFINV_STATE\" -filter {(LogicSource:PinName == \"${source_name}\") AND (LogicSink == \"${sink_name}\") AND (LogicSinkShortened == \"True\")} -comment {output is hanging}"
        incr waiverTagCount
       }
       puts $fil2 "\n\n\n"
       puts $fil2 "##########"


}

close $fil2 






