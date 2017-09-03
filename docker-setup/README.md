# WPInstall

![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg) [![Docker support: present](https://img.shields.io/badge/Docker%20support-present-blue.svg)](https://www.docker.com/what-docker) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Docker Setup

This directory contains files required to setup LEMP stack using Docker Compose and run WordPress on it.

Requires [docker](https://docs.docker.com/engine/installation/#server) and [docker-compose](https://github.com/docker/compose/releases) to be installed.

### How to use.

- Clone the repo in a directory.
```sh
$ git clone https://github.com/bhavin192/wpinstall
$ cd wpinstall/docker-setup
```

- If you want to have custom `php.ini` put your file in `php`
To download production php.ini
```sh
$ curl -L https://raw.githubusercontent.com/php/php-src/master/php.ini-production -o php/php.ini
```

- Make the `setup.sh` executable and run it.
```sh
$ sudo chmod +x setup.sh
$ sudo ./setup.sh
```

- Start the compose 
```sh
$ sudo docker-compose up
```

## Licensing

WPInstall is licensed under GNU General Public License v3.0. See [LICENSE](https://github.com/bhavin192/wpinstall/blob/master/LICENSE) for the full license text.
