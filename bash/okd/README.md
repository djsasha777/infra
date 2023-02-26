## OPENSHIFT ON BAREMETAL install

# run provision with ssh on proxmox host

    ssh root@192.168.1.11 'bash -s' < provision-proxmox.sh

# add mac adresses dhsp reservation to your local router

# run install on helper/services host

    ssh root@192.168.1.60 'bash -s' < install-all.sh

