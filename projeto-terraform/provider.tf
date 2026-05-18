# ============================================================
#  provider.tf — Configuração dos Providers Terraform
#
#  Define quais providers externos serão usados e suas versões.
#  O provider "bpg/proxmox" é a biblioteca que permite ao
#  Terraform se comunicar com a API do Proxmox VE.
# ============================================================

terraform {
  required_providers {

    # Provider principal: comunica com a API REST do Proxmox VE
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.43.0"
    }

    # Provider auxiliar: gera arquivos locais (ex: inventário Ansible)
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }

  }
}

# ----------------------------------------------------------
# Configuração do Provider Proxmox
#
# endpoint : URL da interface web do Proxmox (porta 8006)
# insecure  : Permite certificado TLS autoassinado (lab/dev)
# api_token : Token de autenticação — lido da variável
#             sensitive definida em variables.tf e terraform.tfvars
#             NUNCA coloque o token diretamente aqui!
# ----------------------------------------------------------
provider "proxmox" {
  endpoint  = "https://10.131.134.84:8006"
  insecure  = true
  api_token = var.proxmox_api_token
}
