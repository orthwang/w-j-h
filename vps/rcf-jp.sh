#!/bin/bash

echo ">>> 开始一键自动初始化 RCF-JP 专属环境 (完美静默防卡死版)..."

# 0. 核心防卡死魔法：设置为完全非交互模式，屏蔽所有安装弹窗问询
export DEBIAN_FRONTEND=noninteractive
APT_OPT="-y -o DPkg::Lock::Timeout=600 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"

# 1. 专属定制：修改主机名
echo ">>> 正在修改主机名为 RCF-JP..."
hostnamectl set-hostname RCF-JP

# 2. 安全获取软件源：忽略时间校验并耐心排队
echo ">>> 正在获取软件源..."
apt-get -o DPkg::Lock::Timeout=600 -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update

# 3. 静默安装基础工具
echo ">>> 正在安装必要工具与时间服务..."
apt-get install $APT_OPT curl wget git vim sudo systemd-timesyncd

# 4. 彻底修复时间并同步上海时区
echo ">>> 正在同步正确时间与设置 Asia/Shanghai 时区..."
systemctl enable --now systemd-timesyncd
systemctl restart systemd-timesyncd
sleep 3
timedatectl set-timezone Asia/Shanghai

# 5. 开启原版 BBR + FQ 网络加速
echo ">>> 正在开启原版 BBR + FQ 网络加速..."
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 6. 静默进行全系统升级
echo ">>> 正在执行系统组件的全面升级..."
apt-get upgrade $APT_OPT

# 7. 倒计时并自动重启
echo "================================================="
echo "RCF-JP 初始化全部完美完成！"
echo "主机名已更改为 RCF-JP，底层防弹优化已生效。"
echo "VPS 将在 3 秒后自动重启，请在 1 分钟后重新连接 SSH。"
echo "================================================="
sleep 3
reboot
