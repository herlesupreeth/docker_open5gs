<?php
/*
 * Copyright (C) 2011 OpenSIPS Project
 *
 * This file is part of opensips-cp, a free Web Control Panel Application for
 * OpenSIPS SIP server.
 *
 * opensips-cp is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * opensips-cp is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */


### List with all the available modules - you can enable and disable module from here
### Here you can choose which modules to be enabled/disabled in the OpenSIPS-CP interface

$config_admin_modules = array (
	"list_admins"	=> array (
		"enabled"	=> true,
		"name"		=> "Access"
	),
	"boxes_config"    => array (
		"enabled"   => true,
		"name"		=> "Boxes"
	),
	"db_config"    => array (
		"enabled"   => true,
		"name"		=> "DB config"
	)
);

$config_modules 	= array (
	"dashboard"		=> array (
		"enabled"	=> true,
		"name"		=> "Dashboard",
		"icon"		=> "images/icon-dashboard.png",
		"modules"	=> array (
			"dashboard"			=> array (
				"enabled"		=> true,
				"name"			=> "Dashboard",
				"path"			=> "system/dashboard"
			),
		)
	),
	"users"			=> array (
		"enabled" 	=> true,
		"name" 		=> "Users",
		"icon"		=> "images/icon-user.svg",
		"modules"	=> array (
			"user_management"	=> array (
				"enabled"		=> true,
				"name"			=> "User Management"
			),
			"alias_management"	=> array (
				"enabled"		=> true,
				"name"			=> "Alias Management"
			),
			"group_management"	=> array (
				"enabled"		=> false,
				"name"			=> "Group Management"
			),
		)
	),
	"system"		=> array (
		"enabled"	=> true,
		"name"		=> "System",
		"icon"		=> "images/icon-system.svg",
		"modules"	=> array (
			"addresses"			=> array (
				"enabled"		=> false,
				"name"			=> "Addresses"
			),
			"callcenter"		=> array (
				"enabled"		=> false,
				"name"			=> "Callcenter"
			),
			"cdrviewer"			=> array (
				"enabled"		=> true,
				"name"			=> "CDR Viewer"
			),
			"dialog"			=> array (
				"enabled"		=> true,
				"name"			=> "Dialog"
			),
			"dialplan"			=> array (
				"enabled"		=> true,
				"name"			=> "Dialplan"
			),
			"dispatcher"			=> array (
				"enabled"		=> true,
				"name"			=> "Dispatcher"
			),
			"domains"			=> array (
				"enabled"		=> true,
				"name"			=> "Domains"
			),
			"drouting"			=> array (
				"enabled"		=> true,
				"name"			=> "Dynamic Routing"
			),
			"clusterer"			=> array (
				"enabled"		=> false,
				"name"			=> "Clusterer"
			),
			"keepalived"		=> array (
				"enabled"		=> false,
				"name"			=> "Keepalived"
			),
			"loadbalancer"			=> array (
				"enabled"		=> false,
				"name"			=> "Load Balancer"
			),
			"mi"				=> array (
				"enabled"		=> true,
				"name"			=> "MI Commands"
			),
			"monit"				=> array (
				"enabled"		=> false,
				"name"			=> "Monit"
			),
			"siptrace"			=> array (
				"enabled"		=> false,
				"name"			=> "SIP Trace"
			),
			"smonitor"			=> array (
				"enabled"		=> true,
				"name"			=> "Statistics Monitor"
			),
			"statusreport"			=> array (
				"enabled"		=> true,
				"name"			=> "Status Report"
			),
			"tls_mgm"			=> array (
				"enabled"		=> false,
				"name"			=> "TLS Management"
			),
			"uac_registrant"		=> array (
				"enabled"		=> false,
				"name"			=> "UAC Registrant"
			),
			"smpp"				=> array (
				"enabled"		=> false,
				"name"			=> "SMPP Gateway"
			),
			"tcp_mgm"			=> array (
				"enabled"		=> false,
				"name"			=> "TCP Management"
			),
			"tracer"				=> array (
				"enabled"		=> false,
				"name"			=> "Tracer"
			),
		)
	),
);




?>
