#!/bin/bash

if [ `whoami` != 'root' ]; then
	echo "need to run as root, or with sudo"; exit
fi

echo -n "###############################
#     _    ____  _   _ ____   #
#    / \  |  _ \| | | |  _ \  #
#   / _ \ | | | | |_| | | | | #
#  / ___ \| |_| |  _  | |_| | #
# /_/   \_\____/|_| |_|____/  #
#=============================#
#    blackhillsinfosec.com    #
###############################

This script will need to associate a user account with all the tools.
Enter the name of a user account you want associated with the install.
If you enter a new account name... It will be created.
Enter account name [adhd]: "
read account
echo

if [ ${#account} == 0 ]; then
	account="adhd"
fi

grepout=`grep "^$account:x" /etc/passwd`

echo "Creating user $account..."
if [ ${#grepout} == 0 ]; then
	echo "Script is creating user: $account"
	adduser $account
else
	echo "User $account already exists."
fi
echo

#get Linux version, determine package manager:

distro=`lsb_release -is`
package_manager=""
if [ $distro == 'Ubuntu' ]; then
	package_manager=apt-get
elif [ $distro == 'Fedora' ]; then
	package_manager=dnf
elif [ $distro == 'CentOS' ]; then
	package_manager=yum
else
	echo "Unknown Linux distribution."
	exit 1
fi

echo -n "Detected that the operating system is $distro, and will use $package_manager as the system package manager to install dependencies.
If this is incorrect, enter the correct package manager.
Package manager [$package_manager]: "
read package_manager_input
echo

if [ ${#package_manager_input} != 0 ]; then
	package_manager=$package_manager_input
fi

echo "========== Updating sources =========="
$package_manager update > /dev/null 2>&1
echo "========== Sources updated =========="

echo "========== Installing prerequisite packages for ADHD =========="
while read prereq; do
	if [[ $prereq != *"#"* ]]; then
		$package_manager -y install $prereq
	fi
done < prerequisites.txt
echo "========== Finished installing prerequisites =========="
echo

# Link to auxilliary scripts here!
echo "========== Installing annoyance tools =========="
for f in 1-annoyance/*.sh; do
	echo "$f"
done
echo "========== Finished installing annoyance tools =========="
echo
