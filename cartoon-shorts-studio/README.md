# cartoon-shorts-studio

A Claude Code plugin for viral narrated cartoon shorts: 2D characters in a painted 3D world, posted to TikTok, YouTube Shorts, Instagram Reels and Facebook. It was built from a real pilot: a bunker cartoon series (EP01-03) and a golf short, November 2026. That pilot ran 20+ script drafts through a lazy-viewer QA loop and studied 3 reference channels.

## One agent does it all
The `shorts-studio` agent (`agents/shorts-studio.md`) runs the whole pipeline by itself: research, script, a strict lazy-viewer QA loop, render, render check, and publish only on your approval. Ask Claude Code to "use shorts-studio to make a short about ..." or give it a reference TikTok link. It loads the skills below stage by stage.

## Skills
| Skill | Use it for |
|---|---|
| `shorts-pipeline` | Coordinating the team: stages, routing, approval gates, render checks, state |
| `shorts-research` | Reverse-engineering a hit video or channel. `scripts/analyze_ref.sh` downloads, transcribes and builds a contact sheet |
| `shorts-script` | Writing the beat-table script in one of three proven shapes, plus a table of swipe killers |
| `shorts-lazy-qa` | Bored-scroller QA: APPROVE or REJECT, the second it gets swiped, and one fix |
| `shorts-render` | Fish Audio voice, pace, captions, camera, sound and output specs on top of `cartoon-3d-short` |
| `shorts-publish` | social-auto-upload setup, logins, uploads and failures, behind a hard approval rule |

## Install
- **From GitHub:** in Claude Code run `/plugin marketplace add sammyview80/cartoon-shorts-studio`, then `/plugin install cartoon-shorts-studio@cartoon-shorts`.
- **As plain skills:** copy each `skills/<name>` folder into `~/.claude/skills/`.

## Requirements
- Rendering:
  - the `cartoon-3d-short` skill (github.com/mromidev/claude-animated-shorts)
  - Remotion with `@remotion/three`
  - Node 20 or later
  - ffmpeg
  - Python with faster-whisper
  - an OpenRouter key for Fish Audio TTS
- Research: `yt-dlp`.
- Publishing: social-auto-upload, plus Google Chrome for YouTube.

## Honest limits
- The view counts are from November 2026 and come from specific accounts. The patterns improve the odds; they do not guarantee views.
- Nobody did a listening pass on any audio mix. Levels were measured, not heard.
- In single-agent mode the agent QA-checks its own script. It reads cold in the lazy-viewer persona and uses a fresh sub-agent when it can, but self-review is still weaker than a separate reviewer.
- The QA reviewer is a model simulating a viewer. Compare its judgement against real 48-hour and 7-day stats.
