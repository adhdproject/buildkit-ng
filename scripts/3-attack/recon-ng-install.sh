#!/bin/bash
#Installation of recon-ng 

install()
{
    if [ -d "/opt/recon-ng" ]; then
    echo "Recon-ng is already installed. Exiting.";
    exit 2
    fi

    git clone https://github.com/lanmaster53/recon-ng
    mv recon-ng/ /opt/
    

    echo "
    Recon-ng installed to /opt/recon-ng/!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/recon-ng" ]; then
    echo "Recon-ng is not installed. Exiting.";
    exit 2
    fi

    
    rm -rf /opt/recon-ng
    echo "recon-ng uninstalled."
    exit 0
}



if [ `whoami` != 'root' ]; then
    echo "recon-ng can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./recon-ng-install.sh [-i|--install]
		sudo ./recon-ng-install.sh [-u|--uninstall]
		";;
esac
