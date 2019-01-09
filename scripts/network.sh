#!/usr/bin/env bash

echo "<==== Write out eth0 settings ====>"
cat > /etc/sysconfig/network-scripts/ifcfg-eth0<<end_o_text
# Generated with Packer
NAME=eth0
DEVICE=eth0
IPV6_AUTOCONF=no
IPV6INIT=no
BOOTPROTO=none
ONBOOT=yes
TYPE=Ethernet
IPADDR=${IPADDR}
GATEWAY=${GATEWAY}
PREFIX=${PREFIX}
DNS1=${DNS1}
DNS2=${DNS2}
end_o_text

/bin/hostnamectl set-hostname ${HOSTNAME}

