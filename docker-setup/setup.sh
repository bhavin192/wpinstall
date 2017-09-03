#!/bin/bash

echo "Downloading wordpress.tar.gz"
curl -L http://wordpress.org/latest.tar.gz -o wordpress.tar.gz
echo "Extracting files"
tar -xzf wordpress.tar.gz
echo "Changing ownership of files"
sudo chown -R 33:33 wordpress
rm -f wordpress.tar.gz
