#!/bin/bash

# Time to install Sqlite Bug Server!

install() {
	if [ -d "/opt/sqlitebugserver" ]; then
		echo "Sqlite Bug Server is already installed. Exiting."
		exit 2
	fi
	
	git clone https://bitbucket.org/zaeyx/sqlitebugserver
	mv sqlitebugserver/ /opt/

	echo "
	Sqlite Bug Server installed to /opt/sqlitebugserver/!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/sqlitebugserver" ]; then
		echo "Sqlite Bug Server is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/sqlitebugserver

	echo "
	Sqlite Bug Server uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Sqlite Bug Server can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./sqlitebugserver-install.sh [-i|--install]
		sudo ./sqlitebugserver-install.sh [-u|--uninstall]
		";;
esac
