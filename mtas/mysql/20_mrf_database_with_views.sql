-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 172.22.0.101
-- Generation Time: Jul 01, 2025 at 01:28 AM
-- Server version: 9.3.0
-- PHP Version: 8.2.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `asterisk`
--

CREATE DATABASE IF NOT EXISTS asterisk;
CREATE USER IF NOT EXISTS 'asterisk'@'%' IDENTIFIED BY 'asterisk_pwd';
GRANT ALL PRIVILEGES ON asterisk.* TO 'asterisk'@'%';
USE asterisk;

-- --------------------------------------------------------

--
-- Table structure for table `alembic_version_voicemail`
--

CREATE TABLE `alembic_version_voicemail` (
  `version_num` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `alembic_version_voicemail`
--

INSERT INTO `alembic_version_voicemail` (`version_num`) VALUES
('64fae6bbe7fb');

-- --------------------------------------------------------

--
-- Table structure for table `meetme`
--

CREATE TABLE `meetme` (
  `id` int UNSIGNED NOT NULL,
  `confno` varchar(80) NOT NULL DEFAULT '0',
  `username` varchar(64) NOT NULL DEFAULT '',
  `domain` varchar(128) NOT NULL DEFAULT '',
  `pin` varchar(20) DEFAULT NULL,
  `adminpin` varchar(20) DEFAULT NULL,
  `members` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `sipusers`
-- (See below for the actual view)
--
CREATE TABLE `sipusers` (
`name` char(64)
,`type` varchar(6)
,`secret` varbinary(0)
,`host` char(64)
,`callerid` varchar(92)
,`context` varchar(7)
,`mailbox` char(64)
,`nat` varchar(3)
,`qualify` varchar(2)
,`fromuser` char(64)
,`authuser` varbinary(0)
,`fromdomain` char(64)
,`insecure` varbinary(0)
,`canreinvite` varchar(2)
,`disallow` varbinary(0)
,`allow` varbinary(0)
,`restrictcid` varbinary(0)
,`defaultip` char(64)
,`ipaddr` char(64)
,`port` varchar(4)
,`regseconds` varbinary(0)
,`defaultuser` char(64)
,`fullcontact` varbinary(0)
,`regserver` char(64)
,`useragent` varbinary(0)
,`lastms` int
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vmaliases`
-- (See below for the actual view)
--
CREATE TABLE `vmaliases` (
`alias` char(64)
,`context` varchar(7)
,`mailbox` char(64)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vmusers`
-- (See below for the actual view)
--
CREATE TABLE `vmusers` (
`uniqueid` varchar(128)
,`customer_id` char(64)
,`context` varchar(7)
,`mailbox` char(64)
,`password` varchar(8)
,`fullname` varchar(3)
,`email` varchar(50)
,`pager` varbinary(0)
,`stamp` datetime
);

-- --------------------------------------------------------

--
-- Table structure for table `voicemail_messages`
--

CREATE TABLE `voicemail_messages` (
  `dir` varchar(255) NOT NULL,
  `msgnum` int NOT NULL,
  `context` varchar(80) DEFAULT NULL,
  `callerid` varchar(80) DEFAULT NULL,
  `origtime` int DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `recording` longblob,
  `flag` varchar(30) DEFAULT NULL,
  `category` varchar(30) DEFAULT NULL,
  `mailboxuser` varchar(30) DEFAULT NULL,
  `mailboxcontext` varchar(30) DEFAULT NULL,
  `msg_id` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alembic_version_voicemail`
--
ALTER TABLE `alembic_version_voicemail`
  ADD PRIMARY KEY (`version_num`);

--
-- Indexes for table `meetme`
--
ALTER TABLE `meetme`
  ADD PRIMARY KEY (`confno`),
  ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `voicemail_messages`
--
ALTER TABLE `voicemail_messages`
  ADD PRIMARY KEY (`dir`,`msgnum`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `meetme`
--
ALTER TABLE `meetme`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

-- --------------------------------------------------------

-- Create View for sipusers from Opensips-DB
DROP TABLE IF EXISTS `sipusers`;

CREATE VIEW `sipusers` AS select
  `opensips`.`subscriber`.`username` AS `name`
  ,_latin1'friend' AS `type`,
  NULL AS `secret`,
  `opensips`.`subscriber`.`domain` AS `host`,
  concat(`opensips`.`subscriber`.`rpid`,_latin1' ',_latin1'<',`opensips`.`subscriber`.`username`,_latin1'>') AS `callerid`,
  _latin1'default' AS `context`,
  `opensips`.`subscriber`.`username` AS `mailbox`,
  _latin1'yes' AS `nat`,
  _latin1'no' AS `qualify`,
  `opensips`.`subscriber`.`username` AS `fromuser`,
  NULL AS `authuser`,
  `opensips`.`subscriber`.`domain` AS `fromdomain`,
  NULL AS `insecure`,
  _latin1'no' AS `canreinvite`,
  NULL AS `disallow`,
  NULL AS `allow`,
  NULL AS `restrictcid`,
  `opensips`.`subscriber`.`domain` AS `defaultip`,
  `opensips`.`subscriber`.`domain` AS `ipaddr`,
  _latin1'5060' AS `port`,
  NULL AS `regseconds`,
  `opensips`.`subscriber`.`username` AS `defaultuser`,
  NULL AS `fullcontact`,
  `opensips`.`subscriber`.`domain` AS `regserver`,
  NULL AS `useragent`,
  0 AS `lastms`
from `opensips`.`subscriber`;

-- Create View for VMUser from Opensips-DB

DROP TABLE IF EXISTS `vmusers`;

CREATE VIEW `vmusers` AS select
  concat(`opensips`.`subscriber`.`username`,`opensips`.`subscriber`.`domain`) AS `uniqueid`,
  `opensips`.`subscriber`.`username` AS `customer_id`,
  _latin1'default' AS `context`,
  `opensips`.`subscriber`.`username` AS `mailbox`,
  `opensips`.`subscriber`.`vmail_password` AS `password`,
  _latin1'joe' AS `fullname`,
  `opensips`.`subscriber`.`email_address` AS `email`,
  NULL AS `pager`,
  `opensips`.`subscriber`.`datetime_created` AS `stamp`
from `opensips`.`subscriber`;

-- Create View for vmaliases from Opensips-DB

DROP TABLE IF EXISTS `vmaliases`;

CREATE VIEW `asterisk`.`vmaliases` AS select
  `opensips`.`dbaliases`.`alias_username` AS `alias`,
  _latin1'default' AS `context`,
  `opensips`.`dbaliases`.`username` AS `mailbox`
from `opensips`.`dbaliases`;




COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
