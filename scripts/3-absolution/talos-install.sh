#!/bin/bash
#Installation of TALOS 

install()
{
    if [ -d "/opt/TALOS" ]; then
    echo "TALOS is already installed. Exiting.";
    exit 2
    fi

    
    cp -R ../../old-tools/TALOS /opt/

    echo "
    TALOS installed!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/TALOS" ]; then
    echo "TALOS is not installed. Exiting.";
    exit 2
    fi

    cd /opt
    rm -rf TALOS
    echo "TALOS uninstalled."
    exit 0
}



if [`whoami` != `root`]; then
    echo "TALOS can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./talos-install.sh [-i|--install]
		sudo ./talos-install.sh [-u|--uninstall]
		";;
esac