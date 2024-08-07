


cd /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/topVclp/inputs/
set cels = (gtcgpinf gtcpipepar1 gtcpipepar2 gteusystop gteutop gtfillparssm1 gtfillparssm2 gtfillparssm3 gtfillparssm4 gtfillparssm5 gtfixpar1 gtfixpar2 gtfixpar3 gtfixpar4 gtfixpar5 gtgacspar1 gtgacspar2 gtgacspar3 gtglobalpar1 gtglobalpar2 gtl3bankm gtl3bankmtieoffpar1 gtl3bankmtieoffpar2 gtl3bankmtieoffpar3 gtl3bankmtieoffpar4 gtlscpar1 gtmcxlpar gtmempipefillpar1 gtmempipefillpar2 gtmempiperc1 gtmempiperc2 gtmempiperc3 gtmempiperc4 gtnode0cbepar1 gtnode0cbepar2 gtnode0lnepar1 gtnode0lnipar1 gtnode1cbepar1 gtnode1cbepar2 gtnode1lnepar1 gtnode1lnipar1 gtnodecompar1 gtnodecompar2 gtnodecompar3 gtnodecompar4 gtnoderc gtphyspar1 gtphyspar2 gtphyspar3 gtphyspar4 gtphyspar5 gtrasterpar1 gtrasterpar2 gtrxbarpar gtscfillpar1 gtscmtfixpar1 gtscmtfixpar2 gtsqbgfpar0 gtsqbgfpar1 gtsqidim0par1 gtsqidim0par2 gtsqidim1par1 gtsqidim1par2 gtssmpar1 gtssmpar2 gtssmpar3 gtssmpar4 gtssmpar5 gtssmpar6 gtssmtieoffpar1 gtssmtieoffpar2 gtxetlbpar1 gtxetlbpar2 gtzpipepar1 gtzpipepar2) 
set location = /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/baseRun/Jun02VclpFull/builds/gen12p93dl2.vclpSamGenJun02/
set netlist = /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/netlistRollup/runs/Dec15CleanTopBuildA1/builds/gen12p93dl2.vclpSamGenDirtyDec15/10_assembly/020_rollup/work/gen12p93dl2.pg.vg.gz
set upfLoc =  /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/upfRollup/Jun02/upf_rollup/work_gen12p93dl2/gen12p93dl2.upf
set dlink = 1

rm ../scripts/sam_verilog_files.list

foreach cel ($cels) 
 echo $cel
if (-f ${location}/00_verify_upf/${cel}_vclp_sam_create/work/${cel}.sam/${cel}/verilog/${cel}_SNPS_VCSTATIC_INM_abstract.v) then
 cp ${location}/00_verify_upf/${cel}_vclp_sam_create/work/${cel}.sam/${cel}/verilog/${cel}_SNPS_VCSTATIC_INM_abstract.v ${cel}.pg.vg
 echo "${cel},`pwd`/${cel}.pg.vg" >> ../scripts/sam_verilog_files.list
else
 echo "verilog does not exist"
endif
end

foreach cel ($pcels)
    echo $cel
    echo "${cel},`pwd`/${cel}.pg.vg" >> ../scripts/sam_verilog_files.list
end


gzip *.vg -f
cd /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/topVclp/runs


echo "netlist exists"
            perl $GTKIT_PATH/multiwell/lp/vclp_run.pl \
                -netlist $netlist \
                    -design gen12p93dl2 \
                        -upf $upfLoc \
                        -work Jun2TopVclp \
                            -sam_list_file /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/topVclp/scripts/sam_verilog_files.list \
                                -dlink $dlink


