#!/bin/bash

# 1. 强制设置时区为北京时间 (核心需求)
echo "正在同步时间..."
timedatectl set-timezone Asia/Shanghai
hwclock --systohc

# 2. 获取必要的系统升级
echo "正在检查系统更新..."
export DEBIAN_FRONTEND=noninteractive
apt update && apt upgrade -y
apt autoremove -y

# 3. 提示完成
echo "------------------------------------------------"
echo "系统初始化完成！"
echo "当前时间: $(date)"
echo "系统已升级到最新版本。"
echo "------------------------------------------------"
