#!/bin/bash

echo ">>> 开始一键自动初始化 VPS 环境 (完美静默版)..."

# 0. 核心防卡死魔法：设置为完全非交互模式，屏蔽所有安装弹窗问询
export DEBIAN_FRONTEND=noninteractive
# 预设 apt 参数：超时排队 + 自动回答yes + 自动保留旧配置文件覆盖新包配置
APT_OPT="-y -o DPkg::Lock::Timeout=600 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"

# 1. 安全获取软件源：忽略时间校验
echo ">>> 正在获取软件源..."
apt-get -o DPkg::Lock::Timeout=600 -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update

# 2. 静默安装基础工具
echo ">>> 正在安装必要工具与时间服务..."
apt-get install $APT_OPT curl wget git vim sudo systemd-timesyncd

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

# 5. 静默进行全系统升级
echo ">>> 正在执行系统组件的全面升级..."
apt-get upgrade $APT_OPT

# 6. 倒计时并自动重启
echo "================================================="
echo "初始化全部完美完成！"
echo "时区同步与网络优化已生效，系统升级完毕。"
echo "VPS 将在 3 秒后自动重启，请在 1 分钟后重新连接 SSH。"
echo "================================================="
sleep 3
reboot
