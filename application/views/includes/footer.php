</body>
</html>
<?php
// 3. Close connection
if (isset($connection)) {
    // free memory
    pg_free_result($result);

    // close connection
    pg_close($dbh);
}
?>
