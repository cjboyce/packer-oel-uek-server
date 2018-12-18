#!/usr/bin/env bash

# Must enable box as a yum server or it can't see channels
/sbin/uln-channel --enable-yum-server -u ${ULN_USERNAME} -p ${ULN_PASSWORD} 

# Add dev EPEL channel
/sbin/uln-channel -a -v -c ol7_x86_64_developer_EPEL -u ${ULN_USERNAME} -p ${ULN_PASSWORD}

# No more yum server...
/sbin/uln-channel --disable-yum-server -u ${ULN_USERNAME} -p ${ULN_PASSWORD}

yum clean all
echo "<==== Install Ansible ====>"
yum install -y ansible

