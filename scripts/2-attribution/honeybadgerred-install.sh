#!/bin/bash

# Time to install HoneyBadger-Red!

install() {
	if [ -d "/opt/honeybadger-red" ]; then
		echo "HoneyBadger-Red is already installed. Exiting."
		exit 2
	fi

	cp -R ../../old-tools/honeybadger-red/opt/honeybadger-red /opt/
	cp -R ../../old-tools/honeybadger-red/var/honeybadger-red /var/www/

	echo "
	HoneyBadger-Red installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/honeybadger-red" ]; then
		echo "HoneyBadger-Red is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/honeybadger-red
	rm -rf /var/www/honeybadger-red

	echo "
	HoneyBadger-Red uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "HoneyBadger-Red can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./honeybadgerred-install.sh [-i|--install]
		sudo ./honeybadgerred-install.sh [-u|--uninstall]
		";;
esac
