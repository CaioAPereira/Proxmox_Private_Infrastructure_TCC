variable "name" {}
variable "node_name" {}
variable "vm_id" {}
variable "template_id" {}
variable "cpu_cores" { default = 2 }
variable "memory_mb" { default = 2048 }
variable "disk_size_gb" { default = 10 }
variable "datastore_id" {}
variable "network_bridge" { default = "vmbr0" }

variable "username" { default = "ubuntu" }
variable "password" { default = "senha123" }
variable "ssh_public_key" { default = "~/.ssh/id_rsa.pub" }

variable "ipv4_address" { default = "dhcp" }
variable "dns_domain" { default = "local" }
variable "dns_servers" { default = ["8.8.8.8"] }

variable "tags" {
  type    = list(string)
  default = ["terraform"]
}
