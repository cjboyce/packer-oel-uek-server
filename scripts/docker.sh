#!/usr/bin/env bash

COMPOSE_VER="1.23.2"

# Must enable box as a yum server or it can't see channels
/sbin/uln-channel --enable-yum-server -u ${ULN_USERNAME} -p ${ULN_PASSWORD} 

# Add addons channel
/sbin/uln-channel -a -v -c ol7_x86_64_addons -u ${ULN_USERNAME} -p ${ULN_PASSWORD}

# No more yum server...
/sbin/uln-channel --disable-yum-server -u ${ULN_USERNAME} -p ${ULN_PASSWORD}

yum clean all
echo "<==== Install docker-engine ====>"
yum install -y docker-engine

# Grab docker-compose
# See this for latest version info: https://github.com/docker/compose/releases
echo "<==== Download docker-compose ====>"
curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose

# Enable at startup
systemctl enable docker.service
