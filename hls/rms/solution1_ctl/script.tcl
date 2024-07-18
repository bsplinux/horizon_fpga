############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
## Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
############################################################
open_project rms
set_top rms_syn
add_files ../src/c/hls/rms/rms.cpp
add_files -tb ../src/c/hls/rms/rms_tb.cpp -cflags "-Wno-unknown-pragmas"
open_solution "solution1_ctl" -flow_target vivado
set_part {xa7z020-clg400-1Q}
create_clock -period 10 -name default
config_export -display_name rms -format ip_catalog -output ../vivado/repo/rms.zip -rtl verilog -vendor Growings -version 1.2 -vivado_clock 10
config_cosim -tool xsim
source "./rms/solution1_ctl/directives.tcl"
csim_design
csynth_design
cosim_design -tool xsim
export_design -format ip_catalog
