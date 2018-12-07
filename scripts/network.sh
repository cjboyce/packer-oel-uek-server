#!/usr/bin/env bash

echo "<==== Write out eth0 settings ====>"
cat > /etc/sysconfig/network-scripts/ifcfg-eth0<<end_o_text
# Generated with Packer
IPV6_AUTOCONF=no
IPV6INIT=no
BOOTPROTO=none
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
IPADDR=${IPADDR}
GATEWAY=${GATEWAY}
PREFIX=${PREFIX}
DNS1=${DNS1}
DNS2=${DNS2}
end_o_text

/bin/hostnamectl set-hostname ${HOSTNAME}

