resource "proxmox_virtual_environment_network_linux_bridge" "this" {
  node_name = var.node_name
  name      = var.bridge_name
  comment   = var.comment

  autostart = true
  mtu       = 1500
  ports     = var.physical_interfaces
}
