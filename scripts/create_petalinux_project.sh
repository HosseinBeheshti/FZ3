#!/bin/bash
shopt -s extglob
# directory settings
ORG_DIR=$(pwd) 
PROJ_NAME=fz3
PROJ_DIR=$ORG_DIR/build/apu/$PROJ_NAME
mkdir -p ./build/apu/

echo "Started at" >> $ORG_DIR/create_petalinux_project_runtime.txt
date >> $ORG_DIR/create_petalinux_project_runtime.txt
if [ -d "$PROJ_DIR" ]; then
     printf "Removing previous files ...\n"
     rm -rf $PROJ_DIR;
fi
cp $ORG_DIR/build/pl/design_1_wrapper.xsa $ORG_DIR/build/apu/design_1_wrapper.xsa
cd $ORG_DIR/build/apu
# create project
petalinux-create --type project --template zynqMP --name $PROJ_NAME
# import hardware
cd $PROJ_DIR
# get hardware description
petalinux-config --get-hw-description=../ --silentconfig
echo "Finished at" >> $ORG_DIR/create_petalinux_project_runtime.txt
date >> $ORG_DIR/create_petalinux_project_runtime.txt