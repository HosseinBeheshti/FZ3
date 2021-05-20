#!/bin/bash
shopt -s extglob
ORG_DIR=$(pwd) 
PROJ_NAME=vivado
PROJ_DIR=$ORG_DIR/build/pl/$PROJ_NAME
echo "Started at" >> $ORG_DIR/build_vivado_project_runtime.txt
date >> $ORG_DIR/build_vivado_project_runtime.txt
# generate bitstream and export platform
vivado -mode tcl -source ./tcl/build_vivado_project.tcl -notrace
# check timing errors 
vivado -mode batch -source ./tcl/check_project_timing.tcl
if [ $? -eq 1 ]
then
    exit 1
fi
echo "Finished at" >> $ORG_DIR/build_vivado_project_runtime.txt
date >> $ORG_DIR/build_vivado_project_runtime.txt