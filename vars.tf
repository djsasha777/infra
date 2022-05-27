variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKEeKirN+yZJTFOA0g1Rp1/SbsCQ49Se/cA/ta9bNLClDL8dvK6fydQSTFlhYVBOWd2XtrEobaSoC6CuYsBV2LN42yXsmZ6IUCBE9h/05VPsdLHOn8zOyovbXOeABK6C285lBJyf72ciJliD8WEavNTfbCxnbcHclJEwgVqJTemCbPSWrk10r5TgvfBAL9gA0K425fHmLrhG3S123XRPH4YsDNXSxm+V0fCREQXkMRgXYB+N+eTF2JtoYS7FOldTeoJNqHXYOwycXkemrsdRhTGjJC2vsTzTWQl+Ma9Y/ALMXc0FKmWIa1ABmp5vPZn4QoVL4JRfuH19VdZmXtWwuDZawRPyP7cABOT4hMtjR18LeqwfOoUB6mLIXf0hCoW5xqqsEo18Wk/tj8ha3pC6eIt/SOWsIT+2VCGYSCrj0kU5qMRIXRg90OqnjcrCZ3aGhj7qHH3+xyy9hZGJMDGmhWdH6bF93oxQeWqhtjgn79zpavA0gF3IrbPi1e+UeE1cU= root@lb"
}

variable "proxmox_host" {
    default = "proxmox"
}

variable "template_name" {
    default = "ubuntu"
}