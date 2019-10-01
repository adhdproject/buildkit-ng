#!/bin/bash

# Time to install Docz.py!

install() {
	if [ -d "/opt/docz.py" ]; then
		echo "Docz.py is already installed. Exiting."
		exit 2
	fi
	
	git clone https://bitbucket.org/Zaeyx/docz.py
	mv docz.py/ /opt/

	echo "
	Docz.py installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/docz.py" ]; then
		echo "Docz.py is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/docz.py

	echo "
	Docz.py uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Docz.py can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./docz.py-install.sh [-i|--install]
		sudo ./docz.py-install.sh [-u|--uninstall]
		";;
esac
