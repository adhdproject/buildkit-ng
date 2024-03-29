#!/bin/bash

# Time to install HoneyBadger!

install() {
	if [ -d "/opt/honeybadger" ]; then
		echo "HoneyBadger is already installed. Exiting."
		exit 2
	fi
	
	git clone https://github.com/adhdproject/honeybadger
	mv honeybadger/ /opt/honeybadger
	pushd /opt/honeybadger/server
	pip3 install -r requirements.txt
	popd

	echo "
	HoneyBadger installed to /opt/honeybadger/!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/honeybadger" ]; then
		echo "HoneyBadger is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/honeybadger

	echo "
	HoneyBadger uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "HoneyBadger can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./honeybadger-install.sh [-i|--install]
		sudo ./honeybadger-install.sh [-u|--uninstall]
		";;
esac
