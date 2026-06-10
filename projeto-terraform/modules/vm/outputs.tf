# ============================================================
#  modules/vm/outputs.tf — Valores exportados pelo módulo VM
#
#  Estes outputs ficam disponíveis para quem chamar o módulo.
#  Ex: module.vm_nginx.ip_address, module.vm_db.vm_id
# ============================================================

# ----------------------------------------------------------
# IP principal da VM
# Obtido via QEMU Guest Agent após o boot.
# Filtra IPs de loopback (127.x.x.x) e retorna o primeiro
# endereço IPv4 válido da lista retornada pelo Proxmox.
# ----------------------------------------------------------
output "ip_address" {
  description = "Endereço IPv4 principal da VM (obtido via QEMU Guest Agent)."
  value       = [for ip in flatten(proxmox_virtual_environment_vm.this.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
}

# ----------------------------------------------------------
# ID da VM no Proxmox
# Útil para referenciar a VM em outros recursos/módulos
# ----------------------------------------------------------
output "vm_id" {
  description = "ID numérico da VM no Proxmox."
  value       = proxmox_virtual_environment_vm.this.vm_id
}
