#!/bin/bash
#Installation of gcat

install()
{
    if [ -d "/opt/java-web-attack" ]; then
    echo "Java-web-app is already installed. Exiting.";
    exit 2
    fi

    git clone https://bitbucket.org/ethanr/java-web-attack
    mv java-web-attack/ /opt/
    

    echo "
    Java-web-app installed!"
    exit 0
}

uninstall()
{
    if [ ! -d "/opt/java-web-app" ]; then
    echo "Gcat is not installed. Exiting.";
    exit 2
    fi

    
    rm -rf /opt/java-web-app
    echo "Java-web-app uninstalled."
    exit 0
}



if [ `whoami` != 'root' ]; then
    echo "Java-web-app can only be installed with root or sudo.";
    exit 1
fi

case "$1" in
	-i|--install)
		install;;
	-u|--uninstall)
		uninstall;;
	*)
		echo "Usage:
		sudo ./java-web-app-install.sh [-i|--install]
		sudo ./java-web-app-install.sh [-u|--uninstall]
		";;
esac
