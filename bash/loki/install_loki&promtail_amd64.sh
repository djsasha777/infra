#!/bin/bash
echo "This script will install loki on your system!"

VERS=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
if [[ "$VERS" == 'ubuntu' ]]; then
echo "your distributive is ${VERS}"
apt update
apt upgrade -y
apt install nano unzip
mkdir lokiinstall
cd lokiinstall
wget https://github.com/grafana/loki/releases/download/v2.7.3/loki-linux-amd64.zip
wget https://github.com/grafana/loki/releases/download/v2.7.3/promtail-linux-amd64.zip
wget https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml
wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml
unzip loki-linux-amd64.zip
unzip promtail-linux-amd64.zip
./loki-linux-amd64 -config.file=loki-local-config.yaml
./promtail-linux-amd64 -config.file=loki-local-config.yaml
cd ..
rm -rf lokiinstall
elif [[ "$VERS" == 'centos' ]]; then
echo "your distributive is ${VERS}"
dnf install nano unzip
mkdir lokiinstall
cd lokiinstall
wget https://github.com/grafana/loki/releases/download/v2.7.3/loki-linux-amd64.zip
wget https://github.com/grafana/loki/releases/download/v2.7.3/promtail-linux-amd64.zip
wget https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml
wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml
unzip loki-linux-amd64.zip
unzip promtail-linux-amd64.zip
./loki-linux-amd64 -config.file=loki-local-config.yaml
./promtail-linux-amd64 -config.file=loki-local-config.yaml
cd ..
rm -rf lokiinstall
else
  echo "DISTRIBUTIVE NOT SUPPORT!"
fi
echo "Loki and promtail are installed!"
