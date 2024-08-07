
set dateToday = `date +"%b%d"`_auto

mkdir $dateToday
cd $dateToday
set blocks = (gtcpipepar1 gtcpipepar2 gteusystop gteutop gtfillparssm1 gtfillparssm2 gtfillparssm3 gtfillparssm4 gtfillparssm5 gtfixpar1 gtfixpar2 gtfixpar3 gtfixpar4 gtfixpar5 gtgacspar1 gtgacspar2 gtgacspar3 gtglobalpar1 gtglobalpar2 gtl3bankm gtl3bankmtieoffpar1 gtl3bankmtieoffpar2 gtl3bankmtieoffpar3 gtl3bankmtieoffpar4 gtlscpar1 gtmcxlpar gtmempipefillpar1 gtmempipefillpar2 gtmempiperc1 gtmempiperc2 gtmempiperc3 gtmempiperc4 gtnode0cbepar1 gtnode0cbepar2 gtnode0lnepar1 gtnode0lnipar1 gtnode1cbepar1 gtnode1cbepar2 gtnode1lnepar1 gtnode1lnipar1 gtnodecompar1 gtnodecompar2 gtnodecompar3 gtnodecompar4 gtnoderc gtphyspar1 gtphyspar2 gtphyspar3 gtphyspar4 gtphyspar5 gtrasterpar1 gtrasterpar2 gtrxbarpar gtscfillpar1 gtscmtfixpar1 gtscmtfixpar2 gtsqbgfpar1 gtsqidim0par1 gtsqidim0par2 gtsqidim1par1 gtsqidim1par2 gtssmpar1 gtssmpar2 gtssmpar3 gtssmpar4 gtssmpar5 gtsqbgfpar0 gtssmpar6 gtssmtieoffpar1 gtssmtieoffpar2 gtxetlbpar1 gtxetlbpar2 gtzpipepar2 gtzpipepar1 gtcgpinf)

foreach block ($blocks)
 echo "$dateToday checkout block $block"
 vault checkout -domain sd -subset upf -tag FV -milestone A0_LV -block $block
 mv ${block}.upf ${block}.apr.upf
end


cd ..
unlink blockInputs
ln -s $dateToday blockInputs


