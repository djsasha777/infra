

# for erasing proxmox drive
lvremove /dev/pve/data  

# convert disc to qcow2
qemu-img convert -O qcow2 /dev/SSD-860/vm-109-disk-0 /mnt/openwrt.qcow2

# impord disc
qm importdisk 700 /mnt/openwrt.qcow2 SSD860 -format raw


#add phisical disc to vm
qm set 700 -scsi1 /dev/disk/by-id/ata-HP_SSD_S750_1TB_HASA43140200190
