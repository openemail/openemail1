#!/bin/bash
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
	
echo -e "\nWorking, please wait..."
docker exec -it $(docker ps -qf name=mysql-openemail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM admin WHERE username='admin';"
docker exec -it $(docker ps -qf name=mysql-openemail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM domain_admins WHERE username='admin';"
docker exec -it $(docker ps -qf name=mysql-openemail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "INSERT INTO admin (username, password, superadmin, active) VALUES ('admin', '{SSHA256}Ho6L15mrvXcGkXSRrr7BYqgJVqbieQP3XIj4nUkZUhA5MmQ0ZjYzNzA4ODUwMWE1', 1, 1);"
docker exec -it $(docker ps -qf name=mysql-openemail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM tfa WHERE username='admin';"
echo "
Your Super Admin credentials:
-----
Username: admin
Password: openemail
TFA: none
"
