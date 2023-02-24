#!/bin/bash
# This script will install dns server and dns configs on dns-single-node-server
sudo dnf install -y epel-release bind bind-utils
sudo dnf update -y
sudo systemctl reboot
mkdir installdir
cd installdir
sudo dnf -y install bind bind-utils
touch named.conf named.conf.local db.192.168.1 db.home.lab install-config.yaml

# file changing
echo "please enter the cluster name"
CLUSTERID=$(read)
echo "please enter the domain name"
DOMAINID=$(read)
echo "Setting cluster domain name to: $CLUSTERID.$DOMAINID"

### change named.conf
cat  >> named.conf <<EOF
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
// See the BIND Administrator's Reference Manual (ARM) for details about the
// configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html

options {
	listen-on port 53 { 127.0.0.1; 192.168.1.210; };
#	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { localhost; 192.168.1.0/24; };

	/* 
	 - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
	 - If you are building a RECURSIVE (caching) DNS server, you need to enable 
	   recursion. 
	 - If your recursive DNS server has a public IP address, you MUST enable access 
	   control to limit queries to your legitimate users. Failing to do so will
	   cause your server to become part of large scale DNS amplification 
	   attacks. Implementing BCP38 within your network would greatly
	   reduce such attack surface 
	*/
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
cat  >> db.192.168.1 <<EOF
$TTL    604800
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
202    IN    PTR    okd4-control-plane-2.okd.home.lab.
203    IN    PTR    okd4-control-plane-3.okd.home.lab.
204    IN    PTR    okd4-compute-1.okd.home.lab.
205    IN    PTR    okd4-compute-2.okd.home.lab.
210    IN    PTR    api.okd.home.lab.
210    IN    PTR    api-int.okd.home.lab.
EOF

### change db.home.lab
cat  >> db.home.lab <<EOF
$TTL    604800
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
okd4-services.home.lab.          IN      A       192.168.1.210

; OpenShift Container Platform Cluster - A records
okd4-bootstrap.okd.home.lab.        IN      A      192.168.1.200
okd4-control-plane-1.okd.home.lab.        IN      A      192.168.1.201
okd4-control-plane-2.okd.home.lab.         IN      A      192.168.1.202
okd4-control-plane-3.okd.home.lab.         IN      A      192.168.1.203
okd4-compute-1.okd.home.lab.        IN      A      192.168.1.204
okd4-compute-2.okd.home.lab.        IN      A      192.168.1.205

; OpenShift internal cluster IPs - A records
api.okd.home.lab.    IN    A    192.168.1.210
api-int.okd.home.lab.    IN    A    192.168.1.210
*.apps.okd.home.lab.    IN    A    192.168.1.210
etcd-0.okd.home.lab.    IN    A     192.168.1.201
etcd-1.okd.home.lab.    IN    A     192.168.1.202
etcd-2.okd.home.lab.    IN    A    192.168.1.203
console-openshift-console.apps.okd.home.lab.     IN     A     192.168.1.210
oauth-openshift.apps.okd.home.lab.     IN     A     192.168.1.210

; OpenShift internal cluster IPs - SRV records
_etcd-server-ssl._tcp.okd.home.lab.    86400     IN    SRV     0    10    2380    etcd-0.lab
_etcd-server-ssl._tcp.okd.home.lab.    86400     IN    SRV     0    10    2380    etcd-1.lab
_etcd-server-ssl._tcp.okd.home.lab.    86400     IN    SRV     0    10    2380    etcd-2.lab
EOF

### change install-config.yaml
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
  replicas: 3

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

pullSecret: '{"auths":{"fake":{"auth": "bar"}}}' 
sshKey: 'ssh-ed25519 AAAA...'   
EOF

# Replace dns references in named config
sudo sed -i 's/okd.home.lab/'$CLUSTERID.$DOMAINID'/' db.192.168.1
sudo sed -i 's/home.lab/'$DOMAINID'/' db.192.168.1
sudo sed -i 's/home.lab/'$DOMAINID'/' db.192.168.1
sudo sed -i 's/okd.home.lab/'$CLUSTERID.$2'/' db.home.lab
sudo sed -i 's/home.lab/'$DOMAINID'/' db.home.lab
sudo sed -i 's/home.lab/'$DOMAINID'/' db.192.168.1
sudo mv db.home.lab db.$DOMAINID
sudo sed -i 's/home.lab/'$DOMAINID'/' named.conf.local
# Replace dns references in install_config.yaml
sudo sed -i 's/home.lab/'$DOMAINID'/' install-config.yaml
sudo sed -i 's/name: okd/name: '$CLUSTERID'/' install-config.yaml
# dns configure
sudo cp named.conf /etc/named.conf
sudo cp named.conf.local /etc/named/
sudo mkdir /etc/named/zones
sudo cp db* /etc/named/zones
sudo systemctl enable named
sudo systemctl start named
sudo systemctl status named
sudo firewall-cmd --permanent --add-port=53/udp
sudo firewall-cmd --reload