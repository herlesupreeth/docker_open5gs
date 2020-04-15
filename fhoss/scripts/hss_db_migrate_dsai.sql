-- MySQL dump 10.10
--
-- Host: localhost    Database: hss_db
-- ------------------------------------------------------
-- Server version	5.0.21-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `hss_db`
--

USE `hss_db`;

--
-- Table structure for table `dsai`
--

DROP TABLE IF EXISTS `dsai`;
CREATE TABLE `dsai` (
  `id` int(11) NOT NULL auto_increment,
  `dsai_tag` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='DSAI table';

--
-- Table structure for table `dsai_ifc`
--

DROP TABLE IF EXISTS `dsai_ifc`;
CREATE TABLE `dsai_ifc` (
  `id` int(11) NOT NULL auto_increment,
  `id_dsai` int(11) NOT NULL default '0',
  `id_ifc` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `idx_id_dsai` (`id_dsai`),
  KEY `idx_id_ifc` (`id_ifc`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED COMMENT='DSAI - iFC Mappings';

--
-- Table structure for table `dsai_impu`
--

DROP TABLE IF EXISTS `dsai_impu`;
CREATE TABLE `dsai_impu` (
  `id` int(11) NOT NULL auto_increment,
  `id_dsai` int(11) NOT NULL default '0',
  `id_impu` int(11) NOT NULL default '0',
  `dsai_value` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `idx_id_dsai` (`id_dsai`),
  KEY `idx_id_impu` (`id_impu`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED COMMENT='DSAI - IMPU/PSI Mappings';

--
-- Update expiration time in subscription old records
--

UPDATE sh_subscription
set expires = -1;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

# DB access rights
grant delete,insert,select,update on hss_db.dsai to hss@localhost identified by 'hss';
grant delete,insert,select,update on hss_db.dsai_ifc to hss@localhost identified by 'hss';
grant delete,insert,select,update on hss_db.dsai_impu to hss@localhost identified by 'hss';
