# Debugging the GHL Dashboard Frontend

## The Unresponsive Button Pattern

When a button appears to do nothing, the cause is usually a **silent API error swallowed by an unhandled promise rejection**.

### Diagnostic Workflow

1. Open the page and reproduce the issue
2. Check browser console for unhandled rejections
3. Isolate API vs frontend — call the endpoint directly from console
4. Trace the data flow: click → state → onSubmit → store → api → backend

## Common Root Causes

### React Controlled Select Mismatch

When `<select value={state}>` doesn't match any `<option>`:
- DOM shows first option (looks correct)
- React state stays at mismatched value
- Form sends stale state → API error → dialog stays open

**Fix:** Use `useState("")` + `useEffect` that auto-selects first template when data loads.

### Vite Stale Cache

After editing `.tsx` files, hot-reload may serve stale bundles:
```bash
lsof -i :5174 -t | xargs kill
cd client && npx vite --port 5174
```
Then hard-refresh (Cmd+Shift+R).

### Hermes MCP Server Registration Gotcha

When `hermes mcp add` fails on `--stdio` flag (argparse conflict), edit `~/.hermes/config.yaml` directly under `mcp_servers`.
