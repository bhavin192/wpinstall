#!/bin/bash

#Copyright: (c) 2017 by Bhavin Gandhi
#License: GNU GPL v3, see LICENSE for more details 

cyan="\033[1;36m"
off_cyan="\033[0m"

# this function will ensure that the given package is installed
function check_install {
    pkg_name=$1
    dpkg-query --show $pkg_name &> /dev/null
    if [ $? -ne 0 ]; then 
        echo -e "Installing $pkg_name..."
        sudo apt-get install $pkg_name
        if [ $? -ne 0 ]; then 
            echo "Installation failed!"
        else
            echo "done."
        fi
    else    
        echo "$pkg_name is alredy installed, skipping..."
    fi
}

#update apt lists
#sudo apt-get update

check_install nginx
check_install debconf-utils
# set configurations for mysql-server
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password secpass#1'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password secpass#1'
check_install mysql-server
# delete the installation configurations of mysql-server
sudo debconf-communicate mysql-server <<< 'PURGE' &> /dev/null

check_install php-fpm 
check_install php-mysql

# don't execute closest php file, if not found
sudo sed -i -e 's/;*cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.0/fpm/php.ini
sudo systemctl restart php7.0-fpm.service


echo "Enter domain name: "
read domain_name
sudo chown $(whoami) /etc/hosts
sudo sed -i -e "\$a127.0.0.1\t$domain_name" /etc/hosts
sudo chown root /etc/hosts

sudo cp nginx.conf /etc/nginx/sites-available/$domain_name
sudo sed -i "s/domain_name/$domain_name/g" /etc/nginx/sites-available/$domain_name
sudo ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/
sudo systemctl reload nginx

