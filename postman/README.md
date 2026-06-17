# OpenHands - Postman Collection

Trigger OpenHands automations with a single click via GitHub repository_dispatch.

## Files

- `Automations_Local.postman_collection.json` - Postman collection
- `Automations_Cloud.postman_environment.json` - Environment with variables

## Setup

### 1. Import into Postman

1. Open Postman
2. Click **Import** → Select both JSON files
3. Select the **Automations - GitHub Dispatch** environment

### 2. Configure Environment

1. Set `GITHUB_TOKEN`:
   - Create a GitHub Personal Access Token: https://github.com/settings/tokens
   - Required scope: `repo` (full control)
   - Paste into the `GITHUB_TOKEN` variable (mark as "Secret")

## Usage

### Quick Start

1. Set `ISSUE_NUMBER` (e.g., `42`)
2. Set `REPO` (e.g., `11thandOrange/BusyBuddy_v2`)
3. Navigate to **📁 Per-Repository Quick Triggers** → Select your repo
4. Click **Send**

That's it! The workflow handles everything else.

### How It Works

```
Postman → GitHub repository_dispatch → HeyItsChloe/.agents workflow → OpenHands Cloud
```

The POST request sends:
```json
{
  "event_type": "postman-webhook",
  "client_payload": {
    "issue": {
      "number": 42,
      "html_url": "https://github.com/11thandOrange/BusyBuddy_v2/issues/42"
    },
    "label": {
      "name": "ready-to-implement"
    },
    "repository": "11thandOrange/BusyBuddy_v2"
  }
}
```

The GitHub workflow extracts the issue info and triggers OpenHands.

## Repositories & Pipelines

| Repository | Pipeline | Label |
|------------|----------|-------|
| 11thandOrange/BusyBuddy_v2 | Autonomous Dev | ready-to-implement |
| 11thandOrange/BusyBuddy_v2 | Complex Logic | complex-logic |
| 11thandOrange/OrderMate | Autonomous Dev | ready-to-implement |
| 11thandOrange/OrderMate | Complex Logic | complex-logic |
| HeyItsChloe/mates4ever | Autonomous Dev | ready-to-implement |
| HeyItsChloe/mates4ever | Complex Logic | complex-logic |
| openhands/openhands | Dev Pipeline | openhands-ready |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GITHUB_TOKEN` | (empty) | GitHub PAT with repo scope |
| `TARGET_REPO` | HeyItsChloe/.agents | Repo to dispatch to |
| `ISSUE_NUMBER` | 42 | Issue number to process |
| `REPO` | 11thandOrange/BusyBuddy_v2 | Source repository |
| `LABEL` | ready-to-implement | Label to pass |

## Troubleshooting

### "401 Unauthorized"
- Verify `GITHUB_TOKEN` is set and valid
- Ensure token has `repo` scope

### "404 Not Found"
- Check `TARGET_REPO` is correct (usually `HeyItsChloe/.agents`)

### "422 Unprocessable Entity"
- Verify `ISSUE_NUMBER` is a valid number
- Ensure `REPO` format is `owner/repo`

## Direct cURL Example

```bash
curl -X POST https://api.github.com/repos/HeyItsChloe/.agents/dispatches \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "postman-webhook",
    "client_payload": {
      "issue": {
        "number": 42,
        "html_url": "https://github.com/11thandOrange/BusyBuddy_v2/issues/42"
      },
      "label": {"name": "ready-to-implement"},
      "repository": "11thandOrange/BusyBuddy_v2"
    }
  }'
```
