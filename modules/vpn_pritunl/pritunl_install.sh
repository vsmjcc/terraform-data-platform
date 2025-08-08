#!/bin/bash
set -e

echo "[+] Adicionando repositórios do Pritunl e MongoDB..."
sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb [signed-by=/usr/share/keyrings/pritunl.gpg] https://repo.pritunl.com/stable/apt jammy main
EOF

sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list << EOF
deb [signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse
EOF

echo "[+] Instalando dependências..."
sudo apt-get update
sudo apt-get install -y gnupg curl

echo "[+] Importando chaves GPG..."
curl -fsSL https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | \
  gpg --dearmor | sudo tee /usr/share/keyrings/pritunl.gpg > /dev/null

curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | \
  gpg --dearmor | sudo tee /usr/share/keyrings/mongodb-server-6.0.gpg > /dev/null

echo "[+] Atualizando pacotes e instalando Pritunl, MongoDB, OpenVPN e WireGuard..."
sudo apt-get update
sudo apt-get install -y pritunl mongodb-org openvpn wireguard wireguard-tools

echo "[+] Desativando firewall (opcional)..."
sudo ufw disable || true

echo "[+]  iniciando serviços do MongoDB e Pritunl..."
sudo systemctl start pritunl mongod

echo "[+] Ativando serviços do MongoDB e Pritunl..."
sudo systemctl enable pritunl mongod

echo "[✔] Instalação concluída com sucesso!"

# Garanta SSM Agent ativo (Ubuntu):
snap install amazon-ssm-agent --classic || true
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || true