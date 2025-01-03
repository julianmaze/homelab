# This is for NFS, use SMB instead
#New-PSDrive -PSProvider FileSystem -Name Z -Root \\storage.local.ayertonz.com\volume1\media -Persist -Scope Global

<# SMB Mounting
Access Synology on your computer: Open your network explorer and enter the Synology NAS IP address. 
Select shared folder: Browse to the shared folder you want to mount. 
Mount as network drive: Right-click on the shared folder and choose the option to "Map network drive" (depending on your operating system). 
#>

$path = "Z:\Movies"
$dirs = Get-ChildItem -Path $path | ? Name -NotMatch "Disney Collection 1937-2008"
$nonCompliantReport = @()
$nonCompliantToDelete = @()
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

        $h265 = $movies | ? { $_.Name -match "265" } 

        # If there is a 265 movie, delete all non 265 movies
        if ($h265) {
            $toDelete = $movies | ? { $_.Name -notmatch "265" }
        } else {
            $toDelete = $movies | ? {[math]::round($_.length /1gb, 2) -ne $size_max}
        }

        $nonCompliantReport += [pscustomobject]@{
            "directory" = $dir.Name
            "count" = $movies.count
            "sizes_gb" = $sizes
            "movies" = $movies.Name
            "max_size" = $size_max
            "max_size_movie" = $toDelete.Name
        }

        $nonCompliantToDelete += $toDelete
    }
}

# Report
[pscustomobject] @{"total_storage_savings" = $savings; "noncompliant_items" = $nonCompliantReport} | ConvertTo-Json -Depth 5| Out-File .\reports\duplicateMovies.json

# Delete
$nonCompliantToDelete | % { $_ | Remove-Item -Force -Confirm:$false -Verbose}

# TODO: Test this
# Start-Job -ScriptBlock {
#   param($toDeleteArray)
#   $toDeleteArray | % { $_ | Remove-Item -Force -Confirm:$false }
# } -ArgumentList $nonCompliantToDelete