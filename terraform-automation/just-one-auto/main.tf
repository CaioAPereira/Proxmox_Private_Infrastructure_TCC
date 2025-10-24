# Código para inicializar a cópia de VM com base em template cloudinit no Proxmox

resource "proxmox_virtual_environment_vm" "vm_cloudinit" {
  name       = "vm-clone-terraform"
  node_name  = "pve"              # nome do nó onde o template está
  vm_id      = 1200               # ID único da nova VM
  started    = true

  clone {
    vm_id = 102                  # ID do template base (cloud-init)
    full  = true                  # se quiser fazer clone completo
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"    # ou o storage onde o disco deve ser criado
    interface    = "scsi0"
    size         = 10
    file_format  = "raw"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"                  # Linux 2.6+
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "local-lvm"    # onde armazenar o CD-ROM de cloud-init (ciuser, etc.)

    user_account {
      username = "ubuntu"
      password = "senha123"
      keys     = [file("~/.ssh/id_rsa.pub")]  # ou chaves públicas adicionais
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    dns {
      domain  = "local"
      servers = ["8.8.8.8"]
    }

    # Opcional: definir hostname e outras variáveis Cloud-Init
    # hostname = "vm-cloudinit"
  }

  # Opcional: Tags para organização no Proxmox
  tags = ["terraform", "cloudinit"]
}