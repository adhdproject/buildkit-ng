#!/bin/bash

# Time to install PHP-HTTP-Tarpit!

install() {
	if [ -d "/opt/portspoof" ]; then
		echo "portspoof is already installed. Exiting."
		exit 2
	fi

	git clone https://github.com/drk1wi/portspoof.git
	#...

	echo "
	Portspoof installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/portspoof" ]; then
		echo "Portspoof is not installed. Nothing to do."
		exit 2
	fi

	#...

	echo "
	Portspoof uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Portspoof can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./portspoof-install.sh [-i|--install]
		sudo ./portspoof-install.sh [-u|--uninstall]
		";;
esac
