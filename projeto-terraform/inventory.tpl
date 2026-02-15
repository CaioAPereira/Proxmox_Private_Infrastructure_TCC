# Este arquivo foi gerado automaticamente pelo Terraform
# Não edite manualmente!

[nginx]
${nginx_ip}

[database]
${db_ip}

[all:vars]
ansible_user = ${ssh_user}
# Descomente a linha abaixo se você usa uma chave SSH específica
# ansible_ssh_private_key_file = /caminho/para/sua/chave_privada

# Nota: Isso assume que o usuário tem sudo sem senha ou é root.
# Lembre-se que você definiu o usuário no seu modules/vm/main.tf (var.username)
