#!/bin/bash

# Time to install Portspoof!

install() {
	if [ -f "/usr/local/bin/portspoof" ]; then
		echo "Portspoof is already installed. Exiting."
		exit 2
	fi

	git clone https://github.com/drk1wi/portspoof.git
	pushd portspoof
	./configure
	make && make install
	popd
	rm -rf portspoof

	echo "
	Portspoof installed to /usr/local/bin/portspoof!"
	exit 0
}

uninstall() {
	if [ ! -f "/usr/local/bin/portspoof" ]; then
		echo "Portspoof is not installed. Nothing to do."
		exit 2
	fi

	git clone https://github.com/drk1wi/portspoof.git
	pushd portspoof
	./configure
	sudo make uninstall
	popd
	rm -rf portspoof

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
