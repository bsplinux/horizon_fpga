############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
## Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
############################################################
set_directive_top -name uarts "uarts"
set_directive_interface -mode m_axi -offset off "uarts" axi
set_directive_array_partition -type complete -dim 1 "uarts" uarts_d
set_directive_unroll "uarts/final_write"
set_directive_pipeline -off=true "uarts/main_loop"
set_directive_pipeline -off=true "uarts/uarts_loop"
set_directive_unroll "uarts/init_loop"
