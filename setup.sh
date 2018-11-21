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
    echo "You chose campus AB"
    cp -p latest-wired_ab.py drcom
    cp -p drcom_ab.conf drcom.conf;;
2)
    echo "You chose campus D"
    cp -p latest-wired_d.py drcom
    cp -p drcom_d.conf drcom.conf;;
*)
    echo "Errors! Please run the program again."
    exit 0;;
esac

read -p "Pleasr enter your username: " username
sed -i "s/username=''/username=\'$username\'/g" drcom.conf
read -p "Pleasr enter your password: " password
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

echo "Network checking..."
python /usr/bin/drcom > ~/drcom.log &
sleep 2s
ping -c 1 baidu.com > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo "OK..."
    ls
    read -p "Remove these files... (Y /N)" option
    case $option in
    Y | y)
        rm -rf ../CQU_drcom;;
    *)
        echo "Not remove";;
    esac
else
    echo "Failed... Please contact me."
    exit 0
fi
sleep 1s

echo "It is OK. Enjoy!"

