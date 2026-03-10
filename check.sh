#!/bin/bash

# =========================================================
# 功能: 验证 VPS 地基状态 (BBR/时间/网络栈/443端口)
# =========================================================

echo "========= 🛡️  VPS 运行状态深度自检 ========="

# 1. 检查 BBR 状态
echo -n "[1/5] BBR 加速状态: "
bbr_status=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
if [ "$bbr_status" == "bbr" ]; then
    echo -e "\e[32m已开启 (OK)\e[0m"
else
    echo -e "\e[31m未开启 (FAIL)\e[0m"
fi

# 2. 检查 TCP 网络优化参数
echo -n "[2/5] 网络栈优化: "
tfo_status=$(cat /proc/sys/net/ipv4/tcp_fastopen)
if [ "$tfo_status" == "3" ]; then
    echo -e "\e[32m高性能模式 (OK)\e[0m"
else
    echo -e "\e[33m默认模式 (建议检查)\e[0m"
fi

# 3. 检查系统时间与时区
echo -n "[3/5] 系统时区: "
timezone=$(date +%Z)
if [ "$timezone" == "CST" ]; then
    echo -e "\e[32m上海/北京时间 (OK)\e[0m"
else
    echo -e "\e[31m非中国时区 ($timezone)\e[0m"
fi

echo -n "[3.1] 时间偏差值: "
# 使用 ntpdate 查询偏差 (不写入)
offset=$(ntpdate -q ntp.aliyun.com 2>/dev/null | tail -1 | awk '{print $6}')
if (( $(echo "$offset < 1" | bc -l) )); then
    echo -e "\e[32m误差 $offset 秒 (极准)\e[0m"
else
    echo -e "\e[31m误差 $offset 秒 (Reality 握手高风险)\e[0m"
fi

# 4. 检查内核版本 (确认 dist-upgrade 是否生效)
echo -n "[4/5] 当前内核版本: "
uname -r

# 5. 检查 443 端口占用情况
echo -n "[5/5] 443 端口监听: "
port_443=$(ss -lpnt | grep :443)
if [ -z "$port_443" ]; then
    echo -e "\e[33m空闲 (等待安装节点)\e[0m"
else
    echo -e "\e[32m已由 $(echo $port_443 | grep -o 'users:(("[^"]*"' | cut -d'"' -f2) 占用 (OK)\e[0m"
fi

echo "=========================================="
