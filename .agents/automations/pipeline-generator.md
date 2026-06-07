# Pipeline Generator Automation

End-to-end automation: GitHub Issue labeled `setup-pipeline` on a repository → audit → generate agents & skills → register automation.

## Pipeline

```
Issue labeled "setup-pipeline" on any repo
        ↓
  repo-auditor              clones repo, analyzes structure, outputs audit JSON
        ↓
  template-resolver          matches audit findings to templates, outputs pipeline spec
        ↓
  agent-generator           creates .agents/agents/*.md for each stage
        ↓
  skill-generator           creates .agents/skills/*.md for each helper
        ↓
  automation-registrar      creates "ready-to-implement" label, registers OpenHands automation
        ↓
  pipeline-committer        commits changes, creates PR with audit summary
```

## Live Automation

| Field | Value |
|-------|-------|
| **Automation ID** | (to be assigned on registration) |
| **Status** | Enabled |
| **Trigger** | `issues.labeled` → `setup-pipeline` on any repository |

## Required Secrets

| Secret | Used by |
|--------|---------|
| `GITHUB_TOKEN` | All GitHub operations (repo-auditor, automation-registrar, pipeline-committer) |

## Setup: Register the Automation

```bash
curl -X POST "https://app.all-hands.dev/api/automation/v1/preset/prompt" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Pipeline Generator",
    "prompt": "You are the pipeline generator automation. A GitHub Issue has been labeled setup-pipeline.\n\nSTEP 1 - repo-auditor: Follow .agents/agents/repo-auditor.md. Clone the repo from the issue repository field, analyze structure, output audit JSON to /tmp/audit-{REPO_NAME}.json.\n\nSTEP 2 - template-resolver: Follow .agents/agents/template-resolver.md. Read audit JSON, match against templates, output pipeline spec to /tmp/pipeline-spec-{REPO_NAME}.json.\n\nSTEP 3 - agent-generator: Follow .agents/agents/agent-generator.md. Read pipeline spec, generate all agent files in .agents/agents/.\n\nSTEP 4 - skill-generator: Follow .agents/agents/skill-generator.md. Read pipeline spec, generate all skill files in .agents/skills/.\n\nSTEP 5 - automation-registrar: Follow .agents/agents/automation-registrar.md. Create 'ready-to-implement' label if needed, register OpenHands automation via API.\n\nSTEP 6 - pipeline-committer: Follow .agents/agents/pipeline-committer.md. Create branch, commit all files, create PR with audit summary.",
    "trigger": {
      "type": "event",
      "source": "github",
      "on": "issues.labeled",
      "filter": "event.label.name == '\''setup-pipeline'\''"
    },
    "timeout": 1800,
    "repos": [
      {"url": "https://github.com/HeyItsChloe/pipeline-generator", "ref": "main"}
    ]
  }'
```

## Verify

```bash
curl -s "https://app.all-hands.dev/api/automation/v1" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  | python3 -c "import json,sys; [print(a['id'], a['name'], a['enabled']) for a in json.load(sys.stdin)['automations']]"
```

## Trigger the Pipeline

```bash
# Create the label if it doesn't exist
gh label create "setup-pipeline" \
  --repo {OWNER}/{REPO} \
  --color "8B5CF6" \
  --description "Generate autonomous dev pipeline for this repo"

# Label an issue to fire the pipeline (use any repo URL in the issue body)
gh issue create --repo HeyItsChloe/pipeline-generator --title "Setup pipeline for my-repo" --body "https://github.com/owner/my-repo"
gh issue edit <ISSUE_NUMBER> --repo HeyItsChloe/pipeline-generator --add-label "setup-pipeline"
```

## Related Files

```
.agents/agents/repo-auditor.md
.agents/agents/template-resolver.md
.agents/agents/agent-generator.md
.agents/agents/skill-generator.md
.agents/agents/automation-registrar.md
.agents/agents/pipeline-committer.md
.agents/templates/agents/
.agents/templates/skills/
```

## What the Pipeline Generator Will Never Do

- Merge to `main`
- Delete existing agents/skills (only adds new ones)
- Modify production code (only creates .agents/ directory)
- Deploy anything