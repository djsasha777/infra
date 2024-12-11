##vm side
ip link set tun77 up
ip addr add 192.168.222.1/32 peer 192.168.222.2 dev tun77
ip route add 192.168.111.0/24 via 192.168.222.1
iptables -t nat -A POSTROUTING -s 192.168.222.2/32 -o eth0 -j MASQUERADE
iptables -A FORWARD -p tcp --syn -s 192.168.222.2/32 -j TCPMSS --set-mss 1356
iptables -t nat -A POSTROUTING -s 192.168.111.0/24 -o tun77 -j MASQUERADE

## router side
# install ssh tunnels package
# add ssh key and VPN Tunnel
# add tun77 device
# add tun interface - static route
# add static route
