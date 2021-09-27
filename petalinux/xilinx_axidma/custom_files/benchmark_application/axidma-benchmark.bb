#
# This file is the axidma-benchmark recipe.
#

SUMMARY = "Simple axidma-benchmark application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://axidma_benchmark.c \
           file://axidma_ioctl.h \
           file://conversion.h \
           file://libaxidma.h \
           file://libaxidma.c \
           file://util.c \
           file://util.h \
	       file://Makefile \
	       file://xdma_lb_axis_switch.c \
	       file://xdma_lb_axis_switch.h \
	       file://xdma_lb_axis_switch_hw.h \
	       file://xdma_lb_axis_switch_linux.c \
	       file://xdma_lb_axis_switch_sinit.c \
		  "

S = "${WORKDIR}"

do_compile() {
	     oe_runmake
}

do_install() {
	     install -d ${D}${bindir}
	     install -m 0755 axidma-benchmark ${D}${bindir}
}
