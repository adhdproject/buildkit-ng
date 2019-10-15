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

	printf "\n[+] Finished installing prerequisites\n"
}



install() {
	printf "\n[+] Installing annoyance tools\n"
	pushd 1-annoyance
	for f in *.sh; do
		bash $f -i
	done
	popd

	printf "\n[+] Finished installing annoyance tools\n"
	
	printf "\n[+] Installing Attribution tools\n\n"
	pushd 2-attribution
	for f in *.sh; do
		bash $f -i
	done
	popd

	printf "\n[+] Finished installing attribution tools\n"

	printf "\n[+] Installing Absolution tools\n\n"
	pushd 3-absolution
	for f in *.sh; do
		bash $f -i
	done
	popd

	printf "\n[+] Finished installing absolution tools\n"

	printf "\n[+] Installing Attack tools\n\n"
	pushd 4-attack
	for f in *.sh; do
		bash $f -i
	done
	popd

	printf "\n[+] Finished installing attack tools\n"
}



uninstall() {
	printf "\n[+] Uninstalling annoyance tools\n"
	pushd 1-annoyance
	for f in *.sh; do
		bash $f -u
	done
	popd

	printf "\n[+] Finished uninstalling annoyance tools\n"
	
	printf "\n[+] Uninstalling Attribution tools\n\n"
	pushd 2-attribution
	for f in *.sh; do
		bash $f -u
	done
	popd

	printf "\n[+] Finished uninstalling attribution tools\n"

	printf "\n[+] Uninstalling Absolution tools\n\n"
	pushd 3-absolution
	for f in *.sh; do
		bash $f -u
	done
	popd

	printf "\n[+] Finished uninstalling absolution tools\n"

	printf "\n[+] Uninstalling Attack tools\n\n"
	pushd 4-attack
	for f in *.sh; do
		bash $f -u
	done
	popd

	printf "\n[+] Finished uninstalling attack tools\n"
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
		install
		echo "[+] Done installing ADHD!";;
        -u|--uninstall)
                echo "[+] Uninstalling ADHD"
                uninstall
		echo "[+] Done uninstalling ADHD!";;
        *)
                echo "Usage:
		sudo ./adhd-install.sh [-i|--install]
		sudo ./adhd-install.sh [-u|--uninstall]";;
esac
