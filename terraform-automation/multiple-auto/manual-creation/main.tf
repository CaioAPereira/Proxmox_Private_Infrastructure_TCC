# Criando vários blocos resource no mesmo arquivo ou em arquivos separados:
 
resource "proxmox_virtual_environment_vm" "vm_nginx" {
  name       = "vm-nginx"
  node_name  = "pve"
  vm_id      = 1201
  clone {
    vm_id = 9000
  }
  cpu { cores = 2 }
  memory { dedicated = 2048 }
  disk {
    datastore_id = "local-lvm"
    size         = 10
    interface    = "scsi0"
  }
  network_device { bridge = "vmbr0" }
  initialization {
    user_account {
      username = "ubuntu"
      password = "senha123"
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
    ip_config { ipv4 { address = "dhcp" } }
  }
}

resource "proxmox_virtual_environment_vm" "vm_db" {
  name       = "vm-db"
  node_name  = "pve"
  vm_id      = 1202
  clone {
    vm_id = 9000
  }
  cpu { cores = 2 }
  memory { dedicated = 4096 }
  disk {
    datastore_id = "local-lvm"
    size         = 20
    interface    = "scsi0"
  }
  network_device { bridge = "vmbr0" }
  initialization {
    user_account {
      username = "ubuntu"
      password = "senha123"
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
    ip_config { ipv4 { address = "dhcp" } }
  }
}
