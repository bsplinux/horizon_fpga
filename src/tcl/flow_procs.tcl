proc build_proj {{proj_name "pl"} {new_proj_name "pl"}} {
    set working_dir [pwd]
    set vivado_dir "./Vivado"
    set tcl_folder $working_dir/src/TCL
    
    cd $vivado_dir
	set ::argv [list --project_name $new_proj_name]
    set ::argc 2
    
	source ${tcl_folder}/recreate_${proj_name}.tcl
	# setting cache location because this property doesn't pass correctly when generating "recreate_${proj_name}.tcl"
	cd $working_dir
    config_ip_cache -import_from_project -use_cache_location Vivado/ip_cache
	#configuring runs 
	# setting back incremental compile, it was set off by the script to prevent using the dcp's that were not saved by SVN 
	set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs synth_1]
	set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_1]
}

proc gen_bitfile {{reset_runs false}} {
    if {$reset_runs} { 
		reset_run synth_1
	}
    launch_runs impl_1 -to_step write_bitstream -jobs 16
    wait_on_run impl_1
}

proc gen_multiboot {{bin_type "app"}} {
	set proj_name [get_property NAME [current_project]]
    open_run impl_1
    set dateTime_32bit [clock format [clock seconds] -format %d%m%y%H]
	if [file exists ./Deliveries/${proj_name}_${dateTime_32bit}] {} {
		file mkdir ./Deliveries/${proj_name}_${dateTime_32bit}
	}
	if {$bin_type == "single" || $bin_type == "all" || $bin_type == "golden"} {
		write_bitstream ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_no_jump.bit -force
	}
	if {$bin_type == "single" || $bin_type == "all"} {
		write_cfgmem -format bin -size 16 -interface SPIx4 -loadbit "up 0x00000000 ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_no_jump.bit" -file "./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_no_jump.bin" -force
    }
	set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design]
    set_property BITSTREAM.CONFIG.TIMER_CFG 0X40010000 [current_design]
    set_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR 0X00800000 [current_design]
    set_property BITSTREAM.CONFIG.NEXT_CONFIG_REBOOT ENABLE [current_design]
	if {$bin_type == "golden" || $bin_type == "all"} {
		#write_bitstream ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_golden.bit -force
		write_cfgmem -format bin -size 16 -interface SPIx4 -loadbit "up 0x00000200 ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_no_jump.bit" -loaddata "up 0x00000000 ./Deliveries/first_block.bin" -file "./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_golden.bin" -force
		#to create a real golden image without the first block use the next line, but since we use the first_block.bin file before the golden the actuall bit file for golden should be *_no_jump.bit as in the line above
		#write_cfgmem -format bin -size 16 -interface SPIx4 -loadbit "up 0x00000000 ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_golden.bit" -file "./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_golden.bin" -force
	}
	set_property BITSTREAM.CONFIG.NEXT_CONFIG_REBOOT DISABLE [current_design]
    set_property BITSTREAM.CONFIG.TIMER_CFG 32'h40100000 [current_design]
    reset_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR [current_design]
	if {$bin_type == "app" || $bin_type == "all"} {
		write_bitstream ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_app.bit -force
		write_cfgmem -format bin -size 16 -interface SPIx4 -loadbit "up 0x00800000 ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_app.bit" -file "./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_app.bin" -force
	}
	#more unused options just for reference
	#write_cfgmem -format bin -size 16 -interface SPIx4 -loadbit "up 0x00000000 ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_golden.bit up 0x00800000 ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_app.bit" -file "./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_both.bin" -force
	#write_cfgmem -format bin -size 16 -interface SPIx4 -loadbit "up 0x00000200 $golden_bitfile_location up 0x00800000 ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_app.bit" -loaddata "up 0x00000000 ./Deliveries/first_block.bin" -file "./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}_3bitfiles.bin" -force
	# note: for golden spcifiy somthinig like this: ./Deliveries/IO_board_golden_29112211/IO_board_golden_no_jump.bit      ====> must use a _no_jump version of golden
}

proc export_design {} {
    set proj_name [get_property NAME [current_project]]
    set dateTime_32bit [clock format [clock seconds] -format %d%m%y%H]
	if [file exists ./Deliveries/${proj_name}_${dateTime_32bit}] {} {
		file mkdir ./Deliveries/${proj_name}_${dateTime_32bit}
	}
	write_hw_platform -fixed -force  -include_bit -file ./Deliveries/${proj_name}_${dateTime_32bit}/${proj_name}.xsa
}

proc unset_cache {} {
	config_ip_cache -disable_cache
	set_property -name "ip_output_repo" -value "" -objects [current_project]
	update_ip_catalog
}

proc set_cache {{cache_location "Vivado/ip_cache"}} {
	config_ip_cache -import_from_project -use_cache_location $cache_location
}

proc set_cache_location {params} {
	#unset the cache from what's wrriten in xpr - very difficalut to manage this using git as vivado uses hard link
	unset_cache
	#set cache to relative location from project or abselut location comming from params file
	if {[dict exist $params cache_location]} {
		set_cache [dict get $params cache_location]
	} else {
		set_cache
	}
}

proc update_ips {params} {
	update_ip_catalog -rebuild -scan_changes
	report_ip_status -name ip_status
	# update HLS blocks
	export_ip_user_files -of_objects [get_ips -filter {IPDEF =~ *:hls:*}] -no_script -sync -force -quiet


	# at this stage if HLS has changed we need to update the IPs
	if {[dict get [dict get $params steps] build_hls]} {
		#building HLS IP names based on params file
		set t [join [dict keys [dict get $params hls_projects]] "* *"]
		set t1 *${t}*
		# HLS IP names can be obtained now by using get_ips $t1
		upgrade_ip [get_ips $t1] -log ip_upgrade.log
		export_ip_user_files -of_objects [get_ips $t1] -no_script -sync -force -quiet
		update_compile_order -fileset sources_1
	}
}

proc run_hls {params} {
	if {[dict get [dict get $params steps] build_hls]} {
		set hls_params_file [open "hls_params.yaml" w]
		set yaml_hls_params [yaml::dict2yaml $params]
		puts $hls_params_file $yaml_hls_params
		close $hls_params_file
		exec vitis_hls -f [pwd]/[dict get $params scripts_location]/create_hls_projs.tcl
	}
}

#check if project is open 
#if { catch {current_project} pr } {
#	# not open
#} else {
#	#open
#}

proc gen_proj_tcl {} {
    set working_dir [pwd]
    set vivado_dir [get_property DIRECTORY [current_project]] 
    set tcl_folder $working_dir/src/TCL
    set proj_name [get_property NAME [current_project]]
    
	cd $vivado_dir
	#we must unset cache, else hard link will be set in script, but don't worry we set back the cache location in build_proj
	config_ip_cache -disable_cache
	set_property -name "ip_output_repo" -value "" -objects [current_project]
	update_ip_catalog
	#we must release the DCP files form incremental compilation or else they will be included in the SVN build while they do not exist
	set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs synth_1]
	set_property write_incremental_synth_checkpoint false [get_runs synth_1]
	set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs impl_1]
	set_property incremental_checkpoint {} [get_runs impl_1]
	export_ip_user_files -of_objects  [get_files $working_dir/Vivado/${proj_name}/${proj_name}.srcs/utils_1/imports/impl_1/${proj_name}_top_routed.dcp] -no_script -reset -force -quiet
	remove_files  -fileset utils_1 $working_dir/Vivado/${proj_name}/${proj_name}.srcs/utils_1/imports/impl_1/${proj_name}_top_routed.dcp
	export_ip_user_files -of_objects  [get_files $working_dir/Vivado/${proj_name}/${proj_name}.srcs/utils_1/imports/synth_1/${proj_name}_top.dcp] -no_script -reset -force -quiet
	remove_files  -fileset utils_1 $working_dir/Vivado/${proj_name}/${proj_name}.srcs/utils_1/imports/synth_1/${proj_name}_top.dcp
	reset_property INCREMENTAL_CHECKPOINT [get_runs synth_1]
	
	write_project_tcl ../recreate_${proj_name}.tcl -force -internal
	file copy -force ../recreate_${proj_name}.tcl ${tcl_folder}/recreate_${proj_name}.tcl
	cd $working_dir
    
	#setting back the project to its orig status
	config_ip_cache -import_from_project -use_cache_location Vivado/ip_cache
	#configuring runs 
	# setting back incremental compile, it was set off by the script to prevent using the dcp's that were not saved by SVN 
	set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs synth_1]
	set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_1]
	config_ip_cache -import_from_project -use_cache_location Vivado/ip_cache
}

proc ext_files_exist {{verbose "true"}} {
    set proj_files [get_files]
    set proj_external_files [lsearch -nocase -all -inline -not $proj_files "[pwd]*"]
    if {$verbose == "true"} {
        foreach file $proj_external_files {
            puts "Error: file $file located outside of wokring folder"
        }
    }
    if {[llength $proj_external_files] > 0} {return 1} else {return 0}
}

proc gen_outputs {{reset_runs false} {bin_type app}} {
	gen_bitfile $reset_runs
	export_design
}

proc flow_menu {} {
	puts "flow_menu:"
	puts "build_proj \{\{proj_name \"pl\"\} \{new_proj_name \"pl\"\} - this utility is depricated"
	puts "gen_bitfile \{\{reset_runs false\}\}"
	puts "gen_multiboot \{bin_type app\}"
	puts "export_design"
	puts "gen_proj_tcl - this utility is depricated"
	puts "ext_files_exist \{\{verbose \"true\"\}\}"
	puts "gen_outputs"
	puts "flow_menu"
}
