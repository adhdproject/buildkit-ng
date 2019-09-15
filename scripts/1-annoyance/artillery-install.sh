#!/bin/bash

# Time to install Artillery!

install() {
	if [ -d "/var/artillery" ]; then
		echo "Artillery is already installed. Exiting.";
		exit 2;
	fi
	
	git clone https://github.com/BinaryDefense/artillery.git
	pushd artillery > /dev/null
	./setup.py -y
	popd > /dev/null
	rm -rf artillery

	echo "
	Artillery installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/var/artillery" ]; then
		echo "Artillery is not installed. Nothing to do.";
		exit 2;
	fi

	#git clone https://github.com/BinaryDefense/artillery.git
	#pushd artillery > /dev/null
	/var/artillery/setup.py -y
	#popd > /dev/null
	#rm -rf artillery

	echo "
	Artillery uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "Artillery can only be installed with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./artillery-install.sh [-i|--install]
		sudo ./artillery-install.sh [-u|--uninstall]
		";;
esac


