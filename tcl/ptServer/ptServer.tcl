

namespace eval timingServerRcg {
    puts "timing server Rcg"
}

proc convertStringToDict {convStr} {
    set my_dict [dict create]
    foreach pair [split $convStr ","] {
        regsub -all {^\s+} $pair "" pair
        regsub -all {\s+$} $pair "" pair
        set parts [split $pair ":"]
        set key [string trim [lindex $parts 0] "^ "]
        set value [string trim [lindex $parts 1] "^ "]
        dict set my_dict $key $value
    }
    return $my_dict
}


proc createDirectory {user} {
    set directory_path "reports/${user}"
    # Check if the directory exists
    if {![file exists $directory_path]} {
        # Create the directory if it doesn't exist
        file mkdir $directory_path
        puts "Directory created: $directory_path"
    } else {
        puts "Directory already exists: $directory_path"
    }
    sh chmod -R 777 $directory_path
}

set databaseName "rcg"
puts "this is rcg timing server running"
### need to load the pt session
set cornerFromTcl [join [lrange [split $cornerName "_"] 0 end-1] "_"]
if {[file exists ${cornerFromTcl}.session]} {
    catch {restore_session ${cornerFromTcl}.session}
} else {
    puts "the session is not present in the given location ${cornerFromTcl}.session"
    exit    
}

set blockName [get_object_name [current_design]]
puts "loading database completed: $blockName"



#return
set sqlcmd "UPDATE ${databaseName}.machineTrackerTable SET status = \'ready\' WHERE machineName = \'$cornerName\' and projectName = \'$project\' and workWeek = \'$workWeek\' and blockName =\'$blockName\';"
set ptCommand [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServer/runSqlCommands.py -C $sqlcmd -D $database]

if {[regexp "Error fetching data from MySQL: 1205" $ptCommand]} {
    puts "FATAL: problem in MYSQL exiting, please contact rcg for determinning the restoring timelines"
    sh sleep 30m
    exit
}

set pingLoop 0
while {1} {
    set cornerFromTcl [join [lrange [split $cornerName "_"] 0 end-1] "_"]
    set machineId [lrange [split $cornerName "_"] end end]
    set startTime [clock seconds]
    set cmd "select commandId,command,user,corner from ${databaseName}.commandInputTable where serviced = 0 and corner = \'$cornerFromTcl\' and machineName = \'$cornerName\' and projectName = \'$project\' and workWeek = \'$workWeek\' and blockName =\'$blockName\';"
    set ptCommand [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServer/runSqlCommands.py -C $cmd -D $database]
    #regsub -all {^\[\(|\)\]|\'} $ptCommand " " ptCommand
    regsub -all {\'} $ptCommand "" ptCommand
    #regsub -all {\s+} $ptCommand " " ptCommand
    set timeToGetCommand [clock seconds]

    

    #set ptCommand [convertStringToDict $ptCommand]
    
    if {$ptCommand == ""} {
        #puts "there is not commands to be processed"
        sh sleep 1
        #puts "database ping"
        incr pingLoop
        if {$pingLoop > 10} {
            set pingLoop 0
                set sqlcmd "UPDATE ${databaseName}.machineTrackerTable SET heartBeat = 0 WHERE machineName = \'$cornerName\' and projectName = \'$project\' and workWeek = \'$workWeek\' and blockName =\'$blockName\';"
                set ptCommand [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServer/runSqlCommands.py -C $sqlcmd -D $database]
   
            puts "database ping"
        }
        continue
    }
    puts "Elapsed time to get command: [expr {$timeToGetCommand - $startTime}] seconds"
    #return
    puts $ptCommand
    set machineId [lrange [split $cornerName "_"] end end]
    set cmdId [lindex [split $ptCommand ","] 0]
    set cmd [lindex [split $ptCommand ","] 1]
    set user [lindex [split $ptCommand ","] 2]
    set corner [lindex [split $ptCommand ","] 3]
    puts "ptCommand $ptCommand :: $cornerFromTcl :: $machineId :: $user :: rcg check"
    #regsub -all {\s+} $user "" user
    #regsub -all {\n} $cmdId "" cmdId
    createDirectory $user
    set location "reports/${user}/${cmdId}.rpt"
    puts $location

    ### set the basic flags in machine tracker
    set sqlcmd "UPDATE ${databaseName}.commandInputTable SET serviced = 1, complete = 0 WHERE commandId = \'$cmdId\' and projectName = \'$project\' and workWeek = \'$workWeek\' and blockName =\'$blockName\';"
    set ptCommand [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServer/runSqlCommands.py -C $sqlcmd -D $database]
    set sqlcmd "UPDATE ${databaseName}.machineTrackerTable SET status = \'running\', heartBeat = 0 WHERE machineName = \'$cornerName\' and projectName = \'$project\' and workWeek = \'$workWeek\' and blockName =\'$blockName\';"
    set ptCommand [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServer/runSqlCommands.py -C $sqlcmd -D $database]
    
    set sqlcmd "select variableValue from ${databaseName}.userVariablesTable where user = \'$user\' ;"
    set ptCommand [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServer/runSqlCommands.py -C $sqlcmd -D $database]
    
    set timeToSetFlags [clock seconds]
    puts "Elapsed time to set flags : [expr {$timeToSetFlags - $timeToGetCommand}] seconds"

    if {$ptCommand != "" } {
        foreach cmds [split $ptCommand "\n"] {
            #puts $cmds
            catch {eval $cmds}
        }
        puts "variables loaded"
    }
    
    #redirect -file $location {catch {eval $cmd}}
    puts "executing $cmd"
    #regsub -all {\s+} $cmd "" cmd
    regsub -all {\n} $cmd "" cmd
    catch {redirect -file $location {puts "Corner: $cornerFromTcl" ; puts $cmd; eval $cmd}}
    sh chmod 777 $location
    #sh sleep 1m

    set timeToCompleteCommand [clock seconds]
    puts "Elapsed time to set flags : [expr {$timeToCompleteCommand - $timeToSetFlags}] seconds"

    set sqlcmd "UPDATE ${databaseName}.machineTrackerTable SET status = \'ready\' WHERE machineName = \'$cornerName\' and projectName = \'$project\' and workWeek = \'$workWeek\' and blockName =\'$blockName\';"
    set ptCommand [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServer/runSqlCommands.py -C $sqlcmd -D $database]
    set sqlcmd "UPDATE ${databaseName}.commandInputTable SET complete = 1, outputLocation = \'[pwd]/${location}\' WHERE commandId = \'$cmdId\' and projectName = \'$project\' and workWeek = \'$workWeek\' and blockName =\'$blockName\';"
    set ptCommand [exec /usr/intel/bin/python3.10.8 /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/ptServer/runSqlCommands.py -C $sqlcmd -D $database]
    ### set the flag for completion

    set timeToResetFlag [clock seconds]
    puts "Elapsed time to reset flags : [expr {$timeToResetFlag - $timeToCompleteCommand}] seconds"

}
