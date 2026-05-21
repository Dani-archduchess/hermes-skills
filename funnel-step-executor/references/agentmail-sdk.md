# AgentMail SDK Reference

## SDK Setup

- **Node.js**: 20+ required
- **Package**: `agentmail` (npm)
- **API key**: Set via `AGENTMAIL_API_KEY` environment variable

## Send Email

```js
const { AgentMailClient } = require('agentmail');
const client = new AgentMailClient({ apiKey: process.env.AGENTMAIL_API_KEY });

const result = await client.inboxes.messages.send('YOUR_INBOX@agentmail.to', {
    to: ['recipient@example.com'],
    subject: 'Subject line',
    text: 'Plain text body',
    html: '<p>HTML body</p>'
});
// Returns: { message_id: "<...>", thread_id: "..." }
```

### Invoke from Hermes

```python
from hermes_tools import terminal
terminal("""cd ~/agentmail && node -e "
const { AgentMailClient } = require('agentmail');
...
"""", timeout=15)
```

## Check Inbox for Replies

```js
const result = await client.inboxes.messages.list('YOUR_INBOX@agentmail.to', { limit: 20 });
// Filter: direction === "inbound" for replies
```

Each message: `message_id`, `thread_id`, `direction`, `from`, `to`, `subject`, `text`, `created_at`.

## Gotchas

### Inbox ID format
**MUST be full domain form:** `go-6383@agentmail.to`
Using just `go-6383` returns 404.

### MCP server vs direct SDK
Prefer direct SDK invocation via `execute_code` + `terminal` for reliability. The MCP server uses the same SDK under the hood.
