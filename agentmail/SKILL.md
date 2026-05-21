---
name: agentmail
description: "Send and track emails via the AgentMail SDK. Use for: sending emails, checking inbox replies, and managing email threads from Hermes."
version: 1.0.0
tags: [agentmail, email, sdk]
---

# AgentMail

## Overview

Integrates Hermes with AgentMail for sending and tracking emails. The SDK runs via Node.js and is invoked through `execute_code` + `terminal`.

## Prerequisites

- Node.js 20+
- AgentMail npm package: `npm install agentmail`
- API key from https://agentmail.to
- An inbox created in your AgentMail account

## Setup

```bash
# Install the SDK
cd ~/agentmail
npm install agentmail

# Set your API key
export AGENTMAIL_API_KEY=your_key_here
```

## Send Email

```python
from hermes_tools import terminal

terminal("""cd ~/agentmail && node -e "
const { AgentMailClient } = require('agentmail');
const client = new AgentMailClient({ apiKey: process.env.AGENTMAIL_API_KEY });
client.inboxes.messages.send('YOUR_INBOX@agentmail.to', {
    to: ['recipient@example.com'],
    subject: 'Subject line',
    text: 'Plain text body',
    html: '<p>HTML body</p>'
}).then(r => console.log(JSON.stringify(r))).catch(e => console.error(e));
"
""", timeout=15)
```

**Returns:** `{ message_id: "...", thread_id: "..." }`

## Check Inbox for Replies

```python
from hermes_tools import terminal

terminal("""cd ~/agentmail && node -e "
const { AgentMailClient } = require('agentmail');
const client = new AgentMailClient({ apiKey: process.env.AGENTMAIL_API_KEY });
client.inboxes.messages.list('YOUR_INBOX@agentmail.to', { limit: 20 }).then(r => {
    const msgs = r.messages || [];
    // Filter inbound (replies)
    const replies = msgs.filter(m => m.direction === 'inbound');
    console.log(JSON.stringify(replies, null, 2));
}).catch(e => console.error(e));
"
""", timeout=15)
```

## Message Object

Each message has:
- `message_id` — unique identifier
- `thread_id` — conversation thread (shared across replies)
- `direction` — `"inbound"` (received) or `"outbound"` (sent)
- `from` — `{ email: "..." }`
- `to` — `[{ email: "..." }]`
- `subject` — subject line
- `text` — plain text body
- `html` — HTML body (if provided)
- `created_at` — ISO timestamp

## Pitfalls

1. **Inbox ID must be full domain form.** `go-6383@agentmail.to` NOT just `go-6383`.
2. **API key must be in environment.** Set `AGENTMAIL_API_KEY` before invoking Node.
3. **Always provide both text and html.** AgentMail requires both formats for reliable delivery.
4. **Thread tracking.** When checking replies, match by `thread_id` to the ID returned from `send()`.
5. **Rate limits.** AgentMail has API rate limits. Use `timeout=15` and be prepared for occasional failures.
