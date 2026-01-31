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
        echo -e "$G  $2 SUCCESS $N"
    else
        echo "ERROR  $2" &>> "$LOGFILE"
        echo -e "$R ERROR  $2 $N"
        exit 1
    fi 
    echo " ................................... " &>> "$LOGFILE"
    echo -e "$G ................................... $N"
}


dnf module disable nodejs -y &>> "$LOGFILE"
VALIDATOR $? "Disable nodejs modules"

dnf module enable nodejs:20 -y &>> "$LOGFILE"
VALIDATOR $? "Enabling Nodejs 20"

dnf install nodejs -y &>> "$LOGFILE"
VALIDATOR $? "Installing Nodejs"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATOR $? "Creating system user roboshop"
else 
    echo -e "user roboshop already exiest ......$Y SKIPPING $N"
fi
mkdir -p /app 
VALIDATOR $? "created /app dir"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> "$LOGFILE"
VALIDATOR $? "Downloaded catalogue.zip in tmp folder"

cd /app 
VALIDATOR $? "change directory to /app"

rm -rf /app/*
VALIDATOR $? "removing existing code"

unzip /tmp/catalogue.zip &>> "$LOGFILE"
VALIDATOR $? "unziped catalogue.zip folder"

npm install &>> "$LOGFILE"
VALIDATOR $? "installed all the dependancies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATOR $? "created catalogue.service file "

systemctl daemon-reload
VALIDATOR $? "completing deamon reload"

systemctl enable catalogue 
VALIDATOR $? "enabling catalogue"

systemctl start catalogue
VALIDATOR $? "starting catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATOR $? "Adding mongo repo"

dnf install mongodb-mongosh -y &>> "$LOGFILE"
VALIDATOR $? "installing mondoDB client"

mongosh --host $MongoDB_IP </app/db/master-data.js &>> "$LOGFILE"
VALIDATOR $? "load catalogue products"

systemctl restart catalogue
VALIDATOR $? "restarting catalogue"