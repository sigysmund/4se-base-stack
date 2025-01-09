IMAGE_FSTYPES:append = " ext4 wic wic.bmap"

# Dependencies required to populate the partitioned full image.
do_image_wic[depends] += " \
    boot-image:do_deploy \
"

DEPENDS += " \
    boot-image \
"