# WPInstall

![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg) [![Docker support: present](https://img.shields.io/badge/Docker%20support-present-blue.svg)](https://www.docker.com/what-docker) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)


This script configures LEMP stack on Ubuntu machine and installs the latest WordPress.

### How to use.

- Clone the repo in a directory.
  ```sh
  $ git clone https://github.com/bhavin192/wpinstall
  $ cd wpinstall
  ```

- Modify the file `nginx.conf` if you want to customize the site configuration.

- Make the script executable.

  ```sh
  $ sudo chmod +x wpinstall.sh
  ```

- Run the script, it will ask for domain name of the site.
  
  ```sh 
  $ sudo ./wpinstall.sh
  ```

  or you can specify the domain name as command line argument 

  ```sh
  $ sudo ./wpinstall.sh --domain "wp.example.com"
  ```

- Log is stored in the file `wpinstall.log`

- After successful execution of the script, open the displayed link in a browser to complete further setup.

This script works but has lot of work to be done in order to ensure if WordPress is installed correctly. 
Tested on `Ubuntu 16.04 LTS (xenial)` instance of `GCP` and `AWS`. 

#### Using Docker

To setup WordPress on LEMP stack using Docker see the [`docker-setup`](https://github.com/bhavin192/wpinstall/tree/master/docker-setup) directory. 

## Licensing

WPInstall is licensed under GNU General Public License v3.0. See [LICENSE](https://github.com/bhavin192/wpinstall/blob/master/LICENSE) for the full license text.
