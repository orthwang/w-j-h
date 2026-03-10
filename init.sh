#!/bin/bash

echo ">>> 开始初始化 VPS 基础环境 (极简安全版)..."

# 1. 核心防卡死魔法：设置为完全非交互模式
export DEBIAN_FRONTEND=noninteractive
# 这里的参数只负责基础安装，绝不执行全量升级，不留任何后患
APT_OPT="-y -o DPkg::Lock::Timeout=600 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"

# 2. 安全获取软件源：忽略时间校验，解决之前遇到的证书 invalid 报错
echo ">>> 正在更新软件源 (安全排队中)..."
apt-get -o DPkg::Lock::Timeout=600 -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update

# 3. 静默安装基础工具 (不碰内核，不碰系统核心)
echo ">>> 正在安装必要基础工具..."
apt-get install $APT_OPT curl wget git vim sudo systemd-timesyncd

# 4. 强制同步上海时区 (这是 Reality 握手成功的生命线)
echo ">>> 正在修正系统时间并同步至 Asia/Shanghai..."
systemctl enable --now systemd-timesyncd
systemctl restart systemd-timesyncd
# 强制等待 2 秒让时间同步生效
sleep 2
timedatectl set-timezone Asia/Shanghai

# 5. 清理残留
echo ">>> 正在清理无效缓存..."
apt-get autoremove -y

echo "================================================="
echo "极简初始化完成！系统环境已就绪。"
echo "✔ 已安装基础工具 (curl/wget/vim/sudo)"
echo "✔ 已强制校准上海时间 (Asia/Shanghai)"
echo "✔ 未改动内核 BBR，未执行系统全量升级 (确保网络兼容性)"
echo "================================================="
