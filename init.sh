#!/bin/bash

echo ">>> 开始一键自动初始化 VPS 环境 (防卡死增强版)..."

# 0. 强制同步系统时间 (解决源证书时间校验报错)
echo ">>> 正在强制同步系统时间..."
date -s "$(curl -s --head http://www.google.com | grep ^Date: | sed 's/Date: //g')"

# 0.1 清理可能卡住的 apt 锁 (解决 Could not get lock 报错)
echo ">>> 检查并清理可能被占用的 apt 锁..."
killall apt apt-get 2>/dev/null
rm -f /var/lib/apt/lists/lock
rm -f /var/cache/apt/archives/lock
rm -f /var/lib/dpkg/lock*
dpkg --configure -a

# 1. 更新系统包并安装基础工具
echo ">>> 正在更新系统组件 (这可能需要几分钟)..."
apt update && apt upgrade -y
apt install -y curl wget git vim sudo

# 2. 设置系统时区为亚洲/上海
echo ">>> 正在同步时区为 Asia/Shanghai..."
timedatectl set-timezone Asia/Shanghai

# 3. 开启 BBR + FQ 网络加速
echo ">>> 正在开启原版 BBR + FQ 拥塞控制..."
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 4. 倒计时并自动重启
echo "================================================="
echo "初始化全部完成！"
echo "时区 (Asia/Shanghai) 与 BBR 加速已生效。"
echo "主机名保持原有设置不变。"
echo "VPS 将在 3 秒后自动重启，请在 1 分钟后重新连接 SSH。"
echo "================================================="
sleep 3
reboot
