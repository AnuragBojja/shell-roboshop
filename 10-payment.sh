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

dnf install python3 gcc python3-devel -y &>> "$LOGFILE"

id roboshop &>> "$LOGFILE"
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATOR $? "Creating system user roboshop"
else 
    echo -e "user roboshop already exiest ......$Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATOR $? "created /app dir"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> "$LOGFILE"
VALIDATOR $? "Downloaded payment.zip in tmp folder"

cd /app 
VALIDATOR $? "change directory to /app"

rm -rf /app/*
VALIDATOR $? "removing existing code"

unzip /tmp/payment.zip &>> "$LOGFILE"
VALIDATOR $? "unziped payment.zip folder"

pip3 install -r requirements.txt &>> "$LOGFILE"
VALIDATOR $? "installing dependancies"

systemctl daemon-reload
systemctl enable payment 
systemctl start payment
VALIDATOR $? "daemon-reloading enabling and starting payment"