#!/bin/bash
ifconfig eth0 10.1.1.11 netmask 255.255.255.0
insmod /lib/modules/5.10.0-xilinx-v2021.2/extra/xilinx-axidma.ko 
./QTTCPServer