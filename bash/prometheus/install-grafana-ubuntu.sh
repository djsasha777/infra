#!/bin/bash
apt update
apt install -y apt-transport-https software-properties-common
curl -s https://packages.grafana.com/gpg.key | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/grafana_key.gpg --import
echo "deb https://packages.grafana.com/enterprise/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
apt update
apt install grafana