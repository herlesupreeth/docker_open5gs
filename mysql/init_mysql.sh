#!/bin/bash -e
cp /mnt/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/

if [ ! -e /var/lib/mysql/ibdata1 ]; then
	echo 'Initialize MySQL DB'
	mysqld --initialize-insecure
fi

/etc/init.d/mysql start

if [ ! -d /var/lib/mysql/pcscf ]; then
	echo 'Creating database for P-CSCF'
	mysqladmin -u root create pcscf
	mysql -u root pcscf < /kamailio/utils/kamctl/mysql/standard-create.sql
	mysql -u root pcscf < /kamailio/utils/kamctl/mysql/presence-create.sql
	mysql -u root pcscf < /kamailio/utils/kamctl/mysql/ims_usrloc_pcscf-create.sql
	mysql -u root pcscf < /kamailio/utils/kamctl/mysql/ims_dialog-create.sql
fi

if [ ! -d /var/lib/mysql/icscf ]; then
	echo 'Creating database for I-CSCF'
	mysqladmin -u root create icscf
	mysql -u root icscf < /kamailio/misc/examples/ims/icscf/icscf.sql
fi

if [ ! -d /var/lib/mysql/scscf ]; then
	echo 'Creating database for S-CSCF'
	mysqladmin -u root create scscf
	mysql -u root scscf < /kamailio/utils/kamctl/mysql/standard-create.sql
	mysql -u root scscf < /kamailio/utils/kamctl/mysql/presence-create.sql
	mysql -u root scscf < /kamailio/utils/kamctl/mysql/ims_usrloc_scscf-create.sql
	mysql -u root scscf < /kamailio/utils/kamctl/mysql/ims_dialog-create.sql
	mysql -u root scscf < /kamailio/utils/kamctl/mysql/ims_charging-create.sql
fi

if [ ! -d /var/lib/mysql/hss_db ]; then
	echo 'Creating database for FHoSS'
	mysql -u root < /mnt/mysql/fhoss/init.sql
	mysql -u root hss_db < /mnt/mysql/fhoss/hss_db.sql
	mysql -u root hss_db < /mnt/mysql/fhoss/userdata.sql
fi


if [ ! -f /var/lib/mysql/kamailio.sem ]; then
	echo 'Grant privileges.'
	mysql -u root < /mnt/mysql/init.sql
	:> /var/lib/mysql/kamailio.sem
fi

echo 'MySQL is running.'
while true; do
	sleep 5
done
