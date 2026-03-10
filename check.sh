#!/bin/bash

# =========================================================
# 功能: 高性能全量初始化 (破除锁死 + 系统升级 + 激进 BBR + 强制对时)
# 适用: DMIT、日本、英国所有 VPS (解决新机 apt 卡死与时间报错)
# =========================================================

echo ">>> [1/4] 正在清理进程锁并进行系统全量升级..."
export DEBIAN_FRONTEND=noninteractive

# 强行解除新装系统可能卡死的 apt 进程锁
rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock
killall -9 apt apt-get dpkg 2>/dev/null
dpkg --configure -a 2>/dev/null

# 核心修改：强制无视 Debian 源的时间校验 (解决时空悖论)
apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false

# 强制保持旧配置，防止升级内核时弹出交互菜单导致脚本卡死
apt-get dist-upgrade -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold

echo ">>> [2/4] 正在暴力同步时间 (Reality 核心命门)..."
apt-get install -y ntpdate systemd-timesyncd
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate -u ntp.aliyun.com || ntpdate -u pool.ntp.org
systemctl enable --now systemd-timesyncd

echo ">>> [3/4] 正在注入激进版 BBR 网络优化参数..."
# 写入增强版内核参数
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
echo "系统已强制升级，BBR 已拉满，时间已精准对齐。"
echo "请记住: 针对挑剔的机器，443 端口请使用 Microsoft 伪装。"
echo "强烈建议: 请输入 reboot 重启一次服务器，让新内核彻底生效。"
echo "================================================="
