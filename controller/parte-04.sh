#!/bin/bash

apt install keystone apache2 libapache2-mod-wsgi-py3 -y

cat > /etc/keystone/keystone.conf << END
[database]
connection = mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone
[token]
provider = fernet
END

mysql -u keystone -pKEYSTONE_DBPASS

su -s /bin/sh -c "keystone-manage db_sync" keystone

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

openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-name Default --os-user-domain-name Default \
  --os-project-name admin --os-username admin --os-password ADMIN_PASS token issue

. admin-openrc.sh

openstack domain create --description "An Example Domain" example # openstack domain delete example
openstack project create --domain Default --description "Service Project" service