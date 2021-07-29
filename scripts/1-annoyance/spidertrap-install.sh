#!/bin/bash

# Time to install Spidertrap!

install() {
	if [ -d "/opt/spidertrap" ]; then
		echo "Spidertrap is already installed. Exiting."
		exit 2
	fi

	git clone https://github.com/adhdproject/spidertrap
	mv spidertrap/ /opt/

	echo "
	Spidertrap installed to /opt/spidertrap/!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/spidertrap" ]; then
		echo "Spidertrap is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/spidertrap

	echo "
	Spidertrap uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Spidertrap can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./spidertrap-install.sh [-i|--install]
		sudo ./spidertrap-install.sh [-u|--uninstall]
		";;
esac
