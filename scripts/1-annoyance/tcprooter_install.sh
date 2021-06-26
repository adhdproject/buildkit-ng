#!/bin/bash

# Time to install TCPRooter!

install() {
	if [ -d "/opt/tcprooter" ]; then
		echo "TCPRooter is already installed. Exiting."
		exit 2
	fi

	cp -R ../../old-tools/tcprooter /opt/

	echo "
	TCPRooter installed to /opt/tcprooter/"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/tcprooter" ]; then
		echo "TCPRooter is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/tcprooter

	echo "
	TCPRooter uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "TCPRooter can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./tcprooter-install.sh [-i|--install]
		sudo ./tcprooter-install.sh [-u|--uninstall]
		";;
esac
