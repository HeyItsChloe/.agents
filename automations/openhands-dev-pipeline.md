# OpenHands Dev Pipeline — User Level

Manually process GitHub Issues from openhands/openhands repository. Clone the repo,
analyze the issue, implement the fix, and create a PR linked to the issue.

## Pipeline

```
Manual dispatch with issue number
        ↓
  ticket-planner              reads issue, creates implementation plan
        ↓
  code-implementer            creates branch, writes code
        ↓
  tester                      writes missing tests
        ↓
  pr-reviewer                 self-review, posts comments
        ↓
  ticket-manager              creates PR linked to issue
        ↓
  ci-monitor                  waits for CI green
        ↓
  whatsapp-notifier           sends review request
```

## All Dependencies Are User-Level

Every agent and skill this pipeline uses lives in `HeyItsChloe/.agents`:

```
agents/ticket-planner.md          ✅
agents/ticket-manager.md         ✅
agents/pr-reviewer.md            ✅
skills/ci-monitor.md              ✅
skills/whatsapp-notifier.md       ✅
```

No repo-level files are required. The automation clones `.agents` for access to
all user-level agents and skills.

## Manual Trigger

This automation is triggered manually via API dispatch:

```bash
# Dispatch the automation with issue number
curl -X POST "https://app.all-hands.dev/api/automation/v1/{automation_id}/dispatch" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "issue_number": 1234,
    "repo": "openhands/openhands"
  }'
```

Or via OpenHands Cloud UI:
1. Navigate to Automations
2. Find "OpenHands Dev Pipeline"
3. Click "Run Now"
4. Provide `issue_number` and `repo` parameters

## Required Secrets

| Secret | Used by |
|--------|---------|
| `GITHUB_TOKEN` | All GitHub operations |

## Target Repository

- **Repo:** openhands/openhands
- **Language:** Python 3.12-3.13
- **Package Manager:** Poetry
- **Test Framework:** pytest, pytest-asyncio
- **E2E Testing:** Playwright
- **Frontend:** TypeScript/Vite
- **Containerization:** Docker

## Register the Automation

```bash
curl -X POST "https://app.all-hands.dev/api/automation/v1/preset/prompt" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "OpenHands Dev Pipeline",
    "prompt": "You are the OpenHands dev pipeline for processing openhands/openhands issues.\n\nISSUE_NUMBER=<input:issue_number>\nREPO=openhands/openhands\n\necho \"Processing issue #$ISSUE_NUMBER from $REPO\"\n\n# Clone the target repo\ngit clone https://github.com/$REPO.git /workspace/$REPO\ncd /workspace/$REPO\n\n# Fetch issue details\nISSUE=$(gh issue view $ISSUE_NUMBER --repo $REPO --json title,body,labels)\nISSUE_TITLE=$(echo \"$ISSUE\" | jq -r '.title')\nISSUE_BODY=$(echo \"$ISSUE\" | jq -r '.body // \"\"')\n\necho \"Issue: $ISSUE_TITLE\"\necho \"---\"\necho \"$ISSUE_BODY\"\n\nSTEP 1 - ticket-planner: Follow agents/ticket-planner.md. Read the issue, explore the codebase, create implementation plan at /tmp/plan-$ISSUE_NUMBER.md.\n\nSTEP 2 - code-implementer: Follow agents/code-implementer.md. Create branch feat/issue-$ISSUE_NUMBER, implement changes following the plan. Run tests before commit.\n\nSTEP 3 - tester: Follow agents/tester.md. Write missing tests for the implementation.\n\nSTEP 4 - pr-reviewer: Follow agents/pr-reviewer.md. Self-review the changes, post comments.\n\nSTEP 5 - ticket-manager: Follow agents/ticket-manager.md. Open PR with Closes #$ISSUE_NUMBER.\n\nSTEP 6 - ci-monitor: Follow skills/ci-monitor.md. Wait for CI to pass.\n\nSTEP 7 - whatsapp-notifier: Follow skills/whatsapp-notifier.md. Send notification with PR link.\n\nOn failure: Post issue comment with error details.",
    "trigger": {
      "type": "cron",
      "schedule": "0 9 * * 1-5",
      "timezone": "America/Los_Angeles"
    },
    "repos": [
      {"url": "https://github.com/HeyItsChloe/.agents", "ref": "main"},
      {"url": "https://github.com/openhands/openhands", "ref": "main"}
    ],
    "timeout": 3600
  }'
```

## What the Pipeline Will Never Do

- Merge to `main`
- Push directly to `main`
- Delete existing code
- Process issues from repos other than openhands/openhands

## Usage

1. Find an issue in openhands/openhands you want to implement
2. Note the issue number
3. Dispatch the automation with the issue number
4. The pipeline will implement the fix and create a PR
5. Review the PR and merge when ready