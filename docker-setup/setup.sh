#!/bin/bash
        
# check if running with root privileges
if [ $(id -u) -ne 0 ]; then
    echo "This script needs root privileges to work correctly." 1>&2
    exit 1
fi

# download wordpress.tar.gz, extract files 
echo "Downloading wordpress.tar.gz"
curl -L http://wordpress.org/latest.tar.gz -o wordpress.tar.gz
echo "Extracting files"
tar -xzf wordpress.tar.gz

# create wp-config.php
echo "Creating wp-config.php for WordPress site"
sudo cp wordpress/wp-config-sample.php wordpress/wp-config.php 

sudo sed -i "s/database_name_here/wordpress_db/g" wordpress/wp-config.php
sudo sed -i "s/username_here/root/g" wordpress/wp-config.php
sudo sed -i "s/password_here/secpass#1/g" wordpress/wp-config.php
sudo sed -i "s/localhost/mysqldb/g" wordpress/wp-config.php

salts_keys=$(curl https://api.wordpress.org/secret-key/1.1/salt) 
salts_keys=$(echo $salts_keys | sed -e 's/\([[\/.*]\|\]\)/\\&/g')

sudo sed -i "/_KEY/d" wordpress/wp-config.php
sudo sed -i "/_SALT/d" wordpress/wp-config.php
sudo sed -i "/define('DB_COLLATE', '');/a$salts_keys" wordpress/wp-config.php

# change ownership of files
echo "Changing ownership of files"
sudo chown -R 33:33 wordpress
rm -f wordpress.tar.gz

# check if docker and docker-compose is installed
which docker &> /dev/null
if [ $? -ne 0 ]; then
    echo "docker is not installed. Follow this link to install docker on your system, https://docs.docker.com/engine/installation/#server"
fi
which docker-compose &> /dev/null
if [ $? -ne 0 ]; then
    echo "docker-compose is not installed. Follow this link to install docker-compose on your system, https://github.com/docker/compose/releases"
fi
