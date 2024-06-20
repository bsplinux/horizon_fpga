############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
## Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
############################################################
open_project rms
set_top rms
add_files ../src/c/hls/rms/rms.cpp
add_files -tb ../src/c/hls/rms/rms_tb.cpp -cflags "-Wno-unknown-pragmas"
open_solution "solution1" -flow_target vivado
set_part {xa7z020-clg400-1Q}
create_clock -period 10 -name default
config_export -display_name rms -format ip_catalog -output ../vivado/repo/rms.zip -rtl verilog -vendor Growings -version 1.2 -vivado_clock 10
source "./rms/solution1/directives.tcl"
csim_design
csynth_design
cosim_design
export_design -rtl verilog -format ip_catalog -output ../vivado/repo/rms.zip
