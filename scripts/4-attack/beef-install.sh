#!/bin/bash
#Installation of beef 

if [`whoami` != `root`]; then
    echo "BeEF can only be installed with root or sudo.";
    exit 1
fi

if [ -d "/opt/beef" ]; then
    echo "BeEF is already installed. Exiting.";
fi

git clone https://github.com/beefproject/beef
mv beef/ /opt/
cd /opt/beef
./install

echo "
BeEF installed!"
exit 0
