FROM open5gs_kamailio

EXPOSE 3306/tcp

COPY init.sql init_mysql.sh /
COPY mysqld.cnf /etc/mysql/mysql.conf.d/

CMD bash /init_mysql.sh
