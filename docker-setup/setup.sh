#!/bin/bash

curl -L http://wordpress.org/latest.tar.gz -o wordpress.tar.gz
tar -xzf wordpress.tar.gz
sudo chown -R 33:33 wordpress
rm -f wordpress.tar.gz
