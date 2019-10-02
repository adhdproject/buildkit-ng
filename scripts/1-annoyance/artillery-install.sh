#!/bin/bash

# Time to install Artillery!

runcmd() {
	echo $1
        $1 2>/dev/null;
        errors=$(($errors+$?));
}

install() {
	errors=0

	if [ -d "/var/artillery" ]; then
		return 255
	fi
	
	runcmd "git clone https://github.com/BinaryDefense/artillery.git"
	runcmd "pushd artillery"
	runcmd "./setup.py -y"
	runcmd "popd"
	runcmd "rm -rf artillery"

	return $errors
}

uninstall() {
	errors=0

	if [ ! -d "/var/artillery" ]; then
		return 255
	fi

	runcmd "/var/artillery/setup.py -y"

	return $errors
}

if [ `whoami` != 'root' ]; then
        echo "Artillery can only be installed or uninstalled with root or sudo."
	exit 1
fi

case "$1" in
	-i|--install)
		echo "Installing Artillery..."
		install
		ret=$?
		if [[ $ret > 0 && $ret < 255 ]]; then
			echo
			echo "Something went wrong while installing Artillery."
		elif [ $ret = 255 ]; then
			echo
			echo "Artillery is already installed. Exiting."
		else
			echo
			echo "Artillery installed!"
		fi;;
	-u|--uninstall)
		echo "Uninstalling Artillery..."
		uninstall
		ret=$?
		if [[ $ret > 0 && $ret < 255 ]]; then
			echo
			echo "Something went wrong while uninstall Artillery."
		elif [ $ret = 255 ]; then
			echo
			echo "Artillery is not installed. Nothing to do."
		elif [ $ret = 0 ]; then
			echo
			echo "Artillery uninstalled!"
		fi;;
	*)
		echo "Usage:
		sudo ./artillery-install.sh [-i|--install]
		sudo ./artillery-install.sh [-u|--uninstall]
		";;
esac
