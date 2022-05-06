# PROXBOX project

Install HA Kubernetes cluster with kubespray and terraform on proxmox

## Prerequisite

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


# connect to kube

    scp root@192.168.1.201:/etc/kubernetes/admin.conf .

    export KUBECONFIG=$KUBECONFIG:admin.conf

# Set up load balancer nodes (lb-0 & lb-1)

Install Keepalived & Haproxy

    apt update && apt install -y keepalived haproxy

configure keepalived: On both nodes create the health check script /etc/keepalived/check_apiserver.sh

    cat >> /etc/keepalived/check_apiserver.sh <<EOF
    #!/bin/sh

    errorExit() {
    echo "*** $@" 1>&2
    exit 1
    }

    curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
    if ip addr | grep -q 192.168.1.220; then
    curl --silent --max-time 2 --insecure https://192.168.1.220:6443/ -o /dev/null || errorExit "Error GET https://192.168.1.220:6443/"
    fi
    EOF

    chmod +x /etc/keepalived/check_apiserver.sh

Create keepalived config /etc/keepalived/keepalived.conf

    cat >> /etc/keepalived/keepalived.conf <<EOF
    vrrp_script check_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 3
    timeout 10
    fall 5
    rise 2
    weight -2
    }

    vrrp_instance VI_1 {
        state BACKUP
        interface eth0
        virtual_router_id 1
        priority 100
        advert_int 5
        authentication {
            auth_type PASS
            auth_pass mysecret
        }
        virtual_ipaddress {
            192.168.1.220
        }
        track_script {
            check_apiserver
        }
    }
    EOF

Enable & start keepalived service

    systemctl enable --now keepalived

Configure haproxy

Update /etc/haproxy/haproxy.cfg

    cat >> /etc/haproxy/haproxy.cfg <<EOF

    frontend kubernetes-frontend
    bind *:8383
    mode tcp
    option tcplog
    default_backend kubernetes-backend

    backend kubernetes-backend
    option httpchk GET /healthz
    http-check expect status 200
    mode tcp
    option ssl-hello-chk
    balance roundrobin
        server kmaster1 192.168.1.201:6443 check fall 3 rise 2
        server kmaster2 192.168.1.202:6443 check fall 3 rise 2

    EOF

Enable & restart haproxy service

    systemctl enable haproxy && systemctl restart haproxy


# ------------KUBERNETES------------

# USER CREATING 

1. Certificate signing

Generate private rsa key file:

    openssl genrsa -out user1.key 2048

Create request:

    openssl req -new -key user1.key -subj "/CN=user1" -out user1.csr 

Make base64 request:

    cat user1.csr | base64 | tr -d "\n"

Past pequest key to user1-csr.yaml

Apply request file:

    kubectl apply -f user1-csr.yaml

Approve csr:

    kubectl certificate approve user1

Get certificate:

    kubectl get csr user1 -o yaml

Decode certificate and save in file:

    ecco 'actual certificate from file user1 -o yaml' | base64 --decode > user1.crt

Connect to cluster using generated files:

    kubectl --server=http://192.168.1.111:6443 \
    --certificate-authority=/etc/kubernetes/pki/ca.crt \
    --client-certificate=user1.crt \
    --client-key=user1.key \







ssh -L 8383:192.168.1.220:8383 -i newkey root@172.22.130.145

cd PROXBOX
export KUBECONFIG=$KUBECONFIG:kubeconfig 
alias kubectl='kubectl --insecure-skip-tls-verify'
kubectl cluster-info

insecure-skip-tls-verify: true