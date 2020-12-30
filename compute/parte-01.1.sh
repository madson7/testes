#!/bin/bash

add-apt-repository cloud-archive:victoria -y

apt update && apt dist-upgrade -y

apt install python3-openstackclient -y