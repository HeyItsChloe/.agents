# OpenHands Autonomous Development Pipeline

For GitHub Issues labelled `ready-to-implement` on `HeyItsChloe/.agents`, the pipeline reads the issue, implements the code, writes tests, reviews, and creates a PR.

## Pipeline

```
Issue labelled "ready-to-implement" on HeyItsChloe/.agents
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

## Trigger

```bash
gh issue edit <ISSUE_NUMBER> --repo HeyItsChloe/.agents --add-label "ready-to-implement"
```

## Required Label

```bash
gh label create "ready-to-implement" \
  --repo HeyItsChloe/.agents \
  --color "22C55E" \
  --description "Issue is ready for autonomous implementation"
```

## Required Secrets

| Secret | Used by |
|--------|---------|
| `GITHUB_TOKEN` | All GitHub operations |

## Tech Stack

This pipeline was generated for the OpenHands repository:
- **Language:** Python 3.12-3.13
- **Package Manager:** Poetry
- **Test Framework:** pytest, pytest-asyncio
- **E2E Testing:** Playwright
- **Frontend:** TypeScript/Vite
- **Containerization:** Docker

## Generated Files

```
.agents/
├── agents/
│   ├── ticket-planner.md
│   ├── code-implementer.md
│   ├── tester.md
│   ├── pr-reviewer.md
│   └── ticket-manager.md
├── skills/
│   ├── env-setup.md
│   ├── ci-monitor.md
│   └── whatsapp-notifier.md
└── automations/
    └── autonomous-dev-pipeline.md
```

## What the Pipeline Will Never Do

- Merge to `main`
- Push directly to `main`
- Delete existing code