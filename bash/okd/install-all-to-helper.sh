#!/bin/bash
# This script will install dns server and dns configs on dns-single-node-server
# sudo dnf install -y epel-release
# set -e #uncheck for debugging mode
sudo dnf update -y
cd
mkdir installdir
cd installdir
sudo dnf -y install bind bind-utils
echo "########creating files"
touch named.conf named.conf.local db.192.168.1 db.home.lab install-config.yaml
# file changing
echo "please enter the cluster name"
read -r CLUSTERID
echo "please enter the domain name"
read -r DOMAINID
echo "Setting cluster domain name to: $CLUSTERID.$DOMAINID"

ls 

### change named.conf
echo "#######Changing file - named.conf..."
cat  >> named.conf <<EOF
options {
	listen-on port 53 { 127.0.0.1; 192.168.1.60; };
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { localhost; 192.168.1.0/24; };
	recursion yes;
	
	forwarders {
                8.8.8.8;
                8.8.4.4;
        };

	dnssec-enable yes;
	dnssec-validation yes;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.root.key";

	managed-keys-directory "/var/named/dynamic";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
	type hint;
	file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
include "/etc/named/named.conf.local";
EOF

### change named.conf.local
echo "########Changing file - named.conf.local..."
cat  >> named.conf.local <<EOF
zone "home.lab" {
    type master;
    file "/etc/named/zones/db.home.lab"; # zone file path
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/named/zones/db.192.168.1";  # 192.168.1.0/24 subnet
};
EOF

### change db.192.168.1
echo "#######Changing file - db.192.168.1"
cat  >> db.192.168.1 <<EOF
\$TTL    604800
@       IN      SOA     okd4-services.home.lab. admin.home.lab. (
                  6     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800     ; Negative Cache TTL
)

; name servers - NS records
    IN      NS      okd4-services.home.lab.

; name servers - PTR records
210    IN    PTR    okd4-services.home.lab.

; OpenShift Container Platform Cluster - PTR records
200    IN    PTR    okd4-bootstrap.okd.home.lab.
201    IN    PTR    okd4-control-plane-1.okd.home.lab.
; 202    IN    PTR    okd4-control-plane-2.okd.home.lab.
; 203    IN    PTR    okd4-control-plane-3.okd.home.lab.
204    IN    PTR    okd4-compute-1.okd.home.lab.
; 205    IN    PTR    okd4-compute-2.okd.home.lab.
210    IN    PTR    api.okd.home.lab.
210    IN    PTR    api-int.okd.home.lab.
EOF

### change db.home.lab
echo "######changing file - change.home.lab..."

cat  >> db.home.lab <<EOF
\$TTL    604800
@       IN      SOA     okd4-services.home.lab. admin.home.lab. (
                  1     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800     ; Negative Cache TTL
)

; name servers - NS records
    IN      NS      okd4-services

; name servers - A records
okd4-services.home.lab.          IN      A       192.168.1.60

; OpenShift Container Platform Cluster - A records
okd4-bootstrap.okd.home.lab.        IN      A      192.168.1.61
okd4-control-plane-1.okd.home.lab.        IN      A      192.168.1.62
; okd4-control-plane-2.okd.home.lab.         IN      A      192.168.1.63
; okd4-control-plane-3.okd.home.lab.         IN      A      192.168.1.64
okd4-compute-1.okd.home.lab.        IN      A      192.168.1.65
; okd4-compute-2.okd.home.lab.        IN      A      192.168.1.66

; OpenShift internal cluster IPs - A records
api.okd.home.lab.    IN    A    192.168.1.60
api-int.okd.home.lab.    IN    A    192.168.1.61
*.apps.okd.home.lab.    IN    A    192.168.1.61
etcd-0.okd.home.lab.    IN    A     192.168.1.62
; etcd-1.okd.home.lab.    IN    A     192.168.1.63
; etcd-2.okd.home.lab.    IN    A    192.168.1.64
console-openshift-console.apps.okd.home.lab.     IN     A     192.168.1.61
oauth-openshift.apps.okd.home.lab.     IN     A     192.168.1.61

; OpenShift internal cluster IPs - SRV records
_etcd-server-ssl._tcp.okd.home.lab.    86400     IN    SRV     0    10    2380    etcd-0.lab
; _etcd-server-ssl._tcp.okd.home.lab.    86400     IN    SRV     0    10    2380    etcd-1.lab
; _etcd-server-ssl._tcp.okd.home.lab.    86400     IN    SRV     0    10    2380    etcd-2.lab
EOF

### change install-config.yaml
echo "#########changing file - install-config.yaml..."
cat  >> install-config.yaml <<EOF
apiVersion: v1
baseDomain: home.lab
metadata:
  name: okd

compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0

controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 1

networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14 
    hostPrefix: 23 
  networkType: OpenShiftSDN
  serviceNetwork: 
  - 172.30.0.0/16

platform:
  none: {}

fips: false

pullSecret: 'PULLSECRET' 
sshKey: 'SSHKEY'   
EOF

# Replace dns references in named config
echo "#######Files modification"
sudo sed -i 's/okd.home.lab/'$CLUSTERID.$DOMAINID'/' db.192.168.1
sudo sed -i 's/home.lab/'$DOMAINID'/' db.192.168.1
sudo sed -i 's/home.lab/'$DOMAINID'/' db.192.168.1
sudo sed -i 's/okd.home.lab/'$CLUSTERID.$DOMAINID'/' db.home.lab
sudo sed -i 's/home.lab/'$DOMAINID'/' db.home.lab
sudo sed -i 's/home.lab/'$DOMAINID'/' db.192.168.1
sudo mv db.home.lab db.$DOMAINID
sudo sed -i 's/home.lab/'$DOMAINID'/' named.conf.local
sudo sed -i 's/home.lab/'$DOMAINID'/' install-config.yaml
sudo sed -i 's/name: okd/name: '$CLUSTERID'/' install-config.yaml

ls 

# dns configure
echo "dns files configure"
sudo cp named.conf /etc/named.conf
sudo cp named.conf.local /etc/named/
sudo mkdir /etc/named/zones
sudo cp db* /etc/named/zones
sudo systemctl enable named
sudo systemctl start named

#add firewall rules
echo "adding firewall rules"
sudo firewall-cmd --permanent --add-port=53/udp
sudo firewall-cmd --reload

echo "DNS server configuration finished! "

#  LOAD BALANCER install
dnf install -y haproxy
echo "HAproxy server software is installed! now configuring!"
cat  >> /etc/haproxy/haproxy.cfg <<EOF

frontend okd4_k8s_api_fe
    bind :6443
    default_backend okd4_k8s_api_be
    mode tcp
    option tcplog

backend okd4_k8s_api_be
    balance source
    mode tcp
    server      okd4-bootstrap 192.168.1.60:6443 check
    server      okd4-control-plane-1 192.168.1.61:6443 check
    # server      okd4-control-plane-2 192.168.1.62:6443 check
    # server      okd4-control-plane-3 192.168.1.63:6443 check

frontend okd4_machine_config_server_fe
    bind :22623
    default_backend okd4_machine_config_server_be
    mode tcp
    option tcplog

backend okd4_machine_config_server_be
    balance source
    mode tcp
    server      okd4-bootstrap 192.168.1.60:22623 check
    server      okd4-control-plane-1 192.168.1.61:22623 check
    # server      okd4-control-plane-2 192.168.1.62:22623 check
    # server      okd4-control-plane-3 192.168.1.63:22623 check

frontend okd4_http_ingress_traffic_fe
    bind :80
    default_backend okd4_http_ingress_traffic_be
    mode tcp
    option tcplog

backend okd4_http_ingress_traffic_be
    balance source
    mode tcp
    server      okd4-compute-1 192.168.1.64:80 check
    # server      okd4-compute-2 192.168.1.65:80 check

frontend okd4_https_ingress_traffic_fe
    bind *:443
    default_backend okd4_https_ingress_traffic_be
    mode tcp
    option tcplog

backend okd4_https_ingress_traffic_be
    balance source
    mode tcp
    server      okd4-compute-1 192.168.1.64:443 check
    # server      okd4-compute-2 192.168.1.65:443 check
EOF
setsebool -P haproxy_connect_any=1
sudo systemctl enable haproxy
sudo systemctl restart haproxy  
echo "haproxy installation and configuration is DONE"
echo "add firewall rules"
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=22623/tcp
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
echo "firewall rules added"

#httpd install
sudo dnf install -y httpd
sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
sudo setsebool -P httpd_read_user_content 1
sudo systemctl enable httpd
sudo systemctl start httpd
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
curl localhost:8080

# install okd
wget https://github.com/okd-project/okd/releases/download/4.12.0-0.okd-2023-02-18-033438/openshift-client-linux-4.12.0-0.okd-2023-02-18-033438.tar.gz
wget https://github.com/okd-project/okd/releases/download/4.12.0-0.okd-2023-02-18-033438/openshift-install-linux-4.12.0-0.okd-2023-02-18-033438.tar.gz

#Extract the okd version of the oc client and openshift-install:
tar -zxvf openshift-client-linux-4.12.0-0.okd-2023-02-18-033438.tar.gz
tar -zxvf openshift-install-linux-4.12.0-0.okd-2023-02-18-033438.tar.gz

#Move the kubectl, oc, and openshift-install to /usr/local/bin and show the version:
sudo mv kubectl oc openshift-install /usr/local/bin/
#Test oc client and openshift-install command
oc version
openshift-install version

#generate ssh key
sudo ssh-keygen -f cluster-install-ssh -t rsa -b 2048 -q -N ""
SSHKEY=$(sudo cat cluster-install-ssh.pub)
sudo sed -Ei "s|SSHKEY|$SSHKEY|g" install-config.yaml

echo "please enter pull secret"
read -r PULLSECRET
sudo sed -Ei "s|PULLSECRET|$PULLSECRET|g" install-config.yaml

cd
openshift-install create manifests --dir=installdir/
# This lines disables schedule application pods on the master nodes 
sed -i 's/mastersSchedulable: true/mastersSchedulable: False/' installdir/manifests/cluster-scheduler-02-config.yml
openshift-install create ignition-configs --dir=installdir/

rm -drf /var/www/html/okd4
sudo mkdir /var/www/html/okd4

sudo cp -R installdir/* /var/www/html/okd4/
sudo chown -R apache: /var/www/html/
sudo chmod -R 755 /var/www/html/
curl localhost:8080/okd4/metadata.json

cd /var/www/html/okd4/
sudo wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230205.3.0/x86_64/fedora-coreos-37.20230205.3.0-metal.x86_64.raw.xz
sudo wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230205.3.0/x86_64/fedora-coreos-37.20230205.3.0-metal.x86_64.raw.xz.sig
sudo mv fedora-coreos-37.20230205.3.0-metal.x86_64.raw.xz fcos.raw.xz
sudo mv fedora-coreos-37.20230205.3.0-metal.x86_64.raw.xz.sig fcos.raw.xz.sig
sudo chown -R apache: /var/www/html/
sudo chmod -R 755 /var/www/html/

# run VMs and make postinstal commands!!!

