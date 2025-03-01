#!/bin/sh
# 99-custom.sh - ImmortalWRT首次启动配置脚本

# 日志文件
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE

# 设置 LAN 接口的桥接设备和静态 IP
echo "Configuring LAN interface and bridge..." >> $LOGFILE
uci set network.lan=interface
uci set network.lan.device='br-lan'
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.50.252'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.50.1'
uci set network.lan.dns='223.5.5.5'
uci add_list network.lan.dns='127.0.0.1'

# 设置桥接设备 br-lan
echo "Configuring bridge device br-lan..." >> $LOGFILE
uci set network.br-lan=device
uci set network.br-lan.name='br-lan'
uci set network.br-lan.type='bridge'

# 添加所有网口到桥接设备
echo "Adding ports to br-lan..." >> $LOGFILE
uci delete network.br-lan.ports
uci add_list network.br-lan.ports='eth0'
uci add_list network.br-lan.ports='eth1'
uci add_list network.br-lan.ports='eth2'
uci add_list network.br-lan.ports='eth3'

# 提交网络配置
echo "Committing network configuration..." >> $LOGFILE
uci commit network

# 设置防火墙规则（允许访问 WebUI）
echo "Configuring firewall..." >> $LOGFILE
uci set firewall.@zone[1].input='ACCEPT'
uci commit firewall

# 设置所有网口可访问 Web 终端和 SSH
echo "Configuring ttyd and SSH access..." >> $LOGFILE
uci delete ttyd.@ttyd[0].interface
uci set dropbear.@dropbear[0].Interface=''
uci commit ttyd
uci commit dropbear

# 设置编译作者信息
echo "Setting build information..." >> $LOGFILE
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Compiled by wukongdaily"
if [ -f "$FILE_PATH" ]; then
    sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH"
else
    echo "Error: $FILE_PATH not found. Cannot set build information." >> $LOGFILE
fi

# 完成
echo "99-custom.sh completed successfully at $(date)" >> $LOGFILE
exit 0
