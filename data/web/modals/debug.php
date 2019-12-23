<?php
if (!isset($_SESSION['openemail_cc_role'])) {
	header('Location: /');
	exit();
}
?>
