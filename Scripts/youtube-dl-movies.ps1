$movies = @(
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA-22R2TZGPW2112/personal_computer/http/us/en/playlist.m3u8"
        title = "And Two If By Sea"
        outputPath = "C:\Users\jmmaz\Videos"
        year = "2020"
        quality = "WEBRip-1080p"
    }
    # @{
    #     url = "https://dms.redbull.tv/v5/destination/rbtv/AA88TP2EZVUH9TW9JZ3E/personal_computer/http/us/en/playlist.m3u8"
    #     season = "03"
    #     episode = "02"
    #     title = "Proving ground (part 1)"
    # },
    # @{
    #     url = "https://dms.redbull.tv/v5/destination/rbtv/AAUCM362V6TPSPI5YEK2/personal_computer/http/us/en/playlist.m3u8"
    #     season = "03"
    #     episode = "03"
    #     title = "Proving ground (part 2)"
    # },
    # @{
    #     url = "https://dms.redbull.tv/v5/destination/rbtv/AA488V7M42GW5WUK8YB5/personal_computer/http/us/en/playlist.m3u8"
    #     season = "03"
    #     episode = "04"
    #     title = "Alaska"
    # },
    # @{
    #     url = "https://dms.redbull.tv/v5/destination/rbtv/AATGBKJE47B1W7Q3J2SU/personal_computer/http/us/en/playlist.m3u8"
    #     season = "03"
    #     episode = "05"
    #     title = "Strike"
    # }

)

foreach($movie in $movies) {
    Start-Process -FilePath "pwsh.exe" -ArgumentList "-NoExit", "-NoProfile", "-Command", "youtube-dl.exe -o '$($movie.outputPath)\$($movie.title) ($($movie.year))\$($movie.title) ($($movie.year)) $($movie.quality)' $($movie.url) --write-sub"
}