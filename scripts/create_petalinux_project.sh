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
echo "H128B717: run petalinux-create"
petalinux-create --type project --template zynqMP --name $PROJ_NAME
# import hardware
cd $PROJ_DIR
# get hardware description
echo "H128B717: run petalinux-config --get-hw-description"
petalinux-config --get-hw-description=../ --silentconfig

# device tree : $ORG_DIR/petalinux/system-user.dtsi
cp $ORG_DIR/petalinux/system-user.dtsi $PROJ_DIR/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi
echo "H128B717: device tree copied"

# project configuration: $ORG_DIR/petalinux/config
#
# Add aarch64 sstate-cache and Setting download mirror
# 1) run petalinux-config -> Yocto Settings -> Local sstate feeds settings -> local sstate feeds url
#           Ex: /<path>/aarch64  for ZynqMP projects
#           (Ex: /tools/Xilinx/PetaLinux/sstate_aarch64_2020.2/aarch64)
# 
# 2) run petalinux-config -> Yocto Settings -> Add pre-mirror url
#       file://<path>/downloads for all projects
#       (Ex: file:///tools/Xilinx/PetaLinux/downloads)
# 
# 3) run petalinux-config -> Yocto Settings -> Enable Network sstate feeds -> [ ] excludes
# 
# 4) run petalinux-config -> Yocto Settings -> Enable BB NO NETWORK -> [ ] excludes
# 
# 5) run petalinux-config -> Image Packaging Configuration -> Root filesystem type -> (EXT4 (SD/eMMC/SATA/USB))
# 
# 6) run petalinux-config -> Image Packaging Configuration ->  (/dev/mmcblk1p2) Device node of SD device
# 
# 7) Subsystem AUTO Hardware Settings -> Advanced bootable images storage Settings -> u-boot env partition settings -> image storage media (primary sd)    
# 
# 8) Subsystem AUTO Hardware Settings -> SD/SDIO Settings -> Primary SD/SDIO (psu_sd_1) 
# 
# 9) Subsystem AUTO Hardware Settings -> Ethernet Settings -> Randomise MAC Address[*] include
# 
# 10) Subsystem AUTO Hardware Settings -> Ethernet Settings -> Obtain IP Automatically[*] include
# 
# 11) change number of thread to 8
cp $ORG_DIR/petalinux/config $PROJ_DIR/project-spec/configs/config
echo "H128B717: config file copied"
echo "H128B717: run petalinux-config --silentconfig"
petalinux-config --silentconfig

# rootfs configuration: $ORG_DIR/petalinux/rootfs_config 
#
# 1) apps -> [*] gpio-demo
#
# 2) Image Features -> [*] auto-login
#
# 3) Petalinux Package Groups -> packagegroup-petalinux -> [*] packagegroup-petalinux
#
# 4) Petalinux Package Groups -> packagegroup-petalinux-multimedia -> [*] packagegroup-petalinux-multimedia  
#
# 5) Petalinux Package Groups -> packagegroup-petalinux-openamp -> [*] packagegroup-petalinux-openamp
#
# 6) Petalinux Package Groups -> packagegroup-petalinux-v4lutils -> [*] packagegroup-petalinux-v4lutils
#
# 7) Petalinux Package Groups -> packagegroup-petalinux-qt -> [*] packagegroup-petalinux-qt
#
# 8) Petalinux Package Groups -> packagegroup-petalinux-qt -> [*] populate_sdk_qt5
#
cp $ORG_DIR/petalinux/rootfs_config $PROJ_DIR/project-spec/configs/rootfs_config
echo "H128B717: rootfs_config file copied"
echo "H128B717: run petalinux-config -c rootfs --silentconfig"
petalinux-config -c rootfs --silentconfig 

echo "Finished at" >> $ORG_DIR/create_petalinux_project_runtime.txt
date >> $ORG_DIR/create_petalinux_project_runtime.txt