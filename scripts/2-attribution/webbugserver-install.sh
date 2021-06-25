#!/bin/bash

# Time to install Web Bug Server!

install() {
	if [ -d "/opt/webbugserver" ]; then
		echo "Web Bug Server is already installed. Exiting."
		exit 2
	fi
	
	git clone https://bitbucket.org/ethanr/webbugserver
	mv webbugserver/ /opt/

	echo "
	Web Bug Server installed to /opt/webbugserver/!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/webbugserver" ]; then
		echo "Web Bug Server is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/webbugserver

	echo "
	Web Bug Server uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Web Bug Server can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./webbugserver-install.sh [-i|--install]
		sudo ./webbugserver-install.sh [-u|--uninstall]
		";;
esac
