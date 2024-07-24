############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
## Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
############################################################
open_project uarts
set_top uarts
add_files ../src/c/hls/uarts/uarts.cpp
add_files -tb ../src/c/hls/uarts/uarts_tb.cpp -cflags "-Wno-unknown-pragmas"
open_solution "solution1" -flow_target vivado
set_part {xa7z020-clg400-1Q}
create_clock -period 10 -name default
config_export -display_name uarts -output ../vivado/repo/uarts.zip -vendor Growings -version 1.2
config_interface -m_axi_addr64=0
config_rtl -reset state
source "./uarts/solution1/directives.tcl"
csim_design -setup
csynth_design
cosim_design
export_design -rtl verilog -format ip_catalog -output ../vivado/repo/uarts.zip
