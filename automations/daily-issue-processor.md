# Daily Issue Processor — Cron Automation

Batch process all `ready-to-implement` issues at 4AM (Mon-Fri) for all repos.

## Trigger

| Field | Value |
|-------|-------|
| **Type** | Cron |
| **Schedule** | `0 4 * * 1-5` (4:00 AM UTC, Mon-Fri) |
| **Timezone** | UTC |

## Filter

```
project != "admin"
```

Issues in the `admin` project are excluded from batch processing.

## What It Does

```
4AM Cron Trigger
       ↓
  Fetch all open issues labeled "ready-to-implement" across repos
       ↓
  For each repo:
    Fetch issues with "ready-to-implement" label
    Filter out issues in "admin" project
       ↓
    For each qualifying issue:
      Trigger the autonomous dev pipeline for that issue
       ↓
  Report summary of processed issues
```

## Repos Covered

| Org | Repos |
|-----|-------|
| `HeyItsChloe` | .agents, mates4ever |
| `11thandOrange` | OrderMate, BusyBuddy_v2 |

## Register the Automation

### Option A: Single Wildcard (All Repos)

```bash
curl -X POST "https://app.all-hands.dev/api/automation/v1/preset/prompt" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Daily Issue Processor (4AM)",
    "prompt": "You are the daily issue processor.\n\nAt 4AM, batch process all open issues labeled ready-to-implement across all repos.\n\nSTEP 1: Determine triggering repo:\nREPO=$(gh repo view --json nameWithOwner -q '\''\''.nameWithOwner'\'')\necho \"Processing: $REPO\"\n\nSTEP 2: Get all open issues with ready-to-implement label:\ngh issue list --repo \"$REPO\" --label ready-to-implement --state open --json number,title,body,project --limit 20\n\nSTEP 3: Filter out issues in admin project:\nFor each issue, check if it is in the admin project. Skip if so.\n\nSTEP 4: For each qualifying issue:\n- Log: \"Processing issue #N: TITLE\"\n- Trigger autonomous pipeline by following the repo'\''s pipeline steps\n\nSTEP 5: Report summary:\n- Total issues found\n- Total issues skipped (admin project)\n- Total issues processed\n\nSTEP 6: Send notification:\nIf issues were processed, send WhatsApp message with summary.",
    "trigger": {
      "type": "cron",
      "schedule": "0 4 * * 1-5",
      "timezone": "UTC"
    },
    "timeout": 7200,
    "repos": [
      {"url": "https://github.com/HeyItsChloe/.agents", "ref": "main"},
      {"url": "https://github.com/HeyItsChloe/mates4ever", "ref": "main"},
      {"url": "https://github.com/11thandOrange/OrderMate", "ref": "main"},
      {"url": "https://github.com/11thandOrange/BusyBuddy_v2", "ref": "main"}
    ]
  }'
```

### Option B: Per-Repo Registration

For more control over each repo's cron processing:

```bash
# OrderMate Daily Processor
curl -X POST "https://app.all-hands.dev/api/automation/v1/preset/prompt" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "OrderMate — Daily Issue Processor (4AM)",
    "prompt": "You are the daily issue processor for OrderMate.\n\nAt 4AM, batch process all open issues labeled ready-to-implement in the OrderMate repo.\n\nSTEP 1: Fetch all open issues with ready-to-implement:\ngh issue list --repo 11thandOrange/OrderMate --label ready-to-implement --state open --json number,title,body --limit 20\n\nSTEP 2: Filter out issues in admin project (skip if in admin).\n\nSTEP 3: For each qualifying issue, trigger the autonomous pipeline:\n- Follow .agents/agents/ordermate-ticket-planner.md\n- Follow .agents/agents/ordermate-implementer.md\n- Continue through all pipeline steps\n\nSTEP 4: Report summary to WhatsApp.",
    "trigger": {
      "type": "cron",
      "schedule": "0 4 * * 1-5",
      "timezone": "UTC"
    },
    "timeout": 7200,
    "repos": [
      {"url": "https://github.com/11thandOrange/OrderMate", "ref": "main"},
      {"url": "https://github.com/HeyItsChloe/.agents", "ref": "main"}
    ]
  }'

# BusyBuddy_v2 Daily Processor
curl -X POST "https://app.all-hands.dev/api/automation/v1/preset/prompt" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "BusyBuddy_v2 — Daily Issue Processor (4AM)",
    "prompt": "You are the daily issue processor for BusyBuddy_v2.\n\nAt 4AM, batch process all open issues labeled ready-to-implement in the BusyBuddy_v2 repo.\n\nSTEP 1: Fetch all open issues with ready-to-implement:\ngh issue list --repo 11thandOrange/BusyBuddy_v2 --label ready-to-implement --state open --json number,title,body --limit 20\n\nSTEP 2: Filter out issues in admin project.\n\nSTEP 3: For each qualifying issue, trigger the autonomous pipeline.\n\nSTEP 4: Report summary to WhatsApp.",
    "trigger": {
      "type": "cron",
      "schedule": "0 4 * * 1-5",
      "timezone": "UTC"
    },
    "timeout": 7200,
    "repos": [
      {"url": "https://github.com/11thandOrange/BusyBuddy_v2", "ref": "main"},
      {"url": "https://github.com/HeyItsChloe/.agents", "ref": "main"}
    ]
  }'

# mates4ever Daily Processor
curl -X POST "https://app.all-hands.dev/api/automation/v1/preset/prompt" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Orbit — Daily Issue Processor (4AM)",
    "prompt": "You are the daily issue processor for Orbit (mates4ever).\n\nAt 4AM, batch process all open issues labeled ready-to-implement.\n\nSTEP 1: Fetch all open issues with ready-to-implement:\ngh issue list --repo HeyItsChloe/mates4ever --label ready-to-implement --state open --json number,title,body --limit 20\n\nSTEP 2: Filter out issues in admin project.\n\nSTEP 3: For each qualifying issue, trigger the autonomous pipeline.\n\nSTEP 4: Report summary to WhatsApp.",
    "trigger": {
      "type": "cron",
      "schedule": "0 4 * * 1-5",
      "timezone": "UTC"
    },
    "timeout": 7200,
    "repos": [
      {"url": "https://github.com/HeyItsChloe/mates4ever", "ref": "main"},
      {"url": "https://github.com/HeyItsChloe/.agents", "ref": "main"}
    ]
  }'
```

## Filter Logic

```bash
# Pseudocode for filtering
for issue in issues:
  if issue.project == "admin":
    skip  # Exclude from batch processing
  else:
    process  # Trigger autonomous pipeline
```

## What Happens to Labeled Issues at 4AM

| Issue State | Action |
|-------------|--------|
| `ready-to-implement` + NOT in admin | ✅ Process at 4AM |
| `ready-to-implement` + IN admin | ⏭️ Skip (admin project) |
| No `ready-to-implement` label | ⏭️ Nothing to do |

## WhatsApp Summary

After batch processing completes, send a summary:

```
Daily Issue Processor Summary — $(date +%Y-%m-%d)

Repo: {REPO_NAME}
Issues found: {COUNT}
Skipped (admin): {SKIPPED}
Processed: {PROCESSED}

Details:
- #N: TITLE — status
- #N: TITLE — status
```

## Verify Registration

```bash
curl -s "https://app.all-hands.dev/api/automation/v1" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  | python3 -c "import json,sys; [print(a['id'], a['name'], a['trigger']) for a in json.load(sys.stdin)['automations'] if '4AM' in a['name']]"
```

## Related Automations

| Automation | Trigger | Purpose |
|------------|---------|---------|
| `autonomous-dev-pipeline` | Label `ready-to-implement` | Single issue processing |
| `complex-logic-pipeline` | Label `complex-logic` | Multi-approach processing |
| `daily-issue-processor` | Cron @ 4AM | Batch processing |