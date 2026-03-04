#!/usr/bin/env bash
set -euo pipefail

USER="tunnel-$(date +%s | base64 | head -c 8 | tr '+/=' 'abc')"

echo "Создаём пользователя: $USER"

sudo useradd -m -d /nonexistent -s /bin/false "$USER" || sudo useradd -s /bin/false "$USER"

# Генерируем пароль
PASS=$(tr -dc 'A-Za-z0-9!?@#$%^&*+' </dev/urandom | head -c 17)

echo "$USER:$PASS" | sudo chpasswd

echo
echo "======================================"
echo "Новый туннельный пользователь готов:"
echo "Логин:     $USER"
echo "Пароль:    $PASS"
echo
echo "Подключение для SOCKS5:"
echo "  ssh -N -D 1080 $USER@ВАШ_IP"
echo
echo "Для проброса порта (пример postgres):"
echo "  ssh -N -L 5433:127.0.0.1:5432 $USER@ВАШ_IP"
echo
echo "!!! Этот пользователь НЕ имеет shell-доступа !!!"
echo "======================================"
echo

# Опционально: сразу ограничить в sshd_config (можно закомментировать)
sudo tee -a /etc/ssh/sshd_config >/dev/null <<EOF

Match User $USER
    AllowTcpForwarding yes
    X11Forwarding no
    ForceCommand /bin/false
EOF

sudo systemctl restart ssh || sudo service ssh restart

echo "Готово. Пользователь ограничен только туннелями."
