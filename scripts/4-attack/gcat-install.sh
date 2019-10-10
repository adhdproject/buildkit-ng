#!/bin/bash
#Installation of gcat

install() {
    if [ -d "/opt/gcat" ]; then
	    echo "Gcat is already installed. Exiting.";
	    exit 2
    fi

    git clone https://github.com/byt3bl33d3r/gcat
    mv gcat/ /opt/
    

    echo "
    Gcat installed!"
    exit 0
}

uninstall() {
    if [ ! -d "/opt/gcat" ]; then
	    echo "Gcat is not installed. Exiting.";
	    exit 2
    fi

    rm -rf /opt/gcat
    echo "gcat uninstalled."
    exit 0
}



if [ `whoami` != 'root' ]; then
    echo "Gcat can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./gcat-install.sh [-i|--install]
		sudo ./gcat-install.sh [-u|--uninstall]
		";;
esac
