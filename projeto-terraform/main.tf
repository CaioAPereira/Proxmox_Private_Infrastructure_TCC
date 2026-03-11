# ========================
#  Módulo de Rede
# ========================
module "network_vmbr1" {
  source              = "./modules/network"
  node_name           = var.node_name
  bridge_name         = "vmbr0"
  comment             = "Rede interna para aplicações"
  physical_interfaces = [""]  # ou deixe [] se for apenas virtual
}

# ========================
#  Módulos de VMs
# ========================
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
  tags           = ["web", "nginx"]
  username       = var.username
  password       = var.password
  ssh_public_key = var.ssh_public_key
}

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
  username       = var.username
  password       = var.password
  ssh_public_key = var.ssh_public_key
}

# ========================
#  Geração do Inventário Ansible
# ========================
resource "local_file" "ansible_inventory" {
  # Isso vai criar o arquivo hosts.ini DENTRO de uma nova pasta 'ansible'
  filename = "${path.module}/ansible/hosts.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    # Pega o primeiro IP da lista retornada pelo 'modules/vm/outputs.tf'
    nginx_ip = module.vm_nginx.ip_address[0]
    db_ip    = module.vm_db.ip_address[0]
    
    # Pega o nome de usuário que você definiu no 'modules/vm/main.tf'
    # Estou assumindo que você passa a mesma var.username para ambos.
    # Se não, você precisará buscá-la de outra forma.
    ssh_user = var.username 
  })
}