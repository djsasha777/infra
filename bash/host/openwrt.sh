opkg update
opkg install parted
parted /dev/mmcblk0
print
resizepart 5 +1G
reboot
mount /dev/mmcblk0p66 /mnt
umount /dev/mmcblk0p66
resize.f2fs -s /dev/mmcblk0p66
poweroff