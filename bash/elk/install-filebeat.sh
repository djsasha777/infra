#!/bin/bash
VERS=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
if [[ "$VERS" == 'ubuntu' ]]; then
echo "your distributive is ${VERS}"
apt update
sudo apt-get install -y filebeat
elif [[ "$VERS" == 'centos' ]]; then
echo "your distributive is ${VERS}"
yum install filebeat
EOF
else
  echo "DISTRIBUTIVE NOT SUPPORT!"
fi
echo "Filebeat are installed!"
cp filebeat.yml /etc/filebeat/