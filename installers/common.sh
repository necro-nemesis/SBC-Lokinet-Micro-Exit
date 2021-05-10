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
    echo -e "              _____ ____   _____ "
    echo -e "             / ____|  _ \ / ____| "
    echo -e "            | (___ | |_) | | "
    echo -e "             \___ \|  _ <| | "
    echo -e "             ____) | |_) | |____ "
    echo -e "            |_____/|____/ \_____| "
    echo -e "${green}         __          __   _            __ "
    echo -e "        / /   ____  / /__(_)___  ___  / /_"
    echo -e "       / /   / __ \/ //_/ / __ \/ _ \/ __/ "
    echo -e "      / /___/ /_/ / ,< / / / / /  __/ /_"
    echo -e "     /_____/\____/_/|_/_/_/ /_/\___/\__/ "
    echo -e "${raspberry}            _                            _ _ "
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

# Replaces NetworkManger with DHCPCD (Armbian install)
function check_for_networkmananger() {
  install_log "Checking for NetworkManager"
  echo "Checking for Network Manager"
    if [ -f /lib/systemd/system/network-manager.service ]; then
  echo "Network Manager found. Replacing with DHCPCD"
        sudo apt-get -y purge network-manager
        sudo apt-get -y install dhcpcd5
    fi

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

function configure_exit() {

		#edit /var/lib/lokinet/lokinet.ini to exit settings
		sed -i 's#\#keyfile=#keyfile=/var/lib/lokinet/exit.private#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#min-connections=4#min-connections=8#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#max-connections=6#max-connections=16#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#exit=0#exit=true#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#reachable=1#reachable=1#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#ifaddr=#ifaddr=172.16.0.1/16#g' /var/lib/lokinet/lokinet.ini
		sed -i 's#\#paths=6#paths=8#g' /var/lib/lokinet/lokinet.ini

		#append /etc/iptables/rules.v4
		iptables -t nat -A POSTROUTING -s 172.16.0.1/16 -o eth0 -j MASQUERADE
		iptables-save > /etc/iptables/rules.v4

		#apply ipv4 forwarding if not already set
		sed -i 's#\#net.ipv4.ip_forward=1#net.ipv4.ip_forward = 1#g' /etc/sysctl.conf
		sudo sysctl -p /etc/sysctl.conf

		#apply resolvconf settings
		#echo "nameserver 127.3.2.1" | sudo tee /etc/resolvconf/resolv.conf.d/head
		#sudo rm /etc/resolv.conf
		#sudo ln -s /etc/resolvconf/run/resolv.conf /etc/resolv.conf
		#sudo resolvconf -u || install_error "Unable to update resolv.conf"

		#clean out installer files
		sudo rm -r /tmp/microexit || install_error "Unable to remove /tmp/microexit folder"

		#provide option to launch and display lokinet exit address

    cyan='\033[1;36m'
    echo -e "${cyan}\n"
    echo -e " Thank you for using SBC Lokinet Micro Exit  "
    echo -e " by Minotaurware.net  "
		install_log "SBC Lokinet Micro Exit setup has completed your installation"
    echo -n "Do you wish to immediately go live with the exit? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Exit not launched. Will launch on next reboot. Exiting installation"
        exit 0
    fi
    install_log "Exit Launching"
		sudo systemctl restart lokinet
		IP="127.3.2.1"
		exit_address=$(host -t cname localhost.loki $IP | awk '/alias for/ { print $6 }')
		install_warning "Your Lokinet Exit Address is:\nhttp://${exit_address}"	
		exit 0 || install_error "Unable to exit"
}

function install_Exit() {
    display_welcome
    update_system_packages
    install_dependencies
    stop_lokinet
    configure_exit
}
