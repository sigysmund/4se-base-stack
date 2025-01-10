# Provide access to the bootloader environment on the boot-env partition
do_install:append() {
    install -d -m 0644 ${D}/boot
    install -d -m 0644 ${D}/data
    printf "/dev/sda1    /boot   vfat    noauto          0 0\n\n" >> ${D}/${sysconfdir}/fstab
    printf "/dev/sda9    /data   ext4    defaults,sync   0 0\n\n" >> ${D}/${sysconfdir}/fstab
}

FILES:${PN} += " \
    /boot \
    /data \
"