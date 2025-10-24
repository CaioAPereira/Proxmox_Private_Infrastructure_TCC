# ========================
#  Módulo de Rede
# ========================
module "network_vmbr1" {
  source              = "./modules/network"
  node_name           = var.node_name
  bridge_name         = "vmbr1"
  comment             = "Rede interna para aplicações"
  physical_interfaces = ["enp6s0"]  # ou vazio se for rede virtual pura
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
  network_bridge = module.network_vmbr1.bridge_name  # depende da rede criada
  tags           = ["web", "nginx"]
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
}


module "vm_cache" {
  source         = "./modules/vm"
  name           = "vm-cache"
  node_name      = "pve"
  vm_id          = 1303
  template_id    = 9000
  datastore_id   = "local-lvm"
  memory_mb      = 1024
  tags           = ["cache", "redis"]
}
