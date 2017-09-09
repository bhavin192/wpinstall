#!/bin/bash

#Copyright: (c) 2017 by Bhavin Gandhi
#License: GNU GPL v3, see LICENSE for more details 

log_file=wpinstall.log

# this function will ensure that the given package is installed
function check_install {
    pkg_name=$1
    dpkg-query --show $pkg_name &>> $log_file
    if [ $? -ne 0 ]; then 
        echo "Installing $pkg_name"
        apt-get install $pkg_name -y &>> $log_file
        if [ $? -ne 0 ]; then 
            echo "Installation of $pkg_name failed!" 1>&2
            exit 1
        else
            echo "done."
        fi
    else    
        echo "$pkg_name is already installed, skipping..."
    fi
}

echo -e "Installing nginx, MySQL, php on the system and deploying latest WordPress. It will aks for domain name.\n"

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
echo "Updating apt package lists, this may take some time."
apt-get update &>> $log_file

check_install nginx
check_install debconf-utils
# set configurations for mysql-server
echo "Creating temporary configuration for mysql"
db_password="secpass#1"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_password" &>> $log_file
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_password" &>> $log_file
check_install mysql-server
# delete the installation configurations of mysql-server
echo "Deleting temporary configuration of mysql"
debconf-communicate mysql-server <<< 'PURGE' &>> $log_file

check_install php7.0-fpm 
check_install php-mysql

# don't execute closest php file, if not found
echo "Configuring php"
sed -i "s/;*cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini &>> $log_file
systemctl restart php7.0-fpm.service &>> $log_file

echo "Enter domain name: "
read domain_name
while [ -z $domain_name ]; do
    echo "domain name cannot be blank! Please enter a valid name."
    read domain_name
done
echo "Creating /etc/hosts entry for new site"
chown $(whoami) /etc/hosts &>> $log_file
sed -i "\$a127.0.0.1\t$domain_name" /etc/hosts &>> $log_file
chown root /etc/hosts &>> $log_file

# create nginx configuration for $domain_name
# check if nginx.conf exist
if [ ! -f nginx.conf ]; then 
    echo "nginx.conf file is missing in current directory. Aborting..." 1>&2
    exit 1
fi
echo "Creating nginx configuration for new site"
cp nginx.conf /etc/nginx/sites-available/$domain_name &>> $log_file
sed -i "s/domain_name/$domain_name/g" /etc/nginx/sites-available/$domain_name &>> $log_file
ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/ &>> $log_file
systemctl reload nginx &>> $log_file

echo "Downloading latest wordpress.zip and extracting in site root"
check_install unzip
curl -L http://wordpress.org/latest.zip -o wordpress.zip &>> $log_file
unzip wordpress.zip -d /tmp/ &>> $log_file
rm -f wordpress.zip &>> $log_file
mkdir /var/www/$domain_name &>> $log_file
mv /tmp/wordpress/* /var/www/$domain_name/ &>> $log_file
rm -rf /tmp/wordpress &>> $log_file

echo "Creating database for new site"
db_name=${domain_name//./_}_db
mysql -u root -p$db_password -e "USE $db_name;" &>> $log_file
if [ $? -ne 0 ]; then
    mysql -u root -p$db_password -e "CREATE DATABASE $db_name;" &>> $log_file
else
    echo "Database $db_name already exist."
fi

# create wp-config.php
echo "Creating wp-config.php for WordPress site"
cp /var/www/$domain_name/wp-config-sample.php /var/www/$domain_name/wp-config.php &>> $log_file

sed -i "s/database_name_here/$db_name/g" /var/www/$domain_name/wp-config.php &>> $log_file
sed -i "s/username_here/root/g" /var/www/$domain_name/wp-config.php &>> $log_file
sed -i "s/password_here/$db_password/g" /var/www/$domain_name/wp-config.php &>> $log_file

salts_keys=$(curl https://api.wordpress.org/secret-key/1.1/salt) 
salts_keys=$(echo $salts_keys | sed -e 's/\([[\/.*]\|\]\)/\\&/g')

sed -i "/_KEY/d" /var/www/$domain_name/wp-config.php &>> $log_file
sed -i "/_SALT/d" /var/www/$domain_name/wp-config.php &>> $log_file
sed -i "/define('DB_COLLATE', '');/a$salts_keys" /var/www/$domain_name/wp-config.php &>> $log_file

echo -e "\nSite can be browsed at http://$domain_name"
echo "root directory of site: /var/www/$domain_name"
echo "nginx configuration of site: /etc/nginx/sites-available/$domain_name"
echo "Database user: root"
echo "Database password: $db_password"
echo "Database name: $db_name"
