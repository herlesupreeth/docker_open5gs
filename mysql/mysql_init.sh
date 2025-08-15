#!/bin/bash

# BSD 2-Clause License

# Copyright (c) 2020-2025, Supreeth Herle
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s/# max_connections        = 151/max_connections        = 250/g" /etc/mysql/mysql.conf.d/mysqld.cnf
cat > ~/.my.cnf <<EOF
[mysql]
user=root
password=ims
EOF

usermod -d /var/lib/mysql/ mysql

echo 'Waiting for MySQL to start.'
/etc/init.d/mysql restart
while true; do
	echo 'quit' | mysql --connect-timeout=1 && break
done

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Grant privileges and set max connections
ROOT_USER_EXISTS=`mysql -u root -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'root' AND Host = '%')"`
if [[ "$ROOT_USER_EXISTS" == 0 ]]
then
	mysql -u root -e "CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'ims'";
	mysql -u root -e "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION";
	mysql -u root -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY ''"
	mysql -u root -e "FLUSH PRIVILEGES;"
fi

pkill -9 mysqld
sleep 5
exec mysqld_safe $@
