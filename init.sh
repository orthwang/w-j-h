#!/bin/bash

# 0. 权限检查：确保是以 root 身份运行
if [[ $EUID -ne 0 ]]; then
   echo "错误：请使用 root 权限运行此脚本 (sudo -i 或 sudo bash)。"
   exit 1
fi

# 1. 修正时间
echo "正在同步时间为 Asia/Shanghai..."
timedatectl set-timezone Asia/Shanghai
hwclock --systohc

# 2. 开启 BBR 加速
echo "正在检查并开启 BBR 加速..."
if ! grep -q "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
    echo "BBR 开启成功！"
else
    echo "BBR 已经开启，跳过设置。"
fi

# 3. 系统全量升级 (防卡死模式)
echo "正在全量升级系统，请稍候..."
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
apt autoremove -y

echo "------------------------------------------------"
echo "初始化完成！"
echo "当前时间: $(date)"
echo "状态：时间已对齐，BBR 已开启，系统已升级到最新。"
echo "------------------------------------------------"
