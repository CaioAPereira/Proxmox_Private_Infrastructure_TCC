# ============================================================
#  variables.tf — Variáveis globais do projeto Terraform
#  Definem os parâmetros de entrada que configuram toda a infra
# ============================================================

# ----------------------------------------------------------
# Autenticação no Proxmox
# O token é marcado como sensitive para não aparecer nos logs
# Deve ser definido em terraform.tfvars (nunca no código!)
# ----------------------------------------------------------
variable "proxmox_api_token" {
  description = "Token de API do Proxmox no formato 'user@realm!token-name=uuid'. Gerado em: Proxmox UI > Datacenter > Permissions > API Tokens."
  type        = string
  sensitive   = true
}

# ----------------------------------------------------------
# Configurações do nó Proxmox
# ----------------------------------------------------------
variable "node_name" {
  description = "Nome do nó (host) Proxmox onde as VMs serão criadas (ex: 'pve')."
  type        = string
  default     = "pve"
}

# ----------------------------------------------------------
# Configurações de Template e Storage
# ----------------------------------------------------------
variable "template_id" {
  description = "ID do template de VM no Proxmox usado como base para clonagem (ex: 9000 para Ubuntu cloud-init)."
  type        = number
  default     = 9000
}

variable "datastore_id" {
  description = "ID do datastore do Proxmox onde os discos das VMs serão armazenados (ex: 'local-lvm')."
  type        = string
  default     = "local-lvm"
}

# ----------------------------------------------------------
# Credenciais de acesso às VMs (cloud-init)
# username/password são injetados no template via cloud-init
# ----------------------------------------------------------
variable "username" {
  description = "Nome do usuário SSH criado via cloud-init nas VMs (ex: 'ubuntu')."
  type        = string
}

variable "password" {
  description = "Senha do usuário cloud-init. Usada como fallback ao SSH por senha."
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Caminho para o arquivo da chave pública SSH que será autorizada nas VMs (ex: ~/.ssh/id_rsa.pub)."
  type        = string
}
