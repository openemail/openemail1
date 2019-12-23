#!/usr/bin/env bash
[[ -f openemail.conf ]] && source openemail.conf
[[ -f ../openemail.conf ]] && source ../openemail.conf

if [[ -z ${DBUSER} ]] || [[ -z ${DBPASS} ]] || [[ -z ${DBNAME} ]]; then
	echo "Cannot find openemail.conf, make sure this script is run from within the openemail folder."
	exit 1
fi

echo -n "Checking MySQL service... "
if [[ -z $(docker ps -qf name=mysql-openemail) ]]; then
	echo "failed"
	echo "MySQL (mysql-openemail) is not up and running, exiting..."
	exit 1
fi

echo "OK"
read -r -p "Are you sure you want to reset the openemail administrator account? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]; then
	echo -e "\nWorking, please wait..."
	docker exec -it $(docker ps -qf name=mysql-openemail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM admin WHERE username='admin';"
  docker exec -it $(docker ps -qf name=mysql-openemail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM domain_admins WHERE username='admin';"
	docker exec -it $(docker ps -qf name=mysql-openemail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "INSERT INTO admin (username, password, superadmin, active) VALUES ('admin', '{SSHA256}4BrbE0bJqOcY//mYmqSbHCPjx+GyAYZ1NCnr50lFtl1lZDJmMDdiMGQ5NDkxMmRh', 1, 1);"
	docker exec -it $(docker ps -qf name=mysql-openemail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM tfa WHERE username='admin';"
	echo "
Reset credentials:
---
Username: admin
Password: openemail
TFA: none
"
else
	echo "Operation canceled."
fi
