#!/bin/bash
#Installation of sweeper 

install()
{
    if [ -d "/opt/sweeper" ]; then
	    echo "sweeper is already installed. Exiting.";
	    exit 2
    fi

    
    cp -R ../../old-tools/sweeper /opt/

    echo "
    sweeper installed!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/sweeper" ]; then
	    echo "sweeper is not installed. Exiting.";
	    exit 2
    fi

    rm -rf /opt/sweeper
    echo "sweeper uninstalled."
    exit 0
}



if [ `whoami` != 'root' ]; then
    echo "sweeper can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./sweeper-install.sh [-i|--install]
		sudo ./sweeper-install.sh [-u|--uninstall]
		";;
esac
