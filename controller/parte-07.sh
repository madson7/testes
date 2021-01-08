#!/bin/bash
. admin-openrc.sh

openstack user create --domain default nova --password NOVA_PASS
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute

openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1

apt install nova-api nova-conductor nova-novncproxy nova-scheduler -y

cat > /etc/nova/nova.conf << END
[api_database]
connection = mysql+pymysql://nova:NOVA_DBPASS@controller/nova_api
[database]
connection = mysql+pymysql://nova:NOVA_DBPASS@controller/nova
[DEFAULT]
transport_url = rabbit://openstack:RABBIT_PASS@controller:5672/
vif_plugging_timeout = 300
vif_plugging_is_fatal = True
compute_driver = libvirt.LibvirtDriver
default_ephemeral_format = ext4
pointer_model = ps2mouse
graceful_shutdown_timeout = 5
metadata_workers = 2
osapi_compute_workers = 2

[api]
auth_strategy = keystone
[keystone_authtoken]
www_authenticate_uri = http://controller:5000/
auth_url = http://controller:5000/
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = NOVA_PASS
my_ip = 10.0.2.11
[vnc]
enabled = true
server_listen = $my_ip
server_proxyclient_address = $my_ip
[glance]
api_servers = http://controller:9292
[oslo_concurrency]
lock_path = /var/lib/nova/tmp
[placement]
region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://controller:5000/v3
username = placement
password = PLACEMENT_PASS
[wsgi]
api_paste_config = /etc/nova/api-paste.ini
[scheduler]
workers = 2
END

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova

systemctl enable \
  nova-api \
  nova-scheduler \
  nova-conductor \
  nova-novncproxy
systemctl start \
  nova-api \
  nova-scheduler \
  nova-conductor \
  nova-novncproxy

su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova


openstack compute service list



cat > admin-openrc.sh << END
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=zOhubvDC9Byy14HPUy2q6vN1067uqiX5 #ADMIN_PASS
export OS_AUTH_URL=http://controller:5000/v3/
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
END