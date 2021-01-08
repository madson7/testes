#!/bin/bash

apt install rabbitmq-server -y

systemctl enable rabbitmq-server
systemctl start rabbitmq-server

rabbitmqctl add_user openstack RABBIT_PASS

rabbitmqctl set_permissions openstack ".*" ".*" ".*"

apt install memcached python3-memcache -y

sed -i "s/^-l/-l 10.0.2.11 #/" /etc/memcached.conf

systemctl enable memcached
systemctl start memcached

apt install etcd -y

systemctl enable etcd
systemctl start etcd

cat > /etc/default/etcd << END
ETCD_NAME="controller"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER="controller=http://10.0.2.11:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.2.11:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.2.11:2379"
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.0.2.11:2379"
END

systemctl restart etcd