#!/bin/bash

apt update
apt upgrade -y

cat > /etc/netplan/00-installer-config.yaml << END
# This is the network config written by 'subiquity'
network:
  ethernets:
    enp0s3:
      addresses:
      - 192.168.0.131/24
      gateway4: 192.168.0.1
      nameservers:
        addresses:
        - 8.8.8.8
  version: 2
END

netplan apply

hostnamectl set-hostname compute1

cat >> /etc/hosts << END

# controller
192.168.0.22       controller
# compute1
192.168.0.131       compute1
# block1
192.168.0.141       block1
# object1
192.168.0.151       object1
# object2
192.168.0.161       object2
END

apt install chrony -y

cat > /etc/chrony/chrony.conf << END
server controller iburst
END

systemctl enable chronyd
systemctl start chronyd

reboot