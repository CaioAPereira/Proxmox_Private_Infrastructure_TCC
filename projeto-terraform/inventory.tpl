# ============================================================
#  inventory.tpl — Template de Inventário Ansible
#
#  Este arquivo é um TEMPLATE processado pelo Terraform após
#  o provisionamento das VMs. Os placeholders ${...} são
#  substituídos pelos IPs e variáveis reais das VMs.
#
#  O arquivo resultante (hosts.ini) é gerado em ansible/hosts.ini
#  e está no .gitignore pois contém dados dinâmicos de infraestrutura.
# ============================================================
#
# ⚠️  NÃO EDITE hosts.ini diretamente — ele é gerado pelo Terraform!
#     Para alterações, edite este template e rode: terraform apply

# ----------------------------------------------------------
# Grupo [nginx]: VM que roda o servidor web + aplicação
# Recebe também o IP do banco de dados como variável de host,
# para que o playbook-web.yml possa configurar a conexão DB.
# ----------------------------------------------------------
[nginx]
${nginx_ip} db_server_ip=${db_ip}

# ----------------------------------------------------------
# Grupo [database]: VM que roda o PostgreSQL
# ----------------------------------------------------------
[database]
${db_ip}

# ----------------------------------------------------------
# Variáveis globais (aplicadas a todos os grupos)
# ansible_user: usuário SSH criado pelo cloud-init no Terraform
# ansible_ssh_private_key_file: chave privada para autenticação
# ----------------------------------------------------------
[all:vars]
ansible_user = "${ssh_user}"
ansible_ssh_private_key_file = ~/.ssh/id_rsa
