#!/bin/bash

# Time to install Jar-Combiner!

install() {
	if [ -d "/opt/jar-combiner" ]; then
		echo "Jar-Combiner is already installed. Exiting."
		exit 2
	fi
	
	git clone https://bitbucket.org/ethanr/jar-combiner
	mv jar-combiner/ /opt/

	echo "
	Jar-Combiner installed to /opt/jar-combiner/!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/jar-combiner" ]; then
		echo "Jar-Combiner is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/jar-combiner

	echo "
	Jar-Combiner uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Jar-Combiner can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./jarcombiner-install.sh [-i|--install]
		sudo ./jarcombiner-install.sh [-u|--uninstall]
		";;
esac
