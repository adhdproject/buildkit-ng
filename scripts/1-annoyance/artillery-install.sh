#!/bin/bash

# Time to install Artillery!

runcmd() {
	echo "Running command: $1"
        $1 2>/dev/null;
        errors=$((errors+$?));
}

install() {
	errors=0

	if [ -d "/var/artillery" ]; then
		return 255
	fi
	
	runcmd "git clone https://github.com/BinaryDefense/artillery.git"
	if [ $errors -eq 0 ]; then
		runcmd "pushd artillery"
		runcmd "./setup.py -y"
		runcmd "popd"
		runcmd "rm -rf artillery"
	fi

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

if [ "$(whoami)" != 'root' ]; then
        echo "Artillery can only be installed or uninstalled with root or sudo."
	exit 1
fi

case "$1" in
	-i|--install)
		echo "Installing Artillery..."
		install
		ret=$?
		if [[ $ret -gt 0 && $ret -lt 255 ]]; then
			echo
			echo "Something went wrong while installing Artillery."
		elif [ $ret -eq 255 ]; then
			echo
			echo "Artillery is already installed. Exiting."
		elif [ $ret -eq 0 ]; then
			echo
			echo "Artillery installed!"
		fi;;
	-u|--uninstall)
		echo "Uninstalling Artillery..."
		uninstall
		ret=$?
		if [[ $ret -gt 0 && $ret -lt 255 ]]; then
			echo
			echo "Something went wrong while uninstall Artillery."
		elif [ $ret -eq 255 ]; then
			echo
			echo "Artillery is not installed. Nothing to do."
		elif [ $ret -eq 0 ]; then
			echo
			echo "Artillery uninstalled!"
		fi;;
	*)
		echo "Usage:
		sudo ./artillery-install.sh [-i|--install]
		sudo ./artillery-install.sh [-u|--uninstall]
		";;
esac
