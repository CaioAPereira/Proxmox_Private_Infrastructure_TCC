# ============================================================
#  terraform.tfvars — Valores das variáveis do projeto
#
#  ⚠️  ATENÇÃO: Este arquivo contém dados sensíveis (tokens,
#  senhas, chaves). Ele está no .gitignore e NÃO deve ser
#  commitado no repositório!
#
#  Use o arquivo terraform.tfvars.example como referência
#  pública (sem valores reais).
# ============================================================

# ----------------------------------------------------------
# Autenticação Proxmox
# Formato: "user@realm!token-name=uuid"
# ----------------------------------------------------------
proxmox_api_token = "caio.pereira@pve!terraform-definitivo=12132bd0-af29-448e-8cc7-289f6bf0b49b"

# ----------------------------------------------------------
# Nó e Storage do Proxmox
# ----------------------------------------------------------
node_name    = "pve"
template_id  = 9000
datastore_id = "local-lvm"

# ----------------------------------------------------------
# Credenciais de acesso às VMs (cloud-init)
# Altere a senha para algo mais seguro em produção!
# ----------------------------------------------------------
username       = "ubuntu"
password       = "senha123"
ssh_public_key = "/root/.ssh/id_rsa.pub"
