# social-auto-upload: local patches that made it work on a headless Linux server with Chromium only

Re-apply these after every `git pull`, then check them with `git diff --stat`.

1. **Use Chromium instead of Chrome** (`channel="chrome"`). Apply this in `uploader/youtube_uploader/main.py`, `uploader/meta_uploader/insgraph_uploader/main.py` (Instagram) and `uploader/meta_uploader/facebook_page_uploader/main.py`.
   ```python
   from conf import LOCAL_CHROME_PATH
   _CHROME = {"executable_path": LOCAL_CHROME_PATH} if LOCAL_CHROME_PATH else {"channel": "chrome"}
   ```
   Then run `sed -i 's/channel="chrome", /**_CHROME, /' <file>`.
2. **YouTube `cookie_auth`: launch with `headless=False`.** In headless Chromium, YouTube Studio serves an "unsupported browser" page, so `check` wrongly reports `invalid`.
3. **TikTok, in `uploader/tk_uploader/main_chrome.py`:**
   - Import from `patchright.async_api` instead of `playwright.async_api`.
   - In `cookie_auth`, wait for `domcontentloaded` and then `wait_for_timeout(8000)` instead of `networkidle`. TikTok Studio never goes network-idle.
   - In `cookie_auth`, launch with `executable_path=LOCAL_CHROME_PATH or None`.
4. **YouTube scheduling:** add a `set_publish_date` step and a Studio "Schedule" step to `uploader/youtube_uploader/main.py`. The upstream code doesn't schedule.
5. **TikTok login helper** (keep it local and list it in `.git/info/exclude`). The repo's `get_tk_cookie` calls `page.pause()`, so it hangs when nobody is at the console. Write a small script instead that:
   - opens tiktok.com/login in headed mode
   - polls for the `sessionid` cookie every 5 s for up to 15 min
   - saves the storage state with `chmod 600`
   - prints only `LOGIN_SAVED` or `LOGIN_TIMEOUT`
