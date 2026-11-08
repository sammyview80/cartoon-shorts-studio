---
name: shorts-render
description: Render an approved short script into a vertical 2D-cartoon-in-3D-world video (three.js inside Remotion) with Fish Audio TTS, word-timed one-word captions, a synthesized SFX and score mix, and a phone-ready QA pass. Use when an approved beat-table script must become an MP4, or when fixing a render's framing, pace, captions or mix. Builds on the cartoon-3d-short skill (github.com/mromidev/claude-animated-shorts).
---

# Shorts render

## Dependencies
- The `cartoon-3d-short` skill: copy github.com/mromidev/claude-animated-shorts to `~/.claude/skills/cartoon-3d-short/`. Read its SKILL.md first. It is MIT licensed and has the world, ink, lens blur, grade and audio templates.
- Remotion with `@remotion/three`, Node 20+, Python 3, ffmpeg.
- faster-whisper for word timings.
- An OpenRouter API key, for Fish Audio TTS.

## Voice
- **Model:** Fish Audio through OpenRouter, `fish-audio/s2.1-pro-free:free` at `/api/v1/audio/speech`.
  - Voice `alloy` works; `onyx` and `echo` returned HTTP 400.
  - The output format must be `mp3` or `pcm`.
  - The `speed` parameter works.
  - The free tier rate-limits (429), so retry with a wait.
- **Pace the user liked:** speed 1.25 with pauses capped at 0.4 s, which gives about 188 wpm.
  - 162 wpm felt too slow; 210 wpm or more felt too fast.
  - Measure wpm on every take, because Fish reads some texts faster than others.
  - If the script's timing would force a faster pace, keep the pace and let the video run longer. Tell the requester.
- **Generate several takes per line** and keep the one that fits its beat. Fish's length varies from take to take.
- **Word times:** take them from faster-whisper (`small.en`), then lock every beat start to the real word times, within ±0.3 s.
  - Whisper sometimes "hallucinates" a zero-length repeat of a phrase. Drop runs of 3 or more words that share one start time. Don't drop every zero-length word: real short words share start times too.
  - If faster-whisper can't find CUDA, pass `device="cpu", compute_type="int8"`.
  - If PyAV rejects `metadata_errors`, decode with ffmpeg to an s16le numpy array and pass the array.
- **Off-screen voices:** for a voice through a door or peephole, low-pass at about 700 Hz (applied twice) and drop the level.

## Picture rules
- **Hook:** frame 0 shows the hook action and its label. Nothing builds up to it.
- **Characters:** 2D cards with one trait each, sized so faces fill a big part of the frame in dialogue shots. Characters must not get cropped by the frame bottom.
- **Labels** (DAY counter, countdown, HOUR 40):
  - Use one fixed slot at the top centre, about 290-420 px from the top on a 1920 px frame.
  - Aim cameras so faces sit below the slot. Labels must never overlap faces.
- **Prefer text on signs in the world:** shopfronts, posters, scoreboards, sticky notes, crowd banners. The 1.5M-view reference does this instead of overlay text.
- **Captions:** one word at a time, white bold with a black outline, in the lower third (about 1480 px from the top). Hide them while a story text (a peephole line, a sign close-up) is on screen.
- **Gags:** every gag gets a close-up where the prop fills at least a third of the frame. A wide cross-section with tiny characters was rejected in QA review of the pilot.
- **Camera:**
  - Use continuous moves between scenes: follow an object, whip pan, fly through a window or hatch, rise or dive through a cutaway.
  - Keep hard cuts to 1-2, for flashbacks and the final slam.
  - The user asked for slower moves with longer holds.
  - For cutaway cross-sections, use clipping planes so the camera never passes through solid ground.
- **Light follows the story:** noon for hope, sunset for tension, night-blue for mystery, red emergency light that is soft enough for props to read, and white for a blast.
- **Effects:** sparks, dust puffs, speed lines, flashes, glowing dots, all as flat 2D sprites.
- **Gotchas from the pilot:**
  - Seat the roofs properly; floating, tilted roofs look broken.
  - A contrail drawn as one straight white line reads as a laser. Draw a soft curved trail with a tiny plane at its head.
  - Show inner views (peepholes, screens) as a lit lens card. It must sit fully below the ceiling, with depthWrite on, or the ink pass draws through it.
  - Back-face culling hides signs that face away. Check sign orientation.

## Sound
- **SFX and score:** synthesized per the skill. Duck the music and SFX under the voice. Place every hit on the word or frame it belongs to; the pilot had to move a club "whack" 0.3 s to its visual.
- **Silent windows** (after a blast, before a knock, on the end card): measure that they are digitally silent. They hit harder than any sound effect.
- **Loudness:** -14 LUFS integrated with true peak at or below -1 dBTP. AAC encoding adds about 0.1 LU.

## Output
- **Full file:** 1080x1920, 30 fps, H.264 CRF 16 with AAC.
- **Small copy:** under 25 MB (CRF 24-25), at the same size and frame count. Cloud publishers on 4 GB machines crashed loading a 99 MB file into the browser.
- **Rendering:** chunked, with `--gl=angle` and concurrency 1. Strip the silent audio from each chunk and concatenate video only, or the timestamps drift. Then mux in the final mix.
- **Disk:** point TEMP, TMP and REMOTION_TMP at a big drive. Remotion bundles copy `public/` (about 1.3 GB) per render and never clean up. Stop if free space drops under 40 GB.
- **Version history:** give each episode its own composition (for example MaxShort, MaxShort2) and back up the source before every fix pass. Never overwrite an earlier version.

## Report back
Report:
- both file paths
- the ffprobe duration
- the LUFS
- stills at the times requested
- a 1 fps contact sheet
- a CHANGES file listing every departure from the script and why
- peak disk use

Also say whether a verifier round or a listening pass was skipped.
