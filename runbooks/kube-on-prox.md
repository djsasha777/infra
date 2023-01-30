# Complete BAREMETAL kubernetes cluster on proxmox

Step by step installation

1. Download iso image of Proxmox https://www.proxmox.com/en/downloads/category/iso-images-pve

2. Create bootable usb drive with balena eatcher 

3. Insert bootable usb drive into server PC, select boot from usb in bios

4. Install Proxmox on system

5. Add user, create token

6. Add Cloud-init Template

Install tools to working mashine

    apt-get install libguestfs-tools

Download the ubuntu cloud image

    wget https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-20220627.1.x86_64.qcow2

Edit cloud.cfg

    virt-edit -a CentOS-Stream-GenericCloud-9-20220627.1.x86_64.qcow2 /etc/cloud/cloud.cfg

edit the disable_root: 1 to disable_root: 0

toggle the “lock_passwd” from “true” to “false”

commit line "- update_etc_hosts" 

cloud_init_modules:
 - migrator
 - seed_random
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - disk_setup
 - mounts
 - set_hostname
 - update_hostname
 - ca-certs
 - rsyslog
 - users-groups
 - ssh
 #- update_etc_hosts  

add apps to cloud-init image 

packages:
 - qemu-guest-agent
 - nano
 - wget
 - curl
 - net-tools

Save changes of /etc/cloud/cloud.cfg and exit

Edit /etc/ssh/sshd_config

 virt-edit -a CentOS-Stream-GenericCloud-9-20220627.1.x86_64.qcow2 /etc/ssh/sshd_config

set PermitRootLogin yes 

save and exit

copy modifier cloud image to proxmox

    scp modified-image.qcow2 proxmoxuser@192.168.1.111:/tmp

Create a new VM with ID 9000

    qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0

Import the downloaded disk to local storage with qcow2 format

    qm importdisk 9000 CentOS-Stream-GenericCloud-9-20220627.1.x86_64.qcow2 local --format qcow2

Attach the new disk to the VM as scsi drive

    qm set 9000 --scsihw virtio-scsi-pci --scsi0 local:9000/vm-9000-disk-0.qcow2

Add Cloud-Init CDROM drive

    qm set 9000 --ide2 local:cloudinit

Speed up booting by setting the bootdisk parameter

    qm set 9000 --boot c --bootdisk scsi0

Configure a serial console for display

    qm set 9000 --serial0 socket --vga serial0

Convert the VM into a template

    qm template 9000

7. ADD virtual maschines using terraform

    terraform init

    terraform plan

    terraform apply

8. Install load balancer with ansible scripts

    cd loadbalancers/ha

    terraform init

    terraform plan

    terraform apply

chech ansible variables in group_vars/all.yaml

install and configure haproxy and keepalived

    ansible-playbook ha-keep-main

9. Install k8s using kubespray

Clone kubespray git

    git clone https://github.com/kubernetes-sigs/kubespray.git
    cd kubespray

Install dependencies from requirements.txt this will install ansible and other components

    sudo pip3 install -r requirements.txt

Copy inventory/sample as inventory/mycluster

    cp -rfp inventory/sample inventory/mycluster

Update Ansible inventory file with inventory builder

    declare -a IPS=(192.168.1.201 192.168.1.202 192.168.1.203 192.168.1.204 192.168.1.205)
    CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

Review and change parameters under inventory/mycluster/group_vars

    cat inventory/mycluster/group_vars/all/all.yml
    cat inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

Deploy Kubespray with Ansible Playbook - run the playbook as root The option --become is required, as for example writing SSL keys in /etc/, installing packages and interacting with various systemd daemons. Without --become the playbook will fail to run!

    ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root --ask-pass --ask-become-pass cluster.yml


10. connect to kubernetes with kubeconfig

copy kubernetes config

    scp root@192.168.1.201:/etc/kubernetes/admin.conf ~/.kube/config

add zerotier address to hosts file

    cat >> /etc/hosts <<EOF
    172.22.196.114 my.kuber.domain
    EOF




kubectl config set-cluster mykuber --certificate-authority=ca.pem --embed-certs=true --server=https://77.223.98.80:8383/ --kubeconfig=mycloud.kubeconfig

kubectl config set-credentials admin
--client-certificate=admin.pem
--client-key=admin-key.pem
--embed-certs=true
--kubeconfig=mycloud.kubeconfig

kubectl config set-context default
--cluster=kubernetes-the-hard-way
--user=admin
--kubeconfig=mycloud.kubeconfig