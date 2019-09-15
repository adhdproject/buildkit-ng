#!/bin/bash

# Time to install Cryptolocked!

if [ `whoami` != 'root' ]; then
        echo "Cryptolocked can only be installed with root or sudo.";
	exit 1
fi

if [ -d "/opt/cryptolocked/" ]; then
	echo "Cryptolocked is already installed. Exiting.";
	exit 2;
fi

git clone https://bitbucket.org/Zaeyx/cryptolocked.git
mv cryptolocked/ /opt/

echo "
Cryptolocked installed!"
exit 0
