#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MongoDB_IP="mongodb.anuragaws.shop"
MYSQL_HOST="mysql.anuragaws.shop"
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

dnf install maven -y &>> "$LOGFILE"

id roboshop &>> "$LOGFILE"
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATOR $? "Creating system user roboshop"
else 
    echo -e "user roboshop already exiest ......$Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATOR $? "created /app dir"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> "$LOGFILE"
VALIDATOR $? "Downloaded shipping.zip in tmp folder"

cd /app 
VALIDATOR $? "change directory to /app"

rm -rf /app/*
VALIDATOR $? "removing existing code"

unzip /tmp/shipping.zip &>> "$LOGFILE"
VALIDATOR $? "unziped shipping.zip folder"

mvn clean package &>> "$LOGFILE"
VALIDATOR $? "installing dependancies"
mv target/shipping-1.0.jar shipping.jar &>> "$LOGFILE"
VALIDATOR $? "moved shipping jar to /app"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATOR $? "creating .service file"
systemctl daemon-reload
VALIDATOR $? "daemon-reloading shipping"
systemctl enable shipping &>> "$LOGFILE"
VALIDATOR $? "enabling shipping"
systemctl start shipping
VALIDATOR $? "starting shipping"

dnf install mysql -y &>> "$LOGFILE"
VALIDATOR $? "installing mysql client"
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e "use cities" &>> "$LOGFILE"
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    VALIDATOR $? "loading schema data into database"
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
    VALIDATOR $? "loading app-user data into database"
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
    VALIDATOR $? "loading Master data into database"
else 
    echo -e "database alredy exist $Y SKIPPING $N"
fi 
systemctl restart shipping
VALIDATOR $? "restarting shipping"