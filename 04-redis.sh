#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MongoDB_IP="mongodb.anuragaws.shop"
LOGFOLDER="/var/log/shell-logs"
SCRIPT_DIR="$PWD"
mkdir -p "$LOGFOLDER"
LOGFILENAME=$( echo $0 | cut -d "." -f1)
START_TIME=$(date +%s)
LOGFILE="$LOGFOLDER/$LOGFILENAME.log"
echo "Log File Created at $LOGFILE"

if [ "$USERID" -ne 0 ]; then
    echo "Run this file with Root Privilage" &>> "$LOGFILE"
    echo "Run this file with Root Privilage"
    exit 1
else 
    echo "This files running with Root Privilage" &>> "$LOGFILE"
    echo "This files running with Root Privilage"
fi

VALIDATOR(){
    if [ "$1" -eq 0 ]; then
        echo " $2 SUCCESS" &>> "$LOGFILE"
        echo -e "$2 $G SUCCESS $N"
    else
        echo "ERROR  $2" &>> "$LOGFILE"
        echo -e "$R ERROR  $2 $N"
        exit 1
    fi 
    echo " ................................... " &>> "$LOGFILE"
}
### Installing redis 7 ###
dnf module disable redis -y &>> "$LOGFILE"
VALIDATOR $? "Disabling  default redis"
dnf module enable redis:7 -y &>> "$LOGFILE"
VALIDATOR $? "Enabling redis 7"
dnf install redis -y &>> "$LOGFILE"
VALIDATOR $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATOR $? "allowing remote connetion to redis"

systemctl enable redis &>> "$LOGFILE"
VALIDATOR $? "Enabling redis"
systemctl start redis &>> "$LOGFILE"
VALIDATOR $? "Starting redis"
END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo "Total time = $TOTAL_TIME"