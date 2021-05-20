#!/bin/bash
shopt -s extglob
ORG_DIR=$(pwd) 
PROJ_NAME=fz3
PROJ_DIR=$ORG_DIR/build/apu/$PROJ_NAME

echo "Started at" >> $ORG_DIR/build_petalinux_project_runtime.txt
date >> $ORG_DIR/build_petalinux_project_runtime.txt
cd $PROJ_DIR

# device tree : $ORG_DIR/petalinux/system-user.dtsi
cp $ORG_DIR/petalinux/system-user.dtsi $PROJ_DIR/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

# project configuration: $ORG_DIR/petalinux/config
#
# Add aarch64 sstate-cache and Setting download mirror
# 1) run petalinux-config -> Yocto Settings -> Local sstate feeds settings -> local sstate feeds url
#           Ex: /<path>/aarch64  for ZynqMP projects
#           (Ex: /tools/Xilinx/petalinux/sstate_aarch64_2020.1/aarch64)
# 
# 2) run petalinux-config -> Yocto Settings -> Add pre-mirror url
#       file://<path>/downloads for all projects
#       (Ex: file:///tools/Xilinx/petalinux/downloads)
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
cp $ORG_DIR/petalinux/config $PROJ_DIR/project-spec/configs/config

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
petalinux-config -c rootfs --silentconfig 

# kernel configuration: $ORG_DIR/petalinux/config
#
# 1)

# Execute the Petalinux Build
petalinux-build
# Package the build into Boot Images
petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --u-boot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --force

# Create qt sdk 
# ref:(https://www.hackster.io/mindaugas2/creating-gui-app-for-the-ultra96-with-qt-28d308)
petalinux-build --sdk

petalinux-package --sysroot
# prepare Qt 
# warning: this steps need to run manually
# 1) create new Kit:
#   Tools -> Options 
# 2) -> kits -> Qt versions -> Add -> Navigate to project location and then to /images/linux/sdk/sysroots/x86_64-petalinux-linux/usr/bin/qt5 and select qmake file.
# Note: change runtime with repo path
# 3) -> kits -> compilers -> Add -> GCC -> C -> renamed compiler to ZynqMPSoC_C / Compiler path: <project path>//images/linux/sdk/sysroots/x86_64-petalinux-linux/usr/bin/aarch64-xilinx-linux/aarch64-linux-gnu-gcc
# Note: change runtime with repo path
# 4) -> kits -> compilers -> Add -> GCC -> C++ -> renamed compiler to ZynqMPSoC_C++ / Compiler path: <project path>//images/linux/sdk/sysroots/x86_64-petalinux-linux/usr/bin/aarch64-xilinx-linux/aarch64-linux-gnu-g++
# Note: change runtime with repo path
# 5) sudo apt-get install gdb-multiarch
# 6) -> kits -> Debugger -> Add -> named debugger Multiarch_GDB / path:  /usr/bin/gdb-multiarch
# Note: Before this step turn on the board and connect it to the internet.
# 7) -> kits -> Add -> 
#       Name: UltraZedEV
#       sysroot: <project path>/images/linux/sdk/sysroots
#       Device type: Generic Linux Device 
#       Device: UltraZedEV
#       compiler: C -> <path>/aarch64-linux-gnu-g / <path>/aarch64-linux-gnu-g++
#       debugger: Multiarch_GDB
#       Qt version: <path>/Qt 5.13.2 (system)
# 8) close Qt creator
#
# 9) source <project path>/images/linux/sdk/environment-setup-aarch64-xilinx-linux
#
# 10) run Qt: {installation directory of Qt}/Tools/QtCreator/bin/qtcreator
#
# 11)  New Project, 
#           -> Application -> Qt Widgets Application
#           -> Build system -> qmake
#           -> Details -> ...
#           -> Kits -> fz3
# 12) complete your applicaiton
#
#   Now we need to complete last steps. Qt Creator doesn't know where to transfer 
#   executable file so we must tell this by editing.pro file. 
#   Open it and add these line below TARGET =... line:
#       target.files = fz3_led_test
#       target.path = /home/root
#       INSTALLS += target
#   These lines will tell Qt Creator where to put and how to name executable file in our Ultra96 development board. Click File -> Save All.
#
# 13) left menu: Project -> Run -> Command line Arguments field add -qws
#
# 13) left menu: Project -> Run -> Run Enviroment -> Add :Environment variable DISPLAY with value =0.0.
#
# 14) Run and fun!
#

echo "Finished at" >> $ORG_DIR/build_petalinux_project_runtime.txt
date >> $ORG_DIR/build_petalinux_project_runtime.txt

# Configuring SD boot 
# Ref: UG1144 (v2020.1) PetaLinux Tools Documentation Reference Guide page: 76
# $ cp images/linux/BOOT.BIN /media/<user>/BOOT/ 
# $ cp images/linux/image.ub /media/<user>/BOOT/ 
# $ cp images/linux/boot.scr /media/<user>/BOOT/ 
# $ sudo tar xvf rootfs.tar.gz -C /media/<user>/rootfs

# picocom terminal
# $ sudo picocom -b 115200 -r -l /dev/ttyUSB0 

# change ip core of board
# $ ifconfig eth0 10.1.1.11 netmask 255.255.255.0
# copy file
# $ scp <app_file> root@10.1.1.11:/home/petalinux/
# solve "ssh remote host identification has changed"
# $ ssh-keygen -R 10.1.1.11

# add custom apps and kernel module
# create a user module called mymodule in C (the default): 
# $ petalinux-create -t modules --name mymodule --enable 
# For example, to create a user application called myapp in C (the default): 
# $ petalinux-create -t apps --name myapp --enable 
# Removes the shared state cache of the corresponding component:
# $ petalinux-build -x distclean