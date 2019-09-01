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
echo "Welcome to use CQU_drcom setup program."

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
cat mycron
echo ""
echo "which means the networkChecking script will run every 30 seconds and "
echo "every 8 hour it will clean logs of drcom."
echo ""
read -p "Set up cron? [Y/n]" ifSet

# Change WIFI Passwprd
read -p "Change your WIFI password? [Y/n]: " ifChange
case $ifChange in
Y|y)
    read -p "Please enter your new WIFI password: " wifi_password;;
N|n)
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
echo "Change WIFI password:"
echo $ifChange

case $ifChange in
Y|y|"")
    echo "Your new password will be:"
    echo $wifi_password;;
N|n|*)
    break;;
esac

echo "Crontab:"
echo $ifSet
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

mv $DRCOM $pkgname
cp -p $pkgname\_$campus.conf  $CONFIG
sed -i "s/username=''/username=\'$username\'/g" $CONFIG
sed -i "s/password=''/password=\'$password\'/g" $CONFIG

if [[ $distro == "pandorabox" ]]
then
    echo "Install python-mini..."
    python --version
    if [ $? -ne 0 ]
    then
        opkg install zlib_1.2.8-1_ralink.ipk python-mini_2.7.3-2_ralink.ipk
    fi
fi
if [[ $distro == "openwrt" ]]
then
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
fi

echo "Set up scripts..."
chmod +x *.sh
chmod +x *drcom
cp -p 99-drcom /etc/hotplug.d/iface/
cp -p drcom /usr/bin/
cp -p networkChecking.sh /usr/bin/
cp -p drcom.conf /etc/
sleep 1s
echo "Almost done!"

case $ifSet in
Y|y)
    echo "Set up cron..."
    crontab mycron
    /etc/init.d/cron restart
    sleep 1s;;
N|n)
    ;;
esac

case $ifChange in
Y|y|"")
    if [[ $distro == "openwrt" ]]
    then
        uci set wireless.@wifi-device[0].disabled=0
        uci set wireless.@wifi-device[1].disabled=0
        uci set wireless.@wifi-iface[0].ssid=OpenWrt_1
        uci set wireless.@wifi-iface[1].ssid=OpenWrt_2
    fi
    uci set wireless.@wifi-iface[0].encryption=psk2
    uci set wireless.@wifi-iface[1].encryption=psk2
    uci set wireless.@wifi-iface[0].key=$wifi_password
    uci set wireless.@wifi-iface[1].key=$wifi_password
    uci commit
    wifi up;;
N|n|*)
    echo "password will leave empty";;
esac

# Network Checking and Remove Setup Files
sh /usr/bin/networkChecking.sh
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
echo "It is OK. Enjoy!"
