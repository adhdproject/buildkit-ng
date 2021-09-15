#!/bin/bash

# Time to install RITA!

install() {
	if [ -d "/opt/rita" ]; then
		echo "RITA is already installed. Exiting."
		exit 2
	fi
	
	git clone https://github.com/activecm/rita/
	mv rita/ /opt/

	pushd /opt/rita/ > /dev/null
	
	./install.sh

	popd

	echo "
	RITA installed to /opt/rita/ and /usr/local/bin
	Zeek installed to /opt/zeek
	Mongodb installed"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/rita" ]; then
		echo "RITA is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/rita

	echo "
	RITA uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "RITA can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./rita-install.sh [-i|--install]
		sudo ./rita-install.sh [-u|--uninstall]
		";;
esac
