# PROXBOX
Install Kubernetes with kubespray and terraform on proxmox

# ADD proxmox template

# run main.tf

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


    
