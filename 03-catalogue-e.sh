#!/bin/bash
set -euo pipefail
# error(){

# }
trap 'echo "There is an errot in $LINENO , command is $BASH_COMMAND"' ERR

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
### Nodejs ###
dnf module disable nodejs -y &>> "$LOGFILE"
dnf module enable nodejs:20 -y &>> "$LOGFILE"
dnf install nodejs -y &>> "$LOGFILE"
echo "Installing Nodejs SUCCESS"

if [ id roboshop &>> "$LOGFILE" ]; then
    echo -e "user roboshop already exiest ......$Y SKIPPING $N"
else 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    echo "Creating roboshop User SUCCESS"
fi

### Downloading Project Files and Installing Dependancies###
mkdir -p /app 
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> "$LOGFILE"
cd /app 
rm -rf /app/*
unzip /tmp/catalogue.zip &>> "$LOGFILE"
npm install &>> "$LOGFILE"
echo "Downloading Project Files and Installing Dependancies SUCCESS"
### Creating service file ###
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
echo "Creating .service file SUCCESS"
### System Deamon reload Restart Stating ###
systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
echo "System Deamon reload Restart Stating SUCCESS"
### Creating repo for mongodb and installing mongodb client ###
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>> "$LOGFILE"
mongosh --host mongodb.anuragaws.shop --quiet --eval "db.adminCommand('listDatabases').databases.map(db => db.name)" | grep catalogue &>> "$LOGFILE"
if [ $? -ne 0 ]; then
    mongosh --host $MongoDB_IP </app/db/master-data.js &>> "$LOGFILE"
else
    echo -e "Database Alredy exist......$Y SKIPPING $N"
fi 
echo "Creating repo for mongodb and installing mongodb client SUCCESS "

systemctl restart catalogue
