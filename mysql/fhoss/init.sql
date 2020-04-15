CREATE DATABASE hss_db;
GRANT ALL PRIVILEGES ON hss_db.* TO 'hss'@'localhost' identified by 'hss';
GRANT ALL PRIVILEGES ON hss_db.* TO 'hss'@'%' identified by 'hss';
FLUSH PRIVILEGES;
