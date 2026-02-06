#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MongoDB_IP="mongodb.anuragaws.shop"
MYSQL_HOST="$MYSQL_HOST"
LOGFOLDER="/var/log/shell-logs"
SCRIPT_DIR="$PWD"
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
        echo " $2 SUCCESS" &>> "$LOGFILE"
        echo -e "$2 $G SUCCESS $N"
    else
        echo "ERROR  $2" &>> "$LOGFILE"
        echo -e "$R ERROR  $2 $N"
        exit 1
    fi 
    echo " ................................... " &>> "$LOGFILE"
}


dnf module disable nginx -y
VALIDATOR $? "disabling default nginx"

dnf module enable nginx:1.24 -y
VALIDATOR $? " enabling nginx 1.24"

dnf install nginx -y
VALIDATOR $? "installing nginx"
systemctl enable nginx 
systemctl start nginx 
VALIDATOR $? "started nginx"
rm -rf /usr/share/nginx/html/* 
VALIDATOR $? "removing default nginx frontend code"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATOR $? "downloading project code"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATOR $? "unzipping project code"
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATOR $? "creating nginx.conf"
systemctl restart nginx 
VALIDATOR $? "restarted nginx"