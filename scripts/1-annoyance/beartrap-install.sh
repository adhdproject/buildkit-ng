#!/bin/bash

# Time to install Bear Trap!

install() {
	if [ -d "/opt/beartrap/" ]; then
		echo "Bear Trap is already installed. Exiting.";
		exit 2;
	fi

	git clone https://github.com/chrisbdaemon/beartrap.git
	mv beartrap/ /opt/

	echo "
	Bear Trap installed to /opt/beartrap/!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/beartrap" ]; then
		echo "Bear Trap is not installed. Nothing to do.";
		exit 2;
	fi

	rm -rf /opt/beartrap

	echo "
	Bear Trap uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Bear Trap can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./beartrap-install.sh [-i|--install]
		sudo ./beartrap-install.sh [-u|--uninstall]
		";;
esac
