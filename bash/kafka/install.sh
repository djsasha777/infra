#!/bin/bash
sudo adduser kafka
sudo adduser kafka sudo
su -l kafka
mkdir /kafka
cd /kafka
curl "https://downloads.apache.org/kafka/3.2.1/kafka_2.12-3.2.1.tgz" -o kafka.tgz
tar -xvzf kafka.tgz --strip 1
echo "delete.topic.enable = true" >> config/server.properties
sed -i 's|log.dirs=|log.dirs=/kafka/logs/|g' config/server.properties ##need test!
cp kafka.service /etc/systemd/system/kafka.service
cp zookeeper.service /etc/systemd/system/zookeeper.service
sudo systemctl start kafka
sudo systemctl enable zookeeper
sudo systemctl enable kafka