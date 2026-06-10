# ============================================================
#  modules/vm/main.tf — Recurso principal de criação de VM
#
#  Este módulo cria uma VM no Proxmox clonando um template
#  existente e aplicando configurações via cloud-init.
#  O firewall Proxmox é habilitado na interface de rede.
# ============================================================

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.43.0"
    }
  }
}

# ----------------------------------------------------------
# Recurso: VM no Proxmox VE
# Clona o template especificado e personaliza via cloud-init
# ----------------------------------------------------------
resource "proxmox_virtual_environment_vm" "this" {

  # Nome e localização no cluster
  name      = var.name
  node_name = var.node_name
  vm_id     = var.vm_id

  # A VM sobe automaticamente após o provisionamento
  started = true

  # ----------------------------------------------------------
  # Clone: copia o template base (ex: Ubuntu cloud-init)
  # O template deve ter o QEMU Guest Agent instalado
  # ----------------------------------------------------------
  clone {
    vm_id = var.template_id
  }

  # ----------------------------------------------------------
  # CPU: número de núcleos alocados
  # ----------------------------------------------------------
  cpu {
    cores = var.cpu_cores
  }

  # ----------------------------------------------------------
  # Memória: RAM dedicada em MB
  # ----------------------------------------------------------
  memory {
    dedicated = var.memory_mb
  }

  # ----------------------------------------------------------
  # Disco principal: armazenado no datastore configurado
  # interface scsi0 = primeiro disco SCSI (padrão cloud)
  # ----------------------------------------------------------
  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size_gb
    file_format  = "raw"
  }

  # ----------------------------------------------------------
  # Interface de rede: conectada à bridge configurada
  # firewall = true habilita o firewall Proxmox nesta NIC
  # As regras são definidas em firewall.tf
  # ----------------------------------------------------------
  network_device {
    bridge   = var.network_bridge
    model    = "virtio"
    firewall = var.enable_firewall
  }

  # ----------------------------------------------------------
  # Tipo de SO: l26 = Linux kernel 2.6+
  # Necessário para o Proxmox otimizar timers e drivers
  # ----------------------------------------------------------
  operating_system {
    type = "l26"
  }

  # ----------------------------------------------------------
  # QEMU Guest Agent: permite ao Proxmox consultar o IP da VM
  # Requer qemu-guest-agent instalado no template
  # Usado pelo output ip_address deste módulo
  # ----------------------------------------------------------
  agent {
    enabled = true
  }

  # ----------------------------------------------------------
  # Cloud-Init: injeção de configuração inicial no boot
  # Configura usuário, senha, chave SSH, rede e DNS
  # ----------------------------------------------------------
  initialization {
    datastore_id = var.datastore_id

    # Credenciais do usuário padrão
    user_account {
      username = var.username
      password = var.password
      keys     = [file(var.ssh_public_key)] # Chave SSH autorizada
    }

    # Configuração de rede (DHCP por padrão)
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    # Configuração DNS
    dns {
      domain  = var.dns_domain
      servers = var.dns_servers
    }
  }

  # Tags para organização no painel Proxmox
  tags = var.tags
}
