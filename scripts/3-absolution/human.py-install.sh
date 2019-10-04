#!/bin/bash
#Installation of human.py 

install()
{
    if [ -d "/opt/human.py" ]; then
    echo "human.py is already installed. Exiting.";
    exit 2
    fi

    
    cp -R ../../old-tools/human.py /opt/

    echo "
    human.py installed!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/human.py" ]; then
    echo "human.py is not installed. Exiting.";
    exit 2
    fi

    cd /opt
    rm -rf human.py
    echo "human.py uninstalled."
    exit 0
}



if [`whoami` != `root`]; then
    echo "human.py can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./human.py-install.sh [-i|--install]
		sudo ./human.py-install.sh [-u|--uninstall]
		";;
esac