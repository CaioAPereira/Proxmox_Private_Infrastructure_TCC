# ============================================================
#  modules/vm/variables.tf — Parâmetros de entrada do módulo VM
#
#  Cada variável aqui define uma configuração que pode ser
#  customizada ao instanciar este módulo no main.tf raiz.
# ============================================================

# ----------------------------------------------------------
# Identificação da VM
# ----------------------------------------------------------
variable "name" {
  description = "Nome da VM no Proxmox (ex: 'vm-nginx', 'vm-db')."
  type        = string
}

variable "node_name" {
  description = "Nome do nó Proxmox onde a VM será criada."
  type        = string
}

variable "vm_id" {
  description = "ID único da VM no Proxmox (ex: 1301, 1302). Deve ser único no cluster."
  type        = number
}

variable "template_id" {
  description = "ID do template que será clonado para criar esta VM."
  type        = number
}

# ----------------------------------------------------------
# Recursos de Hardware
# ----------------------------------------------------------
variable "cpu_cores" {
  description = "Quantidade de núcleos de CPU alocados para a VM."
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Quantidade de memória RAM em MB alocada para a VM."
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "Tamanho do disco principal da VM em GB."
  type        = number
  default     = 10
}

variable "datastore_id" {
  description = "ID do datastore Proxmox onde o disco da VM será armazenado."
  type        = string
}

variable "network_bridge" {
  description = "Nome da bridge de rede à qual a interface de rede da VM será conectada."
  type        = string
  default     = "vmbr0"
}

# ----------------------------------------------------------
# Cloud-Init: configuração inicial do sistema operacional
# Injetada no template no momento da clonagem
# ----------------------------------------------------------
variable "username" {
  description = "Nome do usuário padrão criado pelo cloud-init na VM."
  type        = string
}

variable "password" {
  description = "Senha do usuário cloud-init (sensitive — não aparece em logs)."
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Caminho para o arquivo de chave pública SSH autorizada nas VMs."
  type        = string
}

variable "ipv4_address" {
  description = "Endereço IPv4 estático. Use 'dhcp' para obter IP automaticamente."
  type        = string
  default     = "dhcp"
}

variable "dns_domain" {
  description = "Domínio DNS configurado via cloud-init."
  type        = string
  default     = "local"
}

variable "dns_servers" {
  description = "Lista de servidores DNS configurados via cloud-init."
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# ----------------------------------------------------------
# Tags
# Facilitam organização e busca de VMs no painel Proxmox
# ----------------------------------------------------------
variable "tags" {
  description = "Lista de tags aplicadas à VM para categorização no Proxmox."
  type        = list(string)
  default     = ["terraform"]
}

# ----------------------------------------------------------
# Firewall
# Controla se as regras de firewall serão aplicadas à VM
# ----------------------------------------------------------
variable "enable_firewall" {
  description = "Habilita o firewall Proxmox na interface de rede desta VM."
  type        = bool
  default     = true
}

variable "pg_allowed_source" {
  description = <<EOT
IP ou CIDR de origem autorizado a conectar ao PostgreSQL (porta 5432) desta VM.
Deixe vazio ("") para não criar a regra — use apenas na VM de banco de dados.
Exemplo: "10.131.134.0/24" ou "10.131.134.62"
EOT
  type        = string
  default     = ""
}

variable "enable_pg_outbound" {
  description = "Habilita regra de saída TCP para PostgreSQL (porta 5432). Use true na VM web que precisa conectar ao banco externo."
  type        = bool
  default     = false
}
