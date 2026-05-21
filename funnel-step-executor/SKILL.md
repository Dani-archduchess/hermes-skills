---
name: funnel-step-executor
description: "Watchdog skill for the marketer cron job. Every tick, fetches active funnels and executes the first pending step in each — sending emails via AgentMail, checking for replies, and updating step status."
version: 1.0.0
tags: [ghl, funnel, agent, watchdog, agentmail, email]
related_skills: [ghl-funnel-agent, agentmail, ghl-integration]
---

# Funnel Step Executor (Watchdog)

## Overview

Runs as a cron watchdog (every 2 minutes). Finds active funnels in the GHL Agency Dashboard, locates the first pending step, executes the agent_instructions, and marks the step as completed (or keeps it pending).

Integrates AgentMail for sending emails and GHL API for CRM operations.

## Prerequisites

- Dashboard running at `http://localhost:3001`
- AgentMail API key + inbox configured
- GHL API key + location ID configured
- AgentMail SDK installed

## Tick Loop

### Step 1: Fetch active funnels

```bash
curl -s http://localhost:3001/api/funnels -H "Authorization: Bearer $DASHBOARD_API_KEY"
```

Filter to `status === "active"`. Skip `draft`, `paused`, `complete`.
If none: "✓ No active funnels." and STOP.

### Step 2: Get funnel detail + client data

```bash
curl -s http://localhost:3001/api/funnels/{funnelId} -H "Authorization: Bearer $DASHBOARD_API_KEY"
curl -s http://localhost:3001/api/clients -H "Authorization: Bearer $DASHBOARD_API_KEY"
```

### Step 3: Find first pending step

Lowest `order` where `status === "pending"`. Skip completed/failed.
If none: "✓ All steps complete for {funnelName}"

### Step 4: Execute agent_instructions

Replace template variables:
- `{{ Client Name }}` → `client.name`
- `{{ Company Name }}` → `client.companyName`

**Send email (via AgentMail):**

Use `execute_code` to invoke the AgentMail SDK:

```python
from hermes_tools import terminal
terminal("""cd ~/agentmail && node -e "
const { AgentMailClient } = require('agentmail');
const client = new AgentMailClient({ apiKey: process.env.AGENTMAIL_API_KEY });
client.inboxes.messages.send('$AGENTMAIL_INBOX', {to:[...], subject:'...', text:'...', html:'...'})
  .then(r => console.log(JSON.stringify(r))).catch(e => console.error(e));
"""", timeout=15)
```

**Check GHL (via ghl-integration skill):**

When agent_instructions reference GHL opportunities or contacts, use the patterns from the `ghl-integration` skill.

**Check AgentMail inbox for replies:**

```
client.inboxes.messages.list(inboxId, { limit: 20 })
Filter direction === "inbound". Match by thread_id.
```

### Step 5: PATCH the step

```bash
curl -s -X PATCH "http://localhost:3001/api/funnels/{fid}/steps/{sid}"   -H "Authorization: Bearer $DASHBOARD_API_KEY"   -H "Content-Type: application/json"   -d '{"status":"completed","output":{...},"notes":"...","completed_by":"agent"}'
```

Status values: `completed`, `failed`, `skipped`, `pending` (keep for waiting).

### Step 6: Report

- "✓ Funnel X: completed Step 1 (sent email)"
- "⏳ Funnel X: Step 2 still pending (waiting for reply)"
- "✗ Funnel Y: Step 1 failed (no client email)"

## Pitfalls

1. **Only first pending step per funnel per tick.** Never process multiple steps — some need waiting time.
2. **Null client email = failed step.** Don't guess. Mark as failed with notes.
3. **Branching.** If instructions say "if positive → Won, if negative → Stale", skip the wrong-path steps.
4. **Template variables are inconsistent.** Normalize `{{ Client Name }}`, `{{Client Name}}`, `{{ client_name }}`.
5. **Dashboard must be running.** If `localhost:3001` is down, report and stop.
6. **JSON escaping.** When payloads contain special characters, write to temp file: `-d @/tmp/payload.json`

## Reference Files

- `references/agentmail-sdk.md` — AgentMail SDK API reference
- `references/ghl-pipeline-to-template.md` — Converting GHL pipelines to dashboard templates
