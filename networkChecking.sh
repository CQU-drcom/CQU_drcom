#! /usr/bin/sh
# /usr/bin/networkChecking.sh

log=~/networkChecking.log
if [ ! -f ${log} ]
then
    touch ${log}
fi

dr_log=~/drcom.log
if [ ! -f ${dr_log} ]
then
    touch ${dr_log}
fi

ping -c 1 baidu.com > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo `date`  "......OK......" > ${log}
    echo $NULL > ${dr_log}
else
    echo `date` "......Failed......" >> ${log}
    ps | grep "timeout, retrying" ${dr_log} | grep -v grep
    if [ $? -eq 0 ]
    then
        echo $NULL > ${dr_log}
        echo `date` "......timeout......" >> ${log}
        reboot
    fi
    ps | grep drcom | grep -v grep
    if [ $? -ne 0 ]
    then
        echo "......start drcom......" >> ${log}
    else
        echo "......drcom is running, kill......" >> ${log}
        echo "......start drcom......" >> ${log}
        kill -9 $(pidof python /usr/bin/drcom)
    fi
    python /usr/bin/drcom > ${dr_log} &
fi
