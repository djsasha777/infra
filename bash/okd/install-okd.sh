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