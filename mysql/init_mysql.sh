#!/bin/bash -e
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

if [ ! -f /var/lib/mysql/kamailio.sem ]; then
	echo 'Grant privileges.'
	mysql -u root < /init.sql
	:> /var/lib/mysql/kamailio.sem
fi

echo 'MySQL is running.'
while true; do
	sleep 5
done
