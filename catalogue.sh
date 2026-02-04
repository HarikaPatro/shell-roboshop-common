#!/bin/bash

source ./common.sh
app_name=catalogue
check_root

app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>LOG_FILE
VALIDATE $? "Install mongodb client"

INDEX=$(mongosh mongodb.daws87s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js &>>LOG_FILE
    VALIDATE $? "Load $app_name products"
else
    echo -e "$app_name products already loaded.... $Y skipping $N"
fi

app_restart
print_total_time