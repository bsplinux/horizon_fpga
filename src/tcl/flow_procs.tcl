proc gen_bitfile {{reset_runs false}} {
    if {$reset_runs} { 
		reset_run [current_run -synthesis]
	}
    launch_runs [current_run] -to_step write_bitstream -jobs 16
    wait_on_run [current_run]
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
	puts "gen_bitfile \{\{reset_runs false\}\}"
	puts "export_design"
	puts "ext_files_exist \{\{verbose \"true\"\}\}"
	puts "gen_outputs"
	puts "flow_menu"
}
