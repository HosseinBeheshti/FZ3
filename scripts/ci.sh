#!/bin/bash
source /tools/Xilinx/Vitis/2020.2/settings64.sh
source /tools/Xilinx/Petalinux/PetaLinux/2020.2/tool/settings.sh
ORG_DIR=$(pwd) 
$ORG_DIR/scripts/clean_up_project_repo.sh
$ORG_DIR/scripts/create_vivado_project.sh
$ORG_DIR/scripts/build_vivado_project.sh
$ORG_DIR/scripts/create_petalinux_project.sh
$ORG_DIR/scripts/build_petalinux_project.sh