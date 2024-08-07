### create a config and run from matrix.csv


proc runMatrix {args} {
parse_proc_arguments -args ${args} opt
puts "csv files picked from  $opt(-csvFile)"

if {[file exists $opt(-csvFile)]} {
	set flag 1
	set csvFile $opt(-csvFile)
	while {$flag} {
		puts "running matrix loading csv file"
		set fp [open $csvFile r]
		set file_data [read $fp]
		
		set roundCompleteCSV [open "MatrixCompleted.csv" w]
		set runsCompleted ""
		set columnsCount [expr [llength [split [lindex $file_data 0] ","]] -1]
		for {set colCount 1} {$colCount <= $columnsCount} {incr colCount} {
			set loadDataFile [open "loadDataFile.tcl" w]
			foreach data [lrange [split $file_data "\n"] 0 end-1 ] {

				set data [split $data ","]
				puts -nonewline "[lindex $data 0] : "
				set varName [lindex $data 0]
				puts "[lindex $data $colCount]"
				set varValue [lindex $data $colCount]
				puts $loadDataFile "set $varName \"$varValue\""
				if {$varName == "startRun" && $varValue == "nil"} {
					lreplace $data $colCount 1 "yes"

					close $loadDataFile
					puts "start the rtm shell"
					source ./loadDataFile.tcl
					lynx::create_block ${blockName}.${runName}
					sh sleep 5s
					catch {close_session -id ${blockName}.${runName}/1}
					catch {delete_session -id ${blockName}.${runName}/1}
					set sessionName [new_session -build_name ${blockName}.${runName}]
					set hostName $::env(HOSTNAME)
					set pid [pid]
				
					#### set everything for runs
					puts "copying floorplan data"
					sh cp -rf ${floorplanInput}/* ./builds//${blockName}.${runName}/inputs/
					puts "copying overrides file"
					sh cp -rf $overrideFile ./builds/${blockName}.${runName}/scripts_build/
					####				

					run_flow -id rtm_shell/${hostName}/${pid}/${sessionName}
					puts "runs given"
					sh sleep 5s

				}
			}
		sh sleep 10s
		}
			
		puts "completed set runs"
		set flag 0
		puts "terminating runs"
	}
}

}

define_proc_attributes runMatrix \
    -info "running lynx with csv file as inputs" \
    -hide_body \
    -define_args {
	{-csvFile "give the csv file " "" string required}
    }




#run_flow -id rtm_shell/scfa201311.zsc3.intel.com/27304/gtnode1cbepar1.run2/1




