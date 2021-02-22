# Wireguard Setup

This repo contains a script to install and configure a WireGuard server on Linux. Currently tailored to Ubuntu or Debian. Along with WireGuard, the script sets up UFW. UFW is then configured to allow SSH and WireGuard by default.

There is also a script to assist with installing the client on a Mac.


### Usage

`./install-wg-host.sh [host ip] [client ip] [dns ip]`

example

`./install-wg-host.sh 192.168.10.1 192.168.10.2 192.168.1.1`
