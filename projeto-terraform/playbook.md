# 📋 Guia de Provisionamento — Infra Proxmox + TaskFlow

Passo a passo completo desde o zero até a aplicação rodando.

> 💡 **Convenção usada neste guia:**
> Cada bloco de comandos começa com um comentário indicando **onde executar**:
> ```bash
> # 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform
> ```

---

## 📁 Estrutura do Projeto

```
projeto-terraform/              ← diretório raiz do projeto
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
├── inventory.tpl
├── playbook.md                 ← este arquivo
├── modules/
│   ├── network/
│   └── vm/
└── ansible/
    ├── hosts.ini               ← gerado pelo Terraform
    ├── playbook-db.yml
    ├── playbook-web.yml
    ├── templates/
    └── files/taskflow/
```

---

## ⚙️ Pré-requisitos

Execute estes passos **uma única vez**.  
Pode ser em **qualquer diretório** — são instalações de sistema.

### 1. Terraform instalado

```bash
# 📂 DIRETÓRIO: qualquer um (~, /tmp, etc.)

terraform --version
# Deve retornar v1.x.x ou superior
```

Se não estiver instalado:
```bash
# 📂 DIRETÓRIO: qualquer um

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform -y
```

### 2. Ansible instalado

```bash
# 📂 DIRETÓRIO: qualquer um

ansible --version
# Deve retornar 2.x.x ou superior
```

Se não estiver instalado:
```bash
# 📂 DIRETÓRIO: qualquer um

sudo apt update && sudo apt install ansible -y
```

### 3. Coleções Ansible necessárias

```bash
# 📂 DIRETÓRIO: qualquer um

ansible-galaxy collection install community.docker
ansible-galaxy collection install community.postgresql
```

> Estas coleções fornecem os módulos `docker_compose_v2`, `postgresql_db`, `postgresql_user`, etc.

### 4. Configuração do Ansible (`ansible.cfg`)

O arquivo `ansible.cfg` já está criado na raiz do projeto com duas configurações importantes:

- **`host_key_checking = False`** — desabilita o prompt interativo de fingerprint SSH. Sem isso, o Ansible falha ao tentar conectar em múltiplas VMs simultaneamente, pois não consegue responder aos prompts.
- **`inventory = ansible/hosts.ini`** — define o inventário padrão, eliminando a necessidade de passar `-i ansible/hosts.ini` em todo comando.

Verifique que o arquivo existe:
```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

cat ansible.cfg
# Deve mostrar [defaults] com host_key_checking = False
```

### 4. Chave SSH gerada

```bash
# 📂 DIRETÓRIO: qualquer um (chave salva em ~/.ssh/)

# Verificar se já existe
ls ~/.ssh/id_rsa.pub

# Se não existir, gerar
ssh-keygen -t rsa -b 4096 -C "proxmox-tcc" -f ~/.ssh/id_rsa -N ""
```

> O caminho `/root/.ssh/id_rsa.pub` está configurado no `terraform.tfvars`.

---

## 🚀 ETAPA 1 — Terraform: Provisionar as VMs

> **Todos os comandos do Terraform devem ser executados dentro de:**
> ```
> ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform/
> ```
> O Terraform precisa encontrar os arquivos `main.tf`, `provider.tf`, etc.

### 1.1 — Entrar no diretório do projeto

```bash
# 📂 DIRETÓRIO: qualquer um → vai entrar no projeto

cd ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

# Confirmar que está no lugar certo
pwd
# Saída: /root/Proxmox_Private_Infrastructure_TCC/projeto-terraform

ls
# Deve listar: main.tf  provider.tf  variables.tf  terraform.tfvars  ...
```

### 1.2 — Verificar o `terraform.tfvars`

```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

cat terraform.tfvars
```

Deve conter:
```hcl
proxmox_api_token = "caio.pereira@pve!terraform-definitivo=12132bd0-..."
node_name         = "pve"
template_id       = 9000
datastore_id      = "local-lvm"
username          = "ubuntu"
password          = "senha123"
ssh_public_key    = "/root/.ssh/id_rsa.pub"
```

### 1.3 — Inicializar o Terraform

```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

terraform init
```

Saída esperada:
```
Terraform has been successfully initialized!
```

> Execute apenas na primeira vez ou ao mudar providers/módulos.

### 1.4 — Visualizar o plano de execução

```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

terraform plan
```

Confirme que aparecem na saída:
- `module.vm_nginx` — VM web
- `module.vm_db` — VM banco de dados
- `proxmox_virtual_environment_firewall_rules` — Firewall de cada VM
- `local_file.ansible_inventory` — Arquivo `hosts.ini`

### 1.5 — Aplicar e criar a infraestrutura

```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

terraform apply
```

Confirmar com `yes` quando solicitado.

> ⏱️ Aguarde **3 a 8 minutos** — o Proxmox clona o template e inicializa o QEMU Agent.

### 1.6 — Verificar o inventário gerado

```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

cat ansible/hosts.ini
```

Deve exibir:
```ini
[nginx]
10.131.134.XX db_server_ip=10.131.134.YY

[database]
10.131.134.YY

[all:vars]
ansible_user = "ubuntu"
ansible_ssh_private_key_file = ~/.ssh/id_rsa
```

> Se `hosts.ini` estiver vazio ou com IPs errados, o QEMU Agent ainda não inicializou.
> Aguarde 1-2 minutos e rode `terraform apply` novamente.

### 1.7 — Testar conectividade SSH com as VMs

```bash
# 📂 DIRETÓRIO: qualquer um (conexão SSH direta)

# Testar VM web (substitua pelo IP real do hosts.ini)
ssh -i ~/.ssh/id_rsa ubuntu@<IP_VM_NGINX>
exit

# Testar VM banco
ssh -i ~/.ssh/id_rsa ubuntu@<IP_VM_DB>
exit
```

> Digite `yes` ao ser perguntado sobre o fingerprint na primeira conexão.

---

## 🗄️ ETAPA 2 — Ansible: Configurar o Banco de Dados (vm-db)

> **Todos os comandos do Ansible devem ser executados dentro de:**
> ```
> ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform/
> ```
> O Ansible usa caminho relativo para encontrar `ansible/hosts.ini`,
> `ansible/playbook-db.yml` e os arquivos em `ansible/files/`.

> ⚠️ **Faça SEMPRE esta etapa antes da Etapa 3.**

### 2.1 — Aceitar fingerprints SSH das VMs (apenas uma vez)

Antes de rodar qualquer comando Ansible, adicione as chaves das VMs ao `known_hosts`.
Sem isso, o SSH exibe prompts interativos que o Ansible não consegue responder quando há múltiplos hosts.

```bash
# 📂 DIRETÓRIO: qualquer um
# Substitua pelos IPs reais do ansible/hosts.ini

ssh-keyscan -H <IP_VM_NGINX> <IP_VM_DB> >> ~/.ssh/known_hosts
```

> ⚠️ Repita este passo sempre que destruir e recriar as VMs com `terraform destroy` + `terraform apply`,
> pois os fingerprints mudam quando novas VMs são provisionadas.

### 2.2 — Verificar conectividade com o Ansible

```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform
# O -i não é necessário: ansible.cfg já define o inventário padrão

ansible all -m ping
```

Saída esperada:
```
10.131.134.XX | SUCCESS => { "ping": "pong" }
10.131.134.YY | SUCCESS => { "ping": "pong" }
```

### 2.3 — Executar o playbook do banco de dados

```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

ansible-playbook ansible/playbook-db.yml
```

O que este playbook faz:
1. Atualiza pacotes do sistema
2. Instala PostgreSQL + python3-psycopg2
3. Cria o banco de dados `taskflow`
4. Cria o usuário `taskflow_user` com senha `taskflow_pass`
5. Configura `listen_addresses = '*'` (aceita conexões externas)
6. Libera a sub-rede `10.131.134.0/24` no `pg_hba.conf`
7. Aplica o schema SQL (tabelas `columns` e `tasks`)

Saída esperada ao final:
```
PLAY RECAP
10.131.134.YY : ok=X  changed=X  unreachable=0  failed=0
```

### 2.3 — Verificar o PostgreSQL (opcional)

```bash
# 📂 DIRETÓRIO: qualquer um → conecta na VM banco via SSH

ssh -i ~/.ssh/id_rsa ubuntu@<IP_VM_DB>

  # Agora DENTRO da vm-db:
  sudo -u postgres psql -c "\l"
  # Deve listar o banco 'taskflow'

  sudo -u postgres psql -d taskflow -c "\dt"
  # Deve listar: columns, tasks

exit
# Volta para o diretório original do projeto
```

---

## 🌐 ETAPA 3 — Ansible: Configurar a VM Web (vm-nginx)

### 3.1 — Executar o playbook da VM web

```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

ansible-playbook ansible/playbook-web.yml
```

O que este playbook faz:
1. Atualiza pacotes do sistema
2. Instala Docker Engine + Docker Compose Plugin
3. Copia os arquivos da aplicação para `/opt/taskflow` na VM
4. Gera o `docker-compose.yml` com o IP real da vm-db
5. Sobe os containers: `taskflow-app` (Node.js) + `taskflow-nginx` (proxy reverso)
6. Verifica se o container está rodando

> ⏱️ Leva de **5 a 10 minutos** — Docker baixa imagens e compila o Node.js.

Saída esperada ao final:
```
TASK [Exibir status do container da aplicação]
ok: [10.131.134.XX] => {
    "msg": "TaskFlow App está RODANDO ✅"
}

PLAY RECAP
10.131.134.XX : ok=X  changed=X  unreachable=0  failed=0
```

### 3.2 — Verificar os containers (opcional)

```bash
# 📂 DIRETÓRIO: qualquer um → conecta na VM web via SSH

ssh -i ~/.ssh/id_rsa ubuntu@<IP_VM_NGINX>

  # Agora DENTRO da vm-nginx:
  docker ps
  # Deve listar: taskflow-nginx (porta 80) e taskflow-app

  docker logs taskflow-app
  # Deve mostrar: 🚀 TaskFlow rodando em http://localhost:3000

exit
# Volta para o diretório original do projeto
```

---

## ✅ ETAPA 4 — Verificação Final

```bash
# 📂 DIRETÓRIO: qualquer um (chamadas HTTP para a VM)

# Health check da API
curl http://<IP_VM_NGINX>/health
# Saída esperada: {"status":"ok","timestamp":"2026-..."}

# Listar colunas do kanban via API
curl http://<IP_VM_NGINX>/api/columns
# Deve retornar as 3 colunas em JSON
```

Acesse no navegador:
```
http://<IP_VM_NGINX>
```

---

## 🔄 Reexecutar após mudanças

```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

# Mudou arquivo Terraform
terraform apply

# Mudou playbook ou arquivos da aplicação
ansible-playbook -i ansible/hosts.ini ansible/playbook-web.yml

# Resetar banco de dados
ansible-playbook -i ansible/hosts.ini ansible/playbook-db.yml

# Reiniciar containers sem reprovisionar tudo
ssh -i ~/.ssh/id_rsa ubuntu@<IP_VM_NGINX> "cd /opt/taskflow && docker compose restart"

# Ver logs em tempo real da aplicação
ssh -i ~/.ssh/id_rsa ubuntu@<IP_VM_NGINX> "docker logs -f taskflow-app"

# Destruir toda a infraestrutura
terraform destroy
```

---

## 🐛 Troubleshooting

### "UNREACHABLE" no Ansible
```bash
# 📂 DIRETÓRIO: qualquer um

# Verificar se a VM responde na rede
ping <IP_DA_VM>

# Testar SSH direto
ssh -i ~/.ssh/id_rsa ubuntu@<IP_DA_VM>

# Se não conectar: cloud-init ainda não terminou
# Aguardar ~2 min após o terraform apply e tentar novamente
```

### Container não sobe
```bash
# 📂 DIRETÓRIO: qualquer um → entrar na vm-nginx via SSH

ssh -i ~/.ssh/id_rsa ubuntu@<IP_VM_NGINX>

  # Ver logs de erro do container
  docker logs taskflow-app

  # Testar se a vm-nginx consegue alcançar o PostgreSQL na vm-db
  nc -zv <IP_VM_DB> 5432
  # "Connection succeeded" = OK
  # "Connection refused"   = PostgreSQL não rodando ou firewall bloqueando

exit
```

### Página não carrega mas containers estão UP
```bash
# 📂 DIRETÓRIO: qualquer um → entrar na vm-nginx via SSH

ssh -i ~/.ssh/id_rsa ubuntu@<IP_VM_NGINX>

  # Ver logs do Nginx
  docker logs taskflow-nginx

  # Recriar containers do zero
  cd /opt/taskflow
  docker compose down
  docker compose up -d --build

exit
```

### Erro de token no `terraform plan`
```bash
# 📂 DIRETÓRIO: qualquer um

# Testar token manualmente contra a API do Proxmox
curl -k \
  -H "Authorization: PVEAPIToken=caio.pereira@pve!terraform-definitivo=12132bd0-af29-448e-8cc7-289f6bf0b49b" \
  https://10.131.134.84:8006/api2/json/version
# Deve retornar JSON com versão do Proxmox
```

### `hosts.ini` vazio após `terraform apply`
```bash
# 📂 DIRETÓRIO: ~/Proxmox_Private_Infrastructure_TCC/projeto-terraform

# O QEMU Agent ainda não retornou o IP — aguardar e reaplicar
sleep 120
terraform apply
cat ansible/hosts.ini
```
