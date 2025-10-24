resource "proxmox_virtual_environment_vm" "this" {
  name       = var.name
  node_name  = var.node_name
  vm_id      = var.vm_id
  started    = true

  clone {
    vm_id = var.template_id
  }

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size_gb
    file_format  = "raw"
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = var.datastore_id

    user_account {
      username = var.username
      password = var.password
      keys     = [file(var.ssh_public_key)]
    }

    ip_config {
      ipv4 {
        address = var.ipv4_address
      }
    }

    dns {
      domain  = var.dns_domain
      servers = var.dns_servers
    }
  }

  tags = var.tags
}
