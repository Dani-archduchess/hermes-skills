# GHL Dashboard API Patterns (v2)

## API Basics

- Base URL: `http://localhost:3001`
- Auth header: `Authorization: Bearer <api_key>`
- Content-Type: `application/json`

## Endpoint Reference

### Funnels

| Method | Path | Body | Returns |
|--------|------|------|---------|
| GET | `/api/funnels` | — | `{ funnels, total }` |
| GET | `/api/funnels/:id` | — | `FunnelDetail` (includes steps) |
| POST | `/api/funnels` | `{ templateId, clientId, name }` | `FunnelCreateResponse` |
| PATCH | `/api/funnels/:id` | `{ name?, status? }` | `FunnelDetail` |
| PATCH | `/api/funnels/:fid/steps/:sid` | `{ status?, output?, notes?, completed_by? }` | `FunnelStepOut` |
| DELETE | `/api/funnels/:id` | — | 204 (hard delete + cascade) |
| POST | `/api/funnels/:id/clone` | `{ targetClientId, name }` | `FunnelCreateResponse` |

**Funnel status values:** `draft`, `active`, `paused`, `complete`

### Templates

| Method | Path | Body | Returns |
|--------|------|------|---------|
| GET | `/api/templates` | — | `FunnelTemplate[]` |
| POST | `/api/templates` | `{ name, description?, category?, steps? }` | `FunnelTemplate` |
| PUT | `/api/templates/:id` | `{ name?, description?, category?, steps? }` | `FunnelTemplate` |
| DELETE | `/api/templates/:id` | — | 204 |

### Clients

| Method | Path | Body | Returns |
|--------|------|------|---------|
| GET | `/api/clients` | — | `Client[]` |
| POST | `/api/clients` | `{ name, companyName, subaccountId, password, status, ... }` | `Client` |
| DELETE | `/api/clients/:id` | — | 204 (cascade) |

## Step Model

```json
{
  "name": "Step Name",
  "order": 1,
  "description": "What this step does",
  "agent_instructions": "Directions for the agent",
  "status": "pending|in_progress|completed|failed",
  "output": {},
  "completed_at": "...",
  "completed_by": "agent|human",
  "notes": "..."
}
```

## DELETE Semantics

| Entity | Cascade |
|--------|---------|
| Funnels | Delete funnel + all steps |
| Clients | Delete client + funnels + tickets |
| Templates | Delete template, null-out funnel references |

All deletes are hard deletes (irreversible, 204 No Content).
