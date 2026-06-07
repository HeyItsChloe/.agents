# Automation Registry

Central tracking of all OpenHands automations across repositories.

## Active Automations

| Project | Name | Trigger | Status | Last Run |
|---------|------|---------|--------|----------|
| **BusyBuddy_v2** | Autonomous Dev Pipeline | `ready-to-implement` label | ✅ | - |
| **BusyBuddy_v2** | Daily Issue Processor (4AM) | Cron: `0 4 * * 1-5` | ✅ | - |
| **mates4ever** | Orbit Dev Pipeline | `ready-to-implement` label | ✅ | - |
| **mates4ever** | Daily Issue Processor (4AM) | Cron: `0 4 * * 1-5` | ✅ | - |
| **OrderMate** | Docs Agent Automation | Push to `main` | ✅ | - |
| **OrderMate** | Autonomous Dev Pipeline | `ready-to-implement` label | ✅ | - |
| **OrderMate** | Daily Issue Processor (4AM) | Cron: `0 4 * * 1-5` | ✅ | - |
| **.agents** | Autonomous Dev Pipeline | `ready-to-implement` label | ✅ | - |
| **.agents** | Complex Logic Pipeline | `complex-logic` label | ✅ | - |
| **.agents** | Daily Issue Processor (4AM) | Cron: `0 4 * * 1-5` | ✅ | - |

## Automation IDs

| Automation | ID | Registration Date |
|------------|-----|-------------------|
| BusyBuddy_v2 — Autonomous Dev Pipeline | `3cfefdb0-a1bc-4f26-bcc6-4136ff0fb4da` | 2026-05-31 |
| mates4ever — Orbit Dev Pipeline | `85c6bee9-c0bd-4d17-ab25-83e3d1255970` | 2026-06-01 |
| Complex Logic Pipeline | `2541e763-d4ac-4665-bd9e-4f726de211b6` | 2026-06-01 |
| OrderMate — Autonomous Dev Pipeline | TBD | - |
| OrderMate — Daily Issue Processor (4AM) | TBD | - |

## Repositories

| Repo | Pipeline | Cron | Complex Logic |
|------|----------|------|---------------|
| `11thandOrange/BusyBuddy_v2` | ✅ | ✅ | ✅ |
| `HeyItsChloe/mates4ever` | ✅ | ✅ | ✅ |
| `11thandOrange/OrderMate` | ✅ | ✅ | ✅ |
| `HeyItsChloe/.agents` | ✅ | ✅ | ✅ |

## GitHub Labels

| Label | Pipeline | Description |
|-------|----------|-------------|
| `ready-to-implement` | autonomous-dev-pipeline | Issue queued for autonomous implementation |
| `complex-logic` | complex-logic-pipeline | Issue requires 3 approach comparison |
| `admin` | daily-issue-processor | Excluded from 4AM batch processing |

## Verify Registration

```bash
# List all automations
curl -s "https://app.all-hands.dev/api/automation/v1" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  | python3 -c "import json,sys; [print(a['id'], a['name'], a['enabled']) for a in json.load(sys.stdin)['automations']]"

# Check specific automation
curl -s "https://app.all-hands.dev/api/automation/v1/{AUTOMATION_ID}" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}"
```

## Adding New Automations

See each repo's `.agents/automations/` directory for registration commands:

- `11thandOrange/BusyBuddy_v2/.agents/automations/autonomous-dev-pipeline.md`
- `HeyItsChloe/mates4ever/.agents/automations/orbit-dev-pipeline.md`
- `11thandOrange/OrderMate/.agents/automations/ordermate-dev-pipeline.md`
- `HeyItsChloe/.agents/automations/complex-logic-pipeline.md`
- `HeyItsChloe/.agents/automations/daily-issue-processor.md`

## Auto-Generate Script

To update this registry automatically:

```bash
#!/bin/bash
# generate-registry.sh

curl -s "https://app.all-hands.dev/api/automation/v1" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
for a in data['automations']:
    print(f\"{a['name']} | {a.get('id', 'N/A')} | {a.get('trigger', {}).get('type', 'N/A')} | {'✅' if a.get('enabled') else '❌'}\")
"
```