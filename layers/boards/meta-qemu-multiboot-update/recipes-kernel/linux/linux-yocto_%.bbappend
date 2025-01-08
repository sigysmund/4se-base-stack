FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# The customized machine type inherits from qemuarm, and this needs to be expressed for the kernel build:
#COMPATIBLE_MACHINE:qemuarm-multiboot = "^(qemuarm)$"
#KMACHINE:qemuarm-multiboot = "qemuarm"

# TODO: Split MACHINE related task configs
# Install the device tree dumped by runqemu
# ?? qemuarm.dts ??


SRC_URI += "\
    file://defconfig \
    file://robustness.cfg \
    file://rauc.cfg \
"

#KERNEL_DEVICETREE = "qemuarm.dtb"

# Instead of patching the DTS into the kernel tree, copy it to allow easier modification of the file.
#do_configure:append() {
#    cp ${WORKDIR}/qemuarm.dts ${S}/arch/arm/boot/dts
#    echo "dtb-$(CONFIG_ARCH_QEMU) += qemuarm.dtb" >> ${S}/arch/arm/boot/dts/Makefile
#}