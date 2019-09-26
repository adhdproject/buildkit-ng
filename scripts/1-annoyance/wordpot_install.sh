#!/bin/bash

# Time to install Wordpot!

install() {
	if [ -d "/opt/wordpot" ]; then
		echo "Wordpot is already installed. Exiting."
		exit 2
	fi

	git clone https://github.com/gbrindisi/wordpot
	mv wordpot/ /opt/
	pushd /opt/wordpot
	pip install -r requirements.txt
	popd

	echo "
	Wordpot installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/wordpot" ]; then
		echo "Wordpot is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/wordpot

	echo "
	Wordpot uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Wordpot can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./wordpot-install.sh [-i|--install]
		sudo ./wordpot-install.sh [-u|--uninstall]
		";;
esac
