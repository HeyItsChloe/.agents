# Automation Registrar Agent

Creates the "ready-to-implement" label in the target repository and registers the OpenHands automation via API.

## Inputs

- Pipeline spec: `/tmp/pipeline-spec-{REPO_NAME}.json`
- Target repo: `/tmp/{REPO_NAME}`

## Process

### Step 1: Read Pipeline Spec

```bash
cat /tmp/pipeline-spec-{REPO_NAME}.json | jq .
OWNER=$(jq -r '.owner' /tmp/pipeline-spec-{REPO_NAME}.json)
REPO_NAME=$(jq -r '.repo_name' /tmp/pipeline-spec-{REPO_NAME}.json)
```

### Step 2: Create "ready-to-implement" Label

```bash
# Create the label if it doesn't exist
gh label create "ready-to-implement" \
  --repo $OWNER/$REPO_NAME \
  --color "0075ca" \
  --description "Queued for autonomous implementation" 2>/dev/null || echo "Label may already exist"
```

### Step 3: Build Automation Prompt

Read the generated agents and skills to build the prompt for the OpenHands automation:

```bash
# Read agent list from spec
AGENT_NAMES=$(jq -r '.agents.universal[].name, .agents.conditional[].name' /tmp/pipeline-spec-{REPO_NAME}.json | tr '\n' ', ')
SKILL_NAMES=$(jq -r '.skills.universal[].name, .skills.conditional[].name' /tmp/pipeline-spec-{REPO_NAME}.json | tr '\n' ', ')

# Build prompt with step-by-step instructions referencing generated files
PROMPT="You are the autonomous development pipeline for \$REPO.

A GitHub Issue has been labelled ready-to-implement. Find it: gh issue list --repo \$OWNER/\$REPO --label ready-to-implement --state open --json number,title,body,labels --limit 1

Execute each step. On unrecoverable failure go to final notification step.

STEP 1 - ticket-planner: Follow .agents/agents/ticket-planner.md. Fetch issue, explore codebase, produce plan, save to /tmp/plan-\$ISSUE_NUMBER.md.

STEP 2 - code-implementer: Follow .agents/agents/code-implementer.md. Create branch, implement changes, run tests, commit.

STEP 3 - tester: Follow .agents/agents/tester.md. Write missing tests for new code. Run all test suites. Commit new test files.

STEP 4 - build-check (if applicable): Follow .agents/skills/build-check.md. Run build command. Fix errors if any.

STEP 5 - smoke-tester (if applicable): Follow .agents/agents/smoke-tester.md. Run end-to-end tests, commit screenshots.

STEP 6 - ticket-manager: Push branch, create PR: gh pr create --repo \$OWNER/\$REPO --title ISSUE_TITLE --body Closes #NUMBER. DESCRIPTION --base main.

STEP 7 - pr-reviewer: Follow .agents/agents/pr-reviewer.md. Review diff, post inline comments, iterate on critical issues (max 2 iterations).

STEP 8 - ci-monitor: Follow .agents/skills/ci-monitor.md. Poll gh pr checks, on failure fetch logs, fix, push, re-poll (max 3 retries).

STEP 9 - mark-pr-ready then whatsapp-notifier: If CI passed: follow .agents/skills/mark-pr-ready.md to remove draft status, then follow .agents/skills/whatsapp-notifier.md — message: ✅ PR #NUMBER is ready for your review. Link: PR_URL. If CI failed or earlier failure: follow .agents/skills/whatsapp-notifier.md only — message: ❌ Pipeline failed. Manual action required. Link: PR_URL."
```

### Step 4: Register OpenHands Automation

```bash
# Determine OpenHands host
OPENHANDS_HOST="${OPENHANDS_HOST:-https://app.all-hands.dev}"

# Get repo URL and owner from spec
REPO_URL=$(jq -r '.repo_url' /tmp/pipeline-spec-{REPO_NAME}.json)
OWNER=$(jq -r '.owner' /tmp/pipeline-spec-{REPO_NAME}.json)
REPO_NAME=$(jq -r '.repo_name' /tmp/pipeline-spec-{REPO_NAME}.json)
TIMEOUT=$(jq -r '.automation.timeout // 3600' /tmp/pipeline-spec-{REPO_NAME}.json)
TRIGGER_FILTER=$(jq -r '.automation.trigger_filter' /tmp/pipeline-spec-{REPO_NAME}.json)

# Register via API
curl -s -X POST "${OPENHANDS_HOST}/api/automation/v1/preset/prompt" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "{REPO_NAME} — Autonomous Dev Pipeline",
    "prompt": "'"$(echo "$PROMPT" | sed 's/"/\\"/g')"'",
    "trigger": {
      "type": "event",
      "source": "github",
      "on": "issues.labeled",
      "filter": "'"$(echo "$TRIGGER_FILTER" | sed 's/"/\\"/g')"'"
    },
    "timeout": '"$TIMEOUT"',
    "repos": [
      {"url": "'"$REPO_URL"'", "ref": "main"}
    ]
  }' | jq .
```

### Step 5: Save Automation ID

```bash
# Extract automation ID from response
AUTOMATION_ID=$(curl -s -X POST "${OPENHANDS_HOST}/api/automation/v1/preset/prompt" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{...}' | jq -r '.id // empty')

if [ -n "$AUTOMATION_ID" ]; then
  echo "Automation registered: $AUTOMATION_ID"
  echo "$AUTOMATION_ID" > /tmp/automation-id-{REPO_NAME}.txt
else
  echo "Warning: Could not extract automation ID"
fi
```

### Step 6: Create Automation Config File

```bash
# Write automation details to the target repo
cat > /tmp/{REPO_NAME}/.agents/automations/autonomous-dev-pipeline.md << 'EOF'
# Autonomous Dev Pipeline — {REPO_NAME}

End-to-end automation: GitHub Issue labelled `ready-to-implement` → implemented → PR → reviewed → CI green → notification.

## Pipeline

```
Issue labelled "ready-to-implement"
        ↓
  ticket-planner              reads issue, maps to codebase, writes plan
        ↓
  code-implementer            creates branch, writes code
        ↓
  tester                      writes missing tests
        ↓
  build-check (if applicable) frontend build verification
        ↓
  smoke-tester (if applicable) end-to-end tests
        ↓
  ticket-manager              creates PR linked to issue
        ↓
  pr-reviewer                 self-review, inline comments, iterate (max 2)
        ↓
  ci-monitor                  waits for CI to green (max 3 retries)
        ↓
  whatsapp-notifier           sends review request to your phone
```

## Live Automation

| Field | Value |
|-------|-------|
| **Automation ID** | `{AUTOMATION_ID}` |
| **Status** | ✅ Enabled |
| **Trigger** | `issues.labeled` → `ready-to-implement` on `{OWNER}/{REPO_NAME}` |

## Setup: Register the Automation

```bash
# Already registered via pipeline-generator automation
# Automation ID: {AUTOMATION_ID}
```

## Trigger the Pipeline

```bash
# Create the label if it doesn't exist
gh label create "ready-to-implement" \
  --repo {OWNER}/{REPO_NAME} \
  --color "0075ca" \
  --description "Queued for autonomous implementation"

# Label an issue to fire the pipeline
gh issue edit <ISSUE_NUMBER> \
  --repo {OWNER}/{REPO_NAME} \
  --add-label "ready-to-implement"
```

## What the Pipeline Will Never Do

- Merge to `main`
- Deploy to production
- Modify production environment variables

## Generated Files

```
.agents/agents/
  - ticket-planner.md
  - code-implementer.md
  - tester.md
  - pr-reviewer.md
  - ticket-manager.md
  - {conditional agents}
.agents/skills/
  - env-setup.md
  - ci-monitor.md
  - whatsapp-notifier.md
  - {conditional skills}
```
EOF

# Save automation ID to file
echo "AUTOMATION_ID={AUTOMATION_ID}" >> /tmp/{REPO_NAME}/.agents/automations/autonomous-dev-pipeline.md
```

## Output

- "ready-to-implement" label created in target repo
- OpenHands automation registered and enabled
- Automation config file written to `.agents/automations/autonomous-dev-pipeline.md`
- Automation ID saved to `/tmp/automation-id-{REPO_NAME}.txt`

## Error Handling

If label creation fails (already exists): log and continue
If API registration fails: log error to `/tmp/automation-registration-error.log`, continue with file generation

## Next Step

After automation registration is complete, invoke `pipeline-committer` to commit and create PR.