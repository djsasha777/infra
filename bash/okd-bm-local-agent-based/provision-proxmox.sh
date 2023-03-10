#!/bin/bash

qm create 610 --cdrom ROUTER:iso/agent.x86_64.iso \
  --name "okd-bm-local-agent" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16384  \
  --net0 bridge=vmbr0,virtio=00:ef:44:21:e6:30 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:128 \
  --serial0 socket

qm create 611 --cdrom local:iso/CentOS-Stream-9-latest-x86_64-dvd1.iso \
  --name "okd-bm-installer" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 2 --sockets 1 \
  --memory 8192  \
  --net0 bridge=vmbr0,virtio=00:ef:44:21:e6:31 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:32 \
  --serial0 socket