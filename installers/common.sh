#create hostname account with root privelages.
# function create_user () {
#
# install_log "Create Exit user account"
#
# if [ $(id -u) -eq 0 ]; then
# 	read -p "Enter username : " username
# 	read -s -p "Enter password : " password
# 	egrep "^$username" /etc/passwd >/dev/null
# 	if [ $? -eq 0 ]; then
# 		echo "$username exists!"
# 		exit 1
# 	else
# 		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
# 		useradd -m -p $pass $username
#     sudo adduser $username sudo
# 		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
# 	fi
# else
# 	echo "Only root may add a user to the system"
# 	exit 2
# fi
#
# }

# Outputs a Exit Install log line
function install_log() {
    echo -e "\033[1;32mExit Install: $*\033[m"
}

# Outputs a Exit Install Error log line and exits with status code 1
function install_error() {
    echo -e "\033[1;37;41mExit Install Error: $*\033[m"
    exit 1
}

# Outputs a Exit Warning line
function install_warning() {
    echo -e "\033[1;33mAdvisory: $*\033[m"
}

# Outputs a welcome message
function display_welcome() {
    raspberry='\033[0;35m'
    green='\033[1;32m'
    cyan='\033[1;36m'

    echo -e "${cyan}\n"
    echo -e "  _____ ____   _____ "
    echo -e " / ____|  _ \ / ____| "
    echo -e "| (___ | |_) | | "
    echo -e " \___ \|  _ <| | "
    echo -e " ____) | |_) | |____ "
    echo -e "|_____/|____/ \_____| "
    echo -e "${raspberry}            _                            _ _ "
#    echo -e "            _                            _ _ "
    echo -e "           (_)                          (_) | "
    echo -e "  _ __ ___  _  ___ _ __ ___     _____  ___| |_ "
    echo -e " | '_  '_ \| |/ __| '__/ _ \   / _ \ \/ / | __| "
    echo -e " | | | | | | | (__| | | (_) | |  __/>  <| | |_ "
    echo -e " |_| |_| |_|_|\___|_|  \___/   \___/_/\_\_|\__| "
    echo -e "${cyan}by Minotaurware.net "
    echo -e "${green}\n"
    echo -e "Exit setup tool for SBCs."
    echo -e "The Quick Installer will guide you through a few easy steps\n\n"
		echo -n "Continue with Lokinet Exit Installation? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Installation aborted."
        exit 0
    fi

}

### NOTE: all the below functions are overloadable for system-specific installs
### NOTE: some of the below functions MUST be overloaded due to system-specific installs
# Runs a system software update to make sure we're using all fresh packages

function update_system_packages() {
    # OVERLOAD THIS
    install_error "No function definition for update_system_packages"
}

# Installs additional dependencies using system package manager
function install_dependencies() {
    # OVERLOAD THIS
    install_error "No function definition for install_dependencies"
}

# Halts lokinet to allow for modifications to it
function stop_lokinet(){
    sudo systemctl stop lokinet.service
}

# # Verifies existence and permissions of exit directory
# function create_exit_directory() {
#     install_log "Creating exit files directory"
#     exit_dir="/home/$username/exit"
#
#     if [ -d "$exit_dir" ]; then
#         sudo mv $exit_dir "$exit_dir.`date +%F-%R`" || install_error "Unable to move old '$exit_dir' out of the way"
#     fi
#     sudo mkdir -p "$exit_dir" || install_error "Unable to create directory '$exit_dir'"
#     sudo chown -R $username:$username "$exit_dir" || install_error "Unable to change file ownership for '$exit_dir'"
# }
#
# # Fetches latest files from github for basic exit
# function download_latest_files() {
#     if [ -d "$exit_dir" ]; then
#         sudo mv $exit_dir "$exit_dir.`date +%F-%R`" || install_error "Unable to remove old snap directory"
#     fi
#
#     install_log "Cloning latest files from github"
#     git clone --depth 1 https://github.com/necro-nemesis/SBC-Lokinet-Micro-Exit $exit_dir || install_error "Unable to download files from github"
#
# #handle changes to resolvconf giving nameserver 127.3.2.1 priority.
# 		sudo systemctl stop resolvconf
# 		sudo mv $exit_dir/head /etc/resolvconf/resolv.conf.d/head || install_error "Unable to move resolvconf head file"
# 		sudo rm /etc/resolv.conf
# 		sudo ln -s /etc/resolvconf/run/resolv.conf /etc/resolv.conf
# 		sudo resolvconf -u || install_error "Unable to update resolv.conf"
# 		sudo systemctl start resolvconf
# }
#
# # Sets files ownership in exit directory
# function change_file_ownership() {
#     if [ ! -d "$exit_dir" ]; then
#         install_error "exit directory doesn't exist"
#     fi
#
#     install_log "Changing file ownership in exit directory"
#     sudo chown -R $username:$username "$exit_dir" || install_error "Unable to change file ownership for 'exit_dir'"
# 		sudo chmod -R 0755 "$exit_dir" || install_error "Unable to change permissions for 'exit_dir'"
# 		sudo mv $exit_dir/exit /usr/local/bin
# }

function configure_exit() {

		#append /var/lib/lokinet/lokinet.ini
		sed -i 's#\#keyfile=#keyfile=/var/lib/lokinet/exit.private#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#min-connections=4#min-connections=8#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#max-connections=6#max-connections=16#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#exit=0#exit=true#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#reachable=1#reachable=1#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#ifaddr=#ifaddr=172.16.0.1/16#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#paths=6#paths=8#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#net.ipv4.ip_forward=1#net.ipv4.ip_forward = 1#g' /etc/sysctl.conf
		if grep "172.16.0.1" /etc/iptables/rules.v4 > /dev/null; then
		    echo -n "iptables entry already exists"
					else
				iptables -t nat -A POSTROUTING -s 172.16.0.1/16 -o eth0 -j MASQUERADE
				iptables-save > /etc/iptables/rules.v4
		fi
#		iptables -t nat -A POSTROUTING -s 172.16.0.1/16 -o eth0 -j MASQUERADE
		sudo sysctl -p /etc/sysctl.conf
		sudo systemctl restart lokinet

		#clean out installer files
		sudo rm -r /tmp/microexit || install_error "Unable to remove /tmp/microexit folder"

		#provide option to launch and display lokinet address

    cyan='\033[1;36m'
    echo -e "${cyan}\n"
    echo -e " Thank you for using SBC Lokinet Micro Exit  "
    echo -e " by Minotaurware.net  "
		install_log "SBC Lokinet Micro Exit setup has completed your installation"
		IP="127.3.2.1"
		exit_address=$(host -t cname localhost.loki $IP | awk '/alias for/ { print $6 }')
		install_warning "Your Lokinet Address is:\nhttp://${exit_address}"
    echo -n "Do you wish to immediately go live with the exit? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Exit not launched. Will launch on next reboot. Exiting installation"
        exit 0
    fi
    install_log "Exit Launching"
		sudo systemctl restart lokinet
		exit 0 || install_error "Unable to exit"
}

function install_Exit() {
    display_welcome
    update_system_packages
    install_dependencies
    stop_lokinet
    # create_user
    # create_exit_directory
    # download_latest_files
    # change_file_ownership
    configure_exit
}
