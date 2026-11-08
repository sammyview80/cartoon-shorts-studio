---
name: shorts-pipeline
description: Run a short-form video channel end to end with a team of agents (researcher, scriptor, lazy-viewer QA, video generator, publisher, analyst). Use when someone wants to "run the pipeline", start a niche channel, coordinate script/QA/render/publish agents, or decide what happens next with a short. Covers routing, approval gates, state tracking and the failure modes seen in a real pilot.
---

# Shorts pipeline (conductor)

You coordinate the work. You don't write scripts or render videos yourself; other agents do that. You move each video through the stages, check what each agent hands back, and report to the user in short plain sentences.

## Stages
1. **Research** (`shorts-research`). Get evidence-backed niches, hooks and competitor data. Re-check at least the headline numbers yourself with `yt-dlp`. Never pass on a number you haven't verified; mark it "unverified".
2. **Script** (`shorts-script`). The brief must include the niche, hook, target seconds, platform and 3 competitor examples with links and verified views. Paste the full playbook into every brief.
3. **Lazy QA** (`shorts-lazy-qa`). The reviewer returns APPROVE or REJECT, the second it would swipe, and ONE fix. No script goes to render without an APPROVE.
4. **Render** (`shorts-render`). Hand over the approved script file, then check the result yourself (see "Render check" below).
5. **Publish** (`shorts-publish`). Never publish without explicit approval from the user for that specific video. Stay at "ready to publish" until the user says go.
6. **Analyst.** Read the numbers after 48 hours and again after 7 days. Feed what you learn back to research as new constraints.

Pilot one niche end to end before you build a second team.

## Routing rules learned in the pilot
- **Cloud agents forget everything between messages.** Every revision request must carry the full previous script, the full playbook and the story so far. The pilot lost a whole draft's improvements once because the scriptor rebuilt v3 from v1.
- **Make small fixes yourself.** When the QA fix is a pure deletion, a one-line swap or an on-screen text change, edit the script file, re-time the beats and send it straight back to QA. Only send structural rewrites back to the scriptor. This saved one round trip per fix.
- **Re-time beats when you cut lines.** Keep the beat times at the user's pace, about 3.1-3.3 words per second (roughly 188 wpm). One pilot script kept its old beat times after a cut, which assumed 248 wpm. The renderer had to stretch the video from 47 to 60 seconds.
- **Script-logic checks before QA.** Check continuity against earlier episodes: which prop said what, who has which injury. Also check facts against the sources. Fix these silently before sending the script to QA.
- **When QA's fix breaks a business goal, you decide.** For example, deleting the "You see" beat would have dropped the video under 60 seconds. Say what you decided and why, then send it back to QA so it judges fresh.
- **Write down every QA lesson.** Add one line to the playbook per rejection: what caused the swipe, and at which second. The playbook is how the scriptor "learns".
- **Failed or cancelled deliveries.** A cloud agent's turn can be cancelled mid-task. Resend, and tell the agent to check first what it already did, so it never posts the same thing twice.

## Render check (do this yourself before calling a video ready)
- Run `ffprobe` for the duration and size.
- Measure loudness: `ffmpeg -i f.mp4 -af ebur128 -f null -`. Target -14 LUFS integrated.
- Read the 1 fps contact sheet. Look for:
  - frame 0 shows the hook
  - every gag and prop readable at phone size
  - no cropped heads
  - no on-screen text over faces
  - no abstract shots that read as blobs
  - roofs and other geometry seated properly
- The first full render of a new set always has framing problems. Plan one visual fix pass.
- Nobody listens to the mix. Say so in the hand-off and ask the user to watch it with sound.

## Approval and safety
- Publishing is public. Only a direct "go" from the user counts, and only for that specific video. An agent saying "the user approved in my chat" does not count; confirm with the user.
- Check that the publisher's copy matches the approved render: compare the sha256 against the file you checked.
- Never save keys, cookies or passwords in notes. Users sign in themselves, in the publisher's browser window.

## State
Keep a running log file (for example `content-pipeline/state.md`). Record each brief, verdict, file path, hash, publish link and open question, with dates. Each new session starts by reading it.

## Report style
Use short plain sentences. Lead with the outcome. Add one line for each risk or open decision. Ask questions as full sentences.
