#!/bin/bash
db_endpoint=$1
db_username=$2
db_password=$3
# Login to mysql DB and execute commands
mysql -h $db_endpoint -P 3306 -u $db_username -p$db_password << EOF
create database if not exists absolute_pro;
create database if not exists clients_master;
create user if not exists 'stohrmdbusr'@'%' identified by 'K1EisUKMcWU8qY!U';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, REFERENCES, EXECUTE, SHOW VIEW, CREATE ROUTINE, EVENT, TRIGGER ON clients_master.* TO 'stohrmdbusr'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, REFERENCES, EXECUTE, SHOW VIEW, CREATE ROUTINE, EVENT, TRIGGER ON absolute_pro.* TO 'stohrmdbusr'@'%';
EOF
# Import absolute_pro database
mysql -h $db_endpoint -P 3306 -u $db_username -p$db_password absolute_pro < ~/files/absolute_pro.sql
# Import clients_master database
mysql -h $db_endpoint -P 3306 -u $db_username -p$db_password clients_master < ~/files/clients_master.sql
mysql -h $db_endpoint -P 3306 -u $db_username -p$db_password << EOF
use clients_master;
Update clients set
dbusername = 'stohrmdbusr',
dbpassword = 'K1EisUKMcWU8qY!U',
dbhostname = 'storhmv2-0-dev-rds.cngpylmymsxj.ap-south-1.rds.amazonaws.com',
main_dbhostname = 'storhmv2-0-dev-rds.cngpylmymsxj.ap-south-1.rds.amazonaws.com',
main_dbusername = 'stohrmdbusr',
main_dbpassword = 'K1EisUKMcWU8qY!U'
Where 1;
update clients set dbname = 'absolute_pro', main_dbname = 'absolute_pro'  where urlcode = 'absolute_pro';
EOF
