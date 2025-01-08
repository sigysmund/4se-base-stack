FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://0001-qemu-arm-prefer-virtio-as-boot-source.patch \
    file://0003-qemu_arm_defconfig-configure-virtio-fat-for-env.patch \
    file://fw_env.config \
"
