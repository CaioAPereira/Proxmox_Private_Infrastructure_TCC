# ============================================================
#  inventory.tpl — Template de Inventário Ansible
#
#  Este arquivo é processado pelo Terraform após o provisionamento.
#  Os valores reais de IP e usuário são injetados automaticamente.
#
#  ATENCAO: NAO edite hosts.ini diretamente — ele é gerado!
#  Para alterações, edite este template e rode: terraform apply
# ============================================================

# ----------------------------------------------------------
# Grupo [nginx]: VM web (Node.js + Nginx + TaskFlow)
# db_server_ip é injetado inline como variável de host Ansible,
# permitindo que o playbook-web.yml configure a conexão ao banco.
# ----------------------------------------------------------
[nginx]
${nginx_ip} db_server_ip=${db_ip}

# ----------------------------------------------------------
# Grupo [database]: VM de banco de dados (PostgreSQL)
# ----------------------------------------------------------
[database]
${db_ip}

# ----------------------------------------------------------
# Variáveis globais aplicadas a todos os hosts
# ansible_user: usuário SSH criado pelo cloud-init via Terraform
# ansible_ssh_private_key_file: chave privada para autenticação SSH
# ----------------------------------------------------------
[all:vars]
ansible_user = "${ssh_user}"
ansible_ssh_private_key_file = ~/.ssh/id_rsa
