---
name: shorts-research
description: Reverse-engineer why a short-form video or channel gets millions of views (hook, script beats, pace, captions, hashtags, camera, signage) and verify every number. Use when someone shares a TikTok/YouTube Shorts link or channel and asks "how does this get views", "study this channel", "find a niche", or wants competitor examples for a script brief.
---

# Shorts research

**Rule: never pass on a number you didn't check.** Use yt-dlp to read views, likes, shares, length and date. Mark anything you couldn't check as "unverified".

## Analyze one video
Run `scripts/analyze_ref.sh <url> <out_dir>`. It saves `meta.txt` (stats and caption), `sheet.jpg` (one frame per second) and `transcript.txt` (timestamped, with words per second). Then read the transcript and the contact sheet, and write `ANALYSIS.md` covering:
- **Stats:** the numbers and their age. Views per hour of age is the fair way to compare.
- **Hook:** sentence 1, its word count, and when it ends. What is the odd act, and what are the stakes?
- **Beat map:** every story beat with its timestamp.
- **Pace:** words per second, and how much of the length is spoken.
- **"You see" / mechanism:** where it lands. Is it stakes, or explanation?
- **Ending:** a completed payoff, a mid-sentence cut, or a cliffhanger image.
- **Caption and hashtags:** copy them exactly.
- **Camera:** shot types, how often the scene changes, transitions, how text is shown (overlay or signs in the scene), and lighting changes.
- **Copy and avoid:** what to copy, and what to avoid.

## Analyze a channel
1. List the recent posts: `yt-dlp --flat-playlist --playlist-end 30 --print "%(id)s|%(view_count)s|%(duration)s|%(timestamp)s|%(title)s" <profile_url>`.
2. Work out each post's age from the timestamp. Don't call a post a flop until it's more than 24 hours old.
3. Run the video analysis on the top 3 and the 2 worst posts that are old enough. The gap between them is the lesson.

## Niche scouting
- Find 3 candidate niches.
- For each, give:
  - 5 or more currently viral videos, with links and views
  - creator sizes, to show small accounts can break in
  - why now (the last 1-3 months)
  - competition level
  - monetization path
  - effort per video
  - biggest risk
- Rank them and name one pick.
- Check the length of every "proof" video. Long-form YouTube videos are not evidence for a Shorts niche. The pilot's report mixed 6-12 minute videos in with Shorts.

## Findings so far (see references/)
- `dida-loop-2.5M.md`: a 31-second Part 1 about a roller-coaster loop.
  - Hook: an odd act in 8 words.
  - "You see" gives the stakes at 2.3 s.
  - A visible disaster at 10 s, then a crude fix.
  - A deflating joke: "Does he know what he's doing? Not really."
  - The rival sabotages the fix.
  - It cuts off mid-sentence before the payoff.
  - A true mechanism (the clothoid loop) told as a story.
- `chopsticks-channel.md`: 11 posts from one channel.
  - The 1.5M-view hit is a complete 66-second standalone story: a hero does an absurd act with a deadline, looks wrong for a long time, there's a quiet tell, and then the payoff is shown with a one-line analogy.
  - Captions are the title only, with no hashtags. Text sits on signs in the scene.
  - Posts at 105-110 seconds with a long "in real life" history ending flopped more often.
- Channels checked on 2026-11-07:
  - GeoGlobeTales (YouTube): geography "why/difference" explainers, every Short at 0.8-4.0M.
  - Celyxi (YouTube): true weird-human stories, 12K-4.9M.
- Niche verdicts from 2026-11-06:
  - Generic "how to use AI for videos" is saturated; niche down on the output.
  - General Roblox is killed: demand is falling, incumbents are huge, and the audience is under 18.
