$names = Get-Item -Path Z:\GoPro\Optimized\Lake_Powell_2019_plex\*
$count = 1
foreach ($name in $names) {
    $name | Rename-Item -NewName "Powell-$count.m4v"
    $count++
}