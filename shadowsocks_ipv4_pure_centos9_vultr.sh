#!/bin/bash
# 执行脚本
# curl -fsSL https://raw.githubusercontent.com/cszyx666/commonshell/main/shadowsocks_ipv4_pure_centos9_vultr.sh | bash

dnf install python3 python3-pip firewalld -y
pip3 install https://github.com/shadowsocks/shadowsocks/archive/master.zip
mkdir -p /etc/shadowsocks
cat > /etc/shadowsocks/config.json << 'EOF'
{
    "server": "0.0.0.0",
    "server_port": 7894,
    "password": "U*3jP6RVJ},2e9KX",
    "method": "aes-256-gcm",
    "timeout": 300,
    "fast_open": false
}
EOF
systemctl enable --now firewalld
firewall-cmd --permanent --add-port=7894/tcp
firewall-cmd --permanent --add-port=7894/udp
firewall-cmd --reload
cat > /etc/systemd/system/shadowsocks.service << 'EOF'
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start shadowsocks
systemctl enable shadowsocks
