source /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/tcl/MVBasic/MVBasic.tcl
#/nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/tcl/gui_basic.tcl
set ToolBarName "RCG_MV"

gui_create_menu -menu "${ToolBarName}->MV" -heading "analysis"
gui_create_menu -menu "${ToolBarName}->Analysis" -tcl_cmd {rcg::MVPlaceAnalysis }
gui_create_menu -menu "${ToolBarName}->RunVclp" -tcl_cmd {RunVCLP [array get CellInfo]}

gui_create_menu -menu "${ToolBarName}->___" -separator
gui_create_menu -menu "${ToolBarName}->MVEco" -heading "ECO"
gui_create_menu -menu "${ToolBarName}->BUF/INV To AON" -tcl_cmd {rcg::ConvertBufferAOB  -CellInfo [array get CellInfo]}
gui_create_menu -menu "${ToolBarName}->AON To BUF/INV" -tcl_cmd {rcg::ConvertAOBBuffer  -CellInfo [array get CellInfo]}


gui_create_menu -menu "${ToolBarName}->___" -separator
gui_create_menu -menu "${ToolBarName}->designAnalysis" -heading "designAnalysis"
gui_create_menu -menu "${ToolBarName}->MVColor" -tcl_cmd {rcg::MVColor}


gui_create_menu -menu "${ToolBarName}->___" -separator
gui_create_menu -menu "${ToolBarName}->designAnalysis" -heading "repeaterPlanning"
gui_create_menu -menu "${ToolBarName}->MVColor" -tcl_cmd {rcg::MVColor}


