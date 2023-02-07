#!/bin/bash

dependency_check_deb() {
java -version
if [ $? -ne 0 ]
    then
        # Installing Java 13 if it's not installed
        sudo apt-get install openjdk-13-jre-headless -y
    # Checking if java installed is less than version 7. If yes, installing Java 7. As logstash & Elasticsearch require Java 7 or later.
    elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.7 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
        then
            sudo apt-get install openjdk-13-jre-headless -y
fi
}

dependency_check_rpm() {
    java -version
    if [ $? -ne 0 ]
        then
            #Installing Java 7 if it's not installed
            sudo yum install jre-13.0.2-openjdk -y
        # Checking if java installed is less than version 7. If yes, installing Java 7. As logstash & Elasticsearch require Java 7 or later.
        elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.7 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
            then
                sudo yum install jre-13.0.2-openjdk -y
    fi
}



debian_kafka() {
sudo adduser kafka
sudo adduser kafka sudo
su -l kafka
mkdir /kafka
cd /kafka
curl "https://downloads.apache.org/kafka/3.2.1/kafka_2.12-3.2.1.tgz" -o kafka.tgz
tar -xvzf kafka.tgz --strip 1
echo "delete.topic.enable = true" >> config/server.properties
sed -i 's|log.dirs=|log.dirs=/kafka/logs/|g' config/server.properties ##need test!
cp kafka.service /etc/systemd/system/
cp zookeeper.service /etc/systemd/system/
sudo systemctl start kafka
sudo systemctl enable zookeeper
sudo systemctl enable kafka
}

rpm_kafka() {
sudo adduser kafka
sudo adduser kafka sudo
su -l kafka
mkdir /kafka
cd /kafka
curl "https://downloads.apache.org/kafka/3.2.1/kafka_2.12-3.2.1.tgz" -o kafka.tgz
tar -xvzf kafka.tgz --strip 1
echo "delete.topic.enable = true" >> config/server.properties
sed -i 's|log.dirs=|log.dirs=/kafka/logs/|g' config/server.properties ##need test!
cp kafka.service /etc/systemd/system/
cp zookeeper.service /etc/systemd/system/
sudo systemctl start kafka
sudo systemctl enable zookeeper
sudo systemctl enable kafka
}

# Installing KAFKA Stack
if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
    then
        echo " It's a Debian based system"
        dependency_check_deb
        debian_kafka
elif [ "$(grep -Ei 'fedora|redhat|centos' /etc/*release)" ]
    then
        echo "It's a RedHat based system."
        dependency_check_rpm
        rpm_kafka
else
    echo "This script doesn't support KAFKA installation on this OS."
fi

