# PROXBOX project - kubernetes on proxmox

Prerequisite

Terraform and Ansible is required to run the provisioning and configuration tasks. You may install them on macOS using Homebrew.

    brew install terraform ansible python3

Alternatively you may prepare your Ansible environment using `virtualenv`.

    pip3 install virtualenv

# Create new python virtual environment in .ansible directory
    
    virtualenv .ansible

# Activate the virtual environment according to your shell (e.g. fish)
. .ansible/bin/activate.fish
```

## Terraform Secrets

The passwords and SSH keys used by Terraform are retrieved from the `terraform/.terraform_secret.yaml` file. You may generate new passwords and SSH keys with the following commands.

```bash
# Create a random password with length 24
openssl rand -base64 24

# Create a RSA ssh key in PEM format with comment and file path
ssh-keygen -t rsa -b 4096 -N "" -C "$USERNAME@$DOMAIN" -m pem -f "$PRIVATE_KEY"
```

For the full list of required passwords and SSH keys, you may refer to the below sample configuration.

```yaml
# Proxmox API host URL
pm_api_url: https://<api_host>:8006/api2/json
# Proxmox user (e.g. root@pam)
pm_user: <api_user>
# Proxmox password
pm_password: <api_password>
# Root password
root_password: <root_password>
# Cloud-init user (i.e. terraform) password
user_password: <user_password>
# Key used by Terraform and Ansible to login to bastion host to execute tasks
ssh_key: |
  -----BEGIN RSA PRIVATE KEY-----
  -----END RSA PRIVATE KEY-----
# Key used by the default Terraform sudo user among all provisioned hosts
terraform_key: |
  -----BEGIN RSA PRIVATE KEY-----
  -----END RSA PRIVATE KEY-----
```

Make sure the bastion host has the terraform user and `terraform_key` authorized with `ssh_key`. Otherwise, use the first gateway host as the bastion host and configure the public IP in your DNS service provider. You also need to ensure the `ssh_key` is your default key in `~/.ssh/id_rsa` or specify the location in the SSH command of `ansible/group_vars/*.yml`.

## Container Template

LXC [containers](https://pve.proxmox.com/wiki/Linux_Container) are used to create the DNS and load balancers. You may update available containers and download the required template with the cluster shell in the console as follows.

```bash
# Update the container template database
pveam update

# Download the ubuntu container template
pveam download local ubuntu-20.04-standard_20.04-1_amd64.tar.gz
```

## Cloud-init Template

Virtual machines provisioned are initialized using [Cloud-init](https://pve.proxmox.com/wiki/Cloud-Init_Support). You need to create a cloud-init image and convert it to a VM template in order to further clone in the Terraform Proxmox [provider](https://github.com/Telmate/terraform-provider-proxmox) into VMs, resizing the disk, and configuring the default user, passwords, SSH keys and network. To prepare the template, you may use the following commands.

```bash
# Download the ubuntu cloud image
wget http://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

# Create a new VM with ID 9000
qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0

# Import the downloaded disk to local storage with qcow2 format
qm importdisk 9000 focal-server-cloudimg-amd64.img local --format qcow2

# Attach the new disk to the VM as scsi drive
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local:9000/vm-9000-disk-0.qcow2

# Add Cloud-Init CDROM drive
qm set 9000 --ide2 local:cloudinit

# Speed up booting by setting the bootdisk parameter
qm set 9000 --boot c --bootdisk scsi0

# Configure a serial console for display
qm set 9000 --serial0 socket --vga serial0

# Convert the VM into a template
qm template 9000
```

## Get Started


# Set the one-time password for Proxmox API authentication

    export PM_OTP=xxxxx

# ADD virtual maschines using terraform

    terraform init

    terraform plan

    terraform apply

# Install load balancer with ansible scripts

    cd loadbalancers/ha

    terraform init

    terraform plan

    terraform apply

chech ansible variables in group_vars/all.yaml

install and configure haproxy and keepalived

    ansible-playbook ha-keep-main

# Install k8s using kubespray

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

    ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml


# connect to kubernetes with kubeconfig

copy kubernetes config

    scp root@192.168.1.201:/etc/kubernetes/admin.conf ~/.kube/config

add zerotier address to hosts file

    cat >> /etc/hosts <<EOF
    172.22.196.114 my.kuber.domain
    EOF

use kubectl or lens


fix for cloud-init

virt-edit -a centos9.qcow2 /etc/cloud/cloud.cfg

commit line "- update_etc_hosts" in file 

# The modules that run in the 'init' stage
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
 - update_etc_hosts  #this line!!!


get argocd default pass

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d