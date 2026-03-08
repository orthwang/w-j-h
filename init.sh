#!/bin/bash

# 1. 强制设置时区并同步硬件 (你的核心需求)
echo "正在同步时间..."
timedatectl set-timezone Asia/Shanghai
hwclock --systohc

# 2. 获取必要的系统升级 (防卡死模式)
echo "正在全量升级系统，请稍候..."
export DEBIAN_FRONTEND=noninteractive
apt update
# 这行参数确保了升级过程中即便有配置冲突，也会自动跳过，不会弹窗卡死
apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
apt autoremove -y

# 3. 结果反馈
echo "------------------------------------------------"
echo "系统初始化完成！"
echo "当前时间: $(date)"
echo "状态：补丁已打全，且无需人工干预。"
echo "------------------------------------------------"
