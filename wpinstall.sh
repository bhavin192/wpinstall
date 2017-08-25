#!/bin/bash

#Copyright: (c) 2017 by Bhavin Gandhi
#License: GNU GPL v3, see LICENSE for more details 

# this function will ensure that the given package is installed
function check_install {
    pkg_name=$1
    dpkg-query --show $pkg_name &> /dev/null
    if [ $? -ne 0 ]; then 
        echo "Installing $pkg_name..."
        sudo apt-get install $pkg_name -y
        if [ $? -ne 0 ]; then 
            echo "Installation failed!"
        else
            echo "done."
        fi
    else    
        echo "$pkg_name is already installed, skipping..."
    fi
}

# check if running on Ubuntu or Debian
distro=$(lsb_release -i | cut -f 2)
if [ $distro != "Ubuntu" ] && [ $distro != "Debian" ]; then
    echo "This script is designed to work only on Ubuntu or Debian." 1>&2
    exit 1
fi

# check if running with root privileges
if [ $(id -u) -ne 0 ]; then
    echo "This script needs root privileges to work correctly." 1>&2
    exit 1
fi

# update apt lists
sudo apt-get update

check_install nginx
check_install debconf-utils
# set configurations for mysql-server
db_password="secpass#1"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_password"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_password"
check_install mysql-server
# delete the installation configurations of mysql-server
sudo debconf-communicate mysql-server <<< 'PURGE' &> /dev/null

check_install php7.0-fpm 
check_install php-mysql

# don't execute closest php file, if not found
sudo sed -i -e 's/;*cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.0/fpm/php.ini
sudo systemctl restart php7.0-fpm.service


echo "Enter domain name: "
read domain_name
sudo chown $(whoami) /etc/hosts
sudo sed -i -e "\$a127.0.0.1\t$domain_name" /etc/hosts
sudo chown root /etc/hosts

# create nginx configuration for $domain_name
# check if nginx.conf exist
if [ ! -f nginx.conf ]; then 
    echo "nginx.conf file is missing in current directory. Aborting..." 1>&2
    exit 1
fi
sudo cp nginx.conf /etc/nginx/sites-available/$domain_name
sudo sed -i "s/domain_name/$domain_name/g" /etc/nginx/sites-available/$domain_name
sudo ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/
sudo systemctl reload nginx

check_install unzip
curl -L http://wordpress.org/latest.zip -o wordpress.zip
unzip wordpress.zip -d /tmp/
rm -f wordpress.zip
sudo mkdir /var/www/$domain_name
sudo mv /tmp/wordpress/* /var/www/$domain_name/
sudo rm -rf /tmp/wordpress

db_name=${domain_name//./_}_db
mysql -u root -p$db_password -e "USE $db_name;"
if [ $? -ne 0 ]; then
    mysql -u root -p$db_password -e "CREATE DATABASE $db_name;"
else
    echo "Database $db_name already exist."
fi

# create wp-config.php
sudo cp /var/www/$domain_name/wp-config-sample.php /var/www/$domain_name/wp-config.php

sudo sed -i "s/database_name_here/$db_name/g" /var/www/$domain_name/wp-config.php
sudo sed -i "s/username_here/root/g" /var/www/$domain_name/wp-config.php
sudo sed -i "s/password_here/$db_password/g" /var/www/$domain_name/wp-config.php

salts_keys=$(curl https://api.wordpress.org/secret-key/1.1/salt)
salts_keys=$(echo $salts_keys | sed -e 's/\([[\/.*]\|\]\)/\\&/g')

sudo sed -i "/_KEY/d" /var/www/$domain_name/wp-config.php
sudo sed -i "/_SALT/d" /var/www/$domain_name/wp-config.php
sudo sed -i "/define('DB_COLLATE', '');/a$salts_keys" /var/www/$domain_name/wp-config.php

echo "Site can be browsed at http://$domain_name"
echo "root directory of site: /var/www/$domain_name"
echo "nginx configuration of site: /etc/nginx/sites-available/$domain_name"
echo "Database user: root"
echo "Database password: $db_password"
echo "Database name: $db_name"
