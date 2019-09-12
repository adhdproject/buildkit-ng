#!/bin/bash

if [ `whoami` != 'root' ]; then
	echo "need to run as root, or with sudo"; exit
fi

#get version number
ubuntu_version=`lsb_release -a 2>/dev/null | grep release -i | cut -f2`
if [ -z "$ubuntu_version" ]; then
	ubuntu_version="15.10";
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

echo "Updating Sources"
apt-get update > /dev/null 2>&1

#echo "Installing pre-dependencies"
#while read pa; do
#	if [[ $pa != *"#"* ]]; then
#		apt-get -y install $pa
#	fi
#done < package_list.txt


# Link to auxilliary scripts here!
