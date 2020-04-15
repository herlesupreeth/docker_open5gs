#!/bin/bash
#

FILE=hss_db.sql

mysqldump hss_db -d -B --add-drop-table --add-drop-database >$FILE
echo "# DB access rights" >>$FILE
echo "grant delete,insert,select,update on hss_db.* to hss@localhost identified by 'hss';" >>$FILE

FILE=userdata.sql
mysqldump hss_db -t -B  >$FILE




