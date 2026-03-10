#!/bin/bash

echo ">>> 开始一键自动初始化 VPS 环境 (极致防卡死版)..."

# 1. 强杀开机自带的 apt 进程，释放锁
echo ">>> 正在清理开机自带的更新进程和 apt 锁..."
killall apt apt-get 2>/dev/null
rm -f /var/lib/apt/lists/lock
rm -f /var/cache/apt/archives/lock
rm -f /var/lib/dpkg/lock*
dpkg --configure -a

# 2. 忽略时间校验强制更新，并安装基础工具 (重点修复)
echo ">>> 正在忽略证书时间强制拉取源，并安装必要工具..."
# 这一步直接在 apt 层面临时关掉时间校验，完美绕过 DMIT 的报错
apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update
apt-get install -y curl wget git vim sudo systemd-timesyncd

# 3. 强制触发系统底层时间同步
echo ">>> 正在强制同步系统时间..."
systemctl restart systemd-timesyncd
sleep 2 # 给时间服务一点点生效的时间

# 4. 设置系统时区为亚洲/上海
echo ">>> 正在同步时区为 Asia/Shanghai..."
timedatectl set-timezone Asia/Shanghai

# 5. 开启 BBR + FQ 网络加速
echo ">>> 正在开启原版 BBR + FQ 拥塞控制..."
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 6. 执行完整的系统升级
echo ">>> 正在执行系统组件的全面升级..."
apt-get upgrade -y

# 7. 倒计时并自动重启
echo "================================================="
echo "初始化全部完成！"
echo "时区与网络优化已生效，系统依赖已更新。"
echo "VPS 将在 3 秒后自动重启，请在 1 分钟后重新连接 SSH。"
echo "================================================="
sleep 3
reboot
