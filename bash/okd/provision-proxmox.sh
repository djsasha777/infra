#!/bin/bash

qm create 600 --cdrom local:iso/CentOS-Stream-9-latest-x86_64-dvd1.iso \
  --name "okd4-services" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 1 --sockets 1 \
  --memory 2048  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:60 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:32 \
  --serial0 socket

qm create 601 --cdrom ROUTER:iso/fedora-coreos-37.20230205.3.0-live.x86_64.iso \
  --name "okd4-bootstrap" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16384  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:61 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket

qm create 602 --cdrom ROUTER:iso/fedora-coreos-37.20230205.3.0-live.x86_64.iso \
  --name "okd4-controlplane1" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16384  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:62 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket

qm create 603 --cdrom ROUTER:iso/fedora-coreos-37.20230205.3.0-live.x86_64.iso \
  --name "okd4-compute1" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 2 --sockets 1 \
  --memory 8196  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:63 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket