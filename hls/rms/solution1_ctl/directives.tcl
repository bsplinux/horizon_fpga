############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
## Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
############################################################
set_directive_top -name rms_syn "rms_syn"
set_directive_interface -mode axis -register_mode both -depth 78 -register=true "rms_syn" sample
set_directive_interface -mode axis -register_mode both -depth 78 -register=true "rms_syn" zero_cross
set_directive_interface -mode axis -register_mode both -depth 3 -register=true "rms_syn" d_out
set_directive_pipeline -off=true "rms_syn/main_loop"
