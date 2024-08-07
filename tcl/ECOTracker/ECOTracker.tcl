if {![get_app_var in_gui_session]} {
puts "please enable GUI "
return
}

package require Tk

set project "WCLA0"

proc readConfigFile {filename} {
    set infData {}
    set currentSection ""
    set fp [open $filename r]
    while {![eof $fp]} {
        set line [gets $fp]
        set line [string trim $line]
        if {[string length $line] == 0 } {
            continue
        }
        # Check for a section header
        if {[regexp {^\[(.+)\]$} $line -> section]} {
            set currentSection $section
            continue
        }
        # Parse key-value pairs
        if {[regexp {^(.+?)=(.+)$} $line -> key value]} {
            set key [string trim $key]
            set value [string trim $value]
            # Store the key-value pair in a nested dictionary under the current section
            dict set infData $currentSection $key $value
        }
    }
    close $fp
    return $infData
}



proc ECOTrackerGUI {} {

    toplevel .ecoTracker
    wm title .ecoTracker "Eco Tracker"
    
    # Create a frame within the toplevel window
    frame .ecoTracker.frameAll
    grid .ecoTracker.frameAll -sticky nsew
    
    # Configure grid weights to make the frame resizeable
    grid rowconfigure .ecoTracker 0 -weight 1
    grid columnconfigure .ecoTracker 0 -weight 1
    
    # Create a canvas with scrollbars within the frame
    canvas .ecoTracker.frameAll.c -width 400 -height 200 -xscrollcommand ".ecoTracker.frameAll.xscroll set" -yscrollcommand ".ecoTracker.frameAll.yscroll set"
    scrollbar .ecoTracker.frameAll.xscroll -orient horizontal -command ".ecoTracker.frameAll.c xview"
    scrollbar .ecoTracker.frameAll.yscroll -command ".ecoTracker.frameAll.c yview"
    
    # Place the canvas and scrollbars using grid
    grid .ecoTracker.frameAll.c -row 0 -column 0 -sticky nsew
    grid .ecoTracker.frameAll.xscroll -row 1 -column 0 -sticky ew
    grid .ecoTracker.frameAll.yscroll -row 0 -column 1 -sticky ns
    
    # Configure grid weights within the frame to allocate space properly
    grid rowconfigure .ecoTracker.frameAll 0 -weight 1
    grid columnconfigure .ecoTracker.frameAll 0 -weight 1
    
    # Create a label and place it using grid
    label .ecoTracker.frameAll.c.lblProject -text "Project"
    grid .ecoTracker.frameAll.c.lblProject -row 0 -column 0 -columnspan 1 -sticky wn

    label .ecoTracker.frameAll.c.lblBlockName -text "blockName"
    grid .ecoTracker.frameAll.c.lblBlockName -row 1 -column 0 -columnspan 1 -sticky wn -pady 20

    label .ecoTracker.frameAll.c.lblProjectName2 -text "WCLA0"
    grid .ecoTracker.frameAll.c.lblProjectName2 -row 0 -column 1 -columnspan 1 -sticky wn -padx 50

    label .ecoTracker.frameAll.c.lblBlockName2 -text [get_object_name [get_designs]]
    grid .ecoTracker.frameAll.c.lblBlockName2 -row 1 -column 1 -columnspan 1 -sticky wn -padx 50 -pady 20

    button .ecoTracker.frameAll.c.buttonShowECO -text "ShowECO" -command {puts "button showECO pressed"; displayECOData .ecoTracker}
    grid .ecoTracker.frameAll.c.buttonShowECO -row 2 -column 1 -columnspan 1 -pady 20

    button .ecoTracker.frameAll.c.buttonCommitECO -text "CommitECO" -command {puts "button CommitECO pressed"; generateEco }
    grid .ecoTracker.frameAll.c.buttonCommitECO -row 2 -column 2 -columnspan 1 -pady 20

    button .ecoTracker.frameAll.c.buttonExit -text "Exit" -command {destroy .ecoTracker}
    grid .ecoTracker.frameAll.c.buttonExit -row 2 -column 3 -columnspan 1 -pady 20

    frame .ecoTracker.frameAll.c.ecoDetails
    grid .ecoTracker.frameAll.c.ecoDetails -sticky nsew -row 3 -column 0

    ### populate all the ECO details

}

define_proc_attributes ECOTrackerGUI \
    -info "this proc is for check the ECO status and implementing any released ECO" \
    -hide_body 

proc generateEco {} {
    global project
    set ecoDatas [processConfigFile]
    global widgetVarMap

    set configFilePath "/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/releaseVclpEco/config.ini"
    set configData [readConfigFile $configFilePath]
    set databaseLocation [dict get [dict get $configData $project] databaseLoc]
    if {[file exists "eco.tcl"]} { 
        puts "eco.tcl file exists in the location please remove the file or change the name of the file"
        
        
        toplevel .ecoTrackerExit
        wm title .ecoTrackerExit "Eco Tracker"
    
        # Create a frame within the toplevel window
        frame .ecoTrackerExit.frameAll
        grid .ecoTrackerExit.frameAll -sticky nsew
    
        # Configure grid weights to make the frame resizeable
        grid rowconfigure .ecoTrackerExit 0 -weight 1
        grid columnconfigure .ecoTrackerExit 0 -weight 1
    
        # Create a label and place it using grid
        label .ecoTrackerExit.frameAll.lblProject -text "eco.tcl file exists"
        grid .ecoTrackerExit.frameAll.lblProject -row 0 -column 0 -columnspan 1 -sticky wn

        button .ecoTrackerExit.frameAll.buttonExit -text "Keep File" -command {destroy .ecoTrackerExit}
        grid .ecoTrackerExit.frameAll.buttonExit -row 1 -column 0 -columnspan 1 -pady 20
        button .ecoTrackerExit.frameAll.buttonExit2 -text "Remove File" -command {sh rm eco.tcl; destroy .ecoTrackerExit}
        grid .ecoTrackerExit.frameAll.buttonExit2 -row 1 -column 1 -columnspan 1 -pady 20

        return 0
    }
    set fil [open "eco.tcl" w]
    #puts $fil "set allValidHash \"\""
    dict for {widgetName cbValue} $widgetVarMap {
        set ecoDump 1
        upvar 1 [lindex [split $widgetName "."] 5] myVarLink
        #puts "widgetName $widgetName and cbValue $cbValue and the value of the cb is [subst $myVarLink] "
        set cbVal [subst $myVarLink]
        if {[lsearch [split [get_attribute [get_designs ] ECOTrackerInfo] ":"] $cbValue] > 0} {
            puts "the ECO with hash value $cbValue is already sourced in your design"
            set ecoDump 0
            set sqlQuery "UPDATE ECOTracker set status=\"loaded\" where hash = \"$cbValue\" ;"
            #puts $sqlQuery
            executeSQLCommand $databaseLocation $sqlQuery
        }
        #puts [subst $myVarLink]
            if {$cbVal == 1} {
                #puts "load the ECO where the hash is $cbValue"
                set sqlQuery "SELECT * FROM ECOTracker where hash = \"$cbValue\" and (status = 'pending' or status = 'running');"
                set ecoDatas [executeSQLCommand $databaseLocation $sqlQuery]
                set findEco "[dict get [dict get $configData $project] ecoLocation]/[lindex [split $ecoDatas "|"] 1]/[lindex [split $ecoDatas "|"] 2]"
                #puts "need to source $findEco"
                if {$ecoDump} {
                    puts $fil "source $findEco"
                    puts $fil "set_attribute \[get_designs \] -name ECOTrackerInfo -value \"\[get_attribute \[get_designs \] ECOTrackerInfo\]:$cbValue\""
                    ### now track the table to change the ECO states
                    set sqlQuery "UPDATE ECOTracker set status=\"running\" where hash = \"$cbValue\" ;"
                    puts $sqlQuery
                    executeSQLCommand $databaseLocation $sqlQuery
                }
            }
    }
    close $fil
    return 1
}


proc executeSQLCommand {databasePath sqlQuery} {
    set result [exec sqlite3 $databasePath $sqlQuery]
    return $result
}

proc displayECOData {ecoTracker} {
    set ecoDatas [processConfigFile]
    set labelCount 0
    set rowCount 1
    global widgetVarMap
    foreach child [winfo children $ecoTracker.frameAll.c.ecoDetails] {
        destroy $child
    }

    # Create a frame to hold the eco details if it doesn't exist
    if {![winfo exists $ecoTracker.frameAll.c.ecoDetails]} {
        frame $ecoTracker.frameAll.c.ecoDetails
        grid $ecoTracker.frameAll.c.ecoDetails -row 0 -column 0 -sticky nsew
    }

    label .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader0 -text "ECOId"
    grid .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader0 -row 0 -column 0

    label .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader1 -text "EcoFileName"
    grid .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader1 -row 0 -column 1

    label .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader2 -text "EcoTeamName"
    grid .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader2 -row 0 -column 2

    label .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader3 -text "ECOOwner"
    grid .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader3 -row 0 -column 3
    
    label .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader4 -text "ECOstatus"
    grid .ecoTracker.frameAll.c.ecoDetails.labelEcoHeader4 -row 0 -column 4

    foreach ecoData [split $ecoDatas "\n"] {
        set colCount 0
         #checkbutton $ecoTracker.frameAll.c.ecoDetails.chkBtn${labelCount} -text [lindex [split $ecoData "|"] 10] -variable chkBtn
         set varName "chkBtn${labelCount}"
         set $varName 0
         checkbutton $ecoTracker.frameAll.c.ecoDetails.chkBtn${labelCount} -text [lindex [split $ecoData "|"] 10] -variable $varName 
         grid $ecoTracker.frameAll.c.ecoDetails.chkBtn${labelCount} -row $rowCount -column $colCount
         set widgetName $ecoTracker.frameAll.c.ecoDetails.chkBtn${labelCount}
         dict set widgetVarMap $widgetName [lindex [split $ecoData "|"] 10]
         incr colCount
         incr labelCount
         label $ecoTracker.frameAll.c.ecoDetails.labelEco${labelCount} -text [file tail [lindex [split $ecoData "|"] 2]]
         grid $ecoTracker.frameAll.c.ecoDetails.labelEco${labelCount} -row $rowCount -column $colCount
         incr colCount
         incr labelCount
         label $ecoTracker.frameAll.c.ecoDetails.labelEco${labelCount} -text [lindex [split $ecoData "|"] 3]
         grid $ecoTracker.frameAll.c.ecoDetails.labelEco${labelCount} -row $rowCount -column $colCount
         incr colCount
         incr labelCount
         label $ecoTracker.frameAll.c.ecoDetails.labelEco${labelCount} -text [lindex [split $ecoData "|"] 11]
         grid $ecoTracker.frameAll.c.ecoDetails.labelEco${labelCount} -row $rowCount -column $colCount
         incr colCount
         incr labelCount
         label $ecoTracker.frameAll.c.ecoDetails.labelEco${labelCount} -text [lindex [split $ecoData "|"] 6]
         grid $ecoTracker.frameAll.c.ecoDetails.labelEco${labelCount} -row $rowCount -column $colCount

         incr rowCount
         incr labelCount
    }

}

proc processConfigFile {} {
    global project
    set configFilePath "/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/releaseVclpEco/config.ini"
    set configData [readConfigFile $configFilePath]
    set databaseLocation [dict get [dict get $configData $project] databaseLoc]

    set sqlQuery "SELECT * FROM ECOTracker where blockName = \"[get_object_name [get_designs]]\" and (status = 'pending' OR status = 'running');"
    #puts $sqlQuery
    set ecoDatas [executeSQLCommand $databaseLocation $sqlQuery]
    return $ecoDatas
}



define_user_attribute -classes design -type string -name ECOTrackerInfo
set widgetVarMap {}

