---
name: ghl-funnel-agent
description: "Create and manage GoHighLevel sales funnels via the GHL Agency Dashboard API. Takes a natural language prompt, picks the best template, generates step configurations, and creates the funnel."
version: 2.0.0
tags: [ghl, gohighlevel, funnel, agent, automation, sales]
related_skills: [funnel-step-executor]
---

# GHL Funnel Agent

## Overview

Creates GoHighLevel product sales funnels from natural language prompts using an agentic step model. Each step has a description and agent instructions — the agent works through them sequentially, recording output as it goes.

## When to Use

- "create a funnel for [client]"
- "build a product launch funnel for [company]"
- "generate a funnel using [template]"

## Prerequisites

- GHL Agency Dashboard running at `http://localhost:3001`
- Dashboard API key configured

## How It Works

### Step 1: Fetch templates and clients

```bash
curl -s http://localhost:3001/api/templates -H "Authorization: Bearer $DASHBOARD_API_KEY"
curl -s http://localhost:3001/api/clients -H "Authorization: Bearer $DASHBOARD_API_KEY"
```

### Step 2: Match template and client

Pick the best template based on the user's intent. Match client by name.
If no client exists, tell the user to create one first.

### Step 3: Create the funnel

```bash
curl -s -X POST http://localhost:3001/api/funnels   -H "Authorization: Bearer $DASHBOARD_API_KEY"   -H "Content-Type: application/json"   -d '{"templateId":"<id>","clientId":"<id>","name":"Funnel Name"}'
```

### Step 4: Work through steps

For each step in order:
1. Read `step.description` + `step.agent_instructions`
2. Execute the agent instructions
3. PATCH the step:

```bash
curl -s -X PATCH "http://localhost:3001/api/funnels/:fid/steps/:sid"   -H "Authorization: Bearer $DASHBOARD_API_KEY"   -H "Content-Type: application/json"   -d '{"status":"completed","output":{...},"notes":"Done"}'
```

Status values: `pending` → `in_progress` → `completed` (or `failed`)

### Step 5: Report progress

After completing a step, report which step was done and what's next.

## Current Templates

Templates live in the dashboard DB — fetch them dynamically:

```bash
curl -s http://localhost:3001/api/templates -H "Authorization: Bearer $DASHBOARD_API_KEY"
```

## Pitfalls

1. **NEVER hardcode template IDs.** Always fetch the template list and match by name/category.
2. Don't create overrides — the new model doesn't use them. Steps are copied as-is from the template.
3. Step output goes in the `output` field, not `config`.
4. Always PATCH individual steps, not the whole funnel.
5. If a step fails, set status to `failed` with notes.
6. **DELETE is a hard delete, not an archive.** `DELETE /api/funnels/:id` returns 204. No undo.

## Reference Files

- `references/api-patterns.md` — Full endpoint reference and step model
- `references/debugging-dashboard.md` — Frontend debugging workflow
- `references/crud-pattern.md` — Full-stack CRUD pattern for adding operations
- `references/template-engine.md` — Template engine time-reference behavior
