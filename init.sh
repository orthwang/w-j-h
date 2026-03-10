#!/bin/bash

echo ">>> 开始一键自动初始化 VPS 环境 (安全排队版)..."

# 1. 安全获取软件源：忽略时间校验，并耐心等待系统后台释放锁
echo ">>> 正在获取软件源 (如遇系统开机后台更新，将自动排队等待)..."
apt-get -o DPkg::Lock::Timeout=600 -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update

# 2. 安装基础工具：继续设置 10 分钟超时等待机制
echo ">>> 正在安装必要工具与时间服务..."
apt-get -o DPkg::Lock::Timeout=600 install -y curl wget git vim sudo systemd-timesyncd

# 3. 彻底修复时间并同步上海时区
echo ">>> 正在同步正确时间与设置 Asia/Shanghai 时区..."
systemctl enable --now systemd-timesyncd
systemctl restart systemd-timesyncd
sleep 3
timedatectl set-timezone Asia/Shanghai

# 4. 开启原版 BBR + FQ
echo ">>> 正在开启原版 BBR + FQ 网络加速..."
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 5. 安全进行全系统升级
echo ">>> 正在执行系统组件的全面升级..."
apt-get -o DPkg::Lock::Timeout=600 upgrade -y

# 6. 倒计时并自动重启
echo "================================================="
echo "初始化全部完美完成！"
echo "时区同步与网络优化已生效，系统升级完毕。"
echo "VPS 将在 3 秒后自动重启，请在 1 分钟后重新连接 SSH。"
echo "================================================="
sleep 3
reboot
