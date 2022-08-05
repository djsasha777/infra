#!/bin/bash
set -x
# Make prometheus user
sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Prometheus Monitoring User" prometheus

# Make directories and dummy files necessary for prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo touch /etc/prometheus/prometheus.yml
sudo touch /etc/prometheus/prometheus.rules.yml

# Assign ownership of the files above to prometheus user
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

#obrain architecture
ARCHT=$(uname -m)
if [[ "$ARCHT" == 'aarch64' ]]; then
ARC=arm64
elif [[ "$ARCHT" == 'x86_64' ]]; then
ARC=amd64
elif [[ "$ARCHT" == 'arm64' ]]; then
ARC=arm64
elif [[ "$ARCHT" == 'amd64' ]]; then
ARC=amd64
else
  echo "ARCHITECTURE DONT SUPPORT"
fi
echo "your architecture is ${ARC}"

# Download prometheus and copy utilities to where they should be in the filesystem
#VERSION=2.2.1
VERSION=$(curl https://raw.githubusercontent.com/prometheus/prometheus/master/VERSION)
wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-${ARC}.tar.gz
tar xvzf prometheus-${VERSION}.linux-${ARC}.tar.gz

sudo cp prometheus-${VERSION}.linux-${ARC}/prometheus /usr/local/bin/
sudo cp prometheus-${VERSION}.linux-${ARC}/promtool /usr/local/bin/
sudo cp -r prometheus-${VERSION}.linux-${ARC}/consoles /etc/prometheus
sudo cp -r prometheus-${VERSION}.linux-${ARC}/console_libraries /etc/prometheus

# Assign the ownership of the tools above to prometheus user
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Populate configuration files
cat ./prometheus/prometheus.yml | sudo tee /etc/prometheus/prometheus.yml
cat ./prometheus/prometheus.rules.yml | sudo tee /etc/prometheus/prometheus.rules.yml
cat ./prometheus/prometheus.service | sudo tee /etc/systemd/system/prometheus.service

# systemd
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Installation cleanup
rm prometheus-${VERSION}.linux-${ARC}.tar.gz
rm -rf prometheus-${VERSION}.linux-${ARC}