puts "compare the 2 files and make the nexessary changes it is very specfic to a problem"

proc readFile {fileName} {
    puts "file name $fileName"
    set files [open $fileName r]
    set filesData [split [read $files] "\n"]
    close $files
    return $filesData
}


proc rcgGenSplitPinVio {prefix &current_full_nets} {

    upvar 1 ${&current_full_nets} current_full_nets
    set size($prefix) [sd_get_rc_size -coll $current_full_nets($prefix)]
    puts $size($prefix)
}

proc compareFiles {updatePrefix netCollection &current_full_nets} {
    #parse_proc_arguments -args ${args} opt
    #upvar $current_full_nets $opt(-currentFullNets)
    upvar 1 ${&current_full_nets} current_full_nets
    #set current_full_nets $opt(-currentFullNets)
    #upvar 1 ${&opt(-currentFullNets)} current_full_nets
    #set updatePrefix $opt(-updatePrefix)
    #set netCollection $opt(-netCollection)
    #upvar 1 ${&current_full_nets} current_full_nets
    #puts [array names current_full_nets]
    #return
    set fil [open "compared.tcl" w]
    puts "$updatePrefix -> $netCollection"
    puts "read file $updatePrefix get bus count and prefix name"
    set lines [readFile $updatePrefix]
    set count 0
    set countFound 0
    set eCount 0
    set eCountPrefix 0
    set tPrefix 0
    foreach line $lines {
        set val_ok [regexp {#(\d+)\s.*} $line matched num]

        if $countFound {
            puts $line
            set val_prefix [regexp {set prefix "(.*)"} $line matched namePrefix]
            if {$val_prefix} {
                #puts $namePrefix
                incr tPrefix
                try {
                    set result [exec grep $namePrefix $netCollection]
                } on error {e} {
                    # typically, pattern not found
                    set result "NIL"
                }
                if {$result == "NIL"} {
                    puts $fil "#-E- prefix pattern $namePrefix not found in net collection file"
                    incr eCountPrefix
                } else {
                    #set size($prefix) [sd_get_rc_size -coll $current_full_nets($prefix)]
                    set busSize [sd_get_rc_size -coll $current_full_nets($namePrefix)]
                    #set busSize 0
                    #puts "pattern found in net collection file the number of pins are $num the bussize is $busSize"
                    if {$num == $busSize} {
                        #continue
                        #puts "the busbit is matching"
                    } else {
                        puts $fil "#-E- bus bit is not matching previous db $num current db $busSize"
                        incr eCount
                    }
                }
            }
            set countFound 0
        }
        if {$val_ok} {
            #puts " matched! :)"
            #puts $num
            set countFound 1
        }
        puts $fil $line
    }
    close $fil
    puts "the number of errors are $eCount and prefix missing $eCountPrefix total prefix $tPrefix"
}


#define_proc_attributes compareFiles \
#    -info "this proc will compare the 2 files" \
#    -hide_body \
#    -define_args {
#        {-updatePrefix "give the update_prefix.tcl " "" string required}
#        {-netCollection "give the nets_collection.tcl " "" string required}
#    }
