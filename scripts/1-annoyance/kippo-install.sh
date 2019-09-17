#!/bin/bash

# Time to install Kippo!

install() {
	if [ -d "/opt/kippo" ]; then
		echo "Kippo is already installed. Exiting."
		exit 2
	fi
	
	git clone https://github.com/desaster/kippo.git
	mv kippo/ /opt/

	echo "
	Kippo installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/kippo" ]; then
		echo "Kippo is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/kippo

	echo "
	Kippo uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Kippo can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./kippo-install.sh [-i|--install]
		sudo ./kippo-install.sh [-u|--uninstall]
		";;
esac
