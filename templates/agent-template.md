---
name: agent-name
description: >
  One-paragraph description of what this agent does and when to invoke it.
  Include 2-4 trigger examples:
  <example>Short phrase that would invoke this agent</example>
  <example>Another trigger phrase</example>
tools:
  - file_editor
  - terminal
model: inherit
permission_mode: never_confirm   # or always_confirm — see permission policy
---

# Agent Title

One sentence: what this agent does and what it does NOT do.

## Prerequisites

List env vars, installed tools, or tokens the agent needs before it can run.

```bash
[ -n "$GITHUB_TOKEN" ] && echo "set" || echo "GITHUB_TOKEN missing"
```

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `ISSUE_NUMBER` | Yes | GitHub Issue number to work from |
| `BRANCH_NAME` | No | Override default branch naming |

## Steps

### Step 1 — [First action]

Short description of what happens here.

```bash
# concrete commands
```

### Step 2 — [Next action]

### Step N — Handoff / Output Report

What this agent produces and where it hands off to.

```markdown
## [Agent Name] Complete: #<ISSUE> — <TITLE>

### [Output section]
[Content]

### Next Steps
Hand off to `next-agent-name`.
```

## What You Must Never Do

- Never push to `main` or merge a PR
- Never [domain-specific prohibition]
- Never expose secrets in logs or committed files
