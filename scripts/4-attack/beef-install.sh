#!/bin/bash
#Installation of beef 

install() {
	if [ -d "/opt/beef" ]; then
		echo "BeEF is already installed. Exiting.";
		exit 2;
	fi

	git clone https://github.com/beefproject/beef
	mv beef/ /opt/
	pushd /opt/beef
	./install
	popd

	echo "
	BeEF installed!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/beef" ]; then
		echo "BeEF is not installed. Nothing to do.";
		exit 2;
	fi

	rm -rf /opt/beef

	echo "
	BeEF uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
    echo "BeEF can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./beef-install.sh [-i|--install]
		sudo ./beef-install.sh [-u|--uninstall]
		";;
esac
