# debug linux app in vitis IDE
Replace the system-user.dtsi with the following:
```
/include/ "system-conf.dtsi"
/ {
    chosen {
        bootargs = "earlycon clk_ignore_unused   uio_pdrv_genirq.of_id=generic-uio";
        stdout-path = "serial0:115200n8";
    };
};
  
&axi_gpio_0 {
    compatible = "generic-uio";
};
```
build the project
## Creating the Platform: 
This is not required as users only need the sysroot in Vitis.

However, for ease of use we can create a platform that we can use in Vitis to create our Linux application.

First, let's set up the platform files. 

I have organized the platform files into a folder structure. This is not needed, but users need to be aware of the file paths in the BIF.

The BIF is used in bootgen to create the bootable image. Here we are only using placeholder file names.

```console
mkdir -p build/debug
cd build/debug
mkdir -p sw_comp/src/a53/xrt/image
mkdir sw_comp/src/boot
```
* Copy the image.ub, boot.scr and rootfs.cpio.gz files from the PetaLinux image/linux folder to sw_comp/src/a53/xrt/image 
* Copy the system.bit, bl31.elf, system.dtb, uboot.elf, zynqmp_fsbl (renamed fsbl.elf), and pmufw.elf files from the PetaLinux image/linux folder to sw_comp/src/boot

### Create the BIF:
```
the_ROM_image:
{
  [fsbl_config] a53_x64
  [bootloader] <fz3_base/boot/fsbl.elf>
  [pmufw_image] <fz3_base/boot/pmufw.elf>
  [destination_device=pl] <system.bit>
  [destination_cpu=a53-0, load=0x00100000] <fz3_base/boot/system.dtb>
  [destination_cpu=a53-0, exception_level=el-3, trustzone] <fz3_base/boot/bl31.elf>
  [destination_cpu=a53-0, exception_level=el-2] <fz3_base/boot/u-boot.elf>
}
```
Copy linux.bif to sw_comp/src/boot.

Now create a new platform project in Vitis as [This link](https://forums.xilinx.com/t5/Design-and-Debug-Techniques-Blog/Creating-a-Linux-user-application-in-Vitis-on-a-Zynq-UltraScale/ba-p/1141772)
* create from *.xsa
* linux/psu_cortexa53/64bit exclude bootarg
### Creating the Linux Image in Vitis:
