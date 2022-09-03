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
  pm_timeout = 600
}

resource "proxmox_vm_qemu" "node" {

  count = 4
  name = "kubern-${count.index + 1}"
  target_node = "proxmox"
  
  clone = "ubuntu"

  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  vcpus = 0
  cpu = "host"
  memory = 8192
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    size            = "100G"
    type            = "scsi"
    storage         = "drive"
    iothread = 1
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
  
  nameserver = "8.8.8.8"
  ipconfig0 = "ip=192.168.1.11${count.index + 1}/24,gw=192.168.1.1"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
