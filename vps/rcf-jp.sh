#!/bin/bash
# =========================================================
# RFC VPS 生产级极简初始化脚本 (Debian 13 适配版)
# =========================================================

set -e

echo ">>> [1/4] 系统更新与必备工具安装..."
export DEBIAN_FRONTEND=noninteractive
apt update && apt upgrade -y
apt install -y curl wget git vim sudo htop systemd-timesyncd

echo ">>> [2/4] 设置系统主机名为 rfc..."
hostnamectl set-hostname rfc
grep -q '^127.0.1.1' /etc/hosts && sed -i 's/^127.0.1.1.*/127.0.1.1 rfc/' /etc/hosts || echo '127.0.1.1 rfc' >> /etc/hosts

echo ">>> [3/4] 设置上海时区并启用原生时间同步..."
timedatectl set-timezone Asia/Shanghai
systemctl enable --now systemd-timesyncd

echo ">>> [4/4] 启用原生 BBR..."
cat > /etc/sysctl.d/99-bbr.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl --system

echo "========================================="
echo "✅ 初始化完成！"
echo "当前主机名: $(hostname)"
echo "当前时区: $(timedatectl | grep 'Time zone' | awk '{print $3}')"
echo "NTP 状态: $(timedatectl | grep 'NTP service' | awk '{print $3}')"
echo "TCP 拥塞算法: $(sysctl -n net.ipv4.tcp_congestion_control)"
echo "========================================="
