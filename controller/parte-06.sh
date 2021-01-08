#!/bin/bash
. admin-openrc.sh

openstack user create --domain default placement --password PLACEMENT_PASS
openstack role add --project service --user placement admin
openstack service create --name placement --description "Placement API" placement

openstack endpoint create --region RegionOne placement public http://controller:8778
openstack endpoint create --region RegionOne placement internal http://controller:8778
openstack endpoint create --region RegionOne placement admin http://controller:8778

apt install placement-api -y

cat > /etc/placement/placement.conf << END
[placement_database]
connection = mysql+pymysql://placement:PLACEMENT_DBPASS@controller/placement
[api]
auth_strategy = keystone
[keystone_authtoken]
auth_url = http://controller:5000/v3
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = placement
password = PLACEMENT_PASS
END

su -s /bin/sh -c "placement-manage db sync" placement

systemctl restart apache2

placement-status upgrade check