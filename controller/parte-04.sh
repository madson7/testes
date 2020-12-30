#!/bin/bash

apt install keystone apache2 libapache2-mod-wsgi-py3 -y

cat > /etc/keystone/keystone.conf << END
[database]
connection = mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone
[token]
provider = fernet
END

su -s /bin/sh -c "keystone-manage db_sync" keystone
# 2020-12-20 21:43:27.056 16982 WARNING py.warnings [-] /usr/lib/python3/dist-packages/pymysql/cursors.py:170: Warning: (1280, "Name 'assignment_pkey' ignored for PRIMARY key.")
#   result = self._query(query)

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
  --bootstrap-admin-url http://controller:5000/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne

cat >> /etc/apache2/apache2.conf << END
ServerName controller
END

systemctl enable apache2
systemctl start apache2

cat > admin-openrc.sh << END
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
END

chmod +x admin-openrc.sh

. admin-openrc.sh

openstack project create --domain default --description "Service Project" service

openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-name Default --os-user-domain-name Default \
  --os-project-name admin --os-username admin --os-password ADMIN_PASS token issue