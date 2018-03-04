#/bin/bash

mkdir -p ~/telldus-temp && cd ~/telldus-temp && apt-get --compile source telldus-core
sudo dpkg --install *.deb
#rm -rf ~/telldus-temp
