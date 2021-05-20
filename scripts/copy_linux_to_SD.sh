#!/bin/bash
shopt -s extglob

echo "WARNING: This script delete all file in /media/<user>/BOOT and /media/<user>/rootfs directory" 
read -p "Do you want to continue(y/n)? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# directory settings
ORG_DIR=$(pwd) 
PROJ_NAME=fz3
PROJ_DIR=$ORG_DIR/build/apu/$PROJ_NAME

echo "----------------remove previous files----------------"
sudo rm -rf /media/$USER/BOOT/*
sudo rm -rf /media/$USER/rootfs/*

echo "----------------copy new files----------------"
# create dir: mkdir -p ./build/apu/fz3/images/linux/
sudo rm -rf /media/$USER/BOOT/*
cp $PROJ_DIR/images/linux/BOOT.BIN /media/$USER/BOOT/
cp $PROJ_DIR/images/linux/image.ub /media/$USER/BOOT/
cp $PROJ_DIR/images/linux/boot.scr /media/$USER/BOOT/
sudo tar xvf $PROJ_DIR/images/linux/rootfs.tar.gz -C /media/$USER/rootfs
echo "----------------Sync----------------"
sync
echo "----------------Unmount----------------"
umount /media/$USER/BOOT/
umount /media/$USER/rootfs/
echo "files copied successfully"