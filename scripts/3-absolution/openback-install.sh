#!/bin/bash
#Installation of openbac 

install()
{
    if [ -d "/opt/openbac" ]; then
	    echo "openbac is already installed. Exiting.";
	    exit 2
    fi

    
    cp -R ../../old-tools/openbac /opt/

    echo "
    openbac installed!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/openbac" ]; then
	    echo "openbac is not installed. Exiting.";
	    exit 2
    fi

    rm -rf /opt/openbac
    echo "openbac uninstalled."
    exit 0
}



if [ `whoami` != 'root' ]; then
    echo "openbac can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./openback-install.sh [-i|--install]
		sudo ./openback-install.sh [-u|--uninstall]
		";;
esac
