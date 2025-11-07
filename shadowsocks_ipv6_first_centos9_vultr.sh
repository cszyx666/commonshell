#!/bin/bash
# 执行脚本
# curl -fsSL https://raw.githubusercontent.com/cszyx666/commonshell/main/shadowsocks_ipv6_first_centos9_vultr.sh | bash

dnf install epel-release -y
dnf clean all
rm -rf /var/cache/dnf
dnf makecache
dnf remove epel-release -y 2>/dev/null || true
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
dnf config-manager --set-enabled crb
dnf install -y "Development Tools"
dnf install -y gcc gettext autoconf libtool automake make pcre-devel asciidoc xmlto c-ares-devel libev-devel libsodium-devel mbedtls-devel git
cd /usr/src
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
git submodule update --init --recursive
./autogen.sh
./configure
make && make install
mkdir -p /etc/shadowsocks-libev
cat > /etc/shadowsocks-libev/config.json << 'EOF'
{
    "server": ["[::0]", "0.0.0.0"],
    "server_port": 7894,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "U*3jP6RVJ},2e9KX",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305",
    "fast_open": true,
    "reuse_port": true,
    "no_delay": true,
    "nameserver": "1.1.1.1",
    "mode": "tcp_and_udp",
    "ipv6_first": true
}
EOF
cat > /etc/systemd/system/shadowsocks-libev.service << 'EOF'
[Unit]
Description=Shadowsocks-libev Default Server Service
Documentation=man:shadowsocks-libev(8)
After=network-online.target

[Service]
Type=simple
User=nobody
Group=nobody
ExecStart=/usr/local/bin/ss-server -c /etc/shadowsocks-libev/config.json
LimitNOFILE=32768

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable shadowsocks-libev
systemctl start shadowsocks-libev
firewall-cmd --permanent --add-port=7894/tcp
firewall-cmd --permanent --add-port=7894/udp
firewall-cmd --reload
