#!/bin/bash
#  LOAD BALANCER install
dnf install haproxy
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
sudo systemctl restart haproxy  
echo "haproxy installation and configuration is DONE"
