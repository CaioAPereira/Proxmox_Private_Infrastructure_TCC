terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.43.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://10.131.134.84:8006"
  insecure = true

  api_token = "caio.pereira@pve!terraform-definitivo=12132bd0-af29-448e-8cc7-289f6bf0b49b"
}