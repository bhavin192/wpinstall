#!/bin/bash
        
# check if running with root privileges
if [ $(id -u) -ne 0 ]; then
    echo "This script needs root privileges to work correctly." 1>&2
    exit 1
fi

# download wordpress.tar.gz, extract and change ownership of files 
echo "Downloading wordpress.tar.gz"
curl -L http://wordpress.org/latest.tar.gz -o wordpress.tar.gz
echo "Extracting files"
tar -xzf wordpress.tar.gz
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
