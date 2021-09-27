#!/bin/bash
shopt -s extglob
ORG_DIR=$(pwd) 
PROJ_NAME=fz3
PROJ_DIR=$ORG_DIR/build/apu/$PROJ_NAME
FILE_DIR=$ORG_DIR/petalinux/xilinx_axidma

echo "Started at" >> $ORG_DIR/add_module_and_apps_runtime.txt
date >> $ORG_DIR/add_module_and_apps_runtime.txt

cd $PROJ_DIR

# create a PetaLinux 'modules' project
petalinux-create -t modules -n xilinx-axidma --enable
cp -a $FILE_DIR/driver/*.c $FILE_DIR/driver/*.h $FILE_DIR/include/axidma_ioctl.h $PROJ_DIR/project-spec/meta-user/recipes-modules/xilinx-axidma/files
rm $PROJ_DIR/project-spec/meta-user/recipes-modules/xilinx-axidma/files/xilinx-axidma.c
rm $PROJ_DIR/project-spec/meta-user/recipes-modules/xilinx-axidma/files/Makefile
rm $PROJ_DIR/project-spec/meta-user/recipes-modules/xilinx-axidma/xilinx-axidma.bb
cp $FILE_DIR/custom_files/kernel_module/Makefile $PROJ_DIR/project-spec/meta-user/recipes-modules/xilinx-axidma/files/Makefile
cp $FILE_DIR/custom_files/kernel_module/xilinx-axidma.bb $PROJ_DIR/project-spec/meta-user/recipes-modules/xilinx-axidma/xilinx-axidma.bb
petalinux-build -c xilinx-axidma

# create a PetaLinux 'benchmark' apps
petalinux-create -t apps --name axidma-benchmark --enable 
rm $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files/axidma-benchmark.c
rm $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files/Makefile
rm $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/axidma-benchmark.bb
cp -a $ORG_DIR/hls/dma_lb_axis_switch/dma_lb_axis_switch/solution1/impl/ip/drivers/dma_lb_axis_switch_v1_0/src/*.c $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files
cp -a $ORG_DIR/hls/dma_lb_axis_switch/dma_lb_axis_switch/solution1/impl/ip/drivers/dma_lb_axis_switch_v1_0/src/*.h $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files
cp $FILE_DIR/examples/axidma_benchmark.c $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files/axidma_benchmark.c
cp -a $FILE_DIR/include/*.h $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files
cp -a $FILE_DIR/library/*.c $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files
cp $FILE_DIR/examples/util.c $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files
cp $FILE_DIR/examples/util.h $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files
cp $FILE_DIR/examples/conversion.h $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files
cp $FILE_DIR/custom_files/benchmark_application/Makefile $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/files/Makefile
cp $FILE_DIR/custom_files/benchmark_application/axidma-benchmark.bb $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-benchmark/axidma-benchmark.bb
petalinux-build -c axidma-benchmark

# create a PetaLinux 'transfer' apps
petalinux-create -t apps --name axidma-transfer --enable 
rm $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files/axidma-transfer.c
rm $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files/Makefile
rm $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/axidma-transfer.bb
cp -a $ORG_DIR/hls/dma_lb_axis_switch/dma_lb_axis_switch/solution1/impl/ip/drivers/dma_lb_axis_switch_v1_0/src/*.c $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files
cp -a $ORG_DIR/hls/dma_lb_axis_switch/dma_lb_axis_switch/solution1/impl/ip/drivers/dma_lb_axis_switch_v1_0/src/*.h $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files
cp $FILE_DIR/examples/axidma_transfer.c $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files/axidma_transfer.c
cp -a $FILE_DIR/include/*.h $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files
cp -a $FILE_DIR/library/*.c $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files
cp $FILE_DIR/examples/util.c $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files
cp $FILE_DIR/examples/util.h $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files
cp $FILE_DIR/examples/conversion.h $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files
cp $FILE_DIR/custom_files/transfer_application/Makefile $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/files/Makefile
cp $FILE_DIR/custom_files/transfer_application/axidma-transfer.bb $PROJ_DIR/project-spec/meta-user/recipes-apps/axidma-transfer/axidma-transfer.bb
petalinux-build -c axidma-transfer


# Execute the Petalinux Build
petalinux-build
# Package the build into Boot Images
petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --u-boot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --force

# Create qt sdk 
petalinux-build --sdk
petalinux-package --sysroot

echo "Finished at" >> $ORG_DIR/add_module_and_apps_runtime.txt
date >> $ORG_DIR/add_module_and_apps_runtime.txt
