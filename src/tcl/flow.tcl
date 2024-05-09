package require yaml
# ##################
# setting parameters
# ##################

set params_file params_IO_board.yaml
set new_proj_name {}
if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set proj_name [lindex $::argv $i] }
      "--new_project_name" { incr i; set new_proj_name [lindex $::argv $i] }
      "--build_project" { set build_project true }
	  "--use_recreation_script" { set use_recreation_script true}
	  "--params_file" { incr i; set params_file [lindex $::argv $i]}
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

set root_dir [pwd]
#parameters are set in parmas.yaml
set params [yaml::yaml2dict -file $root_dir/$params_file]

set script_dir $root_dir/[dict get $params scripts_location]
set proj_name       [dict get $params vivado_project]
set build_project   [dict get [dict get $params steps] build    ]
set reset_runs      [dict get [dict get $params steps] reset_runs]
set close_when_done [dict get [dict get $params steps] close]
set build_hls       [dict get [dict get $params steps] build_hls]

if {[dict exist $params new_proj_name]} {
	set new_proj_name [dict get $params new_proj_name]
} else {
	set new_proj_name {}
}
if {${new_proj_name} == {}} {
	set new_proj_name $proj_name
}

# ###################
# running the project
# ###################

source $script_dir/flow_procs.tcl
run_hls $params

#check if project exists ? open 
if {[file exist ./vivado/$new_proj_name/${new_proj_name}.xpr]} {
	open_project ./vivado/$new_proj_name/${new_proj_name}.xpr
} else {
	puts "Error: did not find vivado project, Exiting..."
	return 0
}
set_cache_location $params

#check that there are no files that vivado took from outside the GIT folder
if {[ext_files_exist]} {
    puts "Error: found files external to working folder, Exiting..."
    return 0
}

start_gui
update_ips $params
if $build_project {	gen_outputs $reset_runs}
if $close_when_done {exit}
