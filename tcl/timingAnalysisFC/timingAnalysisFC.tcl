proc timingAnalysis { clk pathType fileName} {
    suppress_message UIC-058
    set TIME_start [clock clicks -milliseconds]
    set countPath 0
    set fil [open "dataFull.csv" a]
    #puts [sort_coll [filter_coll [eval all_registers -data_pins -clock $clk] "${pathType}_slack < 0"] ${pathType}_slack]
    puts "pathName, startpoint, endpoint, slack, clock_uncertainty, endpoint_clock, startpoint_clock, endpoint_clock_latency, startpoint_clock_latency, endpoint_clock_period, logic_levels, max_cell_delay"
    puts $fil "pathName, startpoint, endpoint, slack, clock_uncertainty, endpoint_clock, startpoint_clock, endpoint_clock_latency, startpoint_clock_latency, endpoint_clock_period, logic_levels, max_cell_delay"
    set vioPaths [sort_collection [filter_coll [eval all_registers -data_pins -clock $clk] "${pathType}_slack < 0"] ${pathType}_slack]
    if {[sizeof_coll $vioPaths] > 0} {
        puts "starting timing analysis for clock $clk"
        puts [get_object_name $vioPaths]
        foreach_in_collection path $vioPaths {
            #puts [get_object_name $path]
            set pathName "path_${countPath}"
            set startpoint [get_object_name [get_attribute [get_timing_path -to $path] startpoint]]
            set endpoint [get_object_name [get_attribute [get_timing_path -to $path] endpoint]]
            set slack [get_attribute [get_timing_path -to $path] slack]
            set clock_uncertainty [get_attribute [get_timing_path -to $path] clock_uncertainty]
            set endpoint_clock [get_object_name [get_attribute [get_timing_path -to $path] endpoint_clock]]
            set startpoint_clock [get_object_name [get_attribute [get_timing_path -to $path] startpoint_clock]]
            set endpoint_clock_latency [get_attribute [get_timing_path -to $path] endpoint_clock_latency]
            set startpoint_clock_latency [get_attribute [get_timing_path -to $path] startpoint_clock_latency]
            set endpoint_clock_period [get_attribute [get_timing_path -to $path] endpoint_clock_period]
            set logic_levels [get_attribute [get_timing_path -to $path] logic_levels]
            set max_cell_delay [get_attribute [get_timing_path -to $path] max_cell_delay]

            puts "[eval date] : $pathName, $startpoint, $endpoint, $slack, $clock_uncertainty, $endpoint_clock, $startpoint_clock, $endpoint_clock_latency, $startpoint_clock_latency, $endpoint_clock_period, $logic_levels, $max_cell_delay"
            puts $fil "$pathName, $startpoint, $endpoint, $slack, $clock_uncertainty, $endpoint_clock, $startpoint_clock, $endpoint_clock_latency, $startpoint_clock_latency, $endpoint_clock_period, $logic_levels, $max_cell_delay"
            incr countPath
        }
        set TIME_taken [expr [clock clicks -milliseconds] - $TIME_start]
        puts "time taken for the script is [expr ${TIME_taken}/1000] seconds"
    }
    #set coll   [sort_coll [filter_coll [eval all_registers -data_pins -clock $clk] max_slack<0] max_slack]
    #print $coll
    close $fil
    
    unsuppress_message UIC-058

}

foreach_in_collection clk [get_clock *] {
    set clk [get_object_name $clk]
    set pathType "max"
    set fileName "dataFull.csv"
    #puts $fil "pathName, startpoint, endpoint, slack, clock_uncertainty, endpoint_clock, startpoint_clock, endpoint_clock_latency, startpoint_clock_latency, endpoint_clock_period, logic_levels, max_cell_delay"
timingAnalysis $clk $pathType $fileName
}



