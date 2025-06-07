#!/bin/bash

INPUT_DIR=~/Music/
OUTPUT_DIR="$INPUT_DIR/imovie_ready"

mkdir -p "$OUTPUT_DIR"

for input in "$INPUT_DIR"/*.m4a; do
  filename=$(basename "$input" .m4a)
  output="$OUTPUT_DIR/${filename}_imovie.m4a"
  
  echo "Re-encoding: $filename.m4a -> ${filename}_imovie.m4a"
  
  ffmpeg -y -i "$input" -c:a aac -b:a 192k -ar 44100 "$output"
done

echo "✅ All files re-encoded and saved to: $OUTPUT_DIR"
