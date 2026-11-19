-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 172.22.0.101
-- Generation Time: Jul 01, 2025 at 01:26 AM
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
-- Database: `opensips`
--

CREATE DATABASE IF NOT EXISTS opensips;
CREATE USER IF NOT EXISTS 'opensips'@'%' IDENTIFIED BY 'opensipsrw';
GRANT ALL PRIVILEGES ON opensips.* TO 'opensips'@'%';
USE opensips;

-- --------------------------------------------------------

--
-- Table structure for table `acc`
--

CREATE TABLE `acc` (
  `id` int UNSIGNED NOT NULL,
  `method` char(16) NOT NULL DEFAULT '',
  `from_tag` char(64) NOT NULL DEFAULT '',
  `to_tag` char(64) NOT NULL DEFAULT '',
  `callid` char(64) NOT NULL DEFAULT '',
  `sip_code` char(3) NOT NULL DEFAULT '',
  `sip_reason` char(32) NOT NULL DEFAULT '',
  `time` datetime NOT NULL,
  `duration` int UNSIGNED NOT NULL DEFAULT '0',
  `ms_duration` int UNSIGNED NOT NULL DEFAULT '0',
  `setuptime` int UNSIGNED NOT NULL DEFAULT '0',
  `created` datetime DEFAULT NULL,
  `caller_ip` varchar(255) DEFAULT NULL,
  `caller_ua` varchar(255) DEFAULT NULL,
  `callee_ip` varchar(255) DEFAULT NULL,
  `callee_ua` varchar(255) DEFAULT NULL,
  `caller_id` varchar(255) DEFAULT NULL,
  `callee_id` varchar(255) DEFAULT NULL,
  `leg_status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `active_watchers`
--

CREATE TABLE `active_watchers` (
  `id` int UNSIGNED NOT NULL,
  `presentity_uri` char(255) NOT NULL,
  `watcher_username` char(64) NOT NULL,
  `watcher_domain` char(64) NOT NULL,
  `to_user` char(64) NOT NULL,
  `to_domain` char(64) NOT NULL,
  `event` char(64) NOT NULL DEFAULT 'presence',
  `event_id` char(64) DEFAULT NULL,
  `to_tag` char(64) NOT NULL,
  `from_tag` char(64) NOT NULL,
  `callid` char(64) NOT NULL,
  `local_cseq` int NOT NULL,
  `remote_cseq` int NOT NULL,
  `contact` char(255) NOT NULL,
  `record_route` text,
  `expires` int NOT NULL,
  `status` int NOT NULL DEFAULT '2',
  `reason` char(64) DEFAULT NULL,
  `version` int NOT NULL DEFAULT '0',
  `socket_info` char(64) NOT NULL,
  `local_contact` char(255) NOT NULL,
  `sharing_tag` char(32) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `config`
--

CREATE TABLE `config` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `description` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dbaliases`
--

CREATE TABLE `dbaliases` (
  `id` int UNSIGNED NOT NULL,
  `alias_username` char(64) NOT NULL DEFAULT '',
  `alias_domain` char(64) NOT NULL DEFAULT '',
  `username` char(64) NOT NULL DEFAULT '',
  `domain` char(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dialog`
--

CREATE TABLE `dialog` (
  `dlg_id` bigint UNSIGNED NOT NULL,
  `callid` char(255) NOT NULL,
  `from_uri` char(255) NOT NULL,
  `from_tag` char(64) NOT NULL,
  `to_uri` char(255) NOT NULL,
  `to_tag` char(64) NOT NULL,
  `mangled_from_uri` char(255) DEFAULT NULL,
  `mangled_to_uri` char(255) DEFAULT NULL,
  `caller_cseq` char(11) NOT NULL,
  `callee_cseq` char(11) NOT NULL,
  `caller_ping_cseq` int UNSIGNED NOT NULL,
  `callee_ping_cseq` int UNSIGNED NOT NULL,
  `caller_route_set` text,
  `callee_route_set` text,
  `caller_contact` char(255) DEFAULT NULL,
  `callee_contact` char(255) DEFAULT NULL,
  `caller_sock` char(64) NOT NULL,
  `callee_sock` char(64) NOT NULL,
  `state` int UNSIGNED NOT NULL,
  `start_time` int UNSIGNED NOT NULL,
  `timeout` int UNSIGNED NOT NULL,
  `vars` blob,
  `profiles` text,
  `script_flags` char(255) DEFAULT NULL,
  `module_flags` int UNSIGNED NOT NULL DEFAULT '0',
  `flags` int UNSIGNED NOT NULL DEFAULT '0',
  `rt_on_answer` char(64) DEFAULT NULL,
  `rt_on_timeout` char(64) DEFAULT NULL,
  `rt_on_hangup` char(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dialplan`
--

CREATE TABLE `dialplan` (
  `id` int UNSIGNED NOT NULL,
  `dpid` int NOT NULL,
  `pr` int NOT NULL DEFAULT '0',
  `match_op` int NOT NULL,
  `match_exp` char(64) NOT NULL,
  `match_flags` int NOT NULL DEFAULT '0',
  `subst_exp` char(64) DEFAULT NULL,
  `repl_exp` char(32) DEFAULT NULL,
  `timerec` char(255) DEFAULT NULL,
  `disabled` int NOT NULL DEFAULT '0',
  `attrs` char(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `dialplan`
--

INSERT INTO `dialplan` (`id`, `dpid`, `pr`, `match_op`, `match_exp`, `match_flags`, `subst_exp`, `repl_exp`, `timerec`, `disabled`, `attrs`) VALUES
(1, 1, 0, 1, '^(\\+|00|011|0)?[1-9][0-9]{6,}$', 0, NULL, NULL, NULL, 0, 'DP_DID'),
(2, 1, 0, 1, '^[a-zA-Z][a-zA-Z0-9\\-_\\.]{4,}$', 0, NULL, NULL, NULL, 0, 'DP_USER'),
(3, 1, 0, 1, '^\\*78$', 0, NULL, NULL, NULL, 0, 'DP_DND_ON'),
(4, 1, 0, 1, '^\\*79$', 0, NULL, NULL, NULL, 0, 'DP_DND_OFF'),
(5, 1, 0, 1, '^\\*98$', 0, NULL, NULL, NULL, 0, 'DP_VMLISTEN'),
(6, 1, 0, 1, '^\\*21\\*.*$', 0, NULL, NULL, NULL, 0, 'DP_CFU'),
(7, 1, 0, 1, '^\\*22\\*[0-9]$', 0, NULL, NULL, NULL, 0, 'DP_VM'),
(8, 1, 0, 1, '^\\*61\\*.*$', 0, NULL, NULL, NULL, 0, 'DP_CFNA'),
(9, 1, 0, 1, '^\\*62\\*.*$', 0, NULL, NULL, NULL, 0, 'DP_CFNR'),
(10, 1, 0, 1, '^\\*67\\*.*$', 0, NULL, NULL, NULL, 0, 'DP_CFB'),
(11, 1, 0, 1, '^\\*31\\*[1-2]$', 0, NULL, NULL, NULL, 0, 'DP_OIR'),
(12, 1, 0, 1, '^\\*77\\*[1-2]$', 0, NULL, NULL, NULL, 0, 'DP_TIR');


-- --------------------------------------------------------

--
-- Table structure for table `dids`
--

CREATE TABLE `dids` (
  `id` int UNSIGNED NOT NULL,
  `alias_username` char(64) NOT NULL DEFAULT '',
  `alias_domain` char(64) NOT NULL DEFAULT '',
  `username` char(64) NOT NULL DEFAULT '',
  `domain` char(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dispatcher`
--

CREATE TABLE `dispatcher` (
  `id` int UNSIGNED NOT NULL,
  `setid` int NOT NULL DEFAULT '0',
  `destination` char(192) NOT NULL DEFAULT '',
  `socket` char(128) DEFAULT NULL,
  `state` int NOT NULL DEFAULT '0',
  `probe_mode` int UNSIGNED NOT NULL DEFAULT '0',
  `weight` char(64) NOT NULL DEFAULT '1',
  `priority` int NOT NULL DEFAULT '0',
  `attrs` char(128) DEFAULT NULL,
  `description` char(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `domain`
--

CREATE TABLE `domain` (
  `id` int UNSIGNED NOT NULL,
  `domain` char(64) NOT NULL DEFAULT '',
  `attrs` char(255) DEFAULT NULL,
  `accept_subdomain` int UNSIGNED NOT NULL DEFAULT '0',
  `last_modified` datetime NOT NULL DEFAULT '1900-01-01 00:00:01'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `domain`
--

INSERT INTO `domain` (`id`, `domain`, `attrs`, `accept_subdomain`, `last_modified`) VALUES
(1, 'ims.mnc001.mcc001.3gppnetwork.org', NULL, 0, '1900-01-01 00:00:01');

-- --------------------------------------------------------

--
-- Table structure for table `dr_carriers`
--

CREATE TABLE `dr_carriers` (
  `id` int UNSIGNED NOT NULL,
  `carrierid` char(64) NOT NULL,
  `gwlist` char(255) NOT NULL,
  `flags` int UNSIGNED NOT NULL DEFAULT '0',
  `sort_alg` char(1) NOT NULL DEFAULT 'N',
  `state` int UNSIGNED NOT NULL DEFAULT '0',
  `attrs` char(255) DEFAULT NULL,
  `description` char(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dr_gateways`
--

CREATE TABLE `dr_gateways` (
  `id` int UNSIGNED NOT NULL,
  `gwid` char(64) NOT NULL,
  `type` int UNSIGNED NOT NULL DEFAULT '0',
  `address` char(128) NOT NULL,
  `strip` int UNSIGNED NOT NULL DEFAULT '0',
  `pri_prefix` char(16) DEFAULT NULL,
  `attrs` char(255) DEFAULT NULL,
  `probe_mode` int UNSIGNED NOT NULL DEFAULT '0',
  `state` int UNSIGNED NOT NULL DEFAULT '0',
  `socket` char(128) DEFAULT NULL,
  `description` char(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dr_groups`
--

CREATE TABLE `dr_groups` (
  `id` int UNSIGNED NOT NULL,
  `username` char(64) NOT NULL,
  `domain` char(128) DEFAULT NULL,
  `groupid` int UNSIGNED NOT NULL DEFAULT '0',
  `description` char(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dr_partitions`
--

CREATE TABLE `dr_partitions` (
  `id` int UNSIGNED NOT NULL,
  `partition_name` char(255) NOT NULL,
  `db_url` char(255) NOT NULL,
  `drd_table` char(255) DEFAULT NULL,
  `drr_table` char(255) DEFAULT NULL,
  `drg_table` char(255) DEFAULT NULL,
  `drc_table` char(255) DEFAULT NULL,
  `ruri_avp` char(255) DEFAULT NULL,
  `gw_id_avp` char(255) DEFAULT NULL,
  `gw_priprefix_avp` char(255) DEFAULT NULL,
  `gw_sock_avp` char(255) DEFAULT NULL,
  `rule_id_avp` char(255) DEFAULT NULL,
  `rule_prefix_avp` char(255) DEFAULT NULL,
  `carrier_id_avp` char(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dr_rules`
--

CREATE TABLE `dr_rules` (
  `ruleid` int UNSIGNED NOT NULL,
  `groupid` char(255) NOT NULL,
  `prefix` char(64) NOT NULL,
  `timerec` char(255) DEFAULT NULL,
  `priority` int NOT NULL DEFAULT '0',
  `routeid` char(255) DEFAULT NULL,
  `gwlist` char(255) DEFAULT NULL,
  `sort_alg` char(1) NOT NULL DEFAULT 'N',
  `sort_profile` int UNSIGNED DEFAULT NULL,
  `attrs` char(255) DEFAULT NULL,
  `description` char(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `location`
--

CREATE TABLE `location` (
  `contact_id` bigint UNSIGNED NOT NULL,
  `username` char(64) NOT NULL DEFAULT '',
  `domain` char(64) DEFAULT NULL,
  `contact` text NOT NULL,
  `received` char(255) DEFAULT NULL,
  `path` char(255) DEFAULT NULL,
  `expires` int UNSIGNED NOT NULL,
  `q` float(10,2) NOT NULL DEFAULT '1.00',
  `callid` char(255) NOT NULL DEFAULT 'Default-Call-ID',
  `cseq` int NOT NULL DEFAULT '13',
  `last_modified` datetime NOT NULL DEFAULT '1900-01-01 00:00:01',
  `flags` int NOT NULL DEFAULT '0',
  `cflags` char(255) DEFAULT NULL,
  `user_agent` char(255) NOT NULL DEFAULT '',
  `socket` char(64) DEFAULT NULL,
  `methods` int DEFAULT NULL,
  `sip_instance` char(255) DEFAULT NULL,
  `kv_store` text,
  `attr` char(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `missed_calls`
--

CREATE TABLE `missed_calls` (
  `id` int UNSIGNED NOT NULL,
  `method` char(16) NOT NULL DEFAULT '',
  `from_tag` char(64) NOT NULL DEFAULT '',
  `to_tag` char(64) NOT NULL DEFAULT '',
  `callid` char(64) NOT NULL DEFAULT '',
  `sip_code` char(3) NOT NULL DEFAULT '',
  `sip_reason` char(32) NOT NULL DEFAULT '',
  `time` datetime NOT NULL,
  `setuptime` int UNSIGNED NOT NULL DEFAULT '0',
  `created` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ocp_admin_privileges`
--

CREATE TABLE `ocp_admin_privileges` (
  `id` int UNSIGNED NOT NULL,
  `first_name` varchar(64) NOT NULL DEFAULT '',
  `last_name` varchar(64) NOT NULL DEFAULT '',
  `username` varchar(64) NOT NULL DEFAULT '',
  `password` varchar(64) NOT NULL DEFAULT '',
  `ha1` varchar(256) DEFAULT '',
  `blocked` varchar(60) DEFAULT NULL,
  `failed_attempts` int DEFAULT '0',
  `available_tools` varchar(512) NOT NULL DEFAULT '',
  `permissions` varchar(512) DEFAULT NULL,
  `secret` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ocp_admin_privileges`
--

INSERT INTO `ocp_admin_privileges` (`id`, `first_name`, `last_name`, `username`, `password`, `ha1`, `blocked`, `failed_attempts`, `available_tools`, `permissions`, `secret`) VALUES
(1, 'Super', 'Admin', 'admin', 'opensips', '0273461fc6bf55340b21e41b9adc41bf', NULL, 0, 'all', 'all', NULL),
(2, 'Super', 'Admin', 'admin', 'opensips', '0273461fc6bf55340b21e41b9adc41bf', NULL, 0, 'all', 'all', NULL),
(3, 'Super', 'Admin', 'admin', 'opensips', '0273461fc6bf55340b21e41b9adc41bf', NULL, 0, 'all', 'all', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `ocp_boxes_config`
--

CREATE TABLE `ocp_boxes_config` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  `mi_conn` varchar(64) DEFAULT NULL,
  `monit_conn` varchar(64) DEFAULT NULL,
  `monit_user` varchar(64) DEFAULT NULL,
  `monit_pass` varchar(64) DEFAULT NULL,
  `monit_ssl` tinyint NOT NULL DEFAULT '0',
  `smonitcharts` tinyint NOT NULL DEFAULT '1',
  `assoc_id` varchar(10) DEFAULT '-1',
  `desc` varchar(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ocp_boxes_config`
--

INSERT INTO `ocp_boxes_config` (`id`, `name`, `mi_conn`, `monit_conn`, `monit_user`, `monit_pass`, `monit_ssl`, `smonitcharts`, `assoc_id`, `desc`) VALUES
(1, '', 'json:172.22.0.100:8888/mi', NULL, NULL, NULL, 0, 1, '1', 'Default box');

-- --------------------------------------------------------

--
-- Table structure for table `ocp_dashboard`
--

CREATE TABLE `ocp_dashboard` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(64) DEFAULT NULL,
  `content` text,
  `order` int DEFAULT NULL,
  `positions` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ocp_dashboard`
--

INSERT INTO `ocp_dashboard` (`id`, `name`, `content`, `order`, `positions`) VALUES
(1, 'Default', '{\"panel_1_widget_1\":\"{\\\"widget_title\\\":\\\"Users\\\",\\\"widget_box\\\":\\\"1\\\",\\\"addwidget\\\":\\\"Add\\\",\\\"widget_type\\\":\\\"registered_users_widget\\\",\\\"panel_id\\\":\\\"1\\\",\\\"widget_id\\\":\\\"panel_1_widget_1\\\"}\",\"panel_1_widget_2\":\"{\\\"widget_name\\\":\\\"CDR\\\",\\\"widget_refresh\\\":\\\"30\\\",\\\"addwidget\\\":\\\"Add\\\",\\\"widget_type\\\":\\\"cdr_widget\\\",\\\"panel_id\\\":\\\"1\\\",\\\"widget_id\\\":\\\"panel_1_widget_2\\\"}\",\"panel_1_widget_3\":\"{\\\"widget_title\\\":\\\"PKG Usage\\\",\\\"widget_box\\\":\\\"1\\\",\\\"widget_warning\\\":\\\"50\\\",\\\"widget_critical\\\":\\\"75\\\",\\\"widget_refresh\\\":\\\"\\\",\\\"addwidget\\\":\\\"Add\\\",\\\"widget_type\\\":\\\"pkg_widget\\\",\\\"panel_id\\\":\\\"1\\\",\\\"widget_id\\\":\\\"panel_1_widget_3\\\"}\",\"panel_1_widget_4\":\"{\\\"widget_title\\\":\\\"Shared memory\\\",\\\"widget_box\\\":\\\"1\\\",\\\"widget_warning\\\":\\\"50\\\",\\\"widget_critical\\\":\\\"75\\\",\\\"widget_refresh\\\":\\\"60\\\",\\\"addwidget\\\":\\\"Add\\\",\\\"widget_type\\\":\\\"shmem_widget\\\",\\\"panel_id\\\":\\\"1\\\",\\\"widget_id\\\":\\\"panel_1_widget_4\\\"}\",\"panel_1_widget_6\":\"{\\\"widget_name\\\":\\\"Dispatching\\\",\\\"widget_box\\\":\\\"1\\\",\\\"widget_partition\\\":\\\"default\\\",\\\"widget_set\\\":\\\"\\\",\\\"widget_refresh\\\":\\\"30\\\",\\\"editwidget\\\":\\\"Edit\\\",\\\"panel_id\\\":\\\"1\\\",\\\"widget_type\\\":\\\"dispatching_widget\\\",\\\"widget_id\\\":\\\"panel_1_widget_6\\\"}\",\"panel_1_widget_7\":\"{\\\"widget_name\\\":\\\"Dynamic Routing\\\",\\\"widget_box\\\":\\\"1\\\",\\\"widget_partition\\\":\\\"\\\",\\\"widget_refresh\\\":\\\"30\\\",\\\"editwidget\\\":\\\"Edit\\\",\\\"panel_id\\\":\\\"1\\\",\\\"widget_type\\\":\\\"gateways_widget\\\",\\\"widget_id\\\":\\\"panel_1_widget_7\\\"}\",\"panel_1_widget_11\":\"{\\\"widget_name\\\":\\\"RTPProxy\\\",\\\"widget_box\\\":\\\"1\\\",\\\"widget_set\\\":\\\"0\\\",\\\"widget_refresh\\\":\\\"60\\\",\\\"addwidget\\\":\\\"Add\\\",\\\"widget_type\\\":\\\"rtpproxy_widget\\\",\\\"panel_id\\\":\\\"1\\\",\\\"widget_id\\\":\\\"panel_1_widget_11\\\"}\",\"panel_1_widget_15\":\"{\\\"widget_name\\\":\\\"RTPEngine\\\",\\\"widget_box\\\":\\\"1\\\",\\\"widget_set\\\":\\\"0\\\",\\\"widget_refresh\\\":\\\"60\\\",\\\"addwidget\\\":\\\"Add\\\",\\\"widget_type\\\":\\\"rtpengine_widget\\\",\\\"panel_id\\\":\\\"1\\\",\\\"widget_id\\\":\\\"panel_1_widget_15\\\"}\"}', 1, '[{\"id\":\"panel_1_widget_1\",\"col\":6,\"row\":1,\"size_x\":2,\"size_y\":3},{\"id\":\"panel_1_widget_2\",\"col\":8,\"row\":1,\"size_x\":2,\"size_y\":3},{\"id\":\"panel_1_widget_3\",\"col\":4,\"row\":1,\"size_x\":2,\"size_y\":3},{\"id\":\"panel_1_widget_4\",\"col\":2,\"row\":1,\"size_x\":2,\"size_y\":3},{\"id\":\"panel_1_widget_6\",\"col\":2,\"row\":6,\"size_x\":2,\"size_y\":2},{\"id\":\"panel_1_widget_7\",\"col\":4,\"row\":6,\"size_x\":2,\"size_y\":2},{\"id\":\"panel_1_widget_11\",\"col\":6,\"row\":6,\"size_x\":2,\"size_y\":2},{\"id\":\"panel_1_widget_15\",\"col\":8,\"row\":6,\"size_x\":2,\"size_y\":2}]');

-- --------------------------------------------------------

--
-- Table structure for table `ocp_db_config`
--

CREATE TABLE `ocp_db_config` (
  `id` int NOT NULL,
  `config_name` varchar(64) NOT NULL,
  `db_host` varchar(64) NOT NULL,
  `db_port` varchar(64) NOT NULL,
  `db_user` varchar(64) NOT NULL,
  `db_pass` varchar(64) DEFAULT NULL,
  `db_name` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ocp_extra_stats`
--

CREATE TABLE `ocp_extra_stats` (
  `id` int NOT NULL,
  `name` text,
  `input` text,
  `box_id` int DEFAULT NULL,
  `tool` varchar(60) DEFAULT NULL,
  `class` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ocp_monitored_stats`
--

CREATE TABLE `ocp_monitored_stats` (
  `name` varchar(64) NOT NULL,
  `box_id` mediumint UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ocp_monitoring_stats`
--

CREATE TABLE `ocp_monitoring_stats` (
  `name` varchar(64) NOT NULL,
  `time` int NOT NULL,
  `value` varchar(64) NOT NULL DEFAULT '0',
  `box_id` mediumint UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ocp_system_config`
--

CREATE TABLE `ocp_system_config` (
  `assoc_id` bigint UNSIGNED NOT NULL,
  `name` varchar(64) DEFAULT NULL,
  `desc` varchar(64) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ocp_system_config`
--

INSERT INTO `ocp_system_config` (`assoc_id`, `name`, `desc`) VALUES
(1, 'System 0', 'Default system');

-- --------------------------------------------------------

--
-- Table structure for table `ocp_tools_config`
--

CREATE TABLE `ocp_tools_config` (
  `id` bigint UNSIGNED NOT NULL,
  `module` varchar(64) NOT NULL,
  `param` varchar(64) NOT NULL,
  `value` blob,
  `box_id` varchar(15) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ocp_tools_config`
--

INSERT INTO `ocp_tools_config` (`id`, `module`, `param`, `value`, `box_id`) VALUES
(1, 'user_management', 'passwd_mode', 0x31, ''),
(2, 'user_management', 'subs_extra_actions', 0x7b2261636c73223a7b22686561646572223a2241434c73222c2269636f6e223a222e2e5c2f2e2e5c2f2e2e5c2f696d616765735c2f73686172655c2f6163636573732e706e67222c22616374696f6e223a225365742041434c73222c22616374696f6e5f66696c65223a22757365725f6d616e6167656d656e745f61636c732e706870222c22616374696f6e5f66756e63223a2266756e6374696f6e202824726573756c7429207b2072657475726e205c226a6176617363726970743a3b5c5c5c22206f6e636c69636b3d5c5c5c2272756e5f696e5f77696e646f772827757365725f6d616e6167656d656e745f61636c732e7068703f7569643d5c222e24726573756c745b276964275d2e5c2227295c223b7d227d7d, ''),
(3, 'user_management', 'subs_extra', 0x7b22636661775f757269223a7b22686561646572223a22416c7761797320466f7277617264222c22696e666f223a22416c7761797320666f72776172642063616c6c7320746f207468697320555249222c2273686f775f696e5f6d61696e5f666f726d223a747275652c2273686f775f696e5f6164645f666f726d223a747275652c2273686f775f696e5f656469745f666f726d223a747275652c2269735f6f7074696f6e616c223a2279222c2273656172636861626c65223a66616c73657d2c22636662735f757269223a7b22686561646572223a224275737920466f7277617264222c22696e666f223a225768656e20627573792c20666f7277617264207468652063616c6c20746f207468697320555249222c2273686f775f696e5f6d61696e5f666f726d223a747275652c2273686f775f696e5f6164645f666f726d223a747275652c2273686f775f696e5f656469745f666f726d223a747275652c2269735f6f7074696f6e616c223a2279222c2273656172636861626c65223a66616c73657d2c2263666e615f757269223a7b22686561646572223a224e6f20416e7377657220466f7277617264222c22696e666f223a225768656e207468657265206973206e6f20616e737765722c20666f7277617264207468652063616c6c20746f207468697320555249222c2273686f775f696e5f6d61696e5f666f726d223a747275652c2273686f775f696e5f6164645f666f726d223a747275652c2273686f775f696e5f656469745f666f726d223a747275652c2269735f6f7074696f6e616c223a2279222c2273656172636861626c65223a66616c73657d2c2263666e665f757269223a7b22686561646572223a224e6f7420466f756e6420466f7277617264222c22696e666f223a225768656e2063616c6c6565206973206e6f7420666f756e642c20666f7277617264207468652063616c6c20746f207468697320555249222c2273686f775f696e5f6d61696e5f666f726d223a747275652c2273686f775f696e5f6164645f666f726d223a747275652c2273686f775f696e5f656469745f666f726d223a747275652c2269735f6f7074696f6e616c223a2279222c2273656172636861626c65223a66616c73657d7d, ''),
(4, 'user_management', 'user_format_func', 0x66756e6374696f6e28247573657229207b0d0a202020207265717569726528226d695f636f6d6d2e70687022293b0d0a202020207265717569726528226366675f636f6d6d2e70687022293b0d0a0d0a20202020246d695f636f6e6e6563746f7273203d206765745f70726f7879735f62795f6173736f635f6964286765745f73657474696e67735f76616c7565282774616c6b5f746f5f746869735f6173736f635f69642729293b0d0a0d0a20202020246572726f7273203d205b5d3b0d0a0d0a2020202069662028656d70747928246d695f636f6e6e6563746f72732929207b0d0a202020202020202072657475726e2066616c73653b0d0a202020207d0d0a0d0a2020202024726573756c74203d206d695f636f6d6d616e64282264705f7472616e736c617465222c205b226470696422203d3e20312c2022696e70757422203d3e2024757365725d2c20246d695f636f6e6e6563746f72735b305d2c20246572726f7273293b0d0a0d0a202020206966202821656d70747928246572726f72732929207b0d0a202020202020202072657475726e2066616c73653b0d0a202020207d0d0a0d0a2020202072657475726e2024726573756c745b2241545452494255544553225d203d3d202244505f55534552223b0d0a7d, ''),
(5, 'alias_management', 'table_aliases', 0x7b2244494473223a2264696473227d, ''),
(6, 'alias_management', 'implicit_domain', 0x31, ''),
(7, 'alias_management', 'suppress_alias_type', 0x31, ''),
(8, 'drouting', 'tabs', 0x67617465776179732e7068702c63617272696572732e7068702c72756c65732e706870, ''),
(9, 'drouting', 'group_ids_file', 0x7b2231223a2244656661756c74227d, ''),
(10, 'drouting', 'gw_attributes_mode', 0x6e6f6e65, ''),
(11, 'drouting', 'carrier_attributes_mode', 0x6e6f6e65, '');

-- --------------------------------------------------------

--
-- Table structure for table `presentity`
--

CREATE TABLE `presentity` (
  `id` int UNSIGNED NOT NULL,
  `username` char(64) NOT NULL,
  `domain` char(64) NOT NULL,
  `event` char(64) NOT NULL,
  `etag` char(64) NOT NULL,
  `expires` int NOT NULL,
  `received_time` int NOT NULL,
  `body` blob,
  `extra_hdrs` blob,
  `sender` char(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pua`
--

CREATE TABLE `pua` (
  `id` int UNSIGNED NOT NULL,
  `pres_uri` char(255) NOT NULL,
  `pres_id` char(255) NOT NULL,
  `event` int NOT NULL,
  `expires` int NOT NULL,
  `desired_expires` int NOT NULL,
  `flag` int NOT NULL,
  `etag` char(64) DEFAULT NULL,
  `tuple_id` char(64) DEFAULT NULL,
  `watcher_uri` char(255) DEFAULT NULL,
  `to_uri` char(255) DEFAULT NULL,
  `call_id` char(64) DEFAULT NULL,
  `to_tag` char(64) DEFAULT NULL,
  `from_tag` char(64) DEFAULT NULL,
  `cseq` int DEFAULT NULL,
  `record_route` text,
  `contact` char(255) DEFAULT NULL,
  `remote_contact` char(255) DEFAULT NULL,
  `version` int DEFAULT NULL,
  `extra_headers` text,
  `sharing_tag` char(32) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rtpproxy_sockets`
--

CREATE TABLE `rtpproxy_sockets` (
  `id` int UNSIGNED NOT NULL,
  `rtpproxy_sock` text NOT NULL,
  `set_id` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `rtpproxy_sockets`
--

INSERT INTO `rtpproxy_sockets` (`id`, `rtpproxy_sock`, `set_id`) VALUES
(1, 'udp:172.22.0.104:7899', 0);

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
-- Table structure for table `subscriber`
--

CREATE TABLE `subscriber` (
  `id` int UNSIGNED NOT NULL,
  `username` char(64) NOT NULL DEFAULT '',
  `domain` char(64) NOT NULL DEFAULT '',
  `password` char(25) NOT NULL DEFAULT '',
  `ha1` char(64) NOT NULL DEFAULT '',
  `ha1_sha256` char(64) NOT NULL DEFAULT '',
  `ha1_sha512t256` char(64) NOT NULL DEFAULT '',
  `cli` varchar(255) DEFAULT NULL,
  `acls` varchar(32) NOT NULL DEFAULT '',
  `cfaw_uri` varchar(255) DEFAULT NULL,
  `cfbs_uri` varchar(255) DEFAULT NULL,
  `cfna_uri` varchar(255) DEFAULT NULL,
  `cfna_timer` int DEFAULT '120',
  `cfnf_uri` varchar(255) DEFAULT NULL,
  `oir` varchar(8) DEFAULT 'false',
  `tir` varchar(8) DEFAULT 'false',  
  `vmail_password` varchar(8) NOT NULL DEFAULT '1234',
  `first_name` varchar(25) NOT NULL DEFAULT '',
  `last_name` varchar(45) NOT NULL DEFAULT '',
  `email_address` varchar(50) NOT NULL DEFAULT '',
  `datetime_created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `rpid` varchar(25) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `uri`
--

CREATE TABLE `uri` (
  `id` int UNSIGNED NOT NULL,
  `username` char(64) NOT NULL DEFAULT '',
  `domain` char(64) NOT NULL DEFAULT '',
  `uri_user` char(64) NOT NULL DEFAULT '',
  `last_modified` datetime NOT NULL DEFAULT '1900-01-01 00:00:01'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `usr_preferences`
--

CREATE TABLE `usr_preferences` (
  `id` int UNSIGNED NOT NULL,
  `uuid` char(64) NOT NULL DEFAULT '',
  `username` char(64) NOT NULL DEFAULT '0',
  `domain` char(64) NOT NULL DEFAULT '',
  `attribute` char(32) NOT NULL DEFAULT '',
  `type` int NOT NULL DEFAULT '0',
  `value` char(128) NOT NULL DEFAULT '',
  `last_modified` datetime NOT NULL DEFAULT '1900-01-01 00:00:01'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `version`
--

CREATE TABLE `version` (
  `table_name` char(32) NOT NULL,
  `table_version` int UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `version`
--

INSERT INTO `version` (`table_name`, `table_version`) VALUES
('acc', 7),
('active_watchers', 12),
('dbaliases', 2),
('dialog', 12),
('dialplan', 5),
('dids', 1),
('dispatcher', 9),
('domain', 4),
('dr_carriers', 3),
('dr_gateways', 6),
('dr_groups', 2),
('dr_partitions', 1),
('dr_rules', 4),
('location', 1013),
('missed_calls', 5),
('presentity', 5),
('pua', 9),
('rtpproxy_sockets', 0),
('subscriber', 8),
('uri', 2),
('usr_preferences', 3),
('watchers', 4),
('xcap', 4);

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
-- Table structure for table `watchers`
--

CREATE TABLE `watchers` (
  `id` int UNSIGNED NOT NULL,
  `presentity_uri` char(255) NOT NULL,
  `watcher_username` char(64) NOT NULL,
  `watcher_domain` char(64) NOT NULL,
  `event` char(64) NOT NULL DEFAULT 'presence',
  `status` int NOT NULL,
  `reason` char(64) DEFAULT NULL,
  `inserted_time` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `xcap`
--

CREATE TABLE `xcap` (
  `id` int UNSIGNED NOT NULL,
  `username` char(64) NOT NULL,
  `domain` char(64) NOT NULL,
  `doc` longblob NOT NULL,
  `doc_type` int NOT NULL,
  `etag` char(64) NOT NULL,
  `source` int NOT NULL,
  `doc_uri` char(255) NOT NULL,
  `port` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `acc`
--
ALTER TABLE `acc`
  ADD PRIMARY KEY (`id`),
  ADD KEY `callid_idx` (`callid`);

--
-- Indexes for table `active_watchers`
--
ALTER TABLE `active_watchers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `active_watchers_idx` (`presentity_uri`,`callid`,`to_tag`,`from_tag`);

--
-- Indexes for table `config`
--
ALTER TABLE `config`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `dbaliases`
--
ALTER TABLE `dbaliases`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `alias_idx` (`alias_username`,`alias_domain`),
  ADD KEY `target_idx` (`username`,`domain`);

--
-- Indexes for table `dialog`
--
ALTER TABLE `dialog`
  ADD PRIMARY KEY (`dlg_id`);

--
-- Indexes for table `dialplan`
--
ALTER TABLE `dialplan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `dids`
--
ALTER TABLE `dids`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `alias_idx` (`alias_username`,`alias_domain`),
  ADD KEY `target_idx` (`username`,`domain`);

--
-- Indexes for table `dispatcher`
--
ALTER TABLE `dispatcher`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `domain`
--
ALTER TABLE `domain`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `domain_idx` (`domain`);

--
-- Indexes for table `dr_carriers`
--
ALTER TABLE `dr_carriers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `dr_carrier_idx` (`carrierid`);

--
-- Indexes for table `dr_gateways`
--
ALTER TABLE `dr_gateways`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `dr_gw_idx` (`gwid`);

--
-- Indexes for table `dr_groups`
--
ALTER TABLE `dr_groups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `dr_partitions`
--
ALTER TABLE `dr_partitions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `dr_rules`
--
ALTER TABLE `dr_rules`
  ADD PRIMARY KEY (`ruleid`);

--
-- Indexes for table `location`
--
ALTER TABLE `location`
  ADD PRIMARY KEY (`contact_id`);

--
-- Indexes for table `missed_calls`
--
ALTER TABLE `missed_calls`
  ADD PRIMARY KEY (`id`),
  ADD KEY `callid_idx` (`callid`);

--
-- Indexes for table `ocp_admin_privileges`
--
ALTER TABLE `ocp_admin_privileges`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ocp_boxes_config`
--
ALTER TABLE `ocp_boxes_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name_key` (`name`);

--
-- Indexes for table `ocp_dashboard`
--
ALTER TABLE `ocp_dashboard`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ocp_db_config`
--
ALTER TABLE `ocp_db_config`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ocp_extra_stats`
--
ALTER TABLE `ocp_extra_stats`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ocp_monitored_stats`
--
ALTER TABLE `ocp_monitored_stats`
  ADD PRIMARY KEY (`name`,`box_id`);

--
-- Indexes for table `ocp_monitoring_stats`
--
ALTER TABLE `ocp_monitoring_stats`
  ADD PRIMARY KEY (`name`,`time`,`box_id`);

--
-- Indexes for table `ocp_system_config`
--
ALTER TABLE `ocp_system_config`
  ADD PRIMARY KEY (`assoc_id`);

--
-- Indexes for table `ocp_tools_config`
--
ALTER TABLE `ocp_tools_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `box_key` (`module`,`param`,`box_id`);

--
-- Indexes for table `presentity`
--
ALTER TABLE `presentity`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `presentity_idx` (`username`,`domain`,`event`,`etag`);

--
-- Indexes for table `pua`
--
ALTER TABLE `pua`
  ADD PRIMARY KEY (`id`),
  ADD KEY `del1_idx` (`pres_uri`,`event`),
  ADD KEY `del2_idx` (`expires`),
  ADD KEY `update_idx` (`pres_uri`,`pres_id`,`flag`,`event`);

--
-- Indexes for table `rtpproxy_sockets`
--
ALTER TABLE `rtpproxy_sockets`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `subscriber`
--
ALTER TABLE `subscriber`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `account_idx` (`username`,`domain`),
  ADD KEY `username_idx` (`username`);

--
-- Indexes for table `uri`
--
ALTER TABLE `uri`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `account_idx` (`username`,`domain`,`uri_user`);

--
-- Indexes for table `usr_preferences`
--
ALTER TABLE `usr_preferences`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ua_idx` (`uuid`,`attribute`),
  ADD KEY `uda_idx` (`username`,`domain`,`attribute`),
  ADD KEY `value_idx` (`value`);

--
-- Indexes for table `version`
--
ALTER TABLE `version`
  ADD UNIQUE KEY `t_name_idx` (`table_name`);

--
-- Indexes for table `watchers`
--
ALTER TABLE `watchers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `watcher_idx` (`presentity_uri`,`watcher_username`,`watcher_domain`,`event`);

--
-- Indexes for table `xcap`
--
ALTER TABLE `xcap`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `account_doc_type_idx` (`username`,`domain`,`doc_type`,`doc_uri`),
  ADD KEY `source_idx` (`source`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `acc`
--
ALTER TABLE `acc`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `active_watchers`
--
ALTER TABLE `active_watchers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `config`
--
ALTER TABLE `config`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dbaliases`
--
ALTER TABLE `dbaliases`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dialplan`
--
ALTER TABLE `dialplan`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `dids`
--
ALTER TABLE `dids`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dispatcher`
--
ALTER TABLE `dispatcher`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `domain`
--
ALTER TABLE `domain`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `dr_carriers`
--
ALTER TABLE `dr_carriers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dr_gateways`
--
ALTER TABLE `dr_gateways`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dr_groups`
--
ALTER TABLE `dr_groups`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dr_partitions`
--
ALTER TABLE `dr_partitions`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dr_rules`
--
ALTER TABLE `dr_rules`
  MODIFY `ruleid` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `location`
--
ALTER TABLE `location`
  MODIFY `contact_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=221450437927124369;

--
-- AUTO_INCREMENT for table `missed_calls`
--
ALTER TABLE `missed_calls`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ocp_admin_privileges`
--
ALTER TABLE `ocp_admin_privileges`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `ocp_boxes_config`
--
ALTER TABLE `ocp_boxes_config`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `ocp_dashboard`
--
ALTER TABLE `ocp_dashboard`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ocp_db_config`
--
ALTER TABLE `ocp_db_config`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ocp_extra_stats`
--
ALTER TABLE `ocp_extra_stats`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ocp_system_config`
--
ALTER TABLE `ocp_system_config`
  MODIFY `assoc_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ocp_tools_config`
--
ALTER TABLE `ocp_tools_config`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `presentity`
--
ALTER TABLE `presentity`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pua`
--
ALTER TABLE `pua`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rtpproxy_sockets`
--
ALTER TABLE `rtpproxy_sockets`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `subscriber`
--
ALTER TABLE `subscriber`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `uri`
--
ALTER TABLE `uri`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `usr_preferences`
--
ALTER TABLE `usr_preferences`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `watchers`
--
ALTER TABLE `watchers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `xcap`
--
ALTER TABLE `xcap`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;


COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
