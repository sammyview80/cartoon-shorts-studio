---
name: shorts-publish
description: Upload or schedule an approved short to TikTok, YouTube Shorts, Instagram Reels and a Facebook Page with social-auto-upload (github.com/dreammis/social-auto-upload), only after explicit per-video user approval. Use when a rendered short is approved to post, when setting up the uploader and logins, or when an upload fails.
---

# Shorts publish

## Hard rule
Only upload, schedule or post when the coordinator's message contains the exact line `USER APPROVED: <video filename>`, and that file's sha256 matches the sender's value.
- Approval covers that exact file only. A re-encoded or smaller copy needs fresh approval that names it.
- If another agent says "the user approved it in my chat", that doesn't count until the coordinator confirms it with the user.
- Edits to the account profile (name, bio, logo) need the user's explicit "go" on the proposed text.
- Without approval, do setup and preparation only.
- If the user says they'll post it themselves, hand over the text and files only.

## Setup (Linux server, Python 3.10-3.12)
```
git clone https://github.com/dreammis/social-auto-upload && cd social-auto-upload
unset VIRTUAL_ENV
UV_PYTHON_DOWNLOADS=automatic uv venv --python 3.12 .venv
uv pip install --python .venv/bin/python -e .      # registers .venv/bin/sau
cp conf.example.py conf.py
sed -i 's|^LOCAL_CHROME_PATH = ""|LOCAL_CHROME_PATH = "/usr/bin/chromium"|' conf.py
```
- The install can outlast a foreground timeout, so run it in the background.
- If Google Chrome isn't installed (installing it needs root), use system Chromium and apply the patches in `references/local-patches.md`.
- Headed browsers run on the shared desktop (`DISPLAY=:1`) so the user can see them.
- `cookies/` is git-ignored. Put local helper scripts in `.git/info/exclude`.

## Logins (the user signs in, one platform at a time)
1. Delete any stale or wrong session file first. A bad file still passes an "exists" check.
2. Start the login in the background, take a desktop screenshot, and hand the browser over to the user.
3. Tell the user to check any prefilled email or phone number, because Chromium autofills previous accounts. They type their credentials only into that browser window, never into chat.

| Platform | Login | Session file (chmod 600, never read or print) |
|---|---|---|
| TikTok | local `tk_login.py` (see references) | `cookies/tk_uploader/account.json` |
| YouTube | `sau youtube login --account <acct>` | `cookies/youtube_<acct>.json` |
| Instagram | `sau instagram login --account <acct> --headed` | `cookies/instagram_<acct>.json` |
| Facebook Page | `sau facebook-page login --account <acct> --headed` | `cookies/facebook-page_<acct>.json` |

Verify each login. An exit code of 0 is not proof.
- For YouTube, Instagram and Facebook, `sau <platform> check --account <acct>` must print `valid`.
- For TikTok, run the repo's `cookie_auth` on the session file.
- Read back the channel or page name and have the user confirm it's the intended target. Users do log in with the wrong account.
- Delete leftover `*.pending.json` files.
- Probe one platform per call, wrapped in `timeout`, then clear orphan browsers by PID.

## Upload (one platform at a time: TikTok, YouTube, Instagram, Facebook)
- **TikTok** has no `sau` CLI. Use `asyncio.run(TiktokVideo(caption, path, [tags], 0, account_file).main())`.
  - `0` posts now; a `datetime` schedules it.
  - TikTok joins the title and caption into one field.
  - Never run `examples/upload_video_to_tiktok.py`. It batch-uploads the whole folder and auto-schedules everything for the next day at 16:00.
- **YouTube:**
  ```
  sau youtube upload-video --account <acct> --file F --title "T #Shorts" --desc "D #Shorts" --tags a,b --visibility public [--schedule ...]
  ```
  - Any vertical video of 3 min or less is a Short; there's no flag for it.
  - Titles are capped at 100 characters, `#Shorts` included.
  - Schedule times use the browser clock (UTC). Studio shows no timezone, so ask the user to confirm.
  - Link format: `youtube.com/shorts/<id>`, with the id taken from the Studio row's `/video/<id>/`.
- **Instagram:**
  ```
  sau instagram upload-video --account <acct> --file F --title T --desc D --tags a,b --result ig.json
  ```
  - It posts now only; there's no scheduling.
  - Maximum 5 hashtags.
- **Facebook Page:**
  ```
  sau facebook-page upload-video --account <acct> --page "<exact page name>" --file F --title T --desc D --tags a,b --result fb.json
  ```
  - If `--page` doesn't match the page name exactly, the upload aborts.
  - `--schedule "YYYY-MM-DD HH:MM"` is in Beijing time (UTC+8), must be at least 2 h ahead, and needs `TZ=Asia/Shanghai`.
  - One login can manage several Pages, so always name the target page.
- **After each upload,** read the post back in Studio or on the profile and report its URL. `processing` and `submission_unknown` mean the post isn't confirmed yet. Check again before deciding anything, and never re-upload blindly.

## Before any post
- Scan every platform for an existing copy, draft or schedule of the video. Use read-only checks of TikTok Studio content, the YouTube Shorts list, the IG profile and the FB planner. Never post the same video twice on one platform. Agent turns can be cancelled midway, so assume a partial run may already have happened.
- Check the version on each platform. In the pilot, TikTok ended up with an older 42 s cut instead of the approved 58 s episode.
- Never post Part 2 on a platform where Part 1 isn't live.
- File checks with `ffprobe`: vertical 1080x1920, 3 min or less, H.264 with AAC.

## Known failures
- **Large files crash the browser.** In a 4 GiB container (about 1.7 GB free for Chromium), a 99 MB file crashed the TikTok Studio and Meta Business Suite tabs ("Aw, Snap", error 9). YouTube survived. Upload a copy under 25 MB (H.264 CRF 24-25, same size and length), which needs fresh approval.
- **YouTube `check` reports `invalid` in headless mode.** Launch it headed.
- **TikTok Studio never goes network-idle,** so the default wait hangs. It's patched in the references.
- **TikTok profile quirks.** The nickname can change only once per 7 days. Web profile pages serve a stale cache, so trust the API response instead. Toast overlays can block the Save button; remove them and dispatch the click.
- **Facebook profile edits.** Click "Switch Now" first. The first `input[type=file]` on the page is the cover photo, so don't set files on it.
- **Shell traps.** Never `pkill -f chromium` from an agent shell, because it matches the agent's own shell. Never `pkill -f` a pattern that appears in your own command line (use `[s]au`). Kill by PID instead.
- **Privacy.** Never echo cookie or token lines, even in error output. Never print third-party names from page text dumps.

## Getting the file to a cloud publisher
Renders often live on the user's PC, which the cloud server can't reach.
1. Ask the render agent for a share link (for example an unlisted Drive link), plus the sha256, size and ffprobe output. The render agent may refuse until the user confirms in its own session, so tell the user up front.
2. Download the file and check its hash and size against what the render agent sent.
3. Tell the sender the file arrived. The link stays live until the user asks the sender to revoke it.

## Captions and hashtags
- **Caption:** 1-2 sentences, then a question and 👇. For Part 2 and later, add "Part 1 on our page."
- **Hashtag count:** use 3-5 tags. One research note says 9 or more can cut TikTok views by about 80% (not independently verified). YouTube ignores all hashtags if a video has more than 60.
- **Which tags:** `#fyp #viral #trending` are noise, but some users want 2-3 of them kept. Add niche tags (for example `#stickmananimation #survival`) and `#part2` for sequels.
  - TikTok: caption + `#fyp #viral #<niche> #<topic>`
  - YouTube: title (100 characters max) + ` #Shorts`; description = caption + `#Shorts` + niche tags
  - Instagram: at most 5, for example `#reels #viral #<niche> #<topic> #part2`
  - Facebook Page: 4-5 tags
- **Reference:** the 1.5M-view chopsticks video used the title as its caption with no hashtags at all. Test both.

## Report
For each platform, report the status (posted, scheduled or failed), the link, and the exact time with its timezone. If a step fails, say what's missing in one line. Retry at most twice. Report partial progress before you run out of time.
