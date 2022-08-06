#!/bin/bash

# Download grafana
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_9.0.6_amd64.deb

# Install grafana
sudo apt-get install -y adduser libfontconfig1
sudo dpkg -i grafana-enterprise_9.0.6_amd64.deb

# systemd
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Installation cleanup
rm grafana-enterprise_9.0.6_amd64.deb