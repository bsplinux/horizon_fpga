############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
## Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
############################################################
set_directive_interface -mode ap_vld "rms" sample
set_directive_pipeline -off=true "rms/main_loop"
set_directive_interface -register=true "rms" d_out
set_directive_top -name rms "rms"
set_directive_interface -mode ap_ctrl_none "rms"
