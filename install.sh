#!/usr/bin/env bash
set -euo pipefail

PREFIX="tunnel"
SUFFIX=$(date +%s | base64 | tr -dc 'a-zA-Z0-9' | head -c 9)
USER="${PREFIX}-${SUFFIX}"

echo "Создаём пользователя: $USER"

useradd -s /bin/false "$USER" || { echo "Ошибка создания пользователя"; exit 1; }

PASS=$(tr -dc 'A-Za-z0-9!?@#$%^&*+' </dev/urandom | head -c 17)

echo "$USER:$PASS" | chpasswd

# Добавляем правило в sshd_config (если ещё нет похожего — не страшно, дубли можно потом убрать)
cat >> /etc/ssh/sshd_config <<EOF

Match User $USER
    AllowTcpForwarding yes
    X11Forwarding no
    ForceCommand /bin/false
EOF

systemctl restart ssh 2>/dev/null || service ssh restart 2>/dev/null

clear

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║         НОВЫЙ ТУННЕЛЬНЫЙ ПОЛЬЗОВАТЕЛЬ      ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "Логин:     $USER"
echo "Пароль:    $PASS"
echo ""
echo "Подключение SOCKS5:"
echo "  ssh -N -D 1080 $USER@твой-ip-адрес"
echo ""
echo "!!! Скопируй пароль прямо сейчас !!!"
echo ""
