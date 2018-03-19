#!/bin/bash

echo
echo "Telldus-core install script for Raspbian-lite"
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run with sudo. Use:"
   echo "    sudo ${0} ${*}" 1>&2
   exit 1
fi
sudo raspi-config
echo
echo "Running apt-get preparation"
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get install dirmngr
sudo apt-get install tree
#Stable version
#sudo sh -c 'echo " deb http://download.telldus.com/debian/ stable main" >> /etc/apt/sources.list'
#sudo sh -c 'echo " deb https://s3.eu-central-1.amazonaws.com/download.telldus.com stable main" >> /etc/apt/sources.list'
# Latest version
# NOTE: Unstable beta seems to work without libftdi1
sudo sh -c 'echo " deb https://s3.eu-central-1.amazonaws.com/download.telldus.com unstable main" >> /etc/apt/sources.list'
sudo apt-key adv --fetch-keys http://download.telldus.com/debian/telldus-public.key
sudo apt-get update
# NOTE: No need for libftdi according to: https://forum.telldus.com/viewtopic.php?f=15&t=4879
#sudo apt-get install -y telldus-core libftdi1
sudo apt-get install -y telldus-core


sudo cat >> ./install-tellstick-snoop.sh <<'EOF'
#!/bin/bash
echo
echo "jstick-snoop install script for Raspbian-lite"
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run with sudo. Use:"
   echo "    sudo ${0} ${*}" 1>&2
   exit 1
fi
echo

#sudo apt-get install -y git
#mkdir github && cd github
#git clone https://github.com/juppinet/jstick.git
sudo sh -c 'echo "#!/bin/bash\ncd jstick;java -classpath jna-4.1.0.jar:commons-logging-1.2.jar:jstick-api-1.7.jar net.jstick.Snoop" >> ./snoop.sh'
chmod +x snoop.sh
sudo apt-get install -y openjdk-9-jre-headless
mkdir jstick
cd jstick
wget https://github.com/juppinet/jstick/raw/master/target/jstick-api-1.7.jar
wget https://maven.java.net/content/repositories/releases/net/java/dev/jna/jna/4.1.0/jna-4.1.0.jar
wget http://apache.mirrors.spacedump.net//commons/logging/binaries/commons-logging-1.2-bin.zip
unzip commons-logging-1.2-bin.zip;mv commons-logging-1.2/commons-logging-1.2.jar .;rm -rf commons-logging-1.2 commons-logging-1.2-bin.zip

EOF
chmod +x ./install-tellstick-snoop.sh

echo "Creating script: tellstick-usb-prepare.sh"
sudo cat >> ./tellstick-usb-prepare.sh <<'EOFF'
#!/bin/bash
echo
echo "Telldus-core USB prepare script for Raspbian-lite"
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run with sudo. Use:"
   echo "    sudo ${0} ${*}" 1>&2
   exit 1
fi
echo
echo "Running USB preparation"
lsusb

sudo modprobe ftdi_sio vendor=0x1781 product=0x0c31
sudo cat >> /etc/modules <<'EOF'
ftdi_sio vendor=0x1781 product=0x0c31
EOF
EOFF
chmod +x ./tellstick-usb-prepare.sh

echo "Creating script: telldus-restart.sh"
sudo cat >> ./telldus-restart.sh <<'EOF'
#!/bin/bash
echo
echo "Restarting telldus daemon"
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run with sudo. Use:"
   echo "    sudo ${0} ${*}" 1>&2
   exit 1
fi
echo
sudo systemctl restart telldusd
systemctl status telldusd
tdtool --list
EOF
chmod +x ./telldus-restart.sh

echo "Creating script: edit-tellstick-conf.sh"
sudo cat >> ./edit-tellstick-conf.sh <<'EOF'
#!/bin/bash
echo
echo "Editing telldus configuration"
echo
nano /etc/tellstick.conf
echo "Run sudo ./telldusd-restart.sh"
EOF
chmod +x ./edit-tellstick-conf.sh

# NOTE: No need for usb-prepare when running without libftdi1
#sudo ./tellstick-usb-prepare.sh

echo
echo "Installation done."
echo
echo "Replace configuration at /etc/tellstick.conf"
echo "Run ./edit-tellstick-conf.sh"
echo "Run sudo ./telldusd-restart.sh to restart after editing config"
echo "Run sudo ./install-tellstick-snoop.sh to install jstick based tellstick sniffer."
echo
