#!/bin/bash
#Installation of ghostwriting 

install()
{
    if [ -d "/opt/ghostwriting" ]; then
    echo "Ghostwriting is already installed. Exiting.";
    exit 2
    fi

    
    cp -R ../../old-tools/ghostwriting /opt/

    echo "
    Ghostwriting installed!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/ghostwriting" ]; then
    echo "Ghostwriting is not installed. Exiting.";
    exit 2
    fi

    
    rm -rf /opt/ghostwriting
    echo "Ghostwriting uninstalled."
    exit 0
}



if [ `whoami` != 'root' ]; then
    echo "Ghostwriting can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./ghostwriting-install.sh [-i|--install]
		sudo ./ghostwriting-install.sh [-u|--uninstall]
		";;
esac
