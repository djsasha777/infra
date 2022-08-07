#!/bin/bash
echo "This script will install and connect zerotier to your system"
echo "please enter zerotier netwirk id"
NETID=$(read)
curl -s https://install.zerotier.com | sudo bash
zerotier-cli join ${NETID}
echo "zerotier installed and connected!"