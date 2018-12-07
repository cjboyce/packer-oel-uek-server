#!/usr/bin/env bash

echo "<==== Registering with ULN ====>"
/usr/sbin/ulnreg_ks --profilename=${HOSTNAME} --username=${ULN_USERNAME} --password=${ULN_PASSWORD} --csi=${ULN_CSI}

echo "<==== Running yum update all ====>"
yum update -y
