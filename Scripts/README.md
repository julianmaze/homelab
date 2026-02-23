# yt-dlp

List Formats

```bash
yt-dlp --list-formats "https://www.youtube.com/watch?v=r43asrLpdsc"
```

Best Audio and Video in mp4 w/ outfile and no larger then 1440p

```bash
yt-dlp -f "bv*[height<=1440p][ext=mp4]+ba*[ext=m4a]" -o "C:\Users\jmmaz\Videos\Bali Movie" "https://www.youtube.com/watch?v=yxikzPVvA3A"
```

Just download m4a (aac codec)

```bash
# Note this may not work with iMovie/apple products
yt-dlp -t aac "" -o "~/Music/..."

# To download an iMovie specific audio file use the following
yt-dlp -f 140 "" -o "~/Music/..."

# Additionally see the reencoding script for more information
```

In case of 403 forbidden errors, first try updating yt-dlp to solve challenges

```bash
sudo yt-dlp -U
```
