<!DOCTYPE html>
<html>
    <head>
    </head>
<body>

<?php
    //Julian's Make Donation Script
    //Server Side script to dump email addresses to local file
    //Also to open new page

    $email = $_POST['email'];
    /*$file = '../../emails.txt';
    $current = file_get_contents($file);
    $current .= $email;
    $current .= "\n";*/

    echo
    "
    <h1>Email: $email</h1>
    ";
    //exec(file_put_contents($file,$current,FILE_APPEND));

?>

</body>
</html>