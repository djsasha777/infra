#!/bin/bash


# go to concole of Bootstrap node

sudo coreos-installer install --ignition-url=http://192.168.1.60:8080/okd4/bootstrap.ign /dev/sda --insecure-ignition && reboot

# go to concole of Control-plane 

sudo coreos-installer install --ignition-url=http://192.168.1.60:8080/okd4/master.ign /dev/sda --insecure-ignition && reboot

# go to concole of Worker node

sudo coreos-installer install --ignition-url=http://192.168.1.60:8080/okd4/worker.ign /dev/sda --insecure-ignition && reboot


# start bootstraping

cd
openshift-install --dir=installdir/ wait-for bootstrap-complete --log-level=info

sudo sed '/ okd4-bootstrap /s/^/#/' /etc/haproxy/haproxy.cfg
sudo systemctl reload haproxy

export KUBECONFIG=~/install_dir/auth/kubeconfig
oc whoami
oc get nodes
oc get csr

wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x jq
sudo mv jq /usr/local/bin/
jq --version
oc get csr -ojson | jq -r '.items[] | select(.status == {} ) | .metadata.name' | \
xargs oc adm certificate approve
oc get clusteroperators

