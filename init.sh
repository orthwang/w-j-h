#!/bin/bash

echo ">>> 正在进行 VPS 基础环境初始化 (极简稳定版)..."

# 1. 暴力同步北京时间 (解决 Reality 握手 -1ms 的死穴)
export DEBIAN_FRONTEND=noninteractive
apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false
apt-get install -y ntpdate
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate -u ntp.aliyun.com || ntpdate -u pool.ntp.org

# 2. 开启原版 BBR 加速 (只写内核参数，不升级内核，确保兼容性)
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 3. 安装必要基础工具 (排除 upgrade，防止搞坏 DMIT 驱动)
APT_OPT="-y -o DPkg::Lock::Timeout=600 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
apt-get install $APT_OPT curl wget git vim sudo systemd-timesyncd

# 4. 固化时间同步服务
systemctl enable --now systemd-timesyncd

echo "================================================="
echo "✅ 初始化完成！已校准时间并开启 BBR。"
echo "现在可以去跑你的节点安装脚本了。"
echo "================================================="
