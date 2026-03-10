#!/bin/bash

echo ">>> 开始初始化 VPS 环境 (对时 + BBR 增强版)..."

# 1. 【核心】暴力对齐北京时间 (解决 Reality -1ms 的死穴)
echo ">>> 正在强制同步系统时间..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false
apt-get install -y ntpdate
# 强制掰回上海时区并同步
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate -u ntp.aliyun.com || ntpdate -u pool.ntp.org

# 2. 【核心】开启原版 BBR 加速 (安全注入模式)
echo ">>> 正在开启原版 BBR + FQ 网络加速..."
# 先清理可能存在的旧配置，防止重复写入
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
# 写入标准 BBR 参数
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
# 即使不重启也立刻生效
sysctl -p

# 3. 基础工具静默安装 (排除全量升级，确保系统稳定)
APT_OPT="-y -o DPkg::Lock::Timeout=600 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
echo ">>> 正在安装必要基础工具..."
apt-get install $APT_OPT curl wget git vim sudo systemd-timesyncd

# 4. 固化时间服务
systemctl enable --now systemd-timesyncd
systemctl restart systemd-timesyncd

echo "================================================="
echo "✅ 初始化全部完成！"
echo "✔ 时间已校准: $(date)"
echo "✔ BBR 加速已生效: $(sysctl net.ipv4.tcp_congestion_control)"
echo "✔ 系统环境纯净 (未执行 upgrade，确保 Reality 兼容性)"
echo "================================================="
