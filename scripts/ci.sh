#!/bin/bash
source /tools/Xilinx/Vitis/2021.2/settings64.sh
source /tools/Xilinx/PetaLinux/2021.2/settings.sh
ORG_DIR=$(pwd) 
$ORG_DIR/scripts/clean_up_project_repo.sh
$ORG_DIR/scripts/create_vivado_project.sh
$ORG_DIR/scripts/build_vivado_project.sh
$ORG_DIR/scripts/create_petalinux_project.sh
$ORG_DIR/scripts/build_petalinux_project.sh