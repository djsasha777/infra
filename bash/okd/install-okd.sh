#!/bin/bash
wget https://github.com/openshift/okd/releases/download/4.5.0-0.okd-2020-10-15-235428/openshift-client-linux-4.5.0-0.okd-2020-10-15-235428.tar.gz
wget https://github.com/openshift/okd/releases/download/4.5.0-0.okd-2020-10-15-235428/openshift-install-linux-4.5.0-0.okd-2020-10-15-235428.tar.gz

#Extract the okd version of the oc client and openshift-install:
tar -zxvf openshift-client-linux-4.5.0-0.okd-2020-10-15-235428.tar.gz
tar -zxvf openshift-install-linux-4.5.0-0.okd-2020-10-15-235428.tar.gz

#Move the kubectl, oc, and openshift-install to /usr/local/bin and show the version:
sudo mv kubectl oc openshift-install /usr/local/bin/
#Test oc client and openshift-install command
oc version
openshift-install version

#generate ssh key
sudo ssh-keygen -f cluster-install-ssh -t rsa -b 2048 -q -N ""
SSHKEY=$(sudo cat cluster-install-ssh.pub)
sudo sed -i '' "s|SSHKEY|${SSHKEY}|g" install-config.yaml

cd
openshift-install create manifests --dir=installdir/
# This lines disables schedule application pods on the master nodes 
sed -i 's/mastersSchedulable: true/mastersSchedulable: False/' installdir/manifests/cluster-scheduler-02-config.yml
openshift-install create ignition-configs --dir=installdir/

rm -drf /var/www/html/okd4
sudo mkdir /var/www/html/okd4

sudo cp -R installdir/* /var/www/html/okd4/
sudo chown -R apache: /var/www/html/
sudo chmod -R 755 /var/www/html/
curl localhost:8080/okd4/metadata.json

cd /var/www/html/okd4/
sudo wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/32.20201004\
.3.0/x86_64/fedora-coreos-32.20201004.3.0-metal.x86_64.raw.xz
sudo wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/32.20201004\
.3.0/x86_64/fedora-coreos-32.20201004.3.0-metal.x86_64.raw.xz.sig
sudo mv fedora-coreos-32.20201004.3.0-metal.x86_64.raw.xz fcos.raw.xz
sudo mv fedora-coreos-32.20201004.3.0-metal.x86_64.raw.xz.sig fcos.raw.xz.sig
sudo chown -R apache: /var/www/html/
sudo chmod -R 755 /var/www/html/