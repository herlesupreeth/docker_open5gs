<?php
require("../../../../config/tools/users/user_management/acls.inc.php");
require_once("../../../../web/common/forms.php");
require_once("../../../../web/common/cfg_comm.php");
$_SESSION['current_tool'] = "user_management";


$uid=$_GET['uid'];
$table=get_settings_value("table_users");
$sql = "select username, domain, acls from ".$table." where id=?";
include("lib/db_connect.php");

if (isset($action) && $action == "Set ACLs") {
	if(!$_SESSION['read_only']){

		$acls = "";
		if (isset($_GET['acls'])) {
			foreach ($_GET['acls'] as $acl_option)
				$acls.=$acl_option;
		}
		$sql = 'update subscriber set acls=? where id=?';
		$stm = $link->prepare($sql);
		if ($stm===FALSE || $stm->execute( array($acls, $uid) )===FALSE) {
			$errors[] = 'Failed to update subscriber\'s ACLS';
		}
	}else{
		$errors[] = "User with Read-Only Rights";
	}

	return;
}

# otherwise, we query for the user
$stm = $link->prepare($sql);
if ($stm === false) {
	die('Failed to issue query ['.$sql.'], error message : ' . print_r($link->errorInfo(), true));
}
$stm->execute( array($uid) );
$info = $stm->fetchAll(PDO::FETCH_ASSOC)[0];

// we consider 20 as a reasonable number of acls / row
$max_rows = 20;
if (sizeof($config_user_acls) <= $max_rows) {
	$height = 80 + sizeof($config_user_acls) * 25;
	$columns = 1;
} else {
	$height = 580;
	$columns = ceil(sizeof($config_user_acls) / $max_rows);
}

?>
<fieldset style="width:<?=$columns * 80?>px;height:<?=$height?>px;background-color:#e9ecef">
<legend align="center">ACLs for subscriber <?=$info["username"]?>@<?=$info["domain"]?></legend>
<br>
<div align="left">

<form action="">
	<?php csrfguard_generate(); ?>
	<table cellspacing="2" cellpadding="2" border="0">
	<?php
	$acls = $info['acls'];
	if (count($config_user_acls) > 0) {
		$keys = array_keys($config_user_acls);
		$size = count($keys);
		for ($r = 0; $r < min($size, $max_rows); $r++) {
			echo('<tr>');
			for ($c = 0; $c < $columns; $c++) {
				$index = $c * $max_rows + $r;
				if ($index < $size) {
					$k = $keys[$index];
					$v = $config_user_acls[$k];
					$checked = (strpos($acls, (string)$k) === false)?false:true;
					echo('<td class="dataRecord"><label><input id="acls" name="acls[]" class="dataRecord" '.
						'type="checkbox" '.($checked?"checked ":"").'value="'.$k.'">'.
						$v.'</input></label><br></td>');
				} else {
					echo('<td class="dataRecord"></td>');
				}
			}
			echo('</tr>');
		}
	}
	?>
	</table>
	<input type="text" hidden name="uid" value="<?=$uid?>">
	<div align="center">
		<br>
		<input type="submit" name="action" value="Set ACLs" class="formButton">
	</div>
</form>
</div>

</fieldset>
<?php exit(); ?>
