#! /usr/bin/sh
echo "Welcome to use CQU_drcom setup program."
sleep 1s
passwd
echo "1.A or B"
echo "2.D"
read -p "Please enter your campus: " choice
case $choice in
1)
    echo ""
    echo "You chose campus AB"
    mv latest-wired_ab.py drcom
    mv drcom_ab.conf drcom.conf;;
2)
    echo ""
    echo "You chose campus D"
    mv latest-wired_d.py drcom
    mv drcom_d.conf drcom.conf;;
*)
    echo ""
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
echo "remove python_ipk..."
rm -rf *.ipk
sleep 1s
echo "Set up scripts..."
chmod +x *.sh
chmod +x *drcom
mv 99-drcom /etc/hotplug.d/iface/
mv drcom /usr/bin/
mv networkChecking.sh /usr/bin/
mv drcom.conf /etc/
sleep 1s
echo "Almost done!"
echo "Set up cron..."
crontab mycron
/etc/init.d/cron restart
sleep 1s
echo "It is OK. Enjoy!"
