#!/bin/bash

# Bootstrap node

sudo coreos-installer install --ignition-url=http://192.168.1.60:8080/okd4/bootstrap.ign /dev/sda --insecure-ignition && reboot

# Control-plane 

sudo coreos-installer install --ignition-url=http://192.168.1.60:8080/okd4/master.ign /dev/sda --insecure-ignition && reboot

# Worker node

sudo coreos-installer install --ignition-url=http://192.168.1.60:8080/okd4/worker.ign /dev/sda --insecure-ignition && reboot
