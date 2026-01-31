#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGFOLDER="/var/log/shell-logs"
mkdir -p "$LOGFOLDER"
LOGFILENAME=$( echo $0 | cut -d "." -f1)
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
        echo " $2 SUCCESSFUL" &>> "$LOGFILE"
        echo -e "$Y  $2 SUCCESSFUL $N"
    else
        echo "ERROR  $2" &>> "$LOGFILE"
        echo -e "$R ERROR  $2 $N"
        exit 1
    fi 
    echo " ................................... " &>> "$LOGFILE"
    echo -e "$G ................................... $N"
}

cp mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATOR $? "Adding mongo repo"

dnf install mongodb-org -y &>> "$LOGFILE"
VALIDATOR $? "Installing MongoDB"

dnf enable mongodb &>> "$LOGFILE"
VALIDATOR $? "Enable MongoDb"

systemctl start mongodb
VALIDATOR $? "start MongoDb"