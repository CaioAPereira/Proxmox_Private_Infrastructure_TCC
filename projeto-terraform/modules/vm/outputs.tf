# output "ip_address" {
  #description = "O primeiro endereço IPv4 da VM (via QEMU Agent)."
  # O recurso 'proxmox_virtual_environment_vm' retorna uma lista de IPs.
  # Estamos pegando o primeiro [0] da lista.
  #value = proxmox_virtual_environment_vm.this.ipv4_addresses[0]
#}

output "ip_address" {
  description = "O IP principal da VM"
  # Achata a lista de IPs e filtra tudo que for diferente de 127.0.0.1, pegando o primeiro resultado válido
  value = [for ip in flatten(proxmox_virtual_environment_vm.this.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
}
