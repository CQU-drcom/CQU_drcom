#!/bin/sh
# shellcheck shell=ash
CONFIG=drcom.conf
CONFIG_PATH=/etc
DRCOM_ORIGIN=latest-wired.py
DRCOM=drcom
DRCOM_PATH=/usr/bin
CONFIG_PATH=/etc
DRCOMLOG=/var/log/drcom.log
NETLOG=/var/log/networkChecking.log
DRCOM_PID=/var/run/drcom-wrapper.pid
ERROR_LOG=/var/log/install-error.log
VERSION_CQU_DRCOM='2.3.2b'

# for cli options
# "-" option is to rewrite long options which getopts do not support.
# ":" behind "-" is to undertake option string value of "-"
# like "--debug" option, "-" is a short option undertaking "-debug",
# and "debug" is the actual option handle by getopts
optspec="-:Vcvhf"
# - for long flag option
# V for verbose option
# c for config changes option
# h for help option
# v for version option
# f for config file option

if [ ! -f "/etc/os-release" ];then
    echo "Recheck your package. You cannot run this script."
    sleep 1
    exit;
fi

# import system information
source /etc/os-release;
distro=`echo $NAME | tr 'A-Z' 'a-z'` # By purefkh, to set all capital letters to lower case

# rewrite echo func By @Hagb
echo() { printf '%s\n' "$*" ; }

# hello mates
hello() {
    clear
    echo "======================================"
    echo "Welcome to CQU_drcom setup script."
    echo "======================================"
}

# config network
network_config() {
    read -p "Manually config the network? [y/N]: " ifSet_wan
    case $ifSet_wan in
        n|N|"")
            ;;
        y|Y)
            read -p "IP (Default to 192.168.1.1): " ifSet_wan_ip
            read -p \
                "DNS (Default to 8.8.8.8 8.8.4.4; use SPACE to specific mutiple DNS): " \
                ifSet_wan_dns
            read -p "GATEWAY (Default to 192.168.1.0): " ifSet_wan_gateway
            read -p "NETMASK (Default to 255.255.255.0): " ifSet_wan_netmask

            uci del network.wan.proto
            uci set network.wan.proto='static'
            uci set network.wan.ipaddr=$ifSet_wan_ip$(
                [ -z "$ifSet_wan_ip" ] && echo 192.168.1.1)
            uci set network.wan.netmask=$ifSet_wan_netmask$(
                [ -z "$ifSet_wan_netmask" ] && echo 255.255.255.0)
            uci set network.wan.gateway=$ifSet_wan_gateway$(
                [ -z "$ifSet_wan_gateway" ] && echo 192.168.1.0)
            uci set network.wan.dns="$ifSet_wan_dns$(
                [ -z "$ifSet_wan_dns" ] && echo 8.8.8.8 8.8.4.4)"
            echo "Commit changes..."
            uci commit
            echo "Restarting network service..."
            /etc/init.d/network restart
            ;;
    esac
}

# remove old file
clean_up() {
    if [ -f "$CONFIG_PATH/$CONFIG" ];then
        mv $CONFIG_PATH/$CONFIG $CONFIG_PATH/$CONFIG.save
    fi
    if [ -f "$DRCOM_PATH/$DRCOM" ];then
        rm $DRCOM_PATH/$DRCOM $DRCOM_PATH/$DRCOM.save
    fi
}

# change root passwd
root_pwd_change() {
    read -p "Change your root password? (For security it will show nothing when you enter.) [Y/n]:" rootpasswd
    case $rootpasswd in
        Y|y|"")
            passwd root;;
        N|n)
            # shellcheck disable=SC2104
            true;;
    esac
    clear
}

#Gether information
inform_gather() {

    echo "[1] A"
    echo "[2] B"
    echo "[3] D"
    echo ""

    read -p "Please enter your campus: " CHOICE
    case $CHOICE in
        1)
            echo ""
            echo "You choose campus A"
            campus=a;;
        2)
            echo ""
            echo "You choose campus B"
            campus=b;;
        3)
            echo ""
            echo "You choose campus D"
            campus=d;;
        *)
            echo ""
            echo "Errors! Please run the program again."
            exit 0;;
    esac
    clear

    # change username and passwd
    read -p "Please enter your Student number: " username
    read -p "Please enter your password: " password

    # Crontab setting confirm
    echo "The cron is a schedule for script to run. It's like:"
    echo "*/1 * * * * sh /usr/bin/networkChecking.sh" \
         "&& sleep 30 && sh /usr/bin/networkChecking.sh"
    echo "* */8 * * * echo $NULL > '$NETLOG'"
    echo ""
    echo "which means the networkChecking script will run every 30 seconds and"
    echo "every 8 hour it will clean logs of drcom."
    echo ""
    read -p "Set up cron? [Y/n]: " ifSet
    case $ifSet in
        Y|y|"")
            ifSet_cron=Yes;;
        N|n)
            ifSet_cron=no;;
    esac


}

client_setting() {
    clear
    clear
    echo "Please enter the drcom client you want"
    echo "[1] drcom-generic with python2 - the default client"
    echo "[2] micropython-drcom with micopython - smaller then python2."
    echo ""
    echo "**Note:"
    echo "    There is no longer python2 package in OpenWrt snapshot."
    echo "    If choosing micropython-drcom, please download the"
    echo "    micropython-drcom-with-lib ipkg package from"
    echo "    https://github.com/Hagb/micropython-drcom/releases and put it in"
    echo "    `pwd`/micropython-drcom-with-lib.ipk"
    echo ""

    read -p "Please enter enter the drcom client you want: " CHOICE
    case $CHOICE in
        "")
            echo ""
            echo "You choose the default option drcom-generic"
            CLIENT=python2;;
        1)
            echo ""
            echo "You choose drcom-generic"
            CLIENT=python2;;
        2)
            echo ""
            echo "You choose micropython-drcom"
            CLIENT=micropy;;
        *)
            echo ""
            echo "Error! Please run the program again."
            exit 0;;
    esac
}

wlan_ssid_settings() {
    # Change WIFI ssid
    read -p "Change wifi ssid ? [Y/n]: " ifset_ssid
    case $ifset_ssid in
        Y|y|"")
            read -p "Use different name? [y/N]: " ifset_ssid_diff
            case $ifset_ssid_diff in
                Y|y)
                    read -p "Enter 5Ghz wifi SSID: " wifi_ssid0
                    read -p "Enter 2.4Ghz wifi SSID: " wifi_ssid1
                    ;;
                N|n|"")
                    read -p "Enter wifi SSID: " wifi_ssid1
                    wifi_ssid0="${wifi_ssid1}_5G"
                    ;;
            esac
            ;;
        N|n)
            echo "SSID will be " $distro
            wifi_ssid0=$distro\_5G
            wifi_ssid1=$distro
            ;;
    esac
}

wlan_passwd_setting() {
    # Wifi password
    read -p "Change your WIFI password ? [Y/n]: " ifChange
    case $ifChange in
        Y|y|"")
            read -p "Use different password? [y/N]: " ifset_passwd_diff
            case $ifset_passwd_diff in
                Y|y)
                    echo "Enter password for " "$wifi_ssid0"
                    read -p ">" wifi_password0
                    echo "Enter password for " "$wifi_ssid1"
                    read -p ">" wifi_password1
                    ;;
                N|n|"")
                    read -p "Please enter your new WIFI password: " \
                        wifi_password0
                    wifi_password1="$wifi_password0"
                    ;;
            esac
            ;;
        N|n)
            echo "Wifi password will leave empty."
            ;;
    esac
}


# Information recheck
recheck() {
    clear
    echo "Your campus:"
    echo $campus
    echo "Your Student number:"
    echo $username
    echo "Your password:"
    echo $password
    echo "SSID for 5Ghz:"
    echo "$wifi_ssid0"
    echo "SSID for 2.4Ghz:"
    echo "$wifi_ssid1"
    echo "Change WIFI password:"
    echo $ifChange
    echo "DrCOM client:"
    echo "$CLIENT version"

    case $ifChange in
        Y|y|"")
            echo "WIFI password for 5Ghz:"
            echo "$wifi_password0"
            echo "WIFI password for 2.4Ghz"
            echo "$wifi_password1" ;;
        N|n|*)
            # shellcheck disable=SC2104
            pass;;
    esac

    echo "Crontab:"
    echo $ifSet_cron
    echo ""
}

# give chances to reenter information
config_choice_changes() {
    while [ $confirm == "no" ]; do
        clear
        echo ""
        echo "Choose the section to resetup from:"
        echo "[1] campus"
        echo "[2] student number"
        echo "[3] password"
        echo "[4] wifi SSID"
        echo "[5] wifi password"
        echo "[6] crontab"
        echo "[7] drcom client"
        echo "Or press any other key to back to information recheck ..."
        read -p  "Please input only the number of the section: " toChange
        case $toChange in
            1)
                read -p "Please enter your campus(a/b/d): " campus
                ;;
            2)
                read -p "Please enter your Student number: " username
                ;;
            3)
                read -p "Please enter your password: " password
                ;;
            4)
                wlan_ssid_settings
                ;;
            5)
                wlan_passwd_setting
                ;;
            6)
                read -p "Set up cron? [Y/n]" ifSet
                case $ifSet in
                    Y|y|"")
                        ifSet_cron=Yes;;
                    N|n)
                        ifSet_cron=no;;
                esac
                ;;
            7)
                client_setting
                ;;
            *)
                confirm=yes
                ;;
        esac
    done
}

setup_confirm() {
    while : ; do
        recheck
        read -p "Is the above information right? [Y/n]: " solution
        case $solution in
            Y|y|"")
                echo "Good!"
                read -n1 -p "Press any key to continue installation... "
                echo ""
                clear
                break
                ;;
            N|n)
                confirm=no
                config_choice_changes
                ;;
            *)
                echo "invalid input!"
                ;;
        esac
    done

}


setup_packages() {

    echo "Setting up package..."
    echo "Changing repositories..."
    echo "Old opkg sources file will be installed as" \
         "/etc/opkg/distfeeds.conf.save"
    cp /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.save
    sed -i 's/downloads.openwrt.org/mirrors.cqu.edu.cn\/openwrt/g' \
        /etc/opkg/distfeeds.conf
    ping -c 1 mirrors.cqu.edu.cn
    if [ $? -eq 0 ] ; then
        echo "Network is connected..."
    else
        echo "Failed... Please check your network connection."
        exit 0
    fi
    opkg update

    echo ""
    if [ "$CLIENT" != micropy ] ; then
        # setup python2
        echo "Installing python..."
        opkg install python
    else
        echo "Installing micropython..."
        opkg install micropython
    fi

    #set up base64
    echo "Setting up coreutils-base64..."
    opkg install coreutils-base64
}

setup_drcom() {
    #setup drcom
    echo "Setting up Dr.com..."
    case $campus in
    "a")
        echo "c2VydmVyID0gJzIwMi4yMDIuMC4xODAnCnVzZXJuYW1lPScnCnBhc3N3b3JkPScnCkNPTlRST0xDSEVDS1NUQVRVUyA9ICdceDIwJwpBREFQVEVSTlVNID0gJ1x4MDUnCmhvc3RfaXAgPSAnMTcyLjI0LjE1Mi44MScKSVBET0cgPSAnXHgwMScKaG9zdF9uYW1lID0gJ0dJTElHSUxJRVlFJwpQUklNQVJZX0ROUyA9ICcyMDIuMjAyLjAuMzMnCmRoY3Bfc2VydmVyID0gJzIwMi4yMDIuMi41MCcKQVVUSF9WRVJTSU9OID0gJ1x4MmZceDAwJwptYWMgPSAweDJjNjAwY2U4YzNjYgpob3N0X29zID0gJ05PVEU3JwpLRUVQX0FMSVZFX1ZFUlNJT04gPSAnXHhkY1x4MDInCnJvcl92ZXJzaW9uID0gRmFsc2UK" | base64 -d > $CONFIG
        ;;
    "b")
        echo "c2VydmVyID0gJzIwMi4yMDIuMC4xNjMnCnVzZXJuYW1lPScnCnBhc3N3b3JkPScnCkNPTlRST0xDSEVDS1NUQVRVUyA9ICdceDIwJwpBREFQVEVSTlVNID0gJ1x4MDYnCmhvc3RfaXAgPSAnMTcyLjI1LjE1NC45NCcKSVBET0cgPSAnXHgwMScKaG9zdF9uYW1lID0gJ0dJTElHSUxJRVlFJwpQUklNQVJZX0ROUyA9ICc4LjguOC44JwpkaGNwX3NlcnZlciA9ICcxMC4xMC43LjY2JwpBVVRIX1ZFUlNJT04gPSAnXHgyNVx4MDAnCm1hYyA9IDB4MTA3ZDFhMWYwNzliCmhvc3Rfb3MgPSAnTk9URTIwJwpLRUVQX0FMSVZFX1ZFUlNJT04gPSAnXHhkOFx4MDInCnJvcl92ZXJzaW9uID0gRmFsc2UK" |base64 -d > $CONFIG
        ;;
    "d")
        echo "c2VydmVyID0gIjEwLjEwLjguMTYyIgp1c2VybmFtZT0nJwpwYXNzd29yZD0nJwpob3N0X25hbWUgPSAiR0lMSUdJTElFWUUiCmhvc3Rfb3MgPSAiTk9URTciCmhvc3RfaXAgPSAiMTAuMjMwLjU5LjI1MSIKUFJJTUFSWV9ETlMgPSAiMjAyLjIwMi4wLjMzIgpkaGNwX3NlcnZlciA9ICIxMC4yMzAuNTkuMiIKbWFjID0gMHhiODg4ZTMwNTE2ODAKQ09OVFJPTENIRUNLU1RBVFVTID0gJ1x4MjAnCkFEQVBURVJOVU0gPSAnXHgwMicKS0VFUF9BTElWRV9WRVJTSU9OID0gJ1x4ZGNceDAyJwonJycKQVVUSF9WRVJTSU9OOgogICAgdW5zaWduZWQgY2hhciBDbGllbnRWZXJJbmZvQW5kSW50ZXJuZXRNb2RlOwogICAgdW5zaWduZWQgY2hhciBEb2dWZXJzaW9uOwonJycKQVVUSF9WRVJTSU9OID0gJ1x4MzFceDAwJwpJUERPRyA9ICdceDAxJwpyb3JfdmVyc2lvbiA9IEZhbHNlCg==" | base64 -d > $CONFIG
        ;;
    esac
    cp $DRCOM_ORIGIN $DRCOM #to avoid drcom not found
    sed -i "s/username=''/username=\'$username\'/g" $CONFIG
    sed -i "s/password=''/password=\'$(echo "$password" | sed 's/\\/\\\\\\\\/g;s/[&/]/\\&/g;s/'\''/\\\\'\'/g)\'/g" $CONFIG

    #set up startup service
    echo "Setting up startup service..."
    case $distro in
        "openwrt")
            echo '#!/bin/sh /etc/rc.common
            START=99
            start() {
                echo "[RUNNING] Starting drcom service..."\
                    stop  >/dev/null
                                    (/usr/bin/drcom > ' "'$DRCOMLOG'" ' &)&
                                    sleep 1
                                    echo "[DONE] Start drcom service succesfully."
                                }
                            stop() {
                                echo "[RUNNING] Stopping drcom..."
                                kill -9 $(cat' "'$DRCOM_PID'" ')
                                rm' "'$DRCOM_PID'" '
                                sleep 1
                                echo "[DONE] Drcom has been stopped."
                            }
                        restart() {
                            echo "[RUNNING] Stopping drcom ... "
                            kill -9 $(cat' "'$DRCOM_PID'" ');
                            rm' "'$DRCOM_PID'" '
                            sleep 1
                            echo "[RUNNING] Restarting drcom ... "
                            (/usr/bin/drcom > ' "'$DRCOMLOG'" ' &)&
                            sleep 2
                            echo "[DONE] Drcom restart succesfully."
                        }' > drcomctl
                    chmod a+x drcomctl
                    mv drcomctl /etc/init.d/.
                    /etc/init.d/drcomctl enable
                    ;;
            esac
            if [ "$CLIENT" != micropy ] ; then
                echo "installing drcom to /usr/bin/drcom-python2"
                cp -p drcom /usr/bin/drcom-python2
                chmod +x /usr/bin/drcom-python2
                drcom_exec=/usr/bin/drcom-python2
            else
                echo "installing micropython-drcom"
                opkg install micropython-drcom-with-lib.ipk || {
                    echo "Failed to install micropython-drcom! exit"
                                    exit 1
                                }
                            mv /etc/drcom_wired.conf /etc/drcom_wired.conf.save
                            ln -s /etc/$CONFIG /etc/drcom_wired.conf
                            drcom_exec=/usr/bin/drcom-wired
            fi
            echo '#!/bin/sh
            while true ; do
                '"'$drcom_exec'"' &
                echo $$ $! >' "'$DRCOM_PID'" '
                wait
                echo $$ >' "'$DRCOM_PID'" '
                sleep 2
            done' > /usr/bin/drcom
            chmod a+x /usr/bin/drcom
            echo "Installing drcom.conf to /etc/drcom.conf"
            cp -p $CONFIG /etc/
            sleep 1s

    #setup networkChecking
    echo "#!/bin/sh
    # /usr/bin/networkChecking.sh
    log='$NETLOG'
    dr_log='$DRCOMLOG'" > networkChecking.sh
    echo "aWYgWyAhIC1mICR7bG9nfSBdCnRoZW4KICAgIHRvdWNoICR7bG9nfQpmaQoKaWYgWyAhIC1mICR7ZHJfbG9nfSBdICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAp0aGVuICAgICAgICAgICAgICAgICAKICAgIHRvdWNoICR7ZHJfbG9nfQpmaQoKcGluZyAtYyAxIGJhaWR1LmNvbSA+IC9kZXYvbnVsbCAyPiYxCmlmIFsgJD8gLWVxIDAgXQp0aGVuCiAgICBlY2hvIGBkYXRlYCAgIi4uLi4uLk9LLi4uLi4uIiA+ICR7bG9nfQogICAgZWNobyAkTlVMTCA+ICR7ZHJfbG9nfQplbHNlCiAgICBlY2hvIGBkYXRlYCAiLi4uLi4uRmFpbGVkLi4uLi4uIiA+ICR7bG9nfQogICAgcHMgfCBncmVwICJ0aW1lb3V0LCByZXRyeWluZyIgJHtkcl9sb2d9IHwgZ3JlcCAtdiBncmVwCiAgICBpZiBbICQ/IC1lcSAwIF0KICAgIHRoZW4KICAgICAgICBlY2hvICROVUxMID4gJHtkcl9sb2d9CiAgICAgICAgZWNobyBgZGF0ZWAgIi4uLi4uLnRpbWVvdXQuLi4uLi4iID4+ICR7bG9nfQogICAgICAgIHJlYm9vdAogICAgZmkKICAgIHBzIHwgZ3JlcCBkcmNvbSB8IGdyZXAgLXYgZ3JlcAogICAgaWYgWyAkPyAtbmUgMCBdCiAgICB0aGVuCiAgICAgICAgZWNobyAiLi4uLi4uc3RhcnQgZHJjb20uLi4uLi4iID4+ICR7bG9nfQogICAgZWxzZQogICAgICAgIGVjaG8gIi4uLi4uLmRyY29tIGlzIHJ1bm5pbmcsIGtpbGwuLi4uLi4iID4+ICR7bG9nfQogICAgICAgIGVjaG8gIi4uLi4uLnN0YXJ0IGRyY29tLi4uLi4uIiA+PiAke2xvZ30KICAgICAgICBraWxsIC05ICQoY2F0IC92YXIvcnVuL2RyY29tLXdyYXBwZXIucGlkKQogICAgICAgIHJtIC92YXIvcnVuL2RyY29tLXdyYXBwZXIucGlkCiAgICAgICAgL3Vzci9iaW4vZHJjb20gPiAke2RyX2xvZ30gJgogICAgZmkKZmkK" | base64 -d >> networkChecking.sh
    chmod a+x networkChecking.sh

    # Network Checking
    (/usr/bin/drcom > "$DRCOMLOG" &)&
    sh networkChecking.sh
    echo "Network checking..."
    sleep 5s
    ping -c 1 baidu.com > /dev/null 2>&1

    if [ $? -eq 0 ] ; then
        echo "OK..."
    else
        echo "Failed... Please contact me."
        exit 0
    fi
}

setup_crontab() {
    #setup cron
    case $ifSet in
        Y|y)
            echo "Set up cron..."
            echo "*/1 * * * * networkChecking.sh && sleep 30 && networkChecking.sh
            * */8 * * * echo  > '$NETLOG'" > wrtcron
            chmod a+x wrtcron
            cp -p networkChecking.sh /usr/bin/
            crontab wrtcron
            /etc/init.d/cron restart
            sleep 1s;;
        N|n)
            ;;
    esac
}

# setup wireless interface
setup_wlan() {
    case $ifChange in
        Y|y|"")
            if [[ $distro == "openwrt" ]] ; then
                uci set wireless.@wifi-device[0].disabled=0
                uci set wireless.@wifi-device[1].disabled=0
                uci set wireless.@wifi-iface[0].ssid="$wifi_ssid0"
                uci set wireless.@wifi-iface[1].ssid="$wifi_ssid1"
            fi
            uci set wireless.@wifi-iface[0].encryption=psk2
            uci set wireless.@wifi-iface[1].encryption=psk2
            uci set wireless.@wifi-iface[0].key="$wifi_password0"
            uci set wireless.@wifi-iface[1].key="$wifi_password1"
            uci commit
            wifi up
            wifi reload;;
        N|n|*)
            echo "password will leave empty";;
    esac
}

setup_done() {
    sleep 1s
    clear
    echo "Done. Enjoy!"
    echo "--------------------"
    echo "Wifi ssid (5Ghz) :" "$wifi_ssid0"
    echo "Passwd :" "$wifi_password0"
    echo "Wifi ssid (2.4Ghz) :" "$wifi_ssid1"
    echo "Passwd :" "$wifi_password1"
    echo ""
    echo "Note: some of mobile phones of Huawei and OPPO don't support 5Ghz wifi, so"
    echo "  you may find only one ssid of your routine in the list."
    echo "--------------------"
}

setup_done_debug() {
    echo "=========="
    echo "Student number: "
    echo $username
    echo "Password: "
    echo $password
    echo "Wifi ssid (5Ghz) :" "$wifi_ssid0"
    echo "Passwd :" "$wifi_password0"
    echo "Wifi ssid (2.4Ghz) :" "$wifi_ssid1"
    echo "Passwd :" "$wifi_password1"
    echo "Crontab: "
    echo $ifSet
    echo "=========="
    uname -a
    echo $distro
    cat /etc/os-release
}

config_file_check() {
    CLIENT="$client"
    ifSet_cron="$set_cron"
    if [[ $ifSet_cron -eq 0 ]]
    then
        ifSet_cron=no
    fi
    
    if ! [[ $campus = "a" || $campus = "b" || $campus = "d" ]]
    then
        echo "Error, value campus with  $campus is not allowed. Please check ."
	echo "Error, value campus with  $campus is not allowed. Please check ." >> $ERROR_LOG
        exit
    fi

    if [ -z "$wifi_ssid0" ];
    then
        wifi_ssid0="openwrt"
    fi
    if [ -z "$wifi_ssid1" ];
    then
        wifi_ssid0="openwrt_5Ghz"
    fi
    if ! [[ $CLIENT = "python2" || $CLIENT = "micropy" ]]; then
        echo "Error, value client with $CLIENT is not allowed. Please check."
	echo "Error, value client with $CLIENT is not allowed. Please check." >> $ERROR_LOG
        exit
    fi



}

# Handle actions without options
if [ ! $1 ]; then
    # config renew after sys-upgrade
    read -p "Is is installation after system upgrade? [y/N]: " ifSet_upgrade
    case $ifSet_upgrade in
        n|N|"")
            clear
            hello
            network_config
            root_pwd_change
            inform_gather
            wlan_ssid_settings
            wlan_passwd_setting
            client_setting
            #				recheck
            setup_confirm
            clean_up
            setup_packages
            setup_drcom
            setup_crontab
            setup_wlan
            setup_done
            ;;
        y|Y)
            clear
            wifi_ssid0="the one you have set"
            wifi_ssid1="the one you have set"
            wifi_password0="the one you have set"
            wifi_password1="the one you have set"
            hello
            network_config
            inform_gather
            client_setting
            # recheck
            setup_confirm
            setup_packages
            setup_drcom
            setup_crontab
            setup_done
            echo "All done!"
            ;;
    esac
else # When running with options
    while getopts "$optspec" optchar; do
        case $optchar in
            -)
                case $OPTARG in
                    dry-run)
                        clear
                        echo "This flag is for test and will print most of the variables."
                        network_config
                        root_pwd_change
                        inform_gather
                        wlan_ssid_settings
                        wlan_passwd_setting
                        client_setting
                        setup_confirm
                        setup_done_debug
                        ;;
                    file)
                        while read line;do
                            eval "$line"
                        done < config.ini
                        hello
                        config_file_check

                        clean_up
                        setup_packages
                        setup_drcom
                        setup_crontab
                        setup_wlan
                        setup_done
                        ;;
                    help)
                        echo ""
                        echo "USAGE: sh ./setup.sh [options]"
                        echo ""
                        echo "-V, --dry-run		Verbose. Run the scripts without actually setting up."
                        echo "-f, --file            Use config file to install automatically"
                        echo "-h, --help			Display this message."
                        ;;
                esac
                ;;
            V)
                clear
                echo "This flag is for test and will print most of the variables."
                hello
                network_config
                root_pwd_change
                inform_gather
                wlan_ssid_settings
                wlan_passwd_setting
                client_setting
                setup_confirm
                setup_done_debug
                ;;
            h)
                echo "USAGE: sh ./setup.sh [options]"
                echo ""
                echo "-V, --dry-run			Verbose. Run the scripts without actually setting up."
                echo "-f, --file            Use config file to install automatically"
                echo "-h, --help				Display this message."
                ;;
            f)
                while read line;do
                    eval "$line"
                done < config.ini
                hello
                config_file_check
                clean_up
                setup_packages
                setup_drcom
                setup_crontab
                setup_wlan
                setup_done
#                 config_file_check
#                 setup_done_debug
                ;;
            *)
                if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                    echo "Non-option argument: '-${OPTARG}'" >&2
                fi
                ;;
        esac
    done
fi
