variable "node_name" {}
variable "bridge_name" {}
variable "comment" {
  default = ""
}
variable "physical_interfaces" {
  type    = list(string)
  default = []
}
