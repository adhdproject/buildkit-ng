#!/bin/bash

# Time to install Weblabyrinth!

install() {
	if [ -d "/var/www/weblabyrinth" ]; then
		echo "Weblabyrinth is already installed. Exiting."
		exit 2
	fi

	git clone https://bitbucket.org/ethanr/weblabyrinth
	mv weblabyrinth/ /var/www/

	echo "
	Weblabyrinth installed to /var/www/weblabyrinth/"
	exit 0
}

uninstall() {
	if [ ! -d "/var/www/weblabyrinth" ]; then
		echo "Weblabyrinth is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /var/www/weblabyrinth

	echo "
	Weblabyrinth uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Weblabyrinth can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./weblabyrinth-install.sh [-i|--install]
		sudo ./weblabyrinth-install.sh [-u|--uninstall]
		";;
esac
