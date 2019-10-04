#!/bin/bash
#Installation of lockdown

install()
{
    if [ -d "/opt/lockdown" ]; then
    echo "lockdown is already installed. Exiting.";
    exit 2
    fi

    
    cp -R ../../old-tools/lockdown /opt/

    echo "
    lockdown installed!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/lockdown" ]; then
    echo "lockdown is not installed. Exiting.";
    exit 2
    fi

    cd /opt
    rm -rf lockdown
    echo "lockdown uninstalled."
    exit 0
}



if [`whoami` != `root`]; then
    echo "lockdown can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./lockdown-install.sh [-i|--install]
		sudo ./lockdown-install.sh [-u|--uninstall]
		";;
esac