namespace import ::tcl::mathfunc::*

proc getManhatDist {bbox1 bbox2} {
    set b1x1 [lindex [lindex $bbox1 0] 0]
    set b1x2 [lindex [lindex $bbox1 1] 0]
    set b1y1 [lindex [lindex $bbox1 0] 1]
    set b1y2 [lindex [lindex $bbox1 1] 1]
    
    #puts "$b1x1 $b1x2 $b1y1 $b1y2 "
    
    set b2x1 [lindex [lindex $bbox2 0] 0]
    set b2x2 [lindex [lindex $bbox2 1] 0]
    set b2y1 [lindex [lindex $bbox2 0] 1]
    set b2y2 [lindex [lindex $bbox2 1] 1]
    
    #puts "$b2x1 $b2x2 $b2y1 $b2y2 "

    set b1cx1 [expr $b1x1 + [abs [expr [expr $b1x1 - $b1x2]/2]]]
    set b1cy1 [expr $b1y1 + [abs [expr [expr $b1y1 - $b1y2]/2]]]

    set bbox1p1 "{$b1cx1 $b1cy1}"

    set b2cx1 [expr $b2x1 + [abs [expr [expr $b2x1 - $b2x2]/2]]]
    set b2cy1 [expr $b2y1 + [abs [expr [expr $b2y1 - $b2y2]/2]]]

    set bbox2p1 "{$b2cx1 $b2cy1}"
    
    #puts "$bbox1p1 $bbox2p1"
### now get the manhattan distance 
    set manhattan_distance [expr {abs($b1cx1 - $b2cx1) + abs($b1cy1 - $b2cy1)}]
    #puts $manhattan_distance
    return $manhattan_distance
    
}



proc checkAdjacentBlocks {cell1 cell2} {
    set allCells [get_cells -intersect  [get_attribute [resize_polygons [get_attribute [get_cells $cell1] bbox] -size {10} ] bbox] -hier]
    set check2 [sizeof_collection [remove_from_collection [get_cells $allCells ] [get_cells $cell2] -intersect]]
    set check1 [sizeof_collection [get_cells $allCells]]
    if {$check2 == 0} {
        #puts "cells are not close "
        return 1
    } else {
       #puts "cells are adjacent" 
       return 0
    }
}


proc getCellName {cell} {
#puts "get the correct name for cell"
set foundCell 0
set count [llength [split $cell "/"]]
set loopCount 0
    while {$foundCell == 0} {
        if {$loopCount > $count} {
            set foundCell 1
            return 0
        }
        #puts "check for cell "
        if {[sizeof_collection [get_cells $cell -quiet]] == 0} {
            set cell [file dirname $cell]
        } else {
            if {[get_attribute [get_cells $cell] design_type] == "module"} {
                set foundCell 1
                return $cell
            } else {
                set cell [file dirname $cell]
            }
        }
        incr loopCount
    }
}

proc checkMrVal {sourceBlk targetBlk sourceMr targetMr clk status} {
    set sourceBlkOrig $sourceBlk
    set targetBlkOrig $targetBlk

    #puts "first name $sourceBlk"
    set sourceBlk [getCellName $sourceBlk]
    #puts "final name $sourceBlk"
    if {$sourceBlk == 0} {
        puts "source cell not found $sourceBlk please check"
        return
    }
    #puts "first target name $targetBlk"
    set targetBlk [getCellName $targetBlk]
    #puts "final target name $targetBlk"
    if {$targetBlk == 0} {
        puts "target cell not found $targetBlk please check"
        return
    }

set sourceBbox [get_attribute [get_cells $sourceBlk] bbox]
set targetBbox [get_attribute [get_cells $targetBlk] bbox]

set manhatDist [getManhatDist $sourceBbox $targetBbox]

#### now get the least of the target and source MR
set minMr [expr {$sourceMr < $targetMr ? $sourceMr : $targetMr}]
set minMr [expr $minMr + 1]

#puts $minMr

if {$clk == "cuclk"} {
set Dist 480
} else {
set Dist 410
}
set Dist 470
set calDist [expr $Dist * $minMr]
#set calDist [expr 0.9 * $calDist]

if {$calDist < $manhatDist} {
set tag "dirty"
} else {
set tag "clean"
}

if {[checkAdjacentBlocks $sourceBlk $targetBlk]} {
    #puts "blocks are not adjacent"
    set notAdjacent "not adjacent"
} else {
    #puts "blocks are adjacent"
    set notAdjacent "adjacent"
}

if {$manhatDist > 0 && $tag == "dirty"} {
    #puts "the manhattan distance between $sourceBlk and $targetBlk : $manhatDist, the min RP is [expr $minMr - 1] and the path is $tag $calDist the cells are $notAdjacent"
    #puts "$sourceBlkOrig , $targetBlkOrig , $manhatDist, [expr $minMr - 1] , $calDist , $notAdjacent"
    return "$sourceBlkOrig , $targetBlkOrig , $manhatDist, [expr $minMr - 1] , $calDist , $notAdjacent, $tag"
}
return 0


}

set fileId [open "listMr.csv" "r"]
set fil [open "referenceAll.csv" "w"]
    puts $fil "senderInst,senderBundle,source MR,targetInst,targetBundle,targetMR,clock,status,minimumMR,manhattanDist, calculatedMR,requiredMR "    
    puts  "senderInst,senderBundle,source MR,targetInst,targetBundle,targetMR,clock,status,minimumMR,manhattanDist, calculatedMR,requiredMR "    
foreach line [split [read $fileId] "\n"] {
    set listData [split $line ","]

    #set sourceBlk [lindex $listData 0]
    #set sourceBlkCel [file dirname $sourceBlk]

    #set targetBlk [lindex $listData 1]
    #set targetBlkCel [file dirname $targetBlk]

    #set sourceMr [lindex $listData 2]
    #set targetMr [lindex $listData 3]
    #set clk [lindex $listData 4]
    #set status [lindex $listData 5]
    #checkMrVal $sourceBlk $targetBlk $sourceMr $targetMr $clk $status
    
    set ID [lindex $listData 0]
    set sourceBlk [lindex $listData 1]
    set sourceBlkCel [file dirname $sourceBlk]

    set sourceBundle [lindex $listData 2]    
    
    set sourceMr [lindex $listData 3]

    set targetBlk [lindex $listData 4]
    set targetBlkCel [file dirname $targetBlk]

    set targetBundle [lindex $listData 5]

    set targetMr [lindex $listData 6]
    set clk [lindex $listData 7]
    set status [lindex $listData 8]

    set lists [split [checkMrVal $sourceBlk $targetBlk $sourceMr $targetMr $clk $status] ","]
    #puts $lists
    if {[llength $lists] > 1} {
        #puts "rcgrcg ::: $lists"
        set manhatDist [lindex $lists 2]
        set minMr [lindex $lists 3]
        set calDist [lindex $lists 4]
        set requiredMr [expr [int [expr $manhatDist / 410]] + 1]
        puts "$sourceBlk,$sourceBundle,$sourceMr,$targetBlk,$targetBundle,$targetMr,$clk,$status,$minMr,$manhatDist,$calDist,$requiredMr"
        puts $fil "$sourceBlk,$sourceBundle,$sourceMr,$targetBlk,$targetBundle,$targetMr,$clk,$status,$minMr,$manhatDist,$calDist,$requiredMr"
    }

}
close $fileId
close $fil




