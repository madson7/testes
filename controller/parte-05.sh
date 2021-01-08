#!/bin/bash
. admin-openrc.sh

openstack user create --domain Default glance --password GLANCE_PASS
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image

openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292

apt install glance -y

cat > /etc/glance/glance-api.conf << END
[database]
connection = mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
[keystone_authtoken]
www_authenticate_uri  = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = GLANCE_PASS
[paste_deploy]
flavor = keystone
[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
END

su -s /bin/sh -c "glance-manage db_sync" glance

systemctl enable glance-api
systemctl start glance-api


glance image-list