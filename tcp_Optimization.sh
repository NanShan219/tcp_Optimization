#!/bin/bash

# 问候语
echo "欢迎使用TCP参数配置脚本"
echo "请输入带宽（单位：Mbps 取VPS带宽或本地带宽最小值）："
read bandwidth
echo "=================="
echo "请输入ping值（单位：ms 本地到vps）："
read ms
echo "=================="


# 检查是否输入了正整数
if ! [[ "$bandwidth" =~ ^[0-9]+$ ]]; then
    echo "错误：请输入一个正整数作为带宽值！"
    exit 1
fi

# 计算相关的数值
size=$(( ( ($bandwidth * 800000) / 8 ) * ( $ms * 2) / 1000 ))

# 定义需要删除的旧配置参数
parameters=(
    "net.ipv4.tcp_rmem"
    "net.ipv4.tcp_wmem"
    "net.core.rmem_max"
    "net.core.wmem_max"
    "net.core.default_qdisc"
    "net.ipv4.tcp_congestion_control"
)

# 删除旧的配置参数
echo "正在删除旧的配置参数..."
for param in "${parameters[@]}"; do
    sed -i "/^$param/d" /etc/sysctl.conf
done
echo "=================="
echo "旧的配置参数已删除"
echo "=================="
# 追加新的配置
echo "正在追加新的配置参数..."
cat > /etc/sysctl.conf << EOF
# TCP参数配置

net.ipv4.tcp_rmem = 4096 87380 ${size}
net.ipv4.tcp_wmem = 4096 16384 ${size}
net.core.rmem_max = ${size}
net.core.wmem_max = ${size}

net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF

# 生效配置
echo "正在使配置生效..."
sysctl -p

# 提示完成
echo "配置已完成，请检查 /etc/sysctl.conf 文件确认"