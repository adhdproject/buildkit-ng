#!/bin/bash

# Time to install Invisiport!

install() {
	if [ -d "/opt/invisiport" ]; then
		echo "Invisiport is already installed. Exiting."
		exit 2
	fi
	
	git clone https://bitbucket.org/Zaeyx/invisiport
	mv invisiport/ /opt/

	echo "
	Invisiport installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/invisiport" ]; then
		echo "Invisiport is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/invisiport

	echo "
	Invisiport uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Invisiport can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./invisiport-install.sh [-i|--install]
		sudo ./invisiport-install.sh [-u|--uninstall]
		";;
esac
