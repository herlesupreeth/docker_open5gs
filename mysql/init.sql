GRANT ALL PRIVILEGES ON pcscf.* TO pcscf@localhost identified by 'heslo';
GRANT ALL PRIVILEGES ON scscf.* TO scscf@localhost identified by 'heslo';
GRANT ALL PRIVILEGES ON icscf.* TO icscf@localhost identified by 'heslo';
GRANT ALL PRIVILEGES ON icscf.* TO provisioning@localhost identified by 'provi';
GRANT ALL PRIVILEGES ON pcscf.* TO 'pcscf'@'%' identified by 'heslo';
GRANT ALL PRIVILEGES ON scscf.* TO 'scscf'@'%' identified by 'heslo';
GRANT ALL PRIVILEGES ON icscf.* TO 'icscf'@'%' identified by 'heslo';
GRANT ALL PRIVILEGES ON icscf.* TO 'provisioning'@'%' identified by 'provi';
FLUSH PRIVILEGES;

use icscf;
INSERT INTO nds_trusted_domains VALUES (1,'ims.mnc001.mcc001.3gppnetwork.org');
INSERT INTO s_cscf VALUES (1,'First and only S-CSCF','sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060');
INSERT INTO s_cscf_capabilities VALUES (1,1,0),(2,1,1);
