#!/bin/bash
if ! command -v vivado &> /dev/null
then
    echo "vivado environment not seted"
    echo "source /tools/Xilinx/Vitis/2020.2/settings64.sh"
	source /tools/Xilinx/Vitis/2020.2/settings64.sh
fi
if ! command -v petalinux-create &> /dev/null
then
    echo "PetaLinux environment not seted"
    echo "source /tools/Xilinx/PetaLinux/2020.2/settings.sh"
	source /tools/Xilinx/PetaLinux/2020.2/settings.sh
fi
ORG_DIR=$(pwd) 
$ORG_DIR/scripts/clean_up_project_repo.sh
$ORG_DIR/scripts/create_vivado_project.sh
$ORG_DIR/scripts/build_vivado_project.sh
$ORG_DIR/scripts/create_petalinux_project.sh
$ORG_DIR/scripts/build_petalinux_project.sh