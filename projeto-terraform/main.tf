# ============================================================
#  main.tf — Ponto de entrada principal da infraestrutura
#
#  Este arquivo orquestra todos os recursos provisionados:
#    1. Módulo de rede  → define a bridge usada pelas VMs
#    2. VM Web (nginx)  → servidor web + aplicação TaskFlow
#    3. VM DB (postgres)→ banco de dados PostgreSQL externo
#    4. Inventário      → arquivo hosts.ini gerado para o Ansible
#
#  Fluxo de provisionamento:
#    terraform apply → VMs criadas → hosts.ini gerado
#    → ansible-playbook playbook-db.yml → ansible-playbook playbook-web.yml
# ============================================================

# ----------------------------------------------------------
# MÓDULO: Rede
#
# Define a bridge de rede que será usada pelas VMs.
# A vmbr0 já existe no Proxmox (criada via UI ou config do host).
# Este módulo serve como abstração nomeada — se a bridge mudar,
# basta atualizar aqui e todos os módulos de VM se atualizam.
# ----------------------------------------------------------
module "network_vmbr1" {
  source              = "./modules/network"
  node_name           = var.node_name
  bridge_name         = "vmbr0"
  comment             = "Rede principal para comunicação das VMs"
  physical_interfaces = []
}

# ----------------------------------------------------------
# MÓDULO: VM Web (Nginx + Docker + TaskFlow)
#
# Servidor web responsável por hospedar a aplicação TaskFlow
# (mini-kanban Node.js). Usa Docker para orquestrar os
# containers da aplicação (app Node.js + Nginx como proxy).
#
# Recursos:
#   - 2 vCPUs, 2 GB RAM, 10 GB disco
#   - Firewall habilitado com regra de saída para PostgreSQL
#     (enable_pg_outbound = true) para conectar à vm-db
# ----------------------------------------------------------
module "vm_nginx" {
  source         = "./modules/vm"
  name           = "vm-nginx"
  node_name      = var.node_name
  vm_id          = 1301
  template_id    = var.template_id
  datastore_id   = var.datastore_id
  memory_mb      = 2048
  disk_size_gb   = 10
  network_bridge = module.network_vmbr1.bridge_name
  tags           = ["web", "nginx", "docker", "taskflow"]

  # Credenciais injetadas via cloud-init
  username       = var.username
  password       = var.password
  ssh_public_key = var.ssh_public_key

  # Firewall: habilita regra de saída TCP para o PostgreSQL
  # na vm-db (porta 5432). A vm web precisa conectar ao banco.
  enable_firewall    = true
  enable_pg_outbound = true
}

# ----------------------------------------------------------
# MÓDULO: VM Banco de Dados (PostgreSQL)
#
# Servidor de banco de dados dedicado, propositalmente separado
# da VM web para documentar e demonstrar a comunicação de rede
# entre VMs distintas — objetivo central do TCC.
#
# O PostgreSQL é instalado diretamente na VM (sem Docker),
# configurado pelo playbook-db.yml do Ansible.
#
# Recursos:
#   - 2 vCPUs, 4 GB RAM, 20 GB disco (maior para dados)
#   - Firewall com regra de entrada liberando PostgreSQL
#     APENAS para o IP/rede da VM web (pg_allowed_source)
# ----------------------------------------------------------
module "vm_db" {
  source         = "./modules/vm"
  name           = "vm-db"
  node_name      = var.node_name
  vm_id          = 1302
  template_id    = var.template_id
  datastore_id   = var.datastore_id
  memory_mb      = 4096
  disk_size_gb   = 20
  network_bridge = module.network_vmbr1.bridge_name
  tags           = ["database", "postgres"]

  # Credenciais injetadas via cloud-init
  username       = var.username
  password       = var.password
  ssh_public_key = var.ssh_public_key

  # Firewall: permite conexões PostgreSQL (porta 5432) SOMENTE
  # originadas da sub-rede onde a VM web está.
  # Altere para o IP exato da vm-nginx se preferir maior restrição.
  enable_firewall   = true
  pg_allowed_source = "10.131.134.0/24"
}

# ----------------------------------------------------------
# RECURSO: Inventário Ansible (gerado automaticamente)
#
# Após o `terraform apply`, este recurso cria o arquivo
# ansible/hosts.ini com os IPs reais das VMs provisionadas.
# O Ansible usa este arquivo para saber quais máquinas
# provisionar e qual usuário SSH utilizar.
#
# O db_server_ip é passado como variável de host para a VM
# nginx, permitindo que o playbook-web.yml configure a
# aplicação TaskFlow para apontar ao banco de dados correto.
# ----------------------------------------------------------
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/hosts.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    nginx_ip = module.vm_nginx.ip_address  # IP da VM web
    db_ip    = module.vm_db.ip_address     # IP da VM de banco de dados
    ssh_user = var.username                # Usuário SSH (cloud-init)
  })
}