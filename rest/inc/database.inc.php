<?php
/*
    Database Connections
*/

// Return database connection
function pgConnection() {
	$conn = new PDO ("pgsql:host=10.1.8.45;dbname=painel_devel;port=5432","painel","p41n3l", array(PDO::ATTR_PERSISTENT => true));
    return $conn;
}

?>
