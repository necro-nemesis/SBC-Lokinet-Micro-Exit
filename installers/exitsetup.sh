UPDATE_URL="https://raw.githubusercontent.com/necro-nemesis/SBC-Lokinet-Micro-Exit/master/"
wget -q ${UPDATE_URL}/installers/common.sh -O /tmp/exitcommon.sh
source /tmp/exitcommon.sh && rm -f /tmp/exitcommon.sh

function update_system_packages() {
    install_log "Updating sources"
    sudo apt-get update || install_error "Unable to update package list"
}

function install_dependencies() {
    install_log "Installing required packages"
    sudo apt-get -y install curl lsb-release gnupg
    echo "Install public key used to sign the lokinet binaries."
    curl -s https://deb.imaginary.stream/public.gpg | sudo apt-key add -
    echo "deb https://deb.imaginary.stream $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/imaginary.stream.list
    sudo debconf-set-selections <<EOF
    iptables-persistent iptables-persistent/autosave_v4 boolean true
    iptables-persistent iptables-persistent/autosave_v6 boolean true
    EOF
    sudo apt-get update
    sudo yes | apt-get install git screen dnsutils python3 resolvconf lokinet iptables-persistent|| install_error "Unable to install dependencies"
}

install_Exit
