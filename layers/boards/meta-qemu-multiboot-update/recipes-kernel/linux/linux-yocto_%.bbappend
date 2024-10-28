# The customized machine type inherits from qemux86-64, and this needs to be expressed for the kernel build:
COMPATIBLE_MACHINE:qemux86-64-multiboot = "^(qemux86|qemux86-64)$"
KMACHINE:qemux86-64-multiboot = "qemux86-64"