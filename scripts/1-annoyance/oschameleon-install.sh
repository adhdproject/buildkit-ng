#!/bin/bash

# Time to install OSChameleon!

install() {
	if [ -d "/opt/oschameleon" ]; then
		echo "OSChameleon is already installed. Exiting."
		exit 2
	fi
	
	#pip install gevent # Prereq not in repo's requirements.txt file

	cp -R ../../old-tools/oschameleon /opt/

	echo "
	OSChameleon installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/oschameleon" ]; then
		echo "OSChameleon is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/oschameleon

	echo "
	OSChameleon uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "OSChameleon can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./oschameleon-install.sh [-i|--install]
		sudo ./oschameleon-install.sh [-u|--uninstall]
		";;
esac
