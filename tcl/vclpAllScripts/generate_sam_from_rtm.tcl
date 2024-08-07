#set ::TEV(verification_tools) "vclp vclp_sam_create"
set block_name gen12p93dl2.vclpSamGenJun02

### set the flow to generate sam files


lynx::create_block $block_name -from_template verify_upf.standalone -local
upf::params vclp,sa_model,enable     1
upf::params vclp,sa_model,enable     1
upf::params vclp,save_session,enable 0

set run_loc "/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/inputs/blockInputs/"
set rtm_location [eval {pwd}]
#/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/baseRun/Oct19/"

set blks [hier::get_designs * -node_type partition]



#copy override files
#sh cp /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/inputs/override/gen12p93dl2.overrides.tcl  builds/${block_name}/inputs/
#sh cp /nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/samCreation/inputs/override/gen12p93dl2.overrides.tcl  builds/${block_name}/inputs/floorplan/
####

foreach blk $blks {
    puts "working on $blk \nlinking from ${run_loc}/${blk}.spyglass_splitbus.pg.vg.gz to ${rtm_location}/builds/${block_name}/inputs/${blk}.pg.vg.gz"
    if { [file exists ${run_loc}/${blk}.spyglass_splitbus.pg.vg.gz]} {

        if {[file exists ${rtm_location}/builds/${block_name}/inputs/${blk}.pg.vg.gz]} {
            sh unlink ${rtm_location}/builds/${block_name}/inputs/${blk}.pg.vg.gz
        }
        sh ln -s ${run_loc}/${blk}.spyglass_splitbus.pg.vg.gz ${rtm_location}/builds/${block_name}/inputs/${blk}.pg.vg.gz
    }
    #puts "working on $blk \nlinking from ${run_loc}/${blk}.spyglass_splitbus.pg.vg.gz to "
    #if { [file exists ${run_loc}/${blk}.spyglass.pg.vg.gz]} {

    #    if {[file exists ${rtm_location}/builds/${block_name}/inputs/${blk}.pg.vg.gz]} {
    #        sh unlink ${rtm_location}/builds/${block_name}/inputs/${blk}.pg.vg.gz
    #    }
    #    #sh ln -s ${run_loc}/${blk}.spyglass.pg.vg.gz ${rtm_location}/builds/${block_name}/inputs/${blk}.pg.vg.gz
    #}

}

foreach blk $blks {
    if {[file exists ${rtm_location}/builds/${block_name}/inputs/${blk}.apr.upf]} {
        sh unlink ${rtm_location}/builds/${block_name}/inputs/${blk}.apr.upf
    }
  sh ln -s ${run_loc}/${blk}.apr.upf ${rtm_location}/builds/${block_name}/inputs/${blk}.apr.upf
}

lynx::configure_blocks $block_name -subdesigns [hier::get_designs * -node_type partition] -value {mode copy}


lynx::run_blocks $block_name  -target verify_upf/setup

return


fe_task_modify -id ${block_name}/1 -task setup -override -layer_name build -list_attr_set { variables { TEV(repo_command) "" } }
fe_task_modify -id ${block_name}/1 -task verify -override -layer_name build -list_attr_set { variables { TEV(verification_tools) "vclp vclp_sam_create" } }
bx_save -filename [pwd]/builds/${block_name}/scripts_build/conf/config_flow.xml
set ssessionName [lindex [split [session_list -tcl_list]  " "] 7]
reload_session -id rtm_shell/${ssessionName}


#sh sleep 15m

foreach blk $blks {
    if {[file exists ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz]} {
        if { [file type ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz] == "link" } {
            puts "netlist present as link ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz"
            puts "sh unlink ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz  "
                sh unlink ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz
        }

    if {[file exists ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz]} {
        if {[file type ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz] == "file"  } {
                puts "netlist present its file \n ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz"
                sh rm ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz  
            }
        }


    } else {
        puts "file dosent exists ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz"
    }
    puts "file linking ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz"
      sh ln -s ${run_loc}/${blk}.spyglass_splitbus.pg.vg.gz ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.spyglass_splitbus.pg.vg.gz  
    
}


foreach blk $blks {
    if {[file exists ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.apr.upf]} {
        catch {sh unlink ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.apr.upf}
        catch {sh rm ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.apr.upf}
    }
  puts "${run_loc}/${blk}.apr.upf ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.apr.upf"
  #sh cp ${run_loc}/${blk}.apr.upf ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.apr.upf
  sh ln -s ${run_loc}/${blk}.apr.upf ${rtm_location}/builds/${block_name}/00_verify_upf/000_setup/work/${blk}.apr.upf
}


lynx::run_blocks $block_name  -target verify_upf/verify__end


