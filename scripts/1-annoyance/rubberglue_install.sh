#!/bin/bash

# Time to install Rubberglue!

install() {
	if [ -d "/opt/rubberglue" ]; then
		echo "Rubberglue is already installed. Exiting."
		exit 2
	fi

	git clone https://github.com/adhdproject/rubberglue
	mv rubberglue/ /opt/

	echo "
	Rubberglue installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/rubberglue" ]; then
		echo "Rubberglue is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/rubberglue

	echo "
	Rubberglue uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Rubberglue can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./rubberglue-install.sh [-i|--install]
		sudo ./rubberglue-install.sh [-u|--uninstall]
		";;
esac
