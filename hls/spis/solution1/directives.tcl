############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
## Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
############################################################
set_directive_interface -mode m_axi -offset off "spis" axi
set_directive_array_partition -type complete -dim 1 "spis" spis_d
set_directive_top -name spis "spis"
set_directive_pipeline -off=true "spis/main_loop"
set_directive_pipeline -off=true "spis/spis_loop"
