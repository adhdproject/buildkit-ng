#!/bin/bash
#Installation of simple-pivot-detect 

install()
{
    if [ -d "/opt/simple-pivot-detect" ]; then
	    echo "simple-pivot-detect is already installed. Exiting.";
	    exit 2
    fi

    
    cp -R ../../old-tools/simple-pivot-detect /opt/

    echo "
    simple-pivot-detect installed!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/simple-pivot-detect" ]; then
	    echo "simple-pivot-detect is not installed. Exiting.";
	    exit 2
    fi

    rm -rf /opt/simple-pivot-detect
    echo "simple-pivot-detect uninstalled."
    exit 0
}



if [ `whoami` != 'root' ]; then
    echo "simple-pivot-detect can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./simple-pivot-detect-install.sh [-i|--install]
		sudo ./simple-pivot-detect-install.sh [-u|--uninstall]
		";;
esac
