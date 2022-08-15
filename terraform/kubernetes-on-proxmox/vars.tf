variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkMEmsJnch4ck17cP5TM9pDpjBw4sz24bxwAVqBMl8OHCSwgS1FaPWVI4xdRv5BUEZqAeCgL8pEucarxC11lYCncv/Mh9lqjuRICVF17i0bvAmHongORGUDUNLEd6QCxdQhm0REvDlbRAtQd89rOMn0HVLRhRLv8ZjkYBrN/OLef56S+x7+n2NI27q+YMtCZQgsIT0dLcsov7ZgHWuSU5U11PiV+d+Y8NboSHEjlMRvMnlxcyyn+9o/z0g1NWpbAeq1OVvR7yE0Q8lGGokkdeUQe5wkn2X2tw9ql7BupGgQTNu/MYMyugGymKJLLZDmBLtu+9423l6q+aURNExO5VUqf93GlJP/FXyDHJdC6mEYiPdu6ZN0G6fKLiOHDaxJi7dfZiyFs5k52iut7O/s1XPvXOjGFAPIZbHrZrseMUnJwYVqfj9vj52MJXFHG6LhZScnp/vlX8FZ567dDPNAhCHpbjVVfBAcywh5tcKqvsIQWumIzB0qk9N6mR7GJXkht8= root@main"
}

variable "proxmox_host" {
    default = "proxmox"
}

variable "template_name" {
    default = "ubuntu20"
}