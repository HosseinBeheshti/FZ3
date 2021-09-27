#!/bin/bash
shopt -s extglob
# directory settings
ORG_DIR=$(pwd) 
PROJ_NAME=vivado
mkdir -p ./build/pl/
PROJ_DIR=$ORG_DIR/build/pl/$PROJ_NAME
echo "Started at" >> $ORG_DIR/create_vivado_project_runtime.txt
date >> $ORG_DIR/create_vivado_project_runtime.txt
if [ -d "$PROJ_DIR" ]; then
     printf "Removing previous files ...\n"
     rm -rf $PROJ_DIR;
fi
# 
# prepare HLS IPs
echo "BUILDING HLS IPCORES"
cwd=$(pwd)
for file in ./hls/*/script.tcl; do
	cd $(dirname "$file")
	echo "++++++++++++++++++++++++++++++++++++++"
	pwd
	echo "++++++++++++++++++++++++++++++++++++++"
	# ---------------- CODE HERE ----------------
	vitis_hls -f script.tcl
	# -------------------------------------------
	echo "**************************************"
	cd $cwd	
	echo
done
# prepare SysGen IPs
# 
# build vivado project
vivado -mode tcl -source $ORG_DIR/tcl/create_vivado_project.tcl -notrace
echo "Finished at" >> $ORG_DIR/create_vivado_project_runtime.txt
date >> $ORG_DIR/create_vivado_project_runtime.txt