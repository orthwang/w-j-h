#!/bin/bash

echo ">>> 正在执行 RFC-JP 专属一键初始化..."

# 1. 永久修改主机名为 RFC-JP
hostnamectl set-hostname RFC-JP
sed -i "s/^127.0.1.1.*/127.0.1.1\tRFC-JP/g" /etc/hosts

# 2. 设置时区为上海
timedatectl set-timezone Asia/Shanghai

# 3. 更新系统并安装基础工具
apt update && apt upgrade -y
apt install -y curl wget git vim sudo

# 4. 开启 BBR + FQ 网络加速
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 5. 倒计时并自动重启
echo "================================================="
echo "全部搞定！主机名已设为 RFC-JP，即将自动重启..."
echo "================================================="
sleep 3
reboot
