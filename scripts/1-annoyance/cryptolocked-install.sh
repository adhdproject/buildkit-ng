#!/bin/bash

# Time to install Cryptolocked!

install() {
	if [ -d "/opt/cryptolocked/" ]; then
		echo "Cryptolocked is already installed. Exiting."
		exit 2
	fi
	
	git clone https://bitbucket.org/Zaeyx/cryptolocked.git
	mv cryptolocked/ /opt/
	
	echo "
	Cryptolocked installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/cryptolocked" ]; then
		echo "Cryptolocked is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/cryptolocked

	echo "
	Cryptolocked uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Cryptolocked can only be installed with root or sudo."
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./cryptolocked-install.sh [-i|--install]
		sudo ./cryptolocked-install.sh [-u|--uninstall]
		";;
esac
