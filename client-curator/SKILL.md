---
name: client-curator
description: "4-month cycle: curates YouTube playlists and recipes for GHL onboarding clients, sends via GHL Conversations API. Load this skill when the curator cron job fires or the user asks to run the curator manually."
version: 1.0.0
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

For each client, search YouTube for their favorite artist. Use `web_search`:

```
web_search(query="{favorite_artist} songs best hits official music video")
web_search(query="{favorite_artist} top tracks")
```

Curate exactly 10 unique YouTube video links. Prefer official music videos and live performances. Exclude any links from previous cycles (from Step 2 history).

Each link in the email uses format: `Song Title — Artist · https://youtube.com/watch?v=VIDEO_ID`

### Step 4: Curate recipes

**4a. Cuisine recipes (5):**
```
web_search(query="best traditional {favorite_cuisine} recipes authentic")
web_search(query="popular {favorite_cuisine} dishes recipes")
```

**4b. Meal recipes (5):**
```
web_search(query="best {go-to_meal} recipe")
web_search(query="{go-to_meal} recipes variations")
```

Find 5 for each category. Exclude repeats from previous cycles. Format: `Recipe Name — Quick description · [Link]`

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

### Step 6: Send via GHL Conversations

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
4. **Recipe links should be from reputable sources.** Prefer sites like allrecipes.com, seriouseats.com, bbcgoodfood.com, bonappetit.com.
5. **If a client has no artist/cuisine/meal data, skip them.** Don't send half-filled emails.
6. **Form ID is the TEST form.** `r5GSJOGT7l0c1tsRomOE` — do not use the production form unless the user explicitly switches.
7. **One email per client per cycle.** Don't split music and recipes into separate emails.
