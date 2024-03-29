#!/bin/bash

# Time to install Honey Ports!

install() {
	if [ -d "/opt/honeyports/" ]; then
		echo "Honey Ports is already installed. Exiting.";
		exit 2;
	fi

	# The old version on google code is archived, but this version of honeyports-0.4a.py
	# has no differences between the other version, so it shouldn't be a problem.
	git clone https://github.com/adhdproject/honeyports.git
	mv honeyports/ /opt/

	echo "
	Honey Ports installed to /opt/honeyports/!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/honeyports/" ]; then
		echo "Honey Ports is not installed. Nothing to do.";
		exit 2;
	fi

	rm -rf /opt/honeyports

	echo "
	Honey Ports uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Honey Ports can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./honeyports-install.sh [-i|--install]
		sudo ./honeyports-install.sh [-u|--uninstall]
		";;
esac
