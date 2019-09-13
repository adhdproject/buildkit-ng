#!/bin/bash

# Time to install Bear Trap!

if [ `whoami` != 'root' ]; then
        echo "Bear Trap can only be installed with root or sudo.";
	exit 1
fi

if [ -d "/opt/beartrap/" ]; then
	echo "Bear Trap is already installed. Exiting.";
	exit 2;
fi

git clone https://github.com/chrisbdaemon/beartrap.git
mv beartrap/ /opt/

echo "
Bear Trap installed!"
exit 0
