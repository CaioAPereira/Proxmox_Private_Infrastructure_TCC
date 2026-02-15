variable "node_name" {
  default = "pve"
}

variable "template_id" {
  default = 9999
}

variable "datastore_id" {
  default = "local-lvm"
}

variable "username" {
  description = "O nome de usuário para SSH e cloud-init (ex: admin, ubuntu)."
  type        = string
}

variable "password" {
  description = "A senha para o usuário do cloud-init."
  type        = string
  sensitive   = true # Para não mostrar a senha no log
}

variable "ssh_public_key" {
  description = "O caminho para o arquivo da chave pública SSH (ex: /root/.ssh/id_rsa.pub)."
  type        = string
}
