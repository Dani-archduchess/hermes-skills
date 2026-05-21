---
name: client-curator
description: "4-month cycle: curates YouTube playlists and recipes for GHL onboarding clients, sends via GHL Conversations API. Load this skill when the curator cron job fires or the user asks to run the curator manually."
version: 1.2.0
tags: [ghl, curator, email, youtube, recipes, automation, cron]
---

# Client Curator — The Relax Estate

## Overview

Every 4 months, Hermes curates personalized content for each client who filled out the onboarding form and emails it via GHL's Conversations API. Each client receives:

- **10 YouTube video links** featuring their favorite artist
- **5 recipes** matching their favorite cuisine
- **5 recipes** matching their go-to meal

## When This Runs

- Automatically via cron every 4 months (batch all clients)
- Manually when the user says "run the curator"

## Form & Field Mapping

**Form ID (test):** `r5GSJOGT7l0c1tsRomOE`

| UUID Field | Meaning | Variable |
|-----------|---------|----------|
| `first_name` | First name | `{{first_name}}` |
| `last_name` | Last name | `{{last_name}}` |
| `email` | Email address | `{{email}}` |
| `wvPKOeVyaZFkF5lIAZts` | Favorite Artist | `{{favorite_artist}}` |
| `FfwDUc8rrtbCAZZccfOr` | Favorite Cuisine | `{{favorite_cuisine}}` |
| `SI8SYiBMjFcP06V8iO9a` | Go-to Meal | `{{go-to_meal}}` |

## Workflow

### Step 0: Load skills

Before beginning, load `ghl-integration` skill for API details.

### Step 1: Fetch submissions

```bash
curl -s "https://services.leadconnectorhq.com/forms/submissions?locationId=ttFcthXlmNejS8lHdriw&formId=r5GSJOGT7l0c1tsRomOE&limit=50" \
  -H "Authorization: Bearer pit-eff1a3a2-ca83-4c88-bc53-f32ee3750363" \
  -H "Version: 2021-07-28" \
  -H "Content-Type: application/json"
```

Paginate if `meta.nextPage` is not null.

### Step 2: For each client, check sent history

Read GHL contact notes to find previous curator sends (look for `[Curator Cycle]` prefix):

```bash
# Get contact notes
curl -s "https://services.leadconnectorhq.com/contacts/{contactId}/notes?locationId=ttFcthXlmNejS8lHdriw&limit=100" \
  -H "Authorization: Bearer pit-eff1a3a2-ca83-4c88-bc53-f32ee3750363" \
  -H "Version: 2021-07-28"
```

Parse notes with `[Curator Cycle]` prefix to extract previously sent links. Store these in a "previously sent" set to avoid repeats.

### Step 3: Curate YouTube links

**3a. Search for videos.** Use `web_search` or direct YouTube search to find video IDs:

```
web_search(query="{favorite_artist} songs official music video")
web_search(query="{favorite_artist} best tracks live performance")
```

**3b. Filter out compilations.** YouTube search mixes in "Greatest Hits" compilations, ranking videos, and playlist roundups alongside individual songs. Before using a video, verify it's an actual song — not "Top 10 Gospel Hits," "Greatest Hits Playlist," or "Most Popular Songs Ranking." Only include individual song videos (official music videos and live performances).

**3c. Get real titles via oEmbed.** Video IDs from search don't carry readable titles. Use YouTube's oEmbed endpoint to resolve them:

```bash
for vid in VIDEO_ID_1 VIDEO_ID_2 ... VIDEO_ID_10; do
  title=$(curl -s "https://www.youtube.com/oembed?url=https://youtube.com/watch?v=${vid}&format=json" \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('title','?'))")
  echo "${title} · https://youtube.com/watch?v=${vid}"
done
```

This gives you `Song Title — Artist` format ready for the email. Run all 10 in a single loop — the oEmbed endpoint is fast and doesn't rate-limit at this scale.

**3d. Curate exactly 10.** Exclude any links from previous cycles (from Step 2 history). Each link in the email uses format: `Song Title — Artist · https://youtube.com/watch?v=VIDEO_ID`

### Step 4: Curate recipes

Use the `web_search` tool (NOT DuckDuckGo Instant Answer API — it's unreliable and returns empty results). Search for recipes from reputable food sites.

**4a. Cuisine recipes (5):**
```
web_search(query="best traditional {favorite_cuisine} recipes")
web_search(query="classic {favorite_cuisine} dishes from allrecipes seriouseats")
```

**4b. Meal recipes (5):**
```
web_search(query="best {go-to_meal} recipe")
web_search(query="{go-to_meal} variations creative twist")
```

Find 5 for each category. Prefer results from: allrecipes.com, seriouseats.com, bbcgoodfood.com, bonappetit.com. Exclude repeats from previous cycles. Format: `Recipe Name — Quick description · [Link]`

### Step 5: Compose email

Use the approved template below. Substitute all `{{placeholders}}` with real data.

**Subject:** From your The Relax Estate family to you 🎁

**HTML body:**
```html
<p>Hey {{first_name}},</p>

<p>Your quarterly edition of The Relax Estate Curator is here — and this one was put together with you specifically in mind.</p>

<p>Based on what you've shared with us, here's what we handpicked for your next four months:</p>

<h2>🎵 Your {{favorite_artist}}-Inspired Playlist</h2>
<p>10 tracks we think will hit just right.</p>
<ol>
  <li><a href="{{link1}}">Song Title — Artist</a></li>
  <!-- ... 10 items -->
</ol>

<h2>🍳 In Your Kitchen This Season</h2>
<p>10 recipes across two categories — comfort classics and something new to try.</p>

<h3>Your {{favorite_cuisine}} Favourites</h3>
<p><em>(For when you want something familiar and deeply satisfying)</em></p>
<ol>
  <li><a href="{{link}}">Recipe Name</a> — Quick description</li>
  <!-- ... 5 items -->
</ol>

<h3>Your {{go-to_meal}} Favourites</h3>
<p><em>(The classics you keep coming back to — tried, tested and always good)</em></p>
<ol>
  <li><a href="{{link}}">Recipe Name</a> — Quick description</li>
  <!-- ... 5 items -->
</ol>

<p>🍽️ Links above go to recipes, videos, or articles — wherever the best version lives.</p>

<p>Hope these bring some joy to your ears and kitchen. Speaking of kitchen, we would really appreciate it if you could prepare one of the recipes and send us a video of it. We'd proudly post it on our socials — only and only if you are comfortable with all of it.</p>

<p>Warmly, The Relax Estate Team</p>
<p><small>hello@therelaxestate.com · Unsubscribe · Update your preferences</small></p>
```

Also compose a plain-text `text` version for email clients that don't render HTML.

### Step 5.5: Verify ALL links before sending

**CRITICAL — every link must be verified before the email goes out.** In the first dry run, 11 out of 20 recipe links were broken (404). YouTube links are reliably verified with HEAD requests; recipe links need browser-based verification.

**YouTube links — fast HEAD check:**
```bash
for url in "${youtube_urls[@]}"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" -I "$url")
  if [ "$status" != "200" ]; then
    echo "BROKEN: $url — replace before sending"
  fi
done
```
All YouTube links should return 200. Replace any that don't.

**Recipe links — delegate to Codex for browser verification:**
Recipe sites use Cloudflare anti-bot protection. HEAD requests fail (403) and even the browser tool may get challenged. The reliable approach is to delegate link verification to Codex, which has browser-based computer-use tools that handle these sites:

```
Delegate to Codex with a prompt like:
"For each of these recipe URLs, navigate to the page and confirm it loads
real recipe content (not 404/paywall). If 404, search the site for the
recipe name and find the correct URL. Report [OK/FAIL] | Title | URL"

Batch URLs in groups of 3-5 to avoid timeouts. Process them in parallel
with multiple delegate_task calls.
```

**Batch strategy for Codex verification:**
1. Send YouTube links in one batch (fast HEAD check, usually all pass)
2. Send recipe links in batches of 3-5 per Codex call
3. Process allrecipe links, seriouseats links, and bbcgoodfood links separately
4. Any link that fails — have Codex search Google for the recipe name + site name to find the replacement

**Working URL reference:** See `references/verified-recipe-urls.md` for URLs confirmed working in this cycle. Check this file before guessing slugs — it contains the canonical URLs for common recipe/site combinations that were found through live browser verification.

**Correction email (if links were already sent broken):**
```
Subject: Quick fix — some recipe links updated 🔧
Body: List of corrected links with brief recipe descriptions.
```
Send ONE correction per client covering all broken links, not one per broken link.

For each client, send ONE email containing all content:

```bash
curl -s -X POST "https://services.leadconnectorhq.com/conversations/messages" \
  -H "Authorization: Bearer pit-eff1a3a2-ca83-4c88-bc53-f32ee3750363" \
  -H "Version: 2021-07-28" \
  -H "Content-Type: application/json" \
  -d '{
    "locationId": "ttFcthXlmNejS8lHdriw",
    "type": "Email",
    "contactId": "{contactId}",
    "subject": "From your The Relax Estate family to you 🎁",
    "html": "{html_body}",
    "text": "{text_body}",
    "from": "support@mp.therelaxestatepros.com"
  }'
```

### Step 7: Log to GHL contact notes

After successful send, log a note with what was sent for future deduplication:

```bash
curl -s -X POST "https://services.leadconnectorhq.com/contacts/{contactId}/notes?locationId=ttFcthXlmNejS8lHdriw" \
  -H "Authorization: Bearer pit-eff1a3a2-ca83-4c88-bc53-f32ee3750363" \
  -H "Version: 2021-07-28" \
  -H "Content-Type: application/json" \
  -d '{"body": "[Curator Cycle YYYY-MM] Artist: {artist}. YouTube links: {comma-separated IDs}. Cuisine recipes: {links}. Meal recipes: {links}."}'
```

The `[Curator Cycle YYYY-MM]` prefix is the key for Step 2 deduplication.

### Step 8: Report

After processing all clients, output a summary:

```
Curator Cycle Complete — {date}

Clients processed: {count}
Emails sent: {count}
Failures: {count}

{client_name}: ✅ Sent (${messageId})
{client_name}: ❌ Failed — {reason}
```

## Pitfalls

1. **Never send test emails without explicit user permission.** The cron job auto-sends because it's a deliberately scheduled system, but interactive test sends must be approved.
2. **Deduplication uses contact notes.** Always read notes before curating. Skip links that appear in any previous `[Curator Cycle]` note.
3. **YouTube links must be real and playable.** Verify each link resolves before including it. Prefer `youtube.com/watch?v=` format.
4. **Filter out compilation/ranking videos.** YouTube search returns "Greatest Hits" compilations, "Top 10" ranking videos, and playlist roundups. These crowd out individual songs. Only include actual song videos — official music videos and live performances.
5. **Use YouTube oEmbed for titles, not raw search text.** Video IDs from search don't carry readable titles. Resolve them via `https://www.youtube.com/oembed?url=https://youtube.com/watch?v={id}&format=json` to get clean `Song — Artist` strings.
6. **Don't use DuckDuckGo Instant Answer API for recipes.** It reliably returns empty results. Use `web_search` tool instead.
7. **Recipe links should be from reputable sources.** Prefer allrecipes.com, seriouseats.com, bbcgoodfood.com, bonappetit.com.
8. **If a client has no artist/cuisine/meal data, skip them.** Don't send half-filled emails.
9. **Form ID is the TEST form.** `r5GSJOGT7l0c1tsRomOE` — do not use the production form unless the user explicitly switches.
10. **One email per client per cycle.** Don't split music and recipes into separate emails.
11. **Recipe sites use Cloudflare anti-bot.** HEAD requests to allrecipes.com, seriouseats.com, and bbcgoodfood.com return 403. The browser tool also gets challenged. These are NOT broken links — Cloudflare only blocks automated traffic. Human recipients can open them normally. Don't waste time replacing 403 recipe links.
12. **BBC Good Food URL slugs must be exact.** Guessed slugs fail (e.g., `/recipes/full-english-breakfast` → 404, actual: `/recipes/ultimate-makeover-full-english-breakfast`). Always find the real URL via site search, never guess the slug.
13. **Verify every link before sending.** The Step 5.5 verification caught 3 dead links in the first dry run. Skipping verification means clients receive broken links. Always run the HEAD-check loop for YouTube and browser/site-search for recipes before calling the GHL send endpoint.
14. **Correction emails for already-sent broken links.** If verification happens after sending (e.g., dry run sent to test contacts), send a brief correction follow-up with the fixed URL. Subject: "Quick fix — one link in your curator email 🔧"
