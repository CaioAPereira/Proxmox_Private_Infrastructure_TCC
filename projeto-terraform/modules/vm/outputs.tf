output "ip_address" {
  description = "O primeiro endereço IPv4 da VM (via QEMU Agent)."
  # O recurso 'proxmox_virtual_environment_vm' retorna uma lista de IPs.
  # Estamos pegando o primeiro [0] da lista.
  value = proxmox_virtual_environment_vm.this.ipv4_addresses[0]
}
