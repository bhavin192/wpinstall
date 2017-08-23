# WPInstall

![stability-wip](https://img.shields.io/badge/stability-work_in_progress-lightgrey.svg)


This script configures LEMP stack on Ubuntu machine and installs the latest WordPress.

### How to use.

- Clone the repo in a directory.
```sh
$ git clone https://github.com/bhavin192/wpinstall
```

- Make the script executable and run it. It will ask for domain name of the site.

```sh
$ sudo chmod +x wpinstall.sh
$ sudo ./wpinstall.sh
```

This script works but has lot of work to be done in order to ensure if WordPress is installed correctly. Tested on Ubuntu 16.04 instance of GCP and AWS. 

## Licensing

WPInstall is licensed under GNU General Public License v3.0. See [LICENSE](https://github.com/bhavin192/wpinstall/blob/master/LICENSE) for the full license text.
