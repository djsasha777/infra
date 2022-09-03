#!/bin/bash
VERS=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
if [[ "$VERS" == 'ubuntu' ]]; then
echo "your distributive is ${VERS}"
sudo apt update
sudo apt instll -y haproxy
elif [[ "$VERS" == 'centos' ]]; then
echo "your distributive is ${VERS}"
yum install haproxy
else
  echo "DISTRIBUTIVE NOT SUPPORT!"
fi
echo "HAproxy server software is installed! now configuring!"
echo "
  listen kubernetes-apiserver-https
  bind *:8383
  mode tcp
  option log-health-checks
  timeout client 3h
  timeout server 3h
  server master1 192.168.1.111:6443 check check-ssl verify none inter 10000
  server master2 192.168.1.112:6443 check check-ssl verify none inter 10000
  balance roundrobin" >> /etc/haproxy/haproxy.cfg
sudo systemctl restart haproxy  
echo "DONE"
