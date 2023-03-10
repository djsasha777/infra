#!/bin/bash

qm create 800 --cdrom local:iso/CentOS-Stream-9-latest-x86_64-dvd1.iso \
  --name "okd-bm-auto-helper" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 1 --sockets 1 \
  --memory 2048  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:20 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:32 \
  --serial0 socket

qm create 801 --cdrom local:iso/rhcos.iso \
  --name "okd-bm-auto-master-0" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16384  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:21 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket

qm create 802 --cdrom local:iso/rhcos.iso \
  --name "okd-bm-auto-master-1" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16384  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:22 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket

qm create 803 --cdrom local:iso/rhcos.iso \
  --name "okd-bm-auto-master-2" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 2 --sockets 1 \
  --memory 8196  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:23 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket

qm create 804 --cdrom local:iso/rhcos.iso \
  --name "okd-bm-auto-worker-0" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 2 --sockets 1 \
  --memory 8196  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:24 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket