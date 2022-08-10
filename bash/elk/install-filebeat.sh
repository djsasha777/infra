#!/bin/bash
VERS=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
if [[ "$VERS" == 'ubuntu' ]]; then
echo "your distributive is ${VERS}"
apt update
sudo apt-get install -y filebeat
elif [[ "$VERS" == 'centos' ]]; then
echo "your distributive is ${VERS}"
yum install filebeat
cat >> /etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
      - /var/log/nginx/*-access.log
  fields:
    type: nginx_access
  fields_under_root: true
  scan_frequency: 5s

- type: log
  enabled: true
  paths:
      - /var/log/nginx/*-error.log
  fields:
    type: nginx_error
  fields_under_root: true
  scan_frequency: 5s

output.logstash:
  hosts: ["192.168.1.98:5044"]

xpack.monitoring:
  enabled: true
  elasticsearch:
    hosts: ["http://192.168.1.98:9200"]
EOF
else
  echo "DISTRIBUTIVE NOT SUPPORT!"
fi
echo "Filebeat are installed!"