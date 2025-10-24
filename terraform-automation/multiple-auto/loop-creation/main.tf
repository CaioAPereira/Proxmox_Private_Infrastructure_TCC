# Se você quiser criar várias VMs parecidas (por exemplo, 3 servidores web), dá pra parametrizar:

variable "vms" {
  default = {
    web1 = { vm_id = 1301, memory = 2048 }
    web2 = { vm_id = 1302, memory = 2048 }
    db1  = { vm_id = 1303, memory = 4096 }
  }
}

# Apenas alterar a variável vms para mudar a criação das VMs.

resource "proxmox_virtual_environment_vm" "vms" {
  for_each  = var.vms
  name      = each.key
  node_name = "pve"
  vm_id     = each.value.vm_id

  clone {
    vm_id = 9000
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    size         = 10
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    user_account {
      username = "ubuntu"
      password = "senha123"
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
