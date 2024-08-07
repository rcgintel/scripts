sh mkdir upf_rollup
sh mkdir upf_rollup/apr_upfs

set sections {gen12p93dl2}

foreach section $sections {
catch {sh rm -rf ./upf_rollup/work_${section}}
#catch {redirect -file ${section}_rollup_upf.log -tee {upf::rollup -top $section -apr_upfs_dir  /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/inputs/blockInputs/ -work_dir ./upf_rollup/work_${section}}}
catch {redirect -file ${section}_rollup_upf.log -tee {upf::rollup -top $section -apr_upfs_dir  ../../samCreation/inputs/blockInputs/ -work_dir ./upf_rollup/work_${section}}}
}
exit

