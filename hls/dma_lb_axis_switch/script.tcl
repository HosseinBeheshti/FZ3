############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
############################################################
open_project dma_lb_axis_switch
set_top dma_lb_axis_switch
add_files dma_lb_axis_switch.cpp
open_solution "solution1" -flow_target vivado
set_part {xczu3eg-sfvc784-1-i}
create_clock -period 10 -name default
#source "./dma_lb_axis_switch/solution1/directives.tcl"
#csim_design
csynth_design
#cosim_design
export_design -flow syn -rtl verilog -format ip_catalog -description "loopback axis switch" -vendor "NoiseIran" -display_name "dma_lb_axis_sw" 
exit