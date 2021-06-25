#!/bin/bash

# Time to install PHP-HTTP-Tarpit!

install() {
	if [ -d "/opt/PHP-HTTP-Tarpit" ]; then
		echo "PHP-HTTP-Tarpit is already installed. Exiting."
		exit 2
	fi

	git clone https://github.com/msigley/PHP-HTTP-Tarpit.git
	mv PHP-HTTP-Tarpit/ /opt/

	echo "
	PHP-HTTP-Tarpit installed to /opt/PHP-HTTP-Tarpit!"
	exit 0
}

uninstall() {
	if [ ! -d "/opt/PHP-HTTP-Tarpit" ]; then
		echo "PHP-HTTP-Tarpit is not installed. Nothing to do."
		exit 2
	fi

	rm -rf /opt/PHP-HTTP-Tarpit

	echo "
	PHP-HTTP-Tarpit uninstalled!"
	exit 0
}

if [ `whoami` != 'root' ]; then
        echo "PHP-HTTP-Tarpit can only be installed or uninstalled with root or sudo.";
	exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./phphttptarpit-install.sh [-i|--install]
		sudo ./phphttptarpit-install.sh [-u|--uninstall]
		";;
esac
