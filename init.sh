#!/bin/bash

# =========================================================
# 功能: 全量初始化 (系统升级 + 激进 BBR + 强制对时)
# 适用: 你的 DMIT、日本、英国所有 VPS
# =========================================================

echo ">>> [1/4] 正在进行系统全量升级 (补齐所有底层依赖)..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
# 强制保持旧配置，防止升级内核时弹出交互菜单导致脚本卡死
apt-get dist-upgrade -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold

echo ">>> [2/4] 正在暴力同步北京时间 (Reality 核心命门)..."
apt-get install -y ntpdate systemd-timesyncd
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate -u ntp.aliyun.com || ntpdate -u pool.ntp.org
systemctl enable --now systemd-timesyncd

echo ">>> [3/4] 正在注入激进版 BBR 网络优化参数..."
# 清理旧配置并写入增强版内核参数
cat > /etc/sysctl.d/99-performance.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864
net.ipv4.tcp_mtu_probing=1
net.core.rmem_max=67108864
net.core.wmem_max=67108864
EOF
sysctl --system

echo ">>> [4/4] 正在安装基础工具包..."
apt-get install -y curl wget git vim sudo lsof tar bzip2 htop

echo "================================================="
echo "✅ 高性能初始化完成！"
echo "系统已升级，BBR 已拉满，时间已对齐。"
echo "请记住: 这台机器 443 端口只能用 Microsoft 伪装。"
echo "================================================="
