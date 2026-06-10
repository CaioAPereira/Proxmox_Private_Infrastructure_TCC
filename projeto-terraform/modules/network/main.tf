# ============================================================
#  modules/network/main.tf — Módulo de Rede (Passthrough)
#
#  SOBRE ESTE MÓDULO:
#  A bridge de rede "vmbr0" já existe e é gerenciada pelo
#  Proxmox diretamente (configurada via UI ou /etc/network/interfaces).
#
#  Este módulo NÃO cria nem modifica a bridge — ele serve como
#  uma camada de abstração nomeada: recebe o nome da bridge
#  como variável e o expõe como output, permitindo que outros
#  módulos referenciem a rede pelo nome do módulo em vez de
#  um valor hardcoded.
#
#  Por que isso é útil?
#  Se a bridge mudar de nome (ex: vmbr0 → vmbr1), basta
#  atualizar a variável em um único lugar (main.tf raiz),
#  sem precisar alterar todos os módulos de VM.
#
#  Para criar bridges via Terraform (caso necessário no futuro),
#  usar: proxmox_virtual_environment_network_linux_bridge
# ============================================================
