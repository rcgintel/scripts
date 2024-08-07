proc fixTimingPath {args} {
    parse_proc_arguments -args $args opts
    if {[info exists opts(-endpoint)]} {
            set timingPath $opts(-endpoint)
            puts "$timingPath data"
    
    redirect -variable timP {report_timing -to $opts(-endpoint) -nosplit}
        set flag 0
        foreach lin [split $timP "\n"] {
            set lin [string trim $lin]
            #set lin [regsub -all "  " $lin " "]
            set lin [regsub -all "\\s{2,}" $lin " "]
            set matchVar [regexp "(.*?)\s+(.*?)\s+(.*?)\s.*" $lin inst incD totD]
            
            if {$flag} {
                if {$matchVar} {
                    puts "$lin,$inst,$incD,$totD"
                }
            }

            set patMatch [regexp ".*clock network delay.*" $lin ]
            if {$patMatch} {
                set flag 1    
            }
            set patMatch [regexp ".*data arrival time.*" $lin ]
            if {$patMatch} {
                set flag 0
            }

            set matchVar 0
        }
    }


}

define_proc_attributes fixTimingPath \
    -info "fix timing path.\n" \
    -define_args {
        {-endpoint "work on timing path" "" string optional}
        {-startpoint "work on timing path" "" string optional}
    }

