# -------------------------------------------------------------------
# Customized system image / rootfs
# -------------------------------------------------------------------
SUMMARY = "Customized system image / rootfs."

LICENSE = "MIT"

inherit system-image
require common-image-features.inc

CORE_IMAGE_BASE_INSTALL += "${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'weston-xwayland matchbox-terminal', '', d)}"

QB_MEM = "-m 512"

CORE_IMAGE_EXTRA_INSTALL:append = " plymouth"
CORE_IMAGE_EXTRA_INSTALL:append = " wayland weston"
IMAGE_FEATURES += "splash package-management hwcodecs weston"


IMAGE_INSTALL:append = " rsyslog"
PACKAGECONFIG:append:pn-rsyslog = " debug imdiag imfile snmp openssl systemd imjournal"
VIRTUAL-RUNTIME_syslog = ""
VIRTUAL-RUNTIME_base-utils-syslog = ""


IMAGE_INSTALL:append = " jack-server libjack libvpl libvpl-tools vpl-gpu-rt"
PACKAGECONFIG:append:pn-ffmpeg = " alsa bzlib fdk-aac gpl jack libopus libvorbis mp3lame openssl sdl2 speex v4l2 vdpau vpl vpx x264 x265 zlib"
IMAGE_INSTALL:append = " ffmpeg"


IMAGE_INSTALL:append = " htop mc nmap tcpdump iptraf-ng iputils nano curl alsa-tools gptfdisk"
EXTRA_IMAGE_FEATURES += "debug-tweaks"
