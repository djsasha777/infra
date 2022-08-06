# Install and configure load balancers









# MANUAL set up load balancer nodes (lb-0 & lb-1)

Install Keepalived & Haproxy

    apt update && apt install -y keepalived haproxy

configure keepalived: On both nodes create the health check script /etc/keepalived/check_apiserver.sh

    cat >> /etc/keepalived/check_apiserver.sh <<EOF
    #!/bin/sh

    errorExit() {
    echo "*** $@" 1>&2
    exit 1
    }

    curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
    if ip addr | grep -q 192.168.1.220; then
    curl --silent --max-time 2 --insecure https://192.168.1.220:6443/ -o /dev/null || errorExit "Error GET https://192.168.1.220:6443/"
    fi
    EOF

    chmod +x /etc/keepalived/check_apiserver.sh

Create keepalived config /etc/keepalived/keepalived.conf

    cat >> /etc/keepalived/keepalived.conf <<EOF
    vrrp_script check_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 3
    timeout 10
    fall 5
    rise 2
    weight -2
    }

    vrrp_instance VI_1 {
        state BACKUP
        interface eth0
        virtual_router_id 1
        priority 100
        advert_int 5
        authentication {
            auth_type PASS
            auth_pass mysecret
        }
        virtual_ipaddress {
            192.168.1.220
        }
        track_script {
            check_apiserver
        }
    }
    EOF

Enable & start keepalived service

    systemctl enable --now keepalived

Configure haproxy

Update /etc/haproxy/haproxy.cfg

    cat >> /etc/haproxy/haproxy.cfg <<EOF

    frontend kubernetes-frontend
    bind *:8383
    mode tcp
    option tcplog
    default_backend kubernetes-backend

    backend kubernetes-backend
    option httpchk GET /healthz
    http-check expect status 200
    mode tcp
    option ssl-hello-chk
    balance roundrobin
        server kmaster1 192.168.1.201:6443 check fall 3 rise 2
        server kmaster2 192.168.1.202:6443 check fall 3 rise 2

    EOF

Enable & restart haproxy service

    systemctl enable haproxy && systemctl restart haproxy





UPDATE

    cat >> /etc/haproxy/haproxy.cfg <<EOF
    listen kubernetes-apiserver-https
    bind 192.168.1.229:8383
    mode tcp
    option log-health-checks
    timeout client 3h
    timeout server 3h
    server master1 192.168.1.201:6443 check check-ssl verify none inter 10000
    server master2 192.168.1.202:6443 check check-ssl verify none inter 10000
    balance roundrobin

    EOF