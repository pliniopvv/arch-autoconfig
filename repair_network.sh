#!/bin/bash
# Script para configurar rede cabeada no Arch Linux com systemd-networkd

echo "Detectando interfaces de rede disponíveis..."
ip link | awk -F: '/^[0-9]+: / {print $2}' | sed 's/ //g'

echo
read -p "Digite o nome da interface que deseja configurar: " INTERFACE

if [ -z "$INTERFACE" ]; then
  echo "Nenhuma interface informada. Abortando."
  exit 1
fi

echo "Ativando interface $INTERFACE..."
sudo ip link set $INTERFACE up

echo "Criando configuração de rede para $INTERFACE..."
sudo tee /etc/systemd/network/20-wired.network > /dev/null <<EOF
[Match]
Name=$INTERFACE

[Network]
DHCP=yes
EOF

echo "Habilitando serviços de rede..."
sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved

echo "Ajustando DNS..."
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

echo "Status da rede:"
networkctl status $INTERFACE
resolvectl status
