
### this should be executed only in the month of july 2024 and only for NVLS project
if {$::env(PROJ_LV_COMMON_PROJECT_NAME) == "nvlsd"} {
    set startDate "2024-07-01"
    set endDate "2024-08-01"
    
    set curDate [clock format [clock seconds] -format {%Y-%m-%d}]
    set curSec [clock seconds]
    
    if {$curSec < [clock scan $endDate] } {
    puts "current data is $curDate lesser than $endDate removing the cells"
        
        set removeCells "bgrgen3vtgt0 ip78gtlyamux tsrdhoriz bgrgen3hip0"
        set cmd "remove_cells \[ get_flat_cells * -filter "
            foreach remCel $removeCells {
                lappend cmd "ref_name == $remCel ||"
            }
            regsub -all "\\|\\|$" [join $cmd " "] "" cmd
            lappend cmd "\"\]"
            set cmd [join $cmd " "]
            regsub -all "\\-filter" $cmd "-filter \"" cmd
            eval $cmd
        
        } 
}
#### end remove cells time based


write_verilog -compress gzip -split_bus -exclude { scalar_wire_declarations leaf_module_declarations physical_only_cells } \
-force_reference { i0mzaondnad1d01x5 i0mzaondnad1d02x5 i0mzaondnad1d03x5 i0mzaondxad1q01x5 i0mzaondxad1q02x5 i0mzaonpxad1q00x5 \
i0mzaontpad1d00x5 i0mzaontpad1n00x5 i0mzaondnab1d01x5 i0mzaondnab1d02x5 i0mzaondnab1d03x5 i0mzaondxab1q01x5 i0mzaondxab1q02x5 \
i0mzaonpxab1q00x5 i0mzaontpab1d00x5 i0mzaontpab1n00x5 i0mzaondnac1d01x5 i0mzaondnac1d02x5 i0mzaondnac1d03x5 i0mzaondxac1q01x5 \
i0mzaondxac1q02x5 i0mzaonpxac1q00x5 i0mzaontpac1d00x5 i0mzaontpac1n00x5 i8xfsoldic1_00 i8xfsoldic2_00 } ${blockName}.spyglass_splitbus.pg.vg.gz

save_upf ${blockName}.apr.upf


