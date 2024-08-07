# Load methodology options and rules
proc ::upf::outputs_post_hook {} {
    checkpoint_session -session $::upf::params(env,design,name).PostCheckLP_rcg
}
#Read netlist
