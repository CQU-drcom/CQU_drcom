#! /usr/bin/sh

conf=/etc/drcom.conf
drcom=/usr/bin/drcom

uname -a | grep PandoraBox | grep -v grep
if [ $? -ne 0 ]
then
    echo "Not PandoraBox, exit..."
    exit 0
fi

echo "Welcome to use CQU_drcom setup program."

sleep 1s
# passwd

if [ -f ${conf} ]
then
    mv /etc/drcom.conf /etc/drcom.conf.save
fi
if [ -f ${drcom} ]
then
    mv /usr/bin/drcom /usr/bin/drcom.save
fi

echo ""
echo "1.A or B"
echo "2.D"
read -p "Please enter your campus: " choice
case $choice in
1)
    echo ""
    echo "You chose campus AB"
    cp -p latest-wired_ab.py drcom
    cp -p drcom_ab.conf drcom.conf;;
2)
    echo ""
    echo "You chose campus D"
    cp -p latest-wired_d.py drcom
    cp -p drcom_d.conf drcom.conf;;
*)
    echo ""
    echo "Errors! Please run the program again."
    exit 0;;
esac

read -p "Please enter your username: " username
sed -i "s/username=''/username=\'$username\'/g" drcom.conf
read -p "Please enter your password: " password
sed -i "s/password=''/password=\'$password\'/g" drcom.conf

echo "Install python-mini..."
opkg install zlib_1.2.8-1_ralink.ipk
opkg install python-mini_2.7.3-2_ralink.ipk

echo "Set up scripts..."
chmod +x *.sh
chmod +x *drcom
cp -p 99-drcom /etc/hotplug.d/iface/
cp -p drcom /usr/bin/
cp -p networkChecking.sh /usr/bin/
cp -p drcom.conf /etc/
sleep 1s
echo "Almost done!"

echo "Set up cron..."
crontab mycron
/etc/init.d/cron restart
python /usr/bin/drcom > ~/drcom.log &
sleep 1s

# Change WIFI Passwprd
read -p "Change your WIFI password...(Y /N)" ifChange
case $ifChange in
Y | y)
    read -p "Please enter your new WIFI password: " wifi_password
    uci set wireless.@wifi-iface[0].encryption=psk2
    uci set wireless.@wifi-iface[1].encryption=psk2
    uci set wireless.@wifi-iface[0].key=$wifi_password
    uci set wireless.@wifi-iface[1].key=$wifi_password
    wifi
    uci commit;;
*)
    echo "";;
esac

# Network Checking and Remove Setup Files
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

echo "It is OK. Enjoy!"
