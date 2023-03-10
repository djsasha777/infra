#!/bin/bash
sudo dnf update -y
cd
mkdir installdir
cd installdir

echo "create files"
touch install-config.yaml agent-config.yaml

### change install-config.yaml
echo "#########changing file - install-config.yaml..."
cat  >> install-config.yaml <<EOF
apiVersion: v1
baseDomain: okd-agent.home.my
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  replicas: 1
metadata:
  name: okd-agent-cluster 
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 192.168.1.0/16
  networkType: OVNKubernetes 
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
pullSecret: 'PULLSECRET' 
sshKey: 'SSHKEY'  
EOF

echo "please enter ip address of host"
read -r IPADDRESS
echo "please enter the mac address"
read -r MACADDRESS
echo "please enter the router ip"
read -r ROUTERIP

sudo ssh-keygen -f cluster-install-ssh -t rsa -b 2048 -q -N ""
SSHKEY=$(sudo cat cluster-install-ssh.pub)
sudo sed -Ei "s|SSHKEY|$SSHKEY|g" install-config.yaml

echo "please enter pull secret"
read -r PULLSECRET
sudo sed -Ei "s|PULLSECRET|$PULLSECRET|g" install-config.yaml

### change agent-config.yaml
echo "#########changing file - agent-config.yaml..."
cat  >> agent-config.yaml <<EOF
apiVersion: v1alpha1
kind: AgentConfig
metadata:
  name: okd-bm-local-agent
rendezvousIP: IPADDRESS
hosts: 
  - hostname: master-0 
    interfaces:
      - name: eno1
        macAddress: MACADDRESS
    rootDeviceHints: 
      deviceName: /dev/sdb
    networkConfig: 
      interfaces:
        - name: eno1
          type: ethernet
          state: up
          mac-address: MACADDRESS
          ipv4:
            enabled: true
            address:
              - ip: IPADDRESS
                prefix-length: 24
            dhcp: false
      dns-resolver:
        config:
          server:
            - ROUTERIP
      routes:
        config:
          - destination: 0.0.0.0/0
            next-hop-address: ROUTERIP
            next-hop-interface: eno1
            table-id: 254  
EOF

sudo sed -i 's/IPADDRESS/'$IPADDRESS'/' agent-config.yaml
sudo sed -i 's/MACADDRESS/name: '$MACADDRESS'/' agent-config.yaml
sudo sed -i 's/ROUTERIP/name: '$ROUTERIP'/' agent-config.yaml

wget ftp://192.168.1.1/AiDisk_a1/repository/openshift-client-linux-4.12.0-0.okd-2023-03-05-022504.tar.gz
wget ftp://192.168.1.1/AiDisk_a1/repository/openshift-install-linux-4.12.0-0.okd-2023-03-05-022504.tar.gz

#Extract the okd version of the oc client and openshift-install:
tar -zxvf openshift-client-linux-4.12.0-0.okd-2023-03-05-022504.tar.gz
tar -zxvf openshift-install-linux-4.12.0-0.okd-2023-03-05-022504.tar.gz

#Move the kubectl, oc, and openshift-install to /usr/local/bin and show the version:
sudo mv kubectl oc openshift-install /usr/local/bin/

openshift-install --dir installdir agent create image

ftp -n <<EOF
open ftp://192.168.1.1/AiDisk_a1/template/iso/
put agent.x86_64.iso
EOF

openshift-install --dir installdir agent wait-for bootstrap-complete --log-level=info