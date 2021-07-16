#!/bin/bash


# Global Variables
path="."

function whiptail_post_process(){
	exit_code=$1

	if [ $exit_code -ne 0 ]; then
		exit $exit_code
	fi
}

setup_gui(){
	# need to install whiptail if it isn't present


	local acct_msg_1="This script will need to associate a user account with all the tools.\
	Enter the name of a user you would like to be associated with the install.\
	If you enter a new account name, it will be created.
	
	"

	account=$(whiptail --title User --inputbox "$acct_msg_1" 15 78 "adhd" 3>&2 2>&1 1>&3)

	whiptail_post_process $?

	if [ ${#account} == 0 ]; then
		account="adhd"
	fi

	grepout=`grep "^$account:x" /etc/passwd`

	if [ ${#grepout} == 0 ]; then
		adduser $account
	fi


	#=====================Determine Package Manager=====================#

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

	pkg_msg="Detected that the operating system is $distro, and will use\
	 $package_manager as the system package manager to install dependencies.\
	 If this is incorrect, enter the correct package manager.
	 
	 "

	package_manager=$(whiptail --title "Package Manager Selection" --inputbox "$pkg_msg" 15 78 "$package_manager" 3>&2 2>&1 1>&3)

	whiptail_post_process $?

	$package_manager update | whiptail --gauge "Updating Sources. Progress bar won't update." 10 50 40


	#=====================Install Pre-reqs=====================#
	pushd $path > /dev/null

	count=$(wc -l prerequisites.txt |cut -d " " -f1)

	local completed=0

	local step=$((100 / $count))

	while read prereq; do
		if [[ $prereq != *"#"* ]]; then
			$package_manager -y install $prereq | whiptail --gauge "Installing $prereq" 10 50 $completed
			completed=$(($completed + $step))
		fi

	done < prerequisites.txt

	popd > /dev/null
}


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

	pushd $path > /dev/null

	while read prereq; do
		if [[ $prereq != *"#"* ]]; then
			$package_manager -y install $prereq
		fi
	done < prerequisites.txt

	popd

	printf "\n[+] Finished installing prerequisites\n"
}



install() {
	printf "\n[+] Installing annoyance tools\n"
	pushd $path/1-annoyance
	for f in *.sh; do
		bash $f -i
	done
	popd

	printf "\n[+] Finished installing annoyance tools\n"
	
	printf "\n[+] Installing Attribution tools\n\n"
	pushd $path/2-attribution
	for f in *.sh; do
		bash $f -i
	done
	popd

	printf "\n[+] Finished installing attribution tools\n"

	printf "\n[+] Installing Attack tools\n\n"
	pushd $path/3-attack
	for f in *.sh; do
		bash $f -i
	done
	popd

	printf "\n[+] Finished installing attack tools\n"
}



uninstall() {
	printf "\n[+] Uninstalling annoyance tools\n"
	pushd $path/1-annoyance
	for f in *.sh; do
		bash $f -u
	done
	popd

	printf "\n[+] Finished uninstalling annoyance tools\n"
	
	printf "\n[+] Uninstalling Attribution tools\n\n"
	pushd $path/2-attribution
	for f in *.sh; do
		bash $f -u
	done
	popd

	printf "\n[+] Finished uninstalling attribution tools\n"

	printf "\n[+] Uninstalling Attack tools\n\n"
	pushd $path/3-attack
	for f in *.sh; do
		bash $f -u
	done
	popd

	printf "\n[+] Finished uninstalling attack tools\n"
}

# Sets the proper working directory for bash so that the installation script can be executed from anywhere on the machine.
set_proper_cwd() {
	# Thanks to ndim: https://stackoverflow.com/questions/3349105/how-can-i-set-the-current-working-directory-to-the-directory-of-the-script-in-ba#3355423 
	path="$(dirname "$0")"
}

function collect_info(){
	#Initialize empty array
	files=()

	local tool_category=$1

	#Iterate through all files ending in .sh in directory and add to array
	for file in *.sh;
	do
		files+=("$file")
		files+=("$mode?")
		files+=("ON")
	done


	TOOLS=$(whiptail --title "$tool_category Tools $mode" --checklist "Choose" 16 78 10 "${files[@]}" 3>&2 2>&1  1>&3)

	whiptail_post_process $?

}

# Function to perform install or uninstall action when in gui mode
function perform_action(){
	another=($TOOLS)
	local length=${#another[@]}

	local ing="ing"

	local completed=0

	local step=$((100 / $length))

	for file in  "${another[@]}";
	do
		local file_name=$(echo "$file" | tr -d '"')
		bash $file_name $1 2>&1 |grep "" | whiptail --gauge "$mode$ing $file_name" 10 50 $completed
		completed=$(($completed + $step))
	done
}

function gui_mode(){
	pushd ./1-annoyance/ > /dev/null
	collect_info "Annoyance"
	perform_action $1
	popd > /dev/null


	pushd ./2-attribution/ > /dev/null
	collect_info "Attribution"
	perform_action $1
	popd > /dev/null


	pushd ./3-attack/ > /dev/null
	collect_info "Attack"
	perform_action $1
	popd > /dev/null
}


if [ `whoami` != 'root' ]; then
	echo "ADHD can only be installed as root or with sudo."
	exit
fi


print_cli_banner(){
	echo "###############################"
	echo "#     _    ____  _   _ ____   #"
	echo "#    / \  |  _ \| | | |  _ \  #"
	echo "#   / _ \ | | | | |_| | | | | #"
	echo "#  / ___ \| |_| |  _  | |_| | #"
	echo "# /_/   \_\____/|_| |_|____/  #"
	echo "#=============================#"
	echo "#    blackhillsinfosec.com    #"
	echo "###############################"
}

set_proper_cwd

function use_cli(){
	print_cli_banner

	case "$1" in
				-i|--install)
					mode="Install"
					mode_abreviation="-i"
					echo "[+] Installing ADHD"
					setup
					install
					echo "[+] Done installing ADHD!";;
					-u|--uninstall)
							mode="Uninstall"
							mode_abreviation="-u"
							echo "[+] Uninstalling ADHD"
							uninstall
					echo "[+] Done uninstalling ADHD!";;
					*)
							echo "Usage:
					sudo ./adhd-install.sh [-i|--install] [-g|--graphical]
					sudo ./adhd-install.sh [-u|--uninstall] [-g|--graphical]";;
			esac
}



function use_term_gui(){
	case "$1" in
				-i|--install)
					setup_gui
					mode="Install"
					mode_abreviation="-i"
					gui_mode "$mode_abreviation"
					thank_you_screen;;
					
					-u|--uninstall)
					mode="Uninstall"
					mode_abreviation="-u"
					gui_mode "$mode_abreviation";;
					*)
							echo "Usage:
					sudo ./adhd-install.sh [-i|--install] [-g|--graphical]
					sudo ./adhd-install.sh [-u|--uninstall] [-g|--graphical]";;
			esac
}

function info_screen(){
	local banner="                     +-----------------------------+
                     |     _    ____  _   _ ____   |
                     |    / \  |  _ \| | | |  _ \  |
                     |   / _ \ | | | | |_| | | | | |
                     |  / ___ \| |_| |  _  | |_| | |
                     | /_/   \_\____/|_| |_|____/  |
                     +=============================+
                     |    blackhillsinfosec.com    |
                     +=============================+"


	local msg="Welcome to the Builkit-ng installation uitlity. This program \
		installs many of the tools in the ADHD project. Please see below for more details!\n
					https://adhdproject.github.io/#!index.md"

	whiptail --title "ADHD Buildkit-ng" --msgbox "$banner \n\n\n $msg" 22 78
}

function thank_you_screen(){
	local ty="Your installation of ADHD is complete! Happy hunting!"

	whiptail --title "End Titles" --msgbox "$ty" 10 40
}

case "$2" in
	-g|--graphical)
		info_screen
		use_term_gui "$1";;
	*)
			use_cli "$1";;
esac
