#/bin/bash

apt-get update
apt-get install apt-utils
apt-get dist-upgrade -qy
apt-get install build-essential wget
apt-get install cmake libconfuse-dev libftdi-dev help2man

