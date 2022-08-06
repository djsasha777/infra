#!/bin/bash
sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Prometheus Monitoring User" prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo touch /etc/prometheus/prometheus.yml
sudo touch /etc/prometheus/prometheus.rules.yml
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
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
  echo "ARCHITECTURE NOT SUPPORT!"
fi
echo "your architecture is ${ARC}"
VERSION=$(curl https://raw.githubusercontent.com/prometheus/prometheus/master/VERSION)
wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-${ARC}.tar.gz
tar xvzf prometheus-${VERSION}.linux-${ARC}.tar.gz
sudo cp prometheus-${VERSION}.linux-${ARC}/prometheus /usr/local/bin/
sudo cp prometheus-${VERSION}.linux-${ARC}/promtool /usr/local/bin/
sudo cp -r prometheus-${VERSION}.linux-${ARC}/consoles /etc/prometheus
sudo cp -r prometheus-${VERSION}.linux-${ARC}/console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
cat prometheus.yml | sudo tee /etc/prometheus/prometheus.yml
cat prometheus.rules.yml | sudo tee /etc/prometheus/prometheus.rules.yml
cat prometheus.service | sudo tee /etc/systemd/system/prometheus.service
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
rm prometheus-${VERSION}.linux-${ARC}.tar.gz
rm -rf prometheus-${VERSION}.linux-${ARC}