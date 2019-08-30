#!/usr/bin/sh


CONFIG=drcom.conf
DRCOM=latest-wired.py
pkgname=drcom
DR_PATH=/usr/bin
CO_PATH=/etc

uname -a | grep PandoraBox | grep -v grep

if [ $? -ne 0 ]
then
   echo "Not PandoraBox, exit..."
   exit 0
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

echo ""
echo "1.A or B"
echo "2.D"

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

# change username and passwd
read -p "Please enter your Student number: " username
read -p "Please enter your password: " password
# Crontab setting confirm
read -p "Set up cron? [Y|N]" ifSet
if  [[ $ifSet != "Y" | $ifSet != "N" ]]
then
            clear
            echo "invalid input"
            read -p "Set up cron? [Y|N]" ifSet
fi

# Change WIFI Passwprd
read -p "Change your WIFI password? [Y/N]: " ifChange
if [[ $ifChange == "Y" ]]
then
	read -p "Please enter your new WIFI password: " wifi_password
fi

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
read -p "Is the above information right? [Y/N]" solution
case $solution in
Y|y)
        echo "Good!";;
N|n)
        echo "Rerun setup.sh!"
        exit 0;;
*)
        echo "invalid input! Rerun."
        exit 0;;
esac
read -n1 -p "Press any key to continue installation... "

mv $DRCOM $pkgname
cp -p $pkgname\_$campus.conf  $CONFIG
sed -i "s/username=''/username=\'$username\'/g" $CONFIG
sed -i "s/password=''/password=\'$password\'/g" $CONFIG
echo "Install python-mini..."
opkg install zlib_1.2.8-1_ralink.ipk python-mini_2.7.3-2_ralink.ipk
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
       python /usr/bin/drcom > ~/drcom.log &
       sleep 1s;;
N|n)
       break;;

case $ifChange in
Y|y|"")
   uci set wireless.@wifi-iface[0].encryption=psk2
   uci set wireless.@wifi-iface[1].encryption=psk2
   uci set wireless.@wifi-iface[0].key=$wifi_password
   uci set wireless.@wifi-iface[1].key=$wifi_password
   wifi
   uci commit;;
N|n|*)
   echo "password will leave empty"
   break;;
esac

Network Checking and Remove Setup Files
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
