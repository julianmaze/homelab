$path = "Z:\Movies"
$dirs = Get-ChildItem -Path $path | ? Name -NotMatch "Disney Collection 1937-2008"
$noncompliant = @()
$savings = 0

foreach ($dir in $dirs) {
    $movies = Get-ChildItem -Path "$path\$($dir.Name)\*" -Include "*.mkv", "*.mp4", "*.avi", "*.mov", "*.m4v"
    if ($movies.count -gt 1) {
        $sizes = $movies | % {[math]::round($_.length /1gb, 2) }
        $measure = $sizes | Measure-Object -Maximum -Sum
        $size_sum = $measure.Sum
        $size_max = $measure.Maximum

        $dif = $size_sum - $size_max
        $savings += $dif

        $noncompliant += [pscustomobject]@{
            "directory" = $dir.Name
            "count" = $movies.count
            "sizes_gb" = $sizes
            "movies" = $movies.Name
            "max_size" = $size_max
            "max_size_movie" = ($movies | ? {[math]::round($_.length /1gb, 2) -eq $size_max}).Name
        }
    }
}

return $noncompliant, $savings

# $n, $s = .\removeDuplicateMovies.ps1
# [pscustomobject] @{"total_storage_savings" = $s; "noncompliant_items" = $n} | ConvertTo-Json -Depth 5| Out-File .\reports\duplicateMovies.json