#!/bin/bash

echo ">>> 开始初始化 VPS 环境..."

# 1. 更新系统包并安装基础工具
echo ">>> 正在更新系统组件 (这可能需要几分钟)..."
apt update && apt upgrade -y
apt install -y curl wget git vim sudo

# 2. 设置系统时区为亚洲/上海
echo ">>> 正在同步时区为 Asia/Shanghai..."
timedatectl set-timezone Asia/Shanghai

# 3. 开启 BBR 网络加速
echo ">>> 正在开启 BBR 拥塞控制..."
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 4. 倒计时并自动重启
echo "================================================="
echo "初始化全部完成！"
echo "系统已经更新了内核和网络配置。"
echo "VPS 将在 3 秒后自动重启，请在 1 分钟后重新连接 SSH。"
echo "================================================="
sleep 3
reboot
