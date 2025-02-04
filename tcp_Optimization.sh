#!/bin/bash

# 问候语
 echo "欢迎使用TCP参数配置脚本"
# echo "请输入带宽（单位：Mbps 取VPS带宽或本地带宽最小值）："
# read bandwidth
# echo "=================="
# echo "请输入ping值（单位：ms 本地到vps）："
# read ms
 echo "=================="


# # 检查是否输入了正整数
# if ! [[ "$bandwidth" =~ ^[0-9]+$ ]]; then
#     echo "错误：请输入一个正整数作为带宽值！"
#     exit 1
# fi

# 计算相关的数值
#size=$(( ( $bandwidth * 100000 ) * ( $ms * 2) / 1000 ))
#max_size=$(( $size * 2 ))

# 定义需要删除的旧配置参数
parameters=(
    "net.core.rmem_max"
    "net.core.wmem_max"
    "net.core.default_qdisc"
    "net.ipv4.tcp_congestion_control"
    "net.ipv4.tcp_window_scaling"
    "net.ipv4.tcp_sack"
    "net.ipv4.tcp_fack"
    "net.ipv4.tcp_dsack"
    "net.ipv4.tcp_mtu_probing"
    "net.ipv4.tcp_no_metrics_save"
    "net.ipv4.tcp_moderate_rcvbuf"
    "net.ipv4.tcp_ecn"
    "net.ipv4.tcp_frto"
    "net.ipv4.tcp_rfc1337"
    "net.ipv4.tcp_adv_win_scale"
    
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
cat >> /etc/sysctl.conf << EOF
vm.swappiness=10                      # 降低交换分区的使用率
net.core.rmem_max=16777216            # 设置接收缓冲区最大值为 16MB
net.core.wmem_max=16777216            # 设置发送缓冲区最大值为 16MB
net.ipv4.tcp_no_metrics_save=1        # 不使用旧连接数据，保证新连接稳定
net.ipv4.tcp_ecn=0                    # 关闭 ECN，避免不兼容路由器导致的丢包
net.ipv4.tcp_frto=0                   # 关闭 F-RTO，避免误判导致超时问题
net.ipv4.tcp_mtu_probing=0            # 禁止动态 MTU 探测，防止因 ICMP 丢失导致 MTU 变化
net.ipv4.tcp_rfc1337=1                # 启用 RFC1337，减少 TIME_WAIT 连接资源占用
net.ipv4.tcp_sack=1                   # 启用 SACK，提升丢包情况下的恢复能力
net.ipv4.tcp_fack=1                   # 启用 FACK，配合 SACK 进一步优化重传
net.ipv4.tcp_window_scaling=1         # 启用窗口缩放，保证高带宽连接的稳定性
net.ipv4.tcp_adv_win_scale=-2         # 使用更保守的 TCP 窗口调整策略
net.ipv4.tcp_moderate_rcvbuf=1        # 自动调整接收缓冲区，提高吞吐量并适应不同环境
net.core.default_qdisc = fq_pie       # 使用 fq_pie 算法作为队列管理器
net.ipv4.tcp_congestion_control = bbr  # 使用 BBR 拥塞控制算法
EOF
echo "=================="
# 生效配置
echo "正在使配置生效..."
sysctl -p
echo "=================="
# 提示完成
echo "配置已完成 欢迎使用"