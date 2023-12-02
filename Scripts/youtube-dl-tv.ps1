$outputPath = "C:\Users\jmmaz\Videos\Life of Kai\Season 3"
$name = "Life of Kai"
$season1 = @(
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA-21THE23Z91W12/personal_computer/http/us/en/playlist.m3u8"
        season = "01"
        episode = "03"
        title = "The legend of Nazaré"
    },
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA-22XXZRCFS1W12/personal_computer/http/us/en/playlist.m3u8"
        season = "01"
        episode = "04"
        title = "Slaying Gigantes"
    }
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA-22XXZYUPD1W12/personal_computer/http/us/en/playlist.m3u8"
        season = "01"
        episode = "05"
        title = "Redemption at Nazaré"
    }
)

$season2 = @(
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA-27P64ANTW1W11/personal_computer/http/us/en/playlist.m3u8"
        season = "02"
        episode = "01"
        title = "The beast awakens"
    },
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA-27P64EZW11W11/personal_computer/http/us/en/playlist.m3u8"
        season = "02"
        episode = "02"
        title = "Redemption at Peahi"
    },
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA-27P649FW52111/personal_computer/http/us/en/playlist.m3u8"
        season = "02"
        episode = "03"
        title = "Day of days"
    },
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA-27PEWSABS2111/personal_computer/http/us/en/playlist.m3u8"
        season = "02"
        episode = "04"
        title = "Air time"
    },
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA-27PEX4YPN1W11/personal_computer/http/us/en/playlist.m3u8"
        season = "02"
        episode = "05"
        title = "The test"
    }

)

$season3 = @(
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AAMM8NFLZY38ELNGKBQ3/personal_computer/http/us/en/playlist.m3u8"
        season = "03"
        episode = "01"
        title = "Reset"
    },
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA88TP2EZVUH9TW9JZ3E/personal_computer/http/us/en/playlist.m3u8"
        season = "03"
        episode = "02"
        title = "Proving ground (part 1)"
    },
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AAUCM362V6TPSPI5YEK2/personal_computer/http/us/en/playlist.m3u8"
        season = "03"
        episode = "03"
        title = "Proving ground (part 2)"
    },
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AA488V7M42GW5WUK8YB5/personal_computer/http/us/en/playlist.m3u8"
        season = "03"
        episode = "04"
        title = "Alaska"
    },
    @{
        url = "https://dms.redbull.tv/v5/destination/rbtv/AATGBKJE47B1W7Q3J2SU/personal_computer/http/us/en/playlist.m3u8"
        season = "03"
        episode = "05"
        title = "Strike"
    }

)

foreach($episode in $season3) {
    Start-Process -FilePath "pwsh.exe" -ArgumentList "-NoExit", "-NoProfile", "-Command", "youtube-dl.exe -o '$outputPath\$name - S$($episode.season)E$($episode.episode) - $($episode.title)' $($episode.url)"
}