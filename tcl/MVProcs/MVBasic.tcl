

namespace eval rcg {
puts "using rcg MV scripts"
}


#array set CellInfo [list VTType {SVT:xqs LVT:xql LLVT:xqm ULLVT:xqv ULLLVT:xqw ELLVT:xqe}]
set CellInfo(VTType)   {SVT:xqs LVT:xql LLVT:xqm ULT:xqv ULTLL:xqw}
set CellInfo(Type)   {Power Optimized:hdp High Density:hdh High Density Logic Cell:hdl}
set CellInfo(Falvour)   {BUF INV CBUF CINV}
set CellInfo(Env) "source /p/gtkit/bin/gtkit_env -c wclsd.n32.gt.xe3lpg1x2_sd0p5_WW6p5_WCL_SD_EV2_model_24ww7p1_sles15"
#source /p/gtkit/bin/gtkit_env -c ptlsd.gcdp192.gt.xe3lpg2x6_sd1p0_WW45p1_FSO5_ww44_SD_GCD_FSO5_ww45p2"
#source /p/gtkit/bin/gtkit_env mtlsd.gcdp128.gt.gen12p73_ECO1_inc5_gcd26a_21ww27p0_rev12_MEMww29e"
#set CellInfo(BatchJob) "nbjob run --target zsc3_express --wash --qslot /CHG/MeteorLake/GMD/ps --class \'SLES12SP5&&CPUMHz>2599&&96G\' "
set CellInfo(BatchJob) "nbjob run --target zsc3_express --wash --qslot /CHG/WildcatLake/N32/apr --class \'SLES12SP5&&96G\' "
#set CellInfo(VTType2)   {SVT:xqs LVT:xql LVTLL:xqm ULLVT:xqv ULLLVT:xqw ELLVT:xqe}
set Project(Name) "WCLA0"
set PTLA0(Buffer) ""
set PTLA0(Inverter) ""
set PTLA0(ISO) ""
set PTLA0(LS) ""
set PTLA0(ELS) ""



proc rcg::AnalyzeSecondaryLoadVA {args} {
    parse_proc_arguments -args ${args} opt
    source /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/tcl/MVProcs/upf_man_eco_utils.stcl
    #/nfs/site/disks/ptlp_infra_env_01/build/scripts/upf/Utils/upf_man_eco_utils.stcl

    toplevel .vladsTop
    frame .vladsTop.frAlles
    
    # create canvas with scrollbars
    canvas .vladsTop.frAlles.c -width 400 -height 200 -xscrollcommand ".vladsTop.frAlles.xscroll set" -yscrollcommand ".vladsTop.frAlles.yscroll set"
    scrollbar .vladsTop.frAlles.xscroll -orient horizontal -command ".vladsTop.frAlles.c xview"
    scrollbar .vladsTop.frAlles.yscroll -command ".vladsTop.frAlles.c yview"
    pack .vladsTop.frAlles.xscroll -side bottom -fill x
    pack .vladsTop.frAlles.yscroll -side right -fill y
    pack .vladsTop.frAlles.c -expand yes -fill both -side top
    
    set cbval ""
    set cbval2 ""
    set infos ""
    set entry1var "get_selection"
    # create frame with widgets
    frame .vladsTop.frAlles.c.frWidgets -borderwidth 1 -relief solid -width 400 -height 400
    
    label .vladsTop.frAlles.c.frWidgets.lbl -text "Secondary connection Analysis"
    grid .vladsTop.frAlles.c.frWidgets.lbl -padx 2 -pady 2 -row 0 -column 1

    # create frame with buttons
    frame .vladsTop.frAlles.c.frButtons -borderwidth 1 -relief solid -width 240 -height 40
    button .vladsTop.frAlles.c.frButtons.btOK -text "OK" -command {puts "button pressed"; set cel [analyzeMVCrossing $cbval3from $cbval3to .vladsTop]; profileMVCrossing $cel .vladsTop}
    button .vladsTop.frAlles.c.frButtons.btAbbruch -text "Cancel" -command {destroy .vladsTop}
    pack .vladsTop.frAlles.c.frButtons.btOK -padx 2 -pady 2 -side left
    pack .vladsTop.frAlles.c.frButtons.btAbbruch -padx 2 -pady 2 -side left

    label .vladsTop.frAlles.c.frWidgets.lbl2 -text "From"
    grid .vladsTop.frAlles.c.frWidgets.lbl2 -padx 2 -pady 2 -row 2 -column 1

    label .vladsTop.frAlles.c.frWidgets.lbl3 -text "To"
    grid .vladsTop.frAlles.c.frWidgets.lbl3 -padx 2 -pady 2 -row 2 -column 3

    ttk::combobox .vladsTop.frAlles.c.frWidgets.cbfrom -textvariable cbval3from -values [get_object_name [get_supply_nets]] 
    grid .vladsTop.frAlles.c.frWidgets.cbfrom -padx 2 -pady 2 -row 3 -column  1 -columnspan 2 -sticky news
    ttk::combobox .vladsTop.frAlles.c.frWidgets.cbto -textvariable cbval3to -values [get_object_name [get_supply_nets]] 
    grid .vladsTop.frAlles.c.frWidgets.cbto -padx 2 -pady 2 -row 3 -column  3 -columnspan 2 -sticky news

    entry .vladsTop.frAlles.c.frWidgets.entry1 -textvariable entry1var -width 10
    grid .vladsTop.frAlles.c.frWidgets.entry1 -padx 2 -pady 2 -row 4 -column 1 -columnspan 4 -sticky news -ipady 100 

    # place widgets and buttons
    .vladsTop.frAlles.c create window 0 0 -anchor nw -window .vladsTop.frAlles.c.frWidgets 
    .vladsTop.frAlles.c create window 200 380 -anchor w -window .vladsTop.frAlles.c.frButtons 

    # determine the scrollregion
    .vladsTop.frAlles.c configure -scrollregion [.vladsTop.frAlles.c bbox all]
    
    # show the canvas
    pack .vladsTop.frAlles -expand yes -fill both -side top
}

#ConvertBufferAOB  [array get CellInfo]

define_proc_attributes rcg::AnalyzeSecondaryLoadVA \
    -info "this proc will open gui to convert AOBBuffer to normal buffer" \
    -hide_body 




proc colorPortsWithSupplyVoltage {} {
    define_user_attribute -classes port -type string -name portSupply
    foreach_in_collection port [get_ports *] {
        set sup [get_object_name [get_related_supply_net [get_ports $port]]]
        set_attribute [get_ports $port] -name portSupply -value $sup
    }
    set colors {red blue orange purple green yellow light_orange light_red}
    set count 0
    gui_change_highlight -remove -all_color
    foreach_in_collection sup [get_supply_nets *] {
        set sup [get_object_name $sup]
        gui_change_highlight  -color [lindex $colors $count]  -collection  [get_ports * -filter "portSupply == $sup"]
        puts "[lindex $colors $count] > $sup > [sizeof_collection [get_ports * -filter "portSupply == $sup"]] > get_ports * -filter \"portSupply == $sup\""
        incr count
    }

}


proc analyzeMVCrossing {from to .vladsTop} {
    upf::find_secondary_load_in_each_va -secondary_supply_loads a_secondary_load_array
    puts "Get the MV crossing from and to $from $to "
    set allCells [get_cells -of [get_object_name $a_secondary_load_array(${from},${to})]]
    return $allCells
}



proc profileMVCrossing {cel .vladsTop} {
    #global .vladsTop.frAlles.c.frWidgets.entry1
    set cel [get_object_name [get_cells $cel]]
    puts "rcg check "
    puts $cel
    set isolationCell [get_object_name [get_cells $cel -filter "is_isolation == true"]]
    set levelShifterCell [get_object_name [get_cells $cel -filter "is_level_shifter == true"]]
    set enableLevelShifterCell [get_object_name [get_cells $cel -filter "is_enable_level_shifter == true"]]
    set AOBCell [remove_from_collection [remove_from_collection [remove_from_collection [get_cells $cel] [get_cells $isolationCell ]] [get_cells $levelShifterCell]] [get_cells $enableLevelShifterCell]]
    gui_change_highlight -remove -all_colors
    gui_change_highlight -color green -collection [get_cells $isolationCell]
    gui_change_highlight -color blue -collection [get_cells $levelShifterCell]
    gui_change_highlight -color yellow -collection [get_cells $enableLevelShifterCell]
    gui_change_highlight -color red -collection [get_cells $AOBCell]
    
    set texts "Cell Stats \n"
    lappend texts "    Number of cells : [sizeof_coll [get_cells $cel]]\n"
    lappend texts "isolation cells (green): [sizeof_coll [get_cells $isolationCell]]\n"
    lappend texts "level shifter cells (blue): [sizeof_coll [get_cells $levelShifterCell]]\n"
    lappend texts "els cells (yellow): [sizeof_coll [get_cells $enableLevelShifterCell]]\n"
    lappend texts "buffer cells (red): [sizeof_coll [get_cells $AOBCell]]\n"
    puts $texts
    .vladsTop.frAlles.c.frWidgets.entry1 delete 0 end
    .vladsTop.frAlles.c.frWidgets.entry1 insert 0 [lindex [split $texts \n] 0]
}





proc getLibCellName {libCell secondaryPG implement .vladsTop} {
    puts "Get the lib cell name $libCell $secondaryPG $implement "
        foreach_in_collection cell [get_selection] {
           set cell [get_object_name $cell] 
           puts "set_reference -to_block $libCell $cell -verbose"
           puts "connect_supply_net $secondaryPG -port ${cell}/VDDR"
           if {$implement  == 1} {
            set_reference -to_block $libCell $cell -verbose
            connect_supply_net $secondaryPG -port ${cell}/VDDR
            }
            destroy .vladsTop

        }
    #set_reference -to_block $lib_cell $cell -verbose
    }

proc CBLibCellName {cb libPat} {
    puts "Get the lib cell name $libPat"
    set libVtType [lindex [split $libPat ":"] 1]
    set celVtType [lindex [split $libPat ":"] 0]
    set celType [lindex [split $libPat ":"] 2]
    if {[string length $celType] == 3}  {
        set libPat "ts05n${libVtType}logl06hdp051f*/HDP${celVtType}06_${celType}_CAQ*"
        $cb configure -values [get_attribute [remove_from_collection [get_lib_cells $libPat] [get_lib_cells ts05n${libVtType}logl06hdp051f*/HDP${celVtType}06_${celType}_CAQ*CK*]] name]

    } else {
        if {[string match "CBUF" ${celType}]} {
            set celType "BUF"
        } else {
            set celType "INV"
        }
        set libPat "*/HDPULTLL06_${celType}_CAQ*CK*"
        $cb configure -values [get_attribute [get_lib_cells $libPat] name]

    }
    }


proc CBLibCellNameNom {cb libPat} {
    puts "Get the lib cell name $libPat"
    set libVtType [lindex [split $libPat ":"] 1]
    set celVtType [lindex [split $libPat ":"] 0]
    set celType [lindex [split $libPat ":"] 2]
    if {[string length $celType] == 3}  {
        set libPat "ts05n${libVtType}logl06hdh051f*/HDB${celVtType}06_${celType}_CAQ*"
        $cb configure -values [get_attribute [remove_from_collection [get_lib_cells $libPat] [get_lib_cells ts05n${libVtType}logl06hdh051f*/HDB${celVtType}06_${celType}_CAQ*CK*]] name]

    } else {
        if {[string match "CBUF" ${celType}]} {
            set celType "BUF"
        } else {
            set celType "INV"
        }
        set libPat "*/HDBULTLL06_${celType}_CAQ*CK*"
        $cb configure -values [get_attribute [get_lib_cells $libPat] name]

    }
    }

    
proc getLibCellNameNom {libCell implement .vladsTop} {
    puts "Get the lib cell name $libCell $implement"
        foreach_in_collection cell [get_selection] {
           set cell [get_object_name $cell] 
           puts "set_reference -to_block $libCell $cell -pin_rebind force"
           if {$implement == 1} {
           set_reference -to_block $libCell $cell -pin_rebind force
            }
           destroy .vladsTop
        }
    }



proc rcg::ConvertBufferAOB {args} {
    parse_proc_arguments -args ${args} opt
    set CellInfo $opt(-CellInfo)

    array set PCellInfo $CellInfo
    toplevel .vladsTop
    frame .vladsTop.frAlles
    
    # create canvas with scrollbars
    canvas .vladsTop.frAlles.c -width 400 -height 200 -xscrollcommand ".vladsTop.frAlles.xscroll set" -yscrollcommand ".vladsTop.frAlles.yscroll set"
    scrollbar .vladsTop.frAlles.xscroll -orient horizontal -command ".vladsTop.frAlles.c xview"
    scrollbar .vladsTop.frAlles.yscroll -command ".vladsTop.frAlles.c yview"
    pack .vladsTop.frAlles.xscroll -side bottom -fill x
    pack .vladsTop.frAlles.yscroll -side right -fill y
    pack .vladsTop.frAlles.c -expand yes -fill both -side top
    
    set cbval ""
    set cbval2 ""
    set infos ""
    set entry1var "get_selection"
    # create frame with widgets
    frame .vladsTop.frAlles.c.frWidgets -borderwidth 1 -relief solid -width 400 -height 200
    
    label .vladsTop.frAlles.c.frWidgets.lbl -text "Convert Buffer To AOB"
    grid .vladsTop.frAlles.c.frWidgets.lbl -padx 2 -pady 2 -row 0 -column 1

    label .vladsTop.frAlles.c.frWidgets.lb2 -text "variable / selection"
    grid .vladsTop.frAlles.c.frWidgets.lb2 -padx 2 -pady 2 -row 1 -column 0
    label .vladsTop.frAlles.c.frWidgets.lb2_1 -text "get_selection"
    grid .vladsTop.frAlles.c.frWidgets.lb2_1 -padx 2 -pady 2 -row 1 -column 1

    #entry .vladsTop.frAlles.c.frWidgets.entry1 -textvariable entry1var -width 10 -heigh 10
    #grid .vladsTop.frAlles.c.frWidgets.entry1 -padx 2 -pady 2 -row 1 -column 1
    #.vladsTop.frAlles.c.frWidgets.entry1 delete 0 15
    #.vladsTop.frAlles.c.frWidgets.entry1 insert 0 $entry1var 

    

    label .vladsTop.frAlles.c.frWidgets.lb3 -text "LibCellType"
    grid .vladsTop.frAlles.c.frWidgets.lb3 -padx 2 -pady 2 -row 2 -column 0
    ComboBox .vladsTop.frAlles.c.frWidgets.cb1 -textvariable cbval1 -values $PCellInfo(VTType)
    grid .vladsTop.frAlles.c.frWidgets.cb1 -padx 2 -pady 2 -row 2 -column  1 

    ComboBox .vladsTop.frAlles.c.frWidgets.cb2 -textvariable cbval2 -values $PCellInfo(Falvour)
    #.vladsTop.frAlles.c.frWidgets.cb2 set "BUF"
    grid .vladsTop.frAlles.c.frWidgets.cb2 -padx 2 -pady 2 -row 2 -column  2 

    label .vladsTop.frAlles.c.frWidgets.lb4 -text "Available Lib Cells"
    grid .vladsTop.frAlles.c.frWidgets.lb4 -padx 2 -pady 2 -row 3 -column 0

    ComboBox .vladsTop.frAlles.c.frWidgets.cb3 -textvariable cbval3 -values [get_attribute [get_lib_cells ts05nxqslogl06hdp051f*/HDPSVT06_BUF_CAQ*] name] -postcommand {CBLibCellName .vladsTop.frAlles.c.frWidgets.cb3 ${cbval1}:${cbval2}}
    grid .vladsTop.frAlles.c.frWidgets.cb3 -padx 2 -pady 2 -row 3 -column  1 -columnspan 2 -sticky news

    label .vladsTop.frAlles.c.frWidgets.lb5 -text "Secondary PG Connection"
    grid .vladsTop.frAlles.c.frWidgets.lb5 -padx 2 -pady 2 -row 4 -column 0

    ComboBox .vladsTop.frAlles.c.frWidgets.cb4 -textvariable cbval4 -values [get_object_name [get_supply_nets *] ]
    grid .vladsTop.frAlles.c.frWidgets.cb4 -padx 2 -pady 2 -row 4 -column  1 -columnspan 2 -sticky news

    checkbutton .vladsTop.frAlles.c.frWidgets.chkB1 -text "Implement" -variable chkB1
    grid .vladsTop.frAlles.c.frWidgets.chkB1 -padx 2 -pady 2 -row 5 -column  1 -columnspan 2 -sticky news

    # get the lib cell
    lappend infos $cbval
    lappend infos $cbval2
    puts $infos
    # create frame with buttons
    frame .vladsTop.frAlles.c.frButtons -borderwidth 1 -relief solid -width 240 -height 40
    button .vladsTop.frAlles.c.frButtons.btOK -text "OK" -command {getLibCellName $cbval3 $cbval4 $chkB1 .vladsTop}
    button .vladsTop.frAlles.c.frButtons.btAbbruch -text "Cancel" -command {destroy .vladsTop}
    pack .vladsTop.frAlles.c.frButtons.btOK -padx 2 -pady 2 -side left
    pack .vladsTop.frAlles.c.frButtons.btAbbruch -padx 2 -pady 2 -side left
    
    # place widgets and buttons
    .vladsTop.frAlles.c create window 0 0 -anchor nw -window .vladsTop.frAlles.c.frWidgets 
    .vladsTop.frAlles.c create window 400 180 -anchor w -window .vladsTop.frAlles.c.frButtons 
    
    # determine the scrollregion
    .vladsTop.frAlles.c configure -scrollregion [.vladsTop.frAlles.c bbox all]
    
    # show the canvas
    pack .vladsTop.frAlles -expand yes -fill both -side top
}

#ConvertBufferAOB  [array get CellInfo]

define_proc_attributes rcg::ConvertBufferAOB \
    -info "this proc will open gui to convert AOBBuffer to normal buffer" \
    -hide_body \
    -define_args {
        {-CellInfo "give the cell name " "" string required}
    }








proc rcg::ConvertAOBBuffer {args} {
    parse_proc_arguments -args ${args} opt
    set CellInfo $opt(-CellInfo)

    array set PCellInfo $CellInfo
    toplevel .vladsTop
    frame .vladsTop.frAlles
    
    # create canvas with scrollbars
    canvas .vladsTop.frAlles.c -width 400 -height 200 -xscrollcommand ".vladsTop.frAlles.xscroll set" -yscrollcommand ".vladsTop.frAlles.yscroll set"
    scrollbar .vladsTop.frAlles.xscroll -orient horizontal -command ".vladsTop.frAlles.c xview"
    scrollbar .vladsTop.frAlles.yscroll -command ".vladsTop.frAlles.c yview"
    pack .vladsTop.frAlles.xscroll -side bottom -fill x
    pack .vladsTop.frAlles.yscroll -side right -fill y
    pack .vladsTop.frAlles.c -expand yes -fill both -side top
    
    set cbval ""
    set cbval2 ""
    set infos ""
    set entry1var "get_selection"
    # create frame with widgets
    frame .vladsTop.frAlles.c.frWidgets -borderwidth 1 -relief solid -width 340 -height 300
    
    label .vladsTop.frAlles.c.frWidgets.lbl -text "Convert AOB To Buffer"
    grid .vladsTop.frAlles.c.frWidgets.lbl -padx 2 -pady 2 -row 0 -column 1

    label .vladsTop.frAlles.c.frWidgets.lb2 -text "variable / selection"
    grid .vladsTop.frAlles.c.frWidgets.lb2 -padx 2 -pady 2 -row 1 -column 0
    label .vladsTop.frAlles.c.frWidgets.lb2_1 -text "get_selection"
    grid .vladsTop.frAlles.c.frWidgets.lb2_1 -padx 2 -pady 2 -row 1 -column 1

    label .vladsTop.frAlles.c.frWidgets.lb3 -text "LibCellType"
    grid .vladsTop.frAlles.c.frWidgets.lb3 -padx 2 -pady 2 -row 2 -column 0
    ComboBox .vladsTop.frAlles.c.frWidgets.cb1 -textvariable cbval1 -values $PCellInfo(VTType)
    grid .vladsTop.frAlles.c.frWidgets.cb1 -padx 2 -pady 2 -row 2 -column  1 

    ComboBox .vladsTop.frAlles.c.frWidgets.cb2 -textvariable cbval2 -values $PCellInfo(Falvour)
    #.vladsTop.frAlles.c.frWidgets.cb2 set "BUF"
    grid .vladsTop.frAlles.c.frWidgets.cb2 -padx 2 -pady 2 -row 2 -column  2 

    label .vladsTop.frAlles.c.frWidgets.lb4 -text "Available Lib Cells"
    grid .vladsTop.frAlles.c.frWidgets.lb4 -padx 2 -pady 2 -row 3 -column 0

    ComboBox .vladsTop.frAlles.c.frWidgets.cb3 -textvariable cbval3 -values [get_attribute [get_lib_cells ts05nxqslogl06hdh051f*/HDBSVT06_BUF_CAQ*] name] -postcommand {CBLibCellNameNom .vladsTop.frAlles.c.frWidgets.cb3 ${cbval1}:${cbval2}}
    grid .vladsTop.frAlles.c.frWidgets.cb3 -padx 2 -pady 2 -row 3 -column  1 -columnspan 2 -sticky news


    checkbutton .vladsTop.frAlles.c.frWidgets.chkB1 -text "Implement" -variable chkB1
    grid .vladsTop.frAlles.c.frWidgets.chkB1 -padx 2 -pady 2 -row 4 -column  1 -columnspan 2 -sticky news

    # get the lib cell
    lappend infos $cbval
    lappend infos $cbval2
    puts $infos
    # create frame with buttons
    frame .vladsTop.frAlles.c.frButtons -borderwidth 1 -relief solid -width 240 -height 40
    button .vladsTop.frAlles.c.frButtons.btOK -text "OK" -command {getLibCellNameNom $cbval3 $chkB1 .vladsTop}
    button .vladsTop.frAlles.c.frButtons.btAbbruch -text "Cancel" -command {destroy .vladsTop}
    pack .vladsTop.frAlles.c.frButtons.btOK -padx 2 -pady 2 -side left
    pack .vladsTop.frAlles.c.frButtons.btAbbruch -padx 2 -pady 2 -side left
    
    # place widgets and buttons
    .vladsTop.frAlles.c create window 0 0 -anchor nw -window .vladsTop.frAlles.c.frWidgets 
    .vladsTop.frAlles.c create window 200 150 -anchor w -window .vladsTop.frAlles.c.frButtons 
    
    # determine the scrollregion
    .vladsTop.frAlles.c configure -scrollregion [.vladsTop.frAlles.c bbox all]
    
    # show the canvas
    pack .vladsTop.frAlles -expand yes -fill both -side top
}


define_proc_attributes rcg::ConvertAOBBuffer \
    -info "this proc will open gui to convert AOBBuffer to normal buffer" \
    -hide_body \
    -define_args {
        {-CellInfo "give the cell name " "" string required}
    }











proc RunVCLP {CellInfo} {
    array set PCellInfo $CellInfo
    set designName [get_object_name [get_designs]]
    write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations} -split_bus ${designName}.spyglass_splitbus.pg.vg.gz
    save_upf ${designName}.apr.upf
    set fil [open "runVCLP.csh" w]
    puts $fil "#!/usr/bin/csh"
    puts $fil "$PCellInfo(Env)"
    puts $fil "#use custom pl file for saving tthe session until fixed in actual flow"
    puts $fil "perl \$GTKIT_PATH/multiwell/lp/vclp_run.pl -skip_checkpoint 0 -design $designName -netlist ${designName}.spyglass_splitbus.pg.vg.gz -upf ${designName}.apr.upf -work vclpRun -local_override_file /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/tcl/MVProcs/hookupFil.tcl"
    puts $fil "#perl /nfs/site/disks/wcln_a0_intg_mw_01/rcg/script/vclp_run.pl -skip_checkpoint 0 -design $designName -netlist ${designName}.spyglass_splitbus.pg.vg.gz -upf ${designName}.apr.upf -work vclpRun"
    puts $fil "#perl /nfs/site/disks/ptlp_a0_intg_mw_01/rcg/RTM_Runs/temp/sc/vclp_run.pl -local_override_file /nfs/site/disks/ptlp_a0_intg_mw_01/rcg/RTM_Runs/scripts/vclpOverride.tcl -skip_checkpoint 0 -design $designName -netlist ${designName}.spyglass.pg.vg.gz -upf ${designName}.apr.upf -work vclpRun"
    close $fil

    set fil [open "fireJob.csh" w]

    set runCmd [pwd]/runVCLP.csh
    puts $fil "$PCellInfo(BatchJob) xterm -T VCLPRun -e \"source $runCmd\""
    #\"source [pwd]/runVCLP.csh\""
    #puts $fil "$PCellInfo(BatchJob) xterm "
    close $fil
    sh source fireJob.csh
}

proc reload_mvCell {args} {
    set cells [get_object_name [get_cells * -filter "ref_name =~*BUF*"]]
    set AON_buf {}
    foreach cel $cells {
        set ref_name [get_attribute [get_cell $cel ] ref_name]
        if {[regexp {(HDP.*)} $ref_name r_name]} {
            lappend AON_buf $cel
        }
    }

    set cells [get_object_name [get_cells * -filter "ref_name =~*INV*"]]
    set AON_INV {}
    foreach cel $cells {
        set ref_name [get_attribute [get_cell $cel ] ref_name]
        if {[regexp {(HDP.*)} $ref_name r_name]} {
            lappend AON_INV $cel
        }
    }

    set ISO [get_flat_cells *UPF*ISO*]


    set vm MVCells 
    gui_remove_vmbucket -vmname $vm -all
    gui_create_vmbucket -vmname $vm -name AOBUF -title {AOBUF} -color red -collection [get_flat_cells $AON_buf]
    gui_create_vmbucket -vmname $vm -name AOINF -title {AOINF} -color green -collection [get_flat_cells $AON_INV]
    gui_create_vmbucket -vmname $vm -name ISO -title {ISO} -color blue -collection $ISO
    gui_create_vmbucket -vmname $vm -name PSW -title {PSW} -color yellow -collection [get_flat_cells * -filter "ref_name =~ HDPSVT06_PGATBDRV0M2_CAQY*"]
}


proc reload_SecondaryPG {args} {
 rcg::getSecondaryPGLength
 set cells [get_object_name [get_cells * -filter "ref_name =~*BUF*"]]
 set AON_buf {}
 foreach cel $cells {
     set ref_name [get_attribute [get_cell $cel ] ref_name]
     if {[regexp {(HDP.*)} $ref_name r_name]} {
         lappend AON_buf $cel
     }
 }

 set cells [get_object_name [get_cells * -filter "ref_name =~*INV*"]]
 set AON_INV {}
 foreach cel $cells {
     set ref_name [get_attribute [get_cell $cel ] ref_name]
     if {[regexp {(HDP.*)} $ref_name r_name]} {
         lappend AON_buf $cel
     }
 }
  
 set vm  MVSecondaryPG
 gui_remove_vmbucket -vmname $vm -all
 gui_create_vmbucket -vmname $vm -name 1 -title {1>} -color green -collection [get_flat_cells $AON_buf -filter "DistToPGStrip < 1"]
 gui_create_vmbucket -vmname $vm -name 2 -title {1to10} -color yellow -collection [remove_from_collection [get_flat_cells $AON_buf -filter "DistToPGStrip < 10"] [get_flat_cells $AON_buf -filter "DistToPGStrip < 1"]]
 gui_create_vmbucket -vmname $vm -name 3 -title {10>} -color red -collection [get_flat_cells $AON_buf -filter "DistToPGStrip > 10"]
 }


proc rcg::MVPlaceAnalysis {args} {
    parse_proc_arguments -args ${args} opt
    # check where the isolation cells are sitting from voltage area
    gui_create_vm -name MVCells -update_cmd reload_mvCell 

    gui_show_map -map MVCells -show true
    # check secondary PG routing length 
    gui_create_vm -name MVSecondaryPG -update_cmd reload_SecondaryPG 

    gui_show_map -map MVSecondaryPG -show true

    # Check SRSN
}


define_proc_attributes rcg::MVPlaceAnalysis \
    -info "this proc will analyze the MV placement" \
    -hide_body \






proc rcg::getSecondaryPGLength {args} {
    parse_proc_arguments -args ${args} opt

    define_user_attribute -classes cell -type string -name NearestPGStrip
    define_user_attribute -classes cell -type string -name DistToPGStrip
    set TIME_start [clock clicks -milliseconds]

    set cells [get_object_name [get_cells * -filter "ref_name =~*BUF*"]]
    set AON_buf {}
    foreach cel $cells {
        set ref_name [get_attribute [get_cell $cel ] ref_name]
        if {[regexp {(HDP.*)} $ref_name r_name]} {
            lappend AON_buf $cel
        }
    }

   set cells [get_object_name [get_cells * -filter "ref_name =~*INV*"]]
   set AON_INV {}
   foreach cel $cells {
       set ref_name [get_attribute [get_cell $cel ] ref_name]
       if {[regexp {(HDP.*)} $ref_name r_name]} {
           lappend AON_INV $cel
       }
   }
    set AON_buf [get_object_name [add_to_coll [get_cells $AON_buf] [get_cells $AON_INV]]]
    
    set count 0
    set countlen 0
    foreach cel $AON_buf {
        if {$count > 500 } {
           puts "Running ... $countlen / [llength $AON_buf] done"
           set count 0
        }
        incr count
        incr countlen
        #puts $cel
        set cel [get_cells $cel]
        set searchDistances {1 5 10 50 100}
        set cbbox [get_attribute [get_cells $cel] bbox]

        set flag 0
        foreach searchDistance $searchDistances { 
            set bbox [get_attribute [resize_polygons $cbbox -size $searchDistance ] bbox]
            set secondaryNet [get_object_name [get_flat_nets -of [get_flat_pins -of ${cel} -all -filter "name == VDDR"] -all]]
            set secondaryPin [get_object_name [get_flat_pins -of ${cel} -all -filter "name == VDDR"]]
            set cmd "get_shapes -intersect \"$bbox\" -filter {shape_use ==\"stripe\" && layer.name == \"M6\" && owner.name == \"$secondaryNet\"}"
            #puts $cmd
            set cmd "change_selection \[get_shapes -intersect \"$bbox\" -filter {shape_use ==\"stripe\" && layer.name == \"M6\" && owner.name == \"$secondaryNet\"}\]"
            eval $cmd
            #puts [sizeof_collection [get_selection ]]
            if {[sizeof_collection [get_selection ]] > 0} {
               set flag 1
               break 
            }
            set cmd "change_selection \[get_shapes -intersect \"$bbox\" -filter {shape_use ==\"stripe\" && layer.name == \"M4\" && owner.name == \"$secondaryNet\"}\] "
            eval $cmd
            if {[sizeof_collection [get_selection ]] > 0} {
               set flag 1
               break 
            }
        }        

        if {$flag == 0} {
            set cmd "change_selection \[get_shapes -filter {shape_use ==\"stripe\" && layer.name == \"M4\" && owner.name == \"$secondaryNet\"}\] "
            eval $cmd
            change_selection [get_shapes [lindex [get_object_name [get_selection ]] 0]]
             if {[sizeof_collection [get_selection ]] > 0} {
               set flag 1
            }
        }

        if {$flag == 0} {
            set_attribute -object $cel -name NearestPGStrip -value [lindex [get_object_name [get_shapes *]] 0]
            set_attribute -object $cel -name DistToPGStrip -value 200
            break
        }


        set paths [get_selection]
        set secondaryPinY0 [lindex [lindex [get_attribute [get_flat_pins $secondaryPin] bbox] 0] 1]
        set mydict [dict create ]
        foreach_in_collection path [get_shapes $paths] {
           set pgPath [lindex [lindex [get_attribute [get_shapes $path] bbox ] 0] 1]
           set yDist [expr abs([expr $pgPath - $secondaryPinY0])]
           dict set mydict [get_object_name $path] $yDist
           #puts $yDist
        }
        #puts $mydict
        set sorted [lsort -real -stride 2 -index 1 $mydict]
        #puts [lindex $sorted 0]
        set_attribute -object $cel -name NearestPGStrip -value [lindex $sorted 0]
        unset mydict
        rcg::distPoint -cell $cel
    }
    set TIME_taken [expr [expr [clock clicks -milliseconds] - $TIME_start] / 1000]
    puts "$TIME_taken seconds"
}


define_proc_attributes rcg::getSecondaryPGLength\
    -info "this proc will analyze the secondary pg connection" \
    -hide_body \








proc rcg::distPoint {args} {
parse_proc_arguments -args ${args} opt
set cel $opt(-cell)


set nearestPGStrip [get_attribute $cel NearestPGStrip]
set pointA [lindex [get_attribute [get_shapes $nearestPGStrip] points ] 0]
set pointB [lindex [get_attribute [get_shapes $nearestPGStrip] points ] 1]
set pointC [lindex [get_attribute [get_flat_pins -of $cel -filter "name == VDDR" -all] bbox] 0]

set vectorAB [list [expr [lindex $pointB 0] - [lindex $pointA 0]] [expr [lindex $pointB 1] - [lindex $pointA 1]]]
set vectorAC [list [expr [lindex $pointC 0] - [lindex $pointA 0]] [expr [lindex $pointC 1] - [lindex $pointA 1]]]
set vectorBC [list [expr [lindex $pointC 0] - [lindex $pointB 0]] [expr [lindex $pointC 1] - [lindex $pointB 1]]]

set dotProAB_BC [expr [expr [lindex $vectorAB 0] * [lindex $vectorBC 0]] + [expr [lindex $vectorAB 1] * [lindex $vectorBC 1]]]
set dotProAB_AC [expr [expr [lindex $vectorAB 0] * [lindex $vectorAC 0]] + [expr [lindex $vectorAB 1] * [lindex $vectorAC 1]]]

set distPoint 0

#case1
if {$dotProAB_BC > 0} {
    set y [expr [lindex $pointC 1] - [lindex $pointB 1]]
    set x [expr [lindex $pointC 0] - [lindex $pointB 0]]
    set distPoint [expr sqrt([expr [expr $x * $x] + [expr $y * $y]])]
#case2
} elseif {$dotProAB_AC < 0} {
    set y [expr [lindex $pointC 1] - [lindex $pointA 1]]
    set x [expr [lindex $pointC 0] - [lindex $pointA 0]]
    set distPoint [expr sqrt([expr [expr $x * $x] + [expr $y * $y]])]
#case3
} else {
        set x1 [lindex $vectorAB 0]
		set y1 [lindex $vectorAB 1]
		set x2 [lindex $vectorAC 0]
		set y2 [lindex $vectorAC 1]
        set mod [expr sqrt([expr [expr $x1 * $x1] + [expr $y1 * $y1]])]
        set distPoint  [expr abs([expr [expr $x1 * $y2] - [expr $y1 * $x2]]) / $mod]
}

    set_attribute -object $cel -name DistToPGStrip -value $distPoint 

}

define_proc_attributes rcg::distPoint \
    -info "this proc will give the distance from cell to nnearestroute" \
    -hide_body \
    -define_args {
        {-cell "give the cell name " "" string required}
    }



#################################
#
#
# rcg analysis procs
#
#
#################################


proc rcg::MVColor {args} {
parse_proc_arguments -args ${args} opt
set color {"green" "red" "blue" "yellow" "orange"}
set count 0
gui_change_highlight -remove -all_colors
puts "the number of domains are [sizeof_coll [get_power_domains *]]\n "
	foreach_in_collection pdDomain [get_power_domains *] {
		gui_change_highlight -color [lindex $color $count] -collection [get_ports * -filter "power_domain == [get_object_name $pdDomain]"]
		puts "[get_object_name $pdDomain] -> [lindex $color $count]"
		set count [incr $count]
	}
}

define_proc_attributes rcg::MVColor \
    -info "color ports macros with respect to voltage areas" \
    -hide_body \
    -define_args {
    }



#### proc to remove all buffers and inverters on the net or port

    
proc rcg::Unbuffer {args} {
    parse_proc_arguments -args ${args} opt
    suppress_message SEL-004
    ##### unbuffer the entire net
    set class [get_attribute [get_selection] object_class]
    if {$class == "port"} {
        puts "class is port"
        set obj [get_ports [get_selection]]
        create_supernet [get_ports [get_selection]] -name temp
    } elseif {$class == "net"} {
        puts "class is net"
        create_supernet [get_pins -of [get_selection] -filter "direction == out"] -name temp
    } elseif {$class == "cell"} {
        puts "class is cell"
        create_supernet [get_pins -of [get_selection] -filter "direction == out"] -name temp
    }  elseif {$class == "pin"} {
        puts "class is pin"
        create_supernet [get_pins [get_selection] -filter "direction == out"] -name temp
    }    

    set bufInv [get_attribute [get_supernets temp -hier] transparent_cells]
    remove_supernets [get_supernets * -hierarchical]
    remove_buffers [remove_from_collection [get_cells $bufInv] [get_cells $bufInv -filter "is_level_shifter"]]
    if {[sizeof_coll [get_cells $bufInv -filter "ref_name =~ *PTCKB*"]]} {
        remove_buffers [get_cells $bufInv -filter "ref_name =~ *PTCKB*"]
    }
    if {[sizeof_coll [get_cells $bufInv -filter "ref_name =~ *BUF*"]]} {
        remove_buffers [get_cells $bufInv -filter "ref_name =~ *BUF*"]
    }
    if {[sizeof_coll [get_cells $bufInv]]} {
        remove_buffers [remove_from_collection [get_cells $bufInv] [get_cells $bufInv -filter "is_level_shifter"]]
    }
    unsuppress_message SEL-004
}


define_proc_attributes rcg::Unbuffer\
    -info "this proc will analyze the MV placement" \
    -hide_body \
    -define_args {
    }




###########
    
    
proc rcg::controlSignalRouting {args} {
    parse_proc_arguments -args ${args} opt
    set controlSource $opt(-port)
    set libCell $opt(-lib_cell)
    set insulatedNwellBuf "PTBUFFHDIWD4BWP143M286H3P48CPDLVT"
    set insulatedNwellBuf "PTINVHDIWD4BWP143M286H3P48CPDLVT"
    set clockAOB "PTCKBHDCWITLD4BWP143M286H3P48CPDLVT"
    set clockAOI "PTCKNHDCWITLD4BWP143M286H3P48CPDLVT"
    set normalBuf "BUFFD8BWP143M117H3P48CPDLVT"
    #set libCell BUFFD8BWP143M117H3P48CPDLVT
    ##### unbuffer the entire net
    if { [sizeof_collection [get_ports $controlSource]] > 0 } {
        set controlSourceClass "port"
    } elseif {[sizeof_collection [get_pins $controlSource]] > 0 } {
        set controlSourceClass "pin"
    }
    if {$controlSourceClass == "port"} {
        puts "class is port"
        create_supernet [get_ports $controlSource] -name temp
    } 

    set bufInv [get_attribute [get_supernets temp] transparent_cells]


    define_user_attribute -classes {cell} -type string -name rcg_is_invbuf

    remove_supernet temp
    #remove_buffers [get_cells $bufInv]
    foreach_in_collection cel [get_cells $bufInv] {
        if {[get_attribute [get_lib_cells -of [get_cells $cel]] is_buffer]} {
            set_attribute [get_cells $cel] -name rcg_is_invbuf -value "buffer"
        } else {
            set_attribute [get_cells $cel] -name rcg_is_invbuf -value "inverter"
        }
    }
    remove_buffers [remove_from_collection [get_cells $bufInv -filter "rcg_is_invbuf == buffer"] [get_flat_cells *special_fdr_buf_ctech_buf_ctech*]]
    remove_buffers [get_cells $bufInv -filter "rcg_is_invbuf == inverter"]

    set sleepPin [get_flat_pins -of [get_flat_nets $controlSource] -filter "name == NSLEEP"]
    set firstECOCell [insert_buffer $controlSource -lib_cell ${libCell}]
    connect_pin -driver [get_flat_pins -of $firstECOCell -filter "direction == out"] $sleepPin

    #### create pattern from first ECO Cell
}


define_proc_attributes rcg::controlSignalRouting \
    -info "this proc will buffer the control signals implementation" \
    -hide_body \
    -define_args {
        {-port "give the control signal port / pin name " "" string required}
        {-lib_cell "give the library cells " "" string required}
    }

## port CFIPwrgood

proc rcg::addControlPattern {args} {
### add a buffer at every x distance starting from point


}
define_proc_attributes rcg::addControlPattern \
    -info "this proc will buffer the control signals implementation" \
    -hide_body \
    -define_args {
        {-lib_cell "give the library cells " "" string required}
        {-xDistance "give the library cells " "" float required}
        {-startPoint "give the origin to start the calculation from " "" string required}
        {-routeMetal "give the metal routing for control signals" "" string required}
    }


    
proc getDriver {cell} {

    return [get_object_name [get_flat_cells -of [get_flat_pins -of [get_flat_nets -of [get_flat_pins -of $cell -filter "direction == out"]] -filter "direction == in"]]]

}

proc findLSOnPath {cell} {
    set pinName $cell    
    ### trace from the pin name and check if this is a LS cell
    set count 0
    while {$count < 10} {
        puts "loop $count [get_object_name [get_cells $pinName]]"
        set pinsName $pinName
            if {[sizeof_coll [get_cells $cel -filter "is_level_shifter"]] > 0} {
                #puts "[get_object_name [get_cells $pinName]] at location $count"
                return [get_object_name [get_cells $pinName]]
            } else {
                set pinName [getDriver [get_cells $pinName]]
                set pinsName [get_flat_cells $pinName]
            }
        incr count
    }
}



set powernet() ""
proc rcg::colorPowerOnHIP {{verbose 0}} {
    global powernet
    foreach snet [get_object_name [remove_from_collection [get_supply_nets] VSS]] {
        set powernet($snet) ""
    }

foreach_in_collection hip [get_flat_cells -filter "is_hard_macro"] {
    set powerPins [get_flat_pins -of $hip -filter "port_type == power" -all]
    foreach_in_collection powerPin $powerPins {
        set snet [get_object_name [get_supply_nets -of $powerPin]]
        if {[lsearch [get_object_name [get_supply_nets ]] $snet] == -1} {
            set snet [regsub "ss_" [lindex [get_object_name [get_supply_sets -of [get_supply_nets $snet]]] 0] ""]
        }
        lappend powernet($snet) [get_object_name $powerPin]
    } 
}

gui_change_highlight -remove -all_color
gui_change_highlight -color "red" -collection [get_flat_pins $powernet()]
if {[llength $powernet()] > 0} {
    puts "Warning: there are [llength $powernet()] pins that are not connected to any supply"
    if {$verbose == 1} {
        puts "the power pins without any supply connections are\n\n"
        puts "###########################################################"
        foreach_in_collection pin [get_flat_pins $powernet()] {
            puts [get_object_name $pin]
        }
        puts "###########################################################\n\n\n"
    }


}
set color {blue orange purple green yellow light_orange light_red}
set count 0
set keys [array names powernet]
            puts "pins with no supply associated is colored in red number of pins [llength $powernet()] : select the pins using \[change_selection \[get_flat_pins \$powernet()\]\]"
    foreach key [array names powernet] {
        if {[string length $key] > 0} {
            gui_change_highlight -color [lindex $color $count] -collection [get_flat_pins $powernet($key)]
            puts "pins connected on ${key} supply is colored in [lindex $color $count] number of pins [llength $powernet($key)] : select the pins using \[change_selection \[get_flat_pins \$powernet($key)\]\]"
            incr count
        }
    }
}







proc rcg::colorSignalOnHIP {{verbose 0}} {
    global powernet
    foreach snet [get_object_name [remove_from_collection [get_supply_nets] VSS]] {
        set powernet($snet) ""
    }

foreach_in_collection hip [get_flat_cells -filter "is_hard_macro"] {
    set powerPins [get_flat_pins -of $hip -filter "port_type == signal" ]
    foreach_in_collection powerPin $powerPins {
        set snet [get_object_name [get_related_supply_nets $powerPin]]
        if {[lsearch [get_object_name [get_supply_nets ]] $snet] == -1} {
            set snet [regsub "ss_" [lindex [get_object_name [get_supply_sets -of [get_supply_nets $snet]]] 0] ""]
        }
        lappend powernet($snet) [get_object_name $powerPin]
    } 
}

gui_change_highlight -remove -all_color
gui_change_highlight -color "red" -collection [get_flat_pins $powernet()]
if {[llength $powernet()] > 0} {
    puts "Warning: there are [llength $powernet()] pins that are not associated to any supply"
    if {$verbose == 1} {
        puts "the pins without any supply association are\n\n"
        puts "###########################################################"
        foreach_in_collection pin [get_flat_pins $powernet()] {
            puts [get_object_name $pin]
        }
        puts "###########################################################\n\n\n"
    }


}
set color {blue orange purple green yellow light_orange light_red}
set count 0
set keys [array names powernet]
            puts "pins with no supply associated is colored in red number of pins [llength $powernet()] : select the pins using \[change_selection \[get_flat_pins \$powernet()\]\]"
    foreach key [array names powernet] {
        if {[string length $key] > 0} {
            gui_change_highlight -color [lindex $color $count] -collection [get_flat_pins $powernet($key)]
            puts "pins associated with ${key} supply is colored in [lindex $color $count] number of pins [llength $powernet($key)] : select the pins using \[change_selection \[get_flat_pins \$powernet($key)\]\]"
            incr count
        }
    }
}


    

    
proc rcg::reportMainSupply {{verbose 0}} {
 set snet [get_object_name [get_supply_nets -of [get_selection]]]
        if {[lsearch [get_object_name [get_supply_nets ]] $snet] == -1} {
            if {$verbose == 1} {
                puts "\n\n"
                puts [get_object_name [get_supply_sets -of [get_supply_nets $snet]]]
                set snet [regsub "ss_" [lindex [get_object_name [get_supply_sets -of [get_supply_nets $snet]]] 0] ""]
            }
        }
        puts "\n\n"
    #puts $snet
    return $snet
}

   
proc rcg::getMainSupply {relSup} {
 set snet [get_object_name [get_supply_nets $relSup]]
        if {[lsearch [get_object_name [get_supply_nets ]] $snet] == -1} {
                set snet [regsub "ss_" [lindex [get_object_name [get_supply_sets -of [get_supply_nets $snet]]] 0] ""]
        }
    return $snet
}

proc rcg::quickSupplyResolve {} {
    rcg::getMainSupply [get_Attribute [get_power_domains -of [get_Selection ] ] primary_power]
}

proc rcg::getIsolationOnPort {port} {

}


proc rcg::getPfetInfo {} {
    puts "the number of voltage areas are [llength [get_object_name [get_voltage_areas]]]\n"
    foreach va [get_object_name [get_voltage_areas]] {
        puts "$va   -> [get_attribute [get_voltage_areas $va] normalized_power_net]"
    }

    report_pst -supplies [remove_from_collection [get_supply_nets] VSS] -nosplit

    #  set pinNameWidth 20
    #    set domainNameWidth 60
    #    set supWidth 20
    #    set vaWidth 20
    #    #set formatStr "%-${pinNameWidth}s %-${supWidth}s %-${domainNameWidth}s %-${vaWidth}s"
    #    puts ""
    #    set pinNameFormat "%-${pinNameWidth}s"
    #    set supNameFormat "%-${supWidth}s"
    #    set domainNameFormat "%-${domainNameWidth}s"
    #    set vaNameFormat "%-${domainNameWidth}s"
    #    #puts [format $formatStr "pinName" "supplyName" "domainName" "voltageArea"]
    #    #
    #    puts -nonewline [format $pinNameFormat "PinName"]
    #    puts -nonewline " "  ;# Extra space between columns
    #    puts -nonewline [format $supNameFormat "SupplyName"]
    #    puts -nonewline " "  ;# Extra space between columns
    #    puts -nonewline [format $domainNameFormat "DomainName"]
    #    puts -nonewline " "  ;# Extra space between columns
    #    puts [format $vaNameFormat "vaName"]
    #    
    #foreach_in_collection va [get_voltage_areas] {
    #    set pswitchCel [lindex [get_object_name [get_flat_cells -of [get_voltage_areas ${va}] -filter "is_power_switch"] ] 0]

    #    foreach_in_collection pswitchPPin [get_flat_pins -of [get_Flat_cells $pswitchCel] -filter "port_type == power" -all] {
    #       change_selection [get_flat_pins -all $pswitchPPin]
    #       set msup [rcg::reportMainSupply]
    #       set domainName [get_object_name [get_power_domains -of $pswitchCel]]
    #        set pinName [get_attribute [get_flat_pins -all $pswitchPPin] name]
    #        set va [get_object_name $va]
    #    #    puts -nonewline [format $formatStr $pinName $msup $domainName $va]
    #    puts -nonewline [format $pinNameFormat $pinName]
    #    puts -nonewline " "  ;# Extra space between columns
    #    puts -nonewline [format $supNameFormat $msup]
    #    puts -nonewline " "  ;# Extra space between columns
    #    puts -nonewline [format $domainNameFormat $domainName]
    #    puts -nonewline " "  ;# Extra space between columns
    #    puts -nonewline [format $vaNameFormat $va]

    #    }
    #}
    #puts ""
}


proc rcg::isolationControlSignal {args} {
### add a buffer at every x distance starting from point
    parse_proc_arguments -args ${args} opt
    set strategy $opt(-strategy)
#get_power_strategies -filter "type ==ISO"
    #get_flat_cells -of [get_power_strategies $strategy]
    define_user_attribute -classes pin -type string -name actDriver
    define_user_attribute -classes cell -type string -name sourceRelSup
    define_user_attribute -classes cell -type string -name sinkRelSup

    foreach_in_collection fpin [ get_flat_pins -of [get_flat_cells -of [get_power_strategies $strategy]] -filter {direction == in}] {
        set libCell [get_lib_cells -of [get_flat_cells -of $fpin]]
        set ctrlPin [get_attribute [get_lib_pins -of [get_lib_cells $libCell] -filter {direction == in && is_isolation_cell_enable_pin == true} ] name]
        if {$ctrlPin != "" } {
            set fpin [get_flat_pins -of [get_flat_cells -of $fpin] -filter "name == $ctrlPin"]
            set supNet [create_supernet -name temp ${fpin}]
            set driver [get_attribute [get_supernets ${supNet}]  drivers ]
            set_attribute [get_flat_pins $fpin] actDriver [get_object_name [get_flat_pins $driver]]
            remove_supernet $supNet
        } else {
            puts "ERROR: check is this is a enable level shifter and make the necessary changes"
            return 0
        }
    }

    
    foreach_in_collection fcel [get_flat_cells -of [get_power_strategies $strategy]] {
        set dataInPin [remove_from_collection [get_flat_pins -of [get_Flat_cells $fcel] -filter {direction == in}] [get_flat_pins -of [get_Flat_cells $fcel] -filter "name == $ctrlPin"]]
        set dataOutPin [get_Flat_pins -of [get_flat_cell $fcel] -filter "direction == out"]
        set supNet [create_supernet -name temp ${dataInPin}]
        set driver [get_attribute [get_supernets ${supNet}]  drivers ]
        remove_supernet $supNet
        set_attribute [get_flat_cells $fcel] sourceRelSup [rcg::getMainSupply [get_related_supply_nets  $driver]]

        set supNet [create_supernet -name temp ${dataOutPin}]
        set loads [get_attribute [get_supernets ${supNet}]  loads ]
        remove_supernet $supNet
        set_attribute [get_flat_cells $fcel] sinkRelSup [get_object_name [get_related_supply_nets  $loads]]
    }


    set actDriverPin [lsort -unique [get_attribute [get_flat_pins -of [get_flat_cells -of [get_power_strategies $strategy]] -filter {direction == in && name != a} ] actDriver]]
    puts "the number of drivers are [llength $actDriverPin]"
    rcg::cleanAnnotation
    create_annotation_text -text "Origin" -origin [list [get_flat_cells -of $actDriverPin] bbox_center 5% 5%] -color "red"         
    gui_change_highlight -color "yellow" -collection [get_flat_cells -of [get_power_strategies $strategy]]
    foreach actDPin ${actDriverPin} {
        set snet [create_supernet -name temp ${actDPin}]
        set allTreeCell [get_attribute [get_supernet ${snet}] transparent_cells]
        remove_supernet $snet
        gui_change_highlight -color "green" -collection [get_flat_cells $allTreeCell]
        gui_change_highlight -color "orange" -collection [get_flat_nets -of [get_flat_pins -of [get_flat_cells $allTreeCell]]]
    }
    puts "strategy: ${strategy} \ncontrolSignal: [get_object_name [get_attribute [get_power_strategies ${strategy}] isolation_signal]] \n control from domain: 
    [get_object_name [get_power_domains -of [get_flat_Cells -of $actDriverPin]]] 
    source supply: [lsort -uniq [get_attribute [get_flat_cells -of [get_power_strategies ${strategy}]] sourceRelSup]]
    sink supply: [lsort -uniq [get_attribute [get_flat_cells -of [get_power_strategies ${strategy}]] sinkRelSup]]
    \n\n"

}
define_proc_attributes rcg::isolationControlSignal \
    -info "this proc will highlight the control signals implementation" \
    -hide_body \
    -define_args {
        {-strategy "give the isolation strategy name " "" string required}
    }


proc rcg::cleanAnnotation {} {
    catch {gui_change_highlight -remove -all_color}
    catch {gui_remove_all_annotations -window Layout.1}
    catch {remove_annotation_shapes [get_annotation_shapes]}
}

proc rcg::traceNextStrategy {} {
    global strategyCount
    if {[info exists strategyCount]} {
        puts "getting the strategy id $strategyCount"
    } else {
        set strategyCount 0
    }
set strategy [lindex [get_object_name [get_power_strategies -filter "type ==ISO"]] $strategyCount]
rcg::isolationControlSignal -strategy $strategy
incr strategyCount
}

proc rcg::allStrategyFile {} {
set strategy [get_object_name [get_power_strategies -filter "type ==ISO"]]
     set outfile [open control_info.csv w]  
     puts $outfile "strategy,controlSignal,control from domain,source supply,sink supply"
    foreach each_strategy $strategy {
        rcg::isolationControlSignal -strategy $each_strategy
        set actDriverPin_1 [lsort -unique [get_attribute [get_flat_pins -of [get_flat_cells -of [get_power_strategies $each_strategy]] -filter {direction == in && name != a} ] actDriver]]
        puts $outfile "${each_strategy},[get_object_name [get_attribute [get_power_strategies ${each_strategy}] isolation_signal]],[get_object_name [get_power_domains -of [get_flat_Cells -of $actDriverPin_1]]],[lsort -uniq [get_attribute [get_flat_cells -of [get_power_strategies ${each_strategy}]] sourceRelSup]],[lsort -uniq [get_attribute [get_flat_cells -of [get_power_strategies ${each_strategy}]] sinkRelSup]]"
        
    }

}

proc rcg::associateIsoToStrategy {} {
set strategy [get_object_name [get_power_strategies -filter "type ==ISO"]]
define_user_attribute -classes cell -type string -name isoStrategyName
    foreach each_strategy $strategy {
        set_attribute [get_cells -of [get_power_strategies $each_strategy]] -name isoStrategyName -value ${each_strategy}
    }
}



source /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/tcl/ECOTracker/ECOTracker.tcl
