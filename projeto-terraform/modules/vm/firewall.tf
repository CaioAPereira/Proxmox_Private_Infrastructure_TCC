# ============================================================
#  modules/vm/firewall.tf — Regras de Firewall Proxmox por VM
#
#  Define as regras de firewall aplicadas à interface de rede
#  de cada VM provisionada pelo módulo. O firewall Proxmox
#  opera na camada de hipervisor (antes do tráfego chegar à VM).
#
#  ORDEM DE AVALIAÇÃO: As regras são avaliadas de cima para
#  baixo. As regras ACCEPT específicas devem vir ANTES de
#  qualquer regra DROP genérica.
#
#  TIPOS:
#    "in"  = tráfego entrando na VM (inbound)
#    "out" = tráfego saindo da VM (outbound)
# ============================================================

resource "proxmox_virtual_environment_firewall_rules" "this" {

  # Associa as regras à VM deste módulo
  node_name = var.node_name
  vm_id     = proxmox_virtual_environment_vm.this.vm_id

  # --------------------------------------------------------
  # REGRA 1: SSH Inbound — Gerenciamento e Ansible
  # Permite conexões SSH de entrada. Essencial para que o
  # Ansible consiga provisionar e configurar a VM.
  # --------------------------------------------------------
  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "22"
    comment = "Permitir SSH (gerenciamento e provisionamento Ansible)"
    enabled = true
  }

  # --------------------------------------------------------
  # REGRA 2: Proxmox API/UI Inbound (TCP 8006)
  # Permite acesso à interface de gerenciamento do Proxmox.
  # Útil quando a VM precisa ser acessível via API Proxmox.
  # --------------------------------------------------------
  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "8006"
    comment = "Acesso via TCP à porta 8006 (Proxmox API/UI)"
    enabled = true
  }

  # --------------------------------------------------------
  # REGRA 3: HTTP/HTTPS Inbound
  # Permite requisições web de entrada (portas 80 e 443).
  # Necessário para a VM web (Nginx) receber tráfego HTTP(S).
  # --------------------------------------------------------
  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "80,443"
    comment = "Permitir HTTP e HTTPS de entrada"
    enabled = true
  }

  # --------------------------------------------------------
  # REGRA 4: HTTP/HTTPS Outbound
  # Permite que a VM faça requisições web de saída.
  # Necessário para: apt update, download de pacotes,
  # pull de imagens Docker, etc.
  # --------------------------------------------------------
  rule {
    type    = "out"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "80,443"
    comment = "Permitir HTTP e HTTPS de saída (apt, Docker, etc.)"
    enabled = true
  }

  # --------------------------------------------------------
  # REGRA 5: DNS Outbound (UDP e TCP)
  # Permite resolução de nomes de domínio.
  # Sem esta regra, `apt`, Docker e curl não funcionam
  # pois não conseguem resolver nomes de servidores.
  # --------------------------------------------------------
  rule {
    type    = "out"
    action  = "ACCEPT"
    proto   = "udp"
    dport   = "53"
    comment = "Permitir DNS de saída (resolução de nomes — UDP)"
    enabled = true
  }

  rule {
    type    = "out"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "53"
    comment = "Permitir DNS de saída (resolução de nomes — TCP)"
    enabled = true
  }

  # --------------------------------------------------------
  # REGRA 6: NTP Outbound
  # Permite sincronização de relógio via protocolo NTP.
  # Essencial para certificados TLS e consistência de logs.
  # --------------------------------------------------------
  rule {
    type    = "out"
    action  = "ACCEPT"
    proto   = "udp"
    dport   = "123"
    comment = "Permitir NTP de saída (sincronização de relógio)"
    enabled = true
  }

  # --------------------------------------------------------
  # REGRA 7 (CONDICIONAL): PostgreSQL Inbound — apenas VM DB
  #
  # Permite conexões de entrada ao PostgreSQL (porta 5432)
  # originadas do IP da VM web (aplicação TaskFlow).
  # Esta regra só é criada quando a variável pg_allowed_source
  # for definida (não vazia) — aplica-se APENAS à vm-db.
  #
  # A "source" restringe de qual IP/CIDR a conexão pode vir,
  # garantindo que apenas a VM web acesse o banco de dados.
  # --------------------------------------------------------
  dynamic "rule" {
    for_each = var.pg_allowed_source != "" ? [1] : []
    content {
      type    = "in"
      action  = "ACCEPT"
      proto   = "tcp"
      source  = var.pg_allowed_source
      dport   = "5432"
      comment = "Permitir acesso ao PostgreSQL a partir da VM Web (${var.pg_allowed_source})"
      enabled = true
    }
  }

  # --------------------------------------------------------
  # REGRA 8 (CONDICIONAL): PostgreSQL Outbound — apenas VM Web
  #
  # Permite que a VM web faça conexões de saída ao PostgreSQL
  # na VM de banco de dados (porta 5432).
  # Criada quando pg_allowed_source está vazio (VM que conecta,
  # não a que recebe) — controlado pela variável has_db_client.
  # --------------------------------------------------------
  dynamic "rule" {
    for_each = var.pg_allowed_source == "" && var.enable_pg_outbound ? [1] : []
    content {
      type    = "out"
      action  = "ACCEPT"
      proto   = "tcp"
      dport   = "5432"
      comment = "Permitir saída TCP ao PostgreSQL na VM de banco de dados"
      enabled = true
    }
  }

  # --------------------------------------------------------
  # REGRA FINAL: Bloqueio de saída (catch-all DROP)
  #
  # Bloqueia TODO tráfego de saída que não foi explicitamente
  # permitido pelas regras acima. Política de segurança
  # "default deny" para tráfego outbound.
  #
  # ⚠️  Esta regra DEVE ser a última da lista outbound!
  #     Regras são avaliadas em ordem — um ACCEPT antes deste
  #     DROP ainda será aceito normalmente.
  # --------------------------------------------------------
  rule {
    type    = "out"
    action  = "DROP"
    comment = "Bloquear todo tráfego de saída não permitido (default deny outbound)"
    enabled = true
  }
}
