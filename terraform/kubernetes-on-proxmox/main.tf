terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.10"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://172.22.6.144:8006/api2/json"
  #pm_api_url = "https://192.168.1.188:8006/api2/json"
  pm_api_token_id = "kube@pam!kubetoken"
  pm_api_token_secret = "9e156aa5-09fd-47d9-a58d-8ac8627cb789"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "node" {
  timeouts {
    create = "20m"
    delete = "2h"
  }
  count = 4
  name = "kubernetes-${count.index + 1}"
  target_node = "proxmox"
  
  clone = "centos"

  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  vcpus = 0
  cpu = "host"
  memory = 6144
  scsihw = "lsi"
  bootdisk = "scsi0"

  disk {
    size            = "60G"
    type            = "scsi"
    storage         = "drive"
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.1.20${count.index + 1}/24,gw=192.168.1.1"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "proxmox_vm_qemu" "nodeadd" {
  timeouts {
    create = "10m"
    delete = "2h"
  }
  count = 1
  name = "kubernetes-5"
  target_node = "proxmox"
  
  clone = "centos"

  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  vcpus = 0
  cpu = "host"
  memory = 6144
  scsihw = "lsi"
  bootdisk = "scsi0"

  disk {
    size            = "60G"
    type            = "scsi"
    storage         = "drive"
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.1.205/24,gw=192.168.1.1"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}