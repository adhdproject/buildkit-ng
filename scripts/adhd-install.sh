#!/bin/bash



setup() {
	echo "This script will need to associate a user account with all the tools."
	echo "Enter the name of a user account you want associated with the install."
	echo "If you enter a new account name, it will be created."
	echo -n "Enter account name [adhd]: "
	read account
	echo

	if [ ${#account} == 0 ]; then
		account="adhd"
	fi
	
	grepout=`grep "^$account:x" /etc/passwd`

	echo "Creating user $account..."
	if [ ${#grepout} == 0 ]; then
		echo "[+] Script is creating user: $account"
		adduser $account
	else
		echo "[!] User $account already exists."
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

	echo "Detected that the operating system is $distro, and will use $package_manager as the system package manager to install dependencies."
	echo "If this is incorrect, enter the correct package manager."
	echo -n "Package manager [$package_manager]: "
	read package_manager_input
	echo
	
	if [ ${#package_manager_input} != 0 ]; then
		package_manager=$package_manager_input
	fi
	
	echo "[+] Updating sources"
	$package_manager update > /dev/null 2>&1
	echo "[+] Sources updated"
	
	echo "[+] Installing prerequisite packages for ADHD"
	while read prereq; do
		if [[ $prereq != *"#"* ]]; then
			$package_manager -y install $prereq
		fi
	done < prerequisites.txt

	echo
	echo "[+] Finished installing prerequisites"
	echo
}



install() {
	# Link to auxilliary scripts here!
	echo "[+] Installing annoyance tools"
	for f in 1-annoyance/*.sh; do
		./$f -i
	done
	
	echo
	echo "[+] Finished installing annoyance tools"
	echo
	
	echo "[+] Installing Attribution tools"
	for f in 2-attribution/*.sh; do
		./$f -i
	done
	
	echo
	echo "[+] Finished installing attribution tools"
	echo
}



if [ `whoami` != 'root' ]; then
	echo "ADHD can only be installed as root or with sudo."
	exit
fi

echo "###############################"
echo "#     _    ____  _   _ ____   #"
echo "#    / \  |  _ \| | | |  _ \  #"
echo "#   / _ \ | | | | |_| | | | | #"
echo "#  / ___ \| |_| |  _  | |_| | #"
echo "# /_/   \_\____/|_| |_|____/  #"
echo "#=============================#"
echo "#    blackhillsinfosec.com    #"
echo "###############################"


case "$1" in
	-i|--install)
		echo "[+] Installing ADHD"
		setup
		install;;
        -u|--uninstall)
                echo "[+] Uninstalling ADHD"
                uninstall;;
        *)
                echo "Usage:
		sudo ./adhd-install.sh [-i|--install]
		sudo ./adhd-install.sh [-u|--uninstall]";;
esac
