foreach fil (`cat names`)
echo $fil
date
python /nfs/site/disks/vmisd_vclp_efficiency/rcg/scripts/versionControl/python/checkUpfMTL128/correctPST.py -B ${fil} -R /nfs/zsc3/disks/mtl_128_intg_mw_01/final_checkout/upf_area/upf_rollup/Sep13_rollup/upf_rollup/work_gcd -U /nfs/site/disks/mtl_128_b0_intg_mw_01/dshanmux/upfRollup/run/upf_rollup/work_gcd/${fil}.upf
end
