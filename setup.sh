#!/usr/bin/sh
CONFIG=drcom.conf
DRCOM=latest-wired.py
pkgname=drcom
DR_PATH=/usr/bin
CO_PATH=/etc

uname -a | grep PandoraBox | grep -v grep

if [ $? -ne 0 ]
then
   uname -a | grep Wrt | grep -v grep
   if [ $? -ne 0 ]
   then
        echo "You cannot use the setup script."
        exit 0
   else
     distro=openwrt
   fi
else
  distro=pandorabox
fi
clear
echo "======================================"
echo "Welcome to use CQU_drcom setup script."
echo "======================================"

#config network
read -p "Manually config the network? [y/N]: " ifSet_wan
case $ifSet_wan in
  n|N|*|"")
      ;;
  y|Y)
      read -p "IP (Default to 192.168.1.1): " ifSet_wan_ip
      read -p "DNS (Default to 8.8.8.8 8.8.4.4; use SPACE to specific mutiple DNS): " ifSet_wan_dns
      read -p "GATEWAY (Default to 192.168.1.0): " ifSet_wan_gateway
      read -p "NETMASK (Default to 255.255.255.0): " ifSet_wan_netmask

      uci del network.wan.proto
      uci set network.wan.proto='static'
      uci set network.wan.ipaddr=\'$ifSet_wan_ip\'
      uci set network.wan.netmask=\'$ifSet_wan_netmask\'
      uci set network.wan.gateway=\'$ifSet_wan_gateway\'
      uci set network.wan.dns=\'$ifSet_wan_dns\'
      echo "Commit changes..."
      uci commit
      echo "Restarting network service..."
      /etc/init.d/network restart
      ;;
esac
sleep 1s

# remove old file

if [ -f $CO_path/$CONFIG ]
then
    cd $CO_PATH
    mv $CONFIG $CONFIG.save
fi
if [ -f $DR_PATH/$pkgname ]
then
    cd $DR_PATH
    mv $pkgname $pkgname.save
fi

# change root passwd

read -p "Change your root password? (For security it will show nothing when you enter.) [Y/n]:" rootpasswd
case $rootpasswd in
Y|y|"")
	passwd root;;
N|n)
	break;;
esac
clear


#Gether information


echo "1.A or B"
echo "2.D"
echo ""

read -p "Please enter your campus: " CHOICE
case $CHOICE in
1)
    echo ""
    echo "You chose campus AB"
    campus=ab;;
2)
    echo ""
    echo "You chose campus D"
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
echo "*/1 * * * * sh /usr/bin/networkChecking.sh && sleep 30 && sh /usr/bin/networkChecking.sh"
echo "* */8 * * * echo $NULL > ~/networkChecking.log"
echo ""
echo "which means the networkChecking script will run every 30 seconds and "
echo "every 8 hour it will clean logs of drcom."
echo ""
read -p "Set up cron? [Y/n]" ifSet
case $ifSet in
Y|y|"")
    ifSet_cron=Yes;;
N|n)
    ifSet_cron=no;;
esac

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
        wifi_ssid0=$wifi_ssid1\_5G
        ;;
    esac
    ;;
N|n)
    echo "SSID will be " $distro
    wifi_ssid0=$distro\_5G
    wifi_ssid1=$distro
    ;;
esac

# Wifi password
read -p "Change your WIFI password ? [Y/n]: " ifChange
case $ifChange in
Y|y|"")
    read -p "Use different password? [y/N]: " ifset_passwd_diff
    case $ifset_passwd_diff in
    Y|y)
        echo "Enter password for " $wifi_ssid0
        read -p ">" wifi_password0
        echo "Enter password for " $wifi_ssid1
        read -p ">" wifi_password1
        ;;
    N|n|"")
        read -p "Please enter your new WIFI password: " wifi_password0
        wifi_password1=$wifi_password0
        ;;
    esac
    ;;
N|n)
    echo "Wifi password will leave empty."
    ;;
esac

# Information recheck
clear
echo "Your campus:"
echo $campus
echo "Your Student number:"
echo $username
echo "Your password:"
echo $password
echo "SSID for 5Ghz:"
echo $wifi_ssid0
echo "SSID for 2.4Ghz:"
echo $wifi_ssid1
echo "Change WIFI password:"
echo $ifChange

case $ifChange in
Y|y|"")
    echo "WIFI password for 5Ghz:"
    echo $wifi_password0
    echo "WIFI password for 2.4Ghz"
    echo $wifi_password1 ;;
N|n|*)
    break;;
esac

echo "Crontab:"
echo $ifSet_cron
echo ""
read -p "Is the above information right? [Y/n]" solution
case $solution in
Y|y|"")
    echo "Good!";;
N|n)
    echo "Rerun setup.sh!"
    exit 0;;
*)
    echo "invalid input! Rerun."
    exit 0;;
esac
read -n1 -p "Press any key to continue installation... "
echo ""
clear

# setup python2
echo "Setting up python2..."
case $distro in
  "pandorabox")
      python --version
      if [ $? -ne 0 ]
      then
          echo "Install python-mini..."
          opkg install zlib_1.2.8-1_ralink.ipk python-mini_2.7.3-2_ralink.ipk
      fi
      ;;
  "openwrt")
      echo "Change repositories..."
      echo "Old opkg sources file will be installed as /etc/opkg/distfeeds.conf.save"
      cp /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.save
      sed -i 's/downloads.openwrt.org/mirrors.cqu.edu.cn\/openwrt/g' /etc/opkg/distfeeds.conf
      ping -c 1 mirrors.cqu.edu.cn
      if [ $? -eq 0 ]
      then
         echo "Network is connected..."
      else
         echo "Failed... Please check your network connection."
         exit 0
      fi
      opkg update
      echo ""
      echo "Install python..."
      opkg install python
      ;;
esac

#set up base64
echo "Setting up coreutils-base64..."

case $distro in
  "pandorabox")
      opkg install coreutils-base64_8.16-1_ralink.ipk
      ;;
  "openwrt")
      opkg install coreutils-base64
      ;;
esac

#setup drcom
echo "Set up Dr.com..."
case $campus in
  "ab")
      echo "c2VydmVyID0gJzIwMi4yMDIuMC4xODAnCnVzZXJuYW1lPScnCnBhc3N3b3JkPScnCkNPTlRST0xDSEVDS1NUQVRVUyA9ICdceDIwJwpBREFQVEVSTlVNID0gJ1x4MDUnCmhvc3RfaXAgPSAnMTcyLjI0LjE1Mi44MScKSVBET0cgPSAnXHgwMScKaG9zdF9uYW1lID0gJ0dJTElHSUxJRVlFJwpQUklNQVJZX0ROUyA9ICcyMDIuMjAyLjAuMzMnCmRoY3Bfc2VydmVyID0gJzIwMi4yMDIuMi41MCcKQVVUSF9WRVJTSU9OID0gJ1x4MmZceDAwJwptYWMgPSAweDJjNjAwY2U4YzNjYgpob3N0X29zID0gJ05PVEU3JwpLRUVQX0FMSVZFX1ZFUlNJT04gPSAnXHhkY1x4MDInCnJvcl92ZXJzaW9uID0gRmFsc2UK" | base64 -d > $CONFIG
      ;;
  "d")
      echo "c2VydmVyID0gJzIwMi4xLjEuMScKdXNlcm5hbWU9JycKcGFzc3dvcmQ9JycKQ09OVFJPTENIRUNLU1RBVFVTID0gJ1x4MDAnCkFEQVBURVJOVU0gPSAnXHgwMScKaG9zdF9pcCA9ICcxMC4yNTMuMTc4LjE0JwpJUERPRyA9ICdceDAxJwpob3N0X25hbWUgPSAnR0lMSUdJTElFWUUnClBSSU1BUllfRE5TID0gJzAuMC4wLjAnCmRoY3Bfc2VydmVyID0gJzEwLjI1My43LjcnCkFVVEhfVkVSU0lPTiA9ICdceDJmXHgwMCcKbWFjID0gMHhiMDI1YWEyMjdkNmIKaG9zdF9vcyA9ICdOT1RFNycKS0VFUF9BTElWRV9WRVJTSU9OID0gJ1x4ZGNceDAyJwpyb3JfdmVyc2lvbiA9IEZhbHNlIAo=" | base64 -d > $CONFIG
      ;;
esac
mv $DRCOM $pkgname
sed -i "s/username=''/username=\'$username\'/g" $CONFIG
sed -i "s/password=''/password=\'$(echo "$password" | sed 's/\\/\\\\\\\\/g;s/[&\/]/\\&/g;s/'\''/\\\\'\'/g)\'/g" $CONFIG

#set up startup service
echo "Setting up startup service..."
case $distro in
"pandorabox")
      echo '#!/bin/sh
      # /etc/hotplug.d/iface/99-drcom
      if [ "$ACTION" = ifup ]; then
          if [ "${INTERFACE}" = "wan" ]; then
              sleep 10 && python /usr/bin/drcom > ~/drcom.log &
          fi
      fi' > 99-drcom
      chmod a+x 99-drcom
      cp -p 99-drcom /etc/hotplug.d/iface/ ;;

"openwrt")
      echo '#!/bin/sh /etc/rc.common
      START=99
      start() {
        (/usr/bin/drcom > /dev/null &)&
      }
      stop() {
        kill -9 $(pidof python)
      }
      restart() {
        (/usr/bin/drcom > /dev/null &)&
      }' > 99-drcom
      chmod a+x 99-drcom
      mv 99-drcom /etc/init.d/.
      /etc/init.d/99-drcom enable
      ;;
esac

echo "installing drcom to /usr/bin/drcom"
echo "installing drcom.conf to /etc/drcom.conf"
cp -p drcom /usr/bin/
cp -p $CONFIG /etc/
sleep 1s

#setup networkChecking
echo "IyEgL3Vzci9iaW4vc2gKIyAvdXNyL2Jpbi9uZXR3b3JrQ2hlY2tpbmcuc2gKCmxvZz1+L25ldHdvcmtDaGVja2luZy5sb2cKaWYgWyAhIC1mICR7bG9nfSBdCnRoZW4KICAgIHRvdWNoICR7bG9nfQpmaQoKZHJfbG9nPX4vZHJjb20ubG9nCmlmIFsgISAtZiAke2RyX2xvZ30gXQp0aGVuCiAgICB0b3VjaCAke2RyX2xvZ30KZmkKCnBpbmcgLWMgMSBiYWlkdS5jb20gPiAvZGV2L251bGwgMj4mMQppZiBbICQ/IC1lcSAwIF0KdGhlbgogICAgZWNobyBgZGF0ZWAgICIuLi4uLi5PSy4uLi4uLiIgPiAke2xvZ30KICAgIGVjaG8gJE5VTEwgPiAke2RyX2xvZ30KZWxzZQogICAgZWNobyBgZGF0ZWAgIi4uLi4uLkZhaWxlZC4uLi4uLiIgPiAke2xvZ30KICAgIHBzIHwgZ3JlcCAidGltZW91dCwgcmV0cnlpbmciICR7ZHJfbG9nfSB8IGdyZXAgLXYgZ3JlcAogICAgaWYgWyAkPyAtZXEgMCBdCiAgICB0aGVuCiAgICAgICAgZWNobyAkTlVMTCA+ICR7ZHJfbG9nfQogICAgICAgIGVjaG8gYGRhdGVgICIuLi4uLi50aW1lb3V0Li4uLi4uIiA+PiAke2xvZ30KICAgICAgICByZWJvb3QKICAgIGZpCiAgICBwcyB8IGdyZXAgZHJjb20gfCBncmVwIC12IGdyZXAKICAgIGlmIFsgJD8gLW5lIDAgXQogICAgdGhlbgogICAgICAgIGVjaG8gIi4uLi4uLnN0YXJ0IGRyY29tLi4uLi4uIiA+PiAke2xvZ30KICAgIGVsc2UKICAgICAgICBlY2hvICIuLi4uLi5kcmNvbSBpcyBydW5uaW5nLCBraWxsLi4uLi4uIiA+PiAke2xvZ30KICAgICAgICBlY2hvICIuLi4uLi5zdGFydCBkcmNvbS4uLi4uLiIgPj4gJHtsb2d9CiAgICAgICAga2lsbCAtOSAkKHBpZG9mIHB5dGhvbiAvdXNyL2Jpbi9kcmNvbSkKICAgIGZpCiAgICBweXRob24gL3Vzci9iaW4vZHJjb20gPiAke2RyX2xvZ30gJgpmaQoK" | base64 -d > networkChecking.sh
chmod a+x networkChecking.sh

#setup cron
case $ifSet in
Y|y)
    echo "Set up cron..."
    echo "Ki8xICogKiAqICogc2ggL3Vzci9iaW4vbmV0d29ya0NoZWNraW5nLnNoICYmIHNsZWVwIDMwICYmIHNoIC91c3IvYmluL25ldHdvcmtDaGVja2luZy5zaAoqICovOCAqICogKiBlY2hvICA+IH4vbmV0d29ya0NoZWNraW5nLmxvZwo=" | base64 -d > wrtcron
    chmod a+x wrtcron
    cp -p networkChecking.sh /usr/bin/
    crontab wrtcron
    /etc/init.d/cron restart
    sleep 1s;;
N|n)
    ;;
esac

#setup wireless interface
case $ifChange in
Y|y|"")
    if [[ $distro == "openwrt" ]]
    then
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

# Network Checking
(/usr/bin/drcom > /dev/null &)&
sh networkChecking.sh
echo "Network checking..."
sleep 10s
ping -c 1 baidu.com > /dev/null 2>&1

if [ $? -eq 0 ]
then
   echo "OK..."
else
   echo "Failed... Please contact me."
   exit 0
fi

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
