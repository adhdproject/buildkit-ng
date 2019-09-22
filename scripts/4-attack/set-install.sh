#!/bin/bash
#Installation of set

install()
{
    if [ -d "/opt/social-engineer-toolkit" ]; then
    echo "social-engineer-toolkit is already installed. Exiting.";
    exit 2
    fi

    git clone https://github.com/trustedsec/social-engineer-toolkit
    mv social-engineer-toolkit/ /opt/
    

    echo "
    social-engineer-toolkit installed!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/social-engineer-toolkit" ]; then
    echo "social-engineer-toolkit is not installed. Exiting.";
    exit 2
    fi

    cd /opt
    rm -rf social-engineer-toolkit
    echo "social-engineer-toolkit uninstalled."
    exit 0
}



if [`whoami` != `root`]; then
    echo "social-engineer-toolkit can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./set-install.sh [-i|--install]
		sudo .set-install.sh [-u|--uninstall]
		";;
esac