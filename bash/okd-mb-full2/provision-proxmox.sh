#!/bin/bash

qm create 700 --cdrom local:iso/CentOS-Stream-9-latest-x86_64-dvd1.iso \
  --name "okd4-helper" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 1 --sockets 1 \
  --memory 2048  \
  --net0 bridge=vmbr0,virtio=62:57:BC:A2:0E:70 \
  --net1 bridge=vmbr1,virtio=62:57:BC:A2:0E:77 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:32 \
  --serial0 socket

qm create 701 --cdrom local:iso/rhcos.iso \
  --name "okd4-bootstrap" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16384  \
  --net0 bridge=vmbr1,virtio=00:0c:29:83:df:be \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket

qm create 702 --cdrom local:iso/rhcos.iso \
  --name "okd4-controlplane1" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16384  \
  --net0 bridge=vmbr1,virtio=00:0c:29:65:d5:0f \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket

qm create 703 --cdrom local:iso/rhcos.iso \
  --name "okd4-compute1" --numa 0 --ostype l26 \
  --cpu cputype=host --cores 2 --sockets 1 \
  --memory 8196  \
  --net0 bridge=vmbr1,virtio=00:0c:29:da:35:11 \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --scsi0 file=NVME:100 \
  --serial0 socket