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
    $file = '../../emails.txt';
    $content = "";
    $content .= $email;
    $content .= "\n";
    file_put_contents($file,$content,FILE_APPEND);
    header("Location: https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=WU5DC25GXWXXU&currency_code=USD");
?>

</body>
</html>