#!/bin/bash

# Time to install PSAD!

install() {
	if [ -d "/opt/psad" ]; then
		echo "PSAD is already installed. Exiting."
		exit 2
	fi

	git clone https://github.com/mrash/psad.git
	mv psad/ /opt/
	/opt/psad/install.pl

	echo "
	PSAD installed!"
	exit 0
}

uninstall() {
	if [ ! -f "/opt/psad" ]; then
		echo "PSAD is not installed. Nothing to do."
		exit 2
	fi

	/opt/psad/install.pl -uninstall
	rm -rf /opt/psad

	echo "
	PSAD uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "PSAD can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./psad-install.sh [-i|--install]
		sudo ./psad-install.sh [-u|--uninstall]
		";;
esac
