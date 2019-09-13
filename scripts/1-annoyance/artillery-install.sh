#!/bin/bash

# Time to install Artillery!

if [ `whoami` != 'root' ]; then
        echo "Artillery can only be installed with root or sudo.";
	exit 1
fi

if [ -d "/var/artillery" ]; then
	echo "Artillery is already installed. Exiting.";
	exit 2;
fi

git clone https://github.com/BinaryDefense/artillery.git
pushd artillery > /dev/null
./setup.py -y
popd > /dev/null
rm -rf artillery

echo "
Artillery installed!"
exit 0
