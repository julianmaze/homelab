# Projects

This is a repo containing all of my projects. I also use the issue tracker to track feature requests and changes I want to make in my infrastructure.

# yt-dlp

List Formats

```console
yt-dlp --list-formats "https://www.youtube.com/watch?v=r43asrLpdsc"
```

Best Audio and Video in mp4 w/ outfile and no larger then 1440p

```console
yt-dlp -f "bv*[height<=1440p][ext=mp4]+ba*[ext=m4a]" -o "C:\Users\jmmaz\Videos\Bali Movie" "https://www.youtube.com/watch?v=yxikzPVvA3A"
```
