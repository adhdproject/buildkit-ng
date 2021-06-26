#!/bin/bash

# Time to install DenyHosts!

install() {
	if [ ! -z `pip3 freeze | grep DenyHosts` ]; then
		echo "DenyHosts is already installed. Exiting."
		exit 2
	fi

	git clone https://github.com/denyhosts/denyhosts.git
	pushd denyhosts > /dev/null
	pip3 install -r requirements.txt
	pip3 install .
	popd > /dev/null
	rm -rf denyhosts
	
	echo "
	DenyHosts installed as python package!"
	exit 0
}

uninstall() {
	if [ -z `pip3 freeze | grep DenyHosts` ]; then
		echo "DenyHosts is not installed. Nothing to do."
		exit 2
	fi

	pip3 uninstall DenyHosts -y
	echo "Removing denyhosts man page"
	rm /usr/share/man/man8/denyhosts.8

	echo "
	DenyHosts uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "DenyHosts can only be installed with root or sudo."
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./denyhosts-install.sh [-i|--install]
		sudo ./denyhosts-install.sh [-u|--uninstall]
		";;
esac
