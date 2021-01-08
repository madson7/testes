#!/bin/bash

apt update && apt upgrade -y

hostnamectl set-hostname controller

cat >> /etc/hosts << END

# controller
192.168.0.111       controller
# compute1
192.168.0.131       compute1
# block1
192.168.0.141       block1
# object1
192.168.0.151       object1
# object2
192.168.0.161       object2
END

cat > /etc/netplan/00-installer-config.yaml << END
# This is the network config written by 'subiquity'
network:
  ethernets:
    enp0s3:
      addresses:
      - 10.0.2.11/24
      gateway4: 10.0.2.1
      nameservers:
        addresses:
        - 8.8.8.8
    enp0s8:
      addresses:
      - 192.168.0.111/24
      gateway4: 192.168.0.1
      nameservers:
        addresses:
        - 8.8.8.8
  version: 2
END

netplan apply

reboot