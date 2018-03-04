#/bin/bash

wget http://s3.eu-central-1.amazonaws.com/download.telldus.com/debian/telldus-public.key
apt-key add telldus-public.key

cp ./telldus.list /etc/apt/sources.list.d/
apt-get update
apt-get install doxygen -qy
apt-get build-dep telldus-core