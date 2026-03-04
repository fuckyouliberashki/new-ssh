#!/usr/bin/env bash
set -euo pipefail

# Можно менять префикс
PREFIX="tunnel"

# Генерируем уникальное имя
SUFFIX=$(date +%s | base64 | head -c 8 | tr '+/=' 'abc')
USER="$$   {PREFIX}-   $${SUFFIX}"

echo "Создаём: $USER"

useradd -s /bin/false "$USER" 2>/dev/null || { echo "Ошибка создания"; exit 1; }

PASS=$$   (tr -dc 'A-Za-z0-9!?@#   $$%^&*+' </dev/urandom | head -c 17)
echo "$USER:$PASS" | chpasswd

# Ограничение в sshd_config
cat >> /etc/ssh/sshd_config <<EOF

Match User $USER
    AllowTcpForwarding yes
    X11Forwarding no
    ForceCommand /bin/false
EOF

systemctl restart ssh 2>/dev/null || service ssh restart

echo
echo "Готово!"
echo "Логин:     $USER"
echo "Пароль:    $PASS"
echo "ssh -N -D 1080 $USER@твой-ip"
