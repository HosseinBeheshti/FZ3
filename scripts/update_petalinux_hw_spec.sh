#!/bin/bash
shopt -s extglob
ORG_DIR=$(pwd) 
PROJ_NAME=fz3
PROJ_DIR=$ORG_DIR/build/apu/$PROJ_NAME
FILE_DIR=$ORG_DIR/petalinux/xilinx_axidma

echo "Started at" >> $ORG_DIR/update_xsa_runtime.txt
date >> $ORG_DIR/update_xsa_runtime.txt

# update xsa 
cp $ORG_DIR/build/pl/design_1_wrapper.xsa $ORG_DIR/build/apu/design_1_wrapper.xsa

# import hardware
cd $PROJ_DIR

# get hardware description
echo "H128B717: run petalinux-config --get-hw-description"
petalinux-config --get-hw-description=../ --silentconfig

# Execute the Petalinux Build
petalinux-build
# Package the build into Boot Images
petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --u-boot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --force

# Create qt sdk 
petalinux-build --sdk
petalinux-package --sysroot

echo "Finished at" >> $ORG_DIR/update_xsa_runtime.txt
date >> $ORG_DIR/update_xsa_runtime.txt
