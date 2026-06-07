# OpenHands Autonomous Development Pipeline

This is an autonomous development pipeline generated for the [OpenHands](https://github.com/openhands/openhands) repository.

## What This Does

When you label an issue with `ready-to-implement` on `HeyItsChloe/.agents`, the pipeline will:

1. **Read the issue** and understand what needs to be built
2. **Create an implementation plan** mapped to the OpenHands codebase
3. **Write the code** on a dedicated branch
4. **Add tests** for the new functionality
5. **Self-review** the changes
6. **Create a PR** linked to the issue
7. **Monitor CI** and notify when ready for review

## Tech Stack

- **Language:** Python 3.12-3.13
- **Package Manager:** Poetry
- **Test Framework:** pytest, pytest-asyncio
- **E2E Testing:** Playwright
- **Frontend:** TypeScript/Vite
- **Containerization:** Docker

## Usage

```bash
# Create an issue
gh issue create --repo HeyItsChloe/.agents \
  --title "Add new feature" \
  --body "Description of the feature"

# Trigger the pipeline
gh issue edit <ISSUE_NUMBER> --repo HeyItsChloe/.agents --add-label "ready-to-implement"
```

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

## Required Setup

1. Add `GITHUB_TOKEN` secret to OpenHands
2. Create the `ready-to-implement` label on `HeyItsChloe/.agents`
