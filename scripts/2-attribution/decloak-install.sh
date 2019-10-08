#!/bin/bash

# Time to install Decloak!

install() {
	if [ -d "/opt/decloak" ]; then
		echo "Decloak is already installed. Exiting."
		exit 2
	fi

	cp -R ../../old-tools/decloak/opt/decloak /opt/
	cp -R ../../old-tools/decloak/var/decloak /var/www/

	echo "
	Decloak installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/decloak" ]; then
		echo "Decloak is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/decloak
	rm -rf /var/www/decloak

	echo "
	Decloak uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Decloak can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./decloak-install.sh [-i|--install]
		sudo ./decloak-install.sh [-u|--uninstall]
		";;
esac
