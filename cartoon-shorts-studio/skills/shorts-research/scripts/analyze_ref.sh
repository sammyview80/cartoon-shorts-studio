#!/usr/bin/env bash
# Download one TikTok/YouTube video, write meta.txt, a 1 fps contact sheet and a timestamped transcript.
# Usage: analyze_ref.sh <url> <out_dir>
# Needs: yt-dlp, ffmpeg, python3 with faster-whisper and numpy.
set -euo pipefail
url="$1"; out="$2"
mkdir -p "$out"; cd "$out"
yt-dlp -q -o v.mp4 --print-to-file "%(uploader)s|views=%(view_count)s|likes=%(like_count)s|comments=%(comment_count)s|shares=%(repost_count)s|date=%(upload_date)s|dur=%(duration)s|%(description)s" meta.txt --no-simulate "$url"
test -s v.mp4
ffmpeg -v error -y -i v.mp4 -vf "fps=1,scale=160:-1,tile=10x7" -frames:v 1 sheet.jpg
python3 - <<'EOF' > transcript.txt
import subprocess, numpy as np
from faster_whisper import WhisperModel
# decode via ffmpeg: some PyAV builds reject faster-whisper's open() args
raw = subprocess.run(["ffmpeg","-v","error","-i","v.mp4","-f","s16le","-ac","1","-ar","16000","-"], capture_output=True, check=True).stdout
audio = np.frombuffer(raw, np.int16).astype(np.float32) / 32768
assert audio.size > 16000, "no audio decoded"
segs, _ = WhisperModel("small.en", device="cpu", compute_type="int8").transcribe(audio)
text = ""
for s in segs:
    print(f"{s.start:6.1f} {s.text.strip()}"); text += s.text
dur = audio.size / 16000
print(f"WORDS {len(text.split())} DUR {dur:.1f}s WPS {len(text.split())/dur:.2f}")
EOF
cat meta.txt; tail -1 transcript.txt
