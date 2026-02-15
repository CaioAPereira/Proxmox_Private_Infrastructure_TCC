variable "node_name" {
  description = "O nome do nó Proxmox (ex: pve)."
  type        = string
}
variable "bridge_name" {
  description = "O nome da bridge existente (ex: vmbr0)."
  type        = string
}
variable "comment" {
  default = ""
}
variable "physical_interfaces" {
  type    = list(string)
  default = []
}

