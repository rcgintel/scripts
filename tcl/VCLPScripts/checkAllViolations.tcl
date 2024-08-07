



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

proc checkAnalogNetIncorrect {fileName} {
set fileName [open "$fileName" w]
set tag "ANALOG_NET_INCORRECT"
set count 0
set errorCount 0
    foreach ids [get_violation_ids  $tag ] {
        set AnalogName [get_violation_field $ids AnalogPin]
        set DigitalName [get_violation_field $ids DigitalPin]
        #puts "$AnalogName $DigitalName"
        #get_trace_paths -from $AnalogName -to $DigitalName
        if {[string match */* $AnalogName] && [string match */* $DigitalName]} {
            puts "$AnalogName $DigitalName"
            incr errorCount
        } else {
            #puts "create waiver from ports to pins"
            #puts "$AnalogName $DigitalName"
            puts $fileName "waive_violation -add ${tag}_${count}_ID -tag $tag -filter {(AnalogPin == \"$AnalogName\") AND (DigitalPin == \"$DigitalName\")} -comment \"Auto checker waiver generated from rcg script\""
            incr count
        }
    }
    if {$errorCount >  0} {
        puts "your design has errors please correct file HSD for fixing the same"
    }
close $fileName
}

sh rm -rf vclpReports
sh mkdir vclpReports
checkAnalogNetIncorrect vclpReports/checkAnalogNetIncorrect.rpt
if {0} {
set count 0
set tag "ISO_BUFINV_STATE"
set projectName "PTLP"
#ANALOG_NET_INCORRECT"

#sh rm -rf dump_iso_bufinv_state
sh mkdir dump_iso_bufinv_state
set fil2 [open "dump_iso_bufinv_state/all_violations.rpt" w]
foreach ids [get_violation_ids  $tag -unwaived] {
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
      if {$projectName == "PTLP"} {
            set d_n [lindex [split $source_name "/"] 0]
        } else {
            set d_n [lindex [split $source_name "/"] 1]
        }
  }

  if {[lindex [split $sink_name "/"] 0] == "gt"} { 
    set s_n [lindex [split $sink_name "/"] 2]
  } else {
      if {$projectName == "PTLP"} {
            set s_n [lindex [split $sink_name "/"] 0]
        } else {
            set s_n [lindex [split $sink_name "/"] 1]
        }
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
       if {[sizeof_collection  [get_ports $sink_name -quiet]] > 0} {

        } else {
       if {[get_attribute [get_pins $sink_name] is_hierarchical]} {
        puts $fil2 "waiver needed: waive_lp -add ${tag}_${waiverTagCount} -tag \"ISO_BUFINV_STATE\" -filter {(LogicSource:PinName == \"${source_name}\") AND (LogicSink == \"${sink_name}\") AND (LogicSinkShortened == \"True\")} -comment {output is hanging}"
        incr waiverTagCount
       }
        }
       puts $fil2 "\n\n\n"
       puts $fil2 "##########"


}

close $fil2 
}


### check for WCL
#
#set count 0
#set tag "LS_STRATEGY_REDUND"
#set projectName "WCLA0"
#
#sh mkdir dump_iso_bufinv_state
##set fil [open "dump_iso_bufinv_state/all_violations.rpt" w]
#set fil [open "dump_iso_bufinv_state/waiverTieLow.tcl" w]
#set sourceName ""
#foreach ids [get_violation_ids  $tag -unwaived] {
#  set source_name [get_violation_field $ids DomainSource]
#  lappend sourceName $source_name
#  set sourcePrimary [get_pins -of [get_nets -of [get_pins -of [get_cells -of [get_pins -of [get_nets -of [get_pins $source_name]] -filter "direction == out" -leaf ] ] -filter "is_enable_pin == false && direction == in"]] -leaf -filter "direction == out"]
#  #  get_object_name [get_lib_cells -of [get_cells -of $sourcePrimary] ]
#    if {[regexp -all  {.*tilo.*} [get_object_name [get_lib_cells -of [get_cells -of $sourcePrimary] ]]    ]} {
#        puts "tielow cell added as source waived the violations"
#        lappend sourceName $source_name
#    }
#    puts "$source_name $sink_name"
#  }
#
#  foreach srcName [lsort -u $sourceName] {
#   puts $fil "waive_lp -add ${tag}_${count}  -comment {waived the error the tie low cell connected to isolation cell the output of the isolation is always grounded} -tag \"${tag}\" -filter {(DomainSource == \"${srcName}\")}"
#    incr count
#
#  }
#
#
#
#close $fil
#



proc checkLSStrategyRedundant {} {
set fil [open "isoCheck.rpt" w]
set tag "LS_STRATEGY_REDUND"
set count 0
set errorCount 0
    foreach ids [get_violation_ids  $tag ] {
        incr count
        set pin [get_violation_field $ids DomainSource]
        puts $pin
        if {[regexp "i0mtil" [get_object_name [get_lib_cells -of [get_cells -of [get_pins -of [get_nets -of $pin ] -leaf -filter "direction == out"]]]]]} {
            puts "connected tie low cell [get_object_name [get_pins -of [get_nets -of $pin ] -leaf -filter "direction == out"]]"
            puts "connected directly to tielow waived"
            waive_lp -add waiverRcg${count} -comment {script used to waive tie low cell added } -filter {tag == LS_STRATEGY_REDUND}
        } else {
            set isoDataPin [get_pins -of [get_cells -of [get_pins -of [get_nets -of $pin ] -leaf -filter "direction == out"] ] -filter "direction == in && (level_shifter_data_pin || isolation_cell_data_pin)"]
            #isolation_cell_data_pin
            set driverLibCell [get_object_name [get_lib_cells -of [get_cells -of [get_pins -leaf -of [get_nets -of [get_pins $isoDataPin]] -filter "direction == out"]]]]
            if {[regexp "i0mtil" $driverLibCell]} {
                puts "need to waive"
                waive_lp -add waiverRcg${count} -comment {script used to waive tie low cell added } -filter {tag == LS_STRATEGY_REDUND}
                #waive_violation -tag $tag -status Waived -id $ids
            } else {
                puts "Error"
                puts $fil "$pin"
                return
            }
        }
    }
close $fil 
}
checkLSStrategyRedundant

