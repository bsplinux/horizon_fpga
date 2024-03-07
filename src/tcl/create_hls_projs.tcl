package require yaml
set root_dir [pwd]

set hls_params_file [open "hls_params.yaml" r]
set rr [read $hls_params_file]
close $hls_params_file
set params [yaml::yaml2dict -file hls_params.yaml]

cd [dict get $params hls_location]
set projs [dict get $params hls_projects]

foreach proj [dict keys $projs] {
	set solution [dict get $projs $proj]
	open_tcl_project ./$proj/$solution/script.tcl
	close_project
}

foreach proj [dict keys $projs] {
	set solution [dict get $projs $proj]
    open_project $proj
    open_solution $solution
    source "./$proj/$solution/directives.tcl"
    csynth_design
    export_design -format ip_catalog -rtl verilog -vendor [dict get $params hls_vendor] -output "[dict get $params hls_output_location]/$proj.zip" -display_name $proj
    close_project
}

set vivado_path [dict get $params xilinx_location]/Xilinx/Vivado/[dict get $params xilinx_version]
exec $vivado_path\\settings64.bat
foreach proj [dict keys $projs] {
	exec unzip -o [dict get $params hls_output_location]/$proj.zip -d [dict get $params hls_output_location]/$proj
}

exit
