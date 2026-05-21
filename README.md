# Hermes Skills — GHL + AgentMail

A collection of Hermes Agent skills for the GHL Agency Dashboard.

## Skills

| Skill | What it does |
|-------|-------------|
| **ghl-funnel-agent** | Create and manage sales funnels via the GHL Agency Dashboard API |
| **funnel-step-executor** | Cron watchdog that processes active funnel steps (emails, GHL checks) |
| **ghl-integration** | Direct GoHighLevel (LeadConnector) v2 API — contacts, opportunities, pipelines |
| **agentmail** | Send and track emails via AgentMail SDK |

## Quick Install

### Option 1: Clone and symlink (recommended)

```bash
git clone https://github.com/Dani-archduchess/hermes-skills.git ~/.hermes/skills/ghl
```

Then add to your Hermes config:

```yaml
skills:
  external_dirs:
    - ~/.hermes/skills/ghl
```

### Option 2: Copy individual skills

```bash
cp -r ghl-funnel-agent ~/.hermes/skills/ghl-funnel-agent
cp -r funnel-step-executor ~/.hermes/skills/funnel-step-executor
cp -r ghl-integration ~/.hermes/skills/ghl-integration
cp -r agentmail ~/.hermes/skills/agentmail
```

### Option 3: Use install script

```bash
./install.sh
```

## Credentials Setup

These skills require API credentials. Create environment variables or `.env` files:

```bash
# GHL
export GHL_API_KEY=your_ghl_api_key
export GHL_LOCATION_ID=your_location_id

# AgentMail
export AGENTMAIL_API_KEY=your_agentmail_api_key
```

Or edit `/etc/hermes/profile/.env`:

```env
GHL_API_KEY=your_ghl_api_key
GHL_LOCATION_ID=your_location_id
AGENTMAIL_API_KEY=your_agentmail_api_key
```

## Dashboard Setup

These skills expect the GHL Agency Dashboard running at `http://localhost:3001`. Clone and start it:

```bash
git clone https://github.com/Dani-archduchess/ghl-agency-dashboard.git
cd ghl-agency-dashboard/server
uvicorn app.main:app --port 3001
```

## Cron Setup

The `funnel-step-executor` skill is designed to run as a Hermes cron job:

```bash
hermes cron create   --name "Funnel Step Executor"   --schedule "every 2m"   --skill funnel-step-executor   --profile your-profile   "Process active funnel steps every 2 minutes"
```
