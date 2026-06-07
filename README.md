# Pipeline Generator

An OpenHands automation that generates autonomous development pipelines for any GitHub repository. The pipeline follows the same patterns as the [BusyBuddy_v2](https://github.com/11thandOrange/BusyBuddy_v2) autonomous dev pipeline.

## Overview

The pipeline generator:
1. **Audits** a repository (detects tech stack, test frameworks, CI/CD)
2. **Generates** agents and skills tailored to that repo
3. **Registers** the OpenHands automation
4. **Commits** everything to a PR for review

## Quick Start

```bash
# Label an issue on any repo to trigger pipeline generation
gh issue edit <ISSUE_NUMBER> --repo owner/repo --add-label "setup-pipeline"
```

Or provide a repo URL in the issue body:
```
https://github.com/owner/my-android-app
```

## Architecture

```
.agents/
├── agents/                    # Pipeline generator agents
│   ├── repo-auditor.md       # Clones repo, analyzes structure
│   ├── template-resolver.md  # Matches audit to templates
│   ├── agent-generator.md    # Creates .agents/agents/*.md
│   ├── skill-generator.md    # Creates .agents/skills/*.md
│   ├── automation-registrar.md # Registers OpenHands automation
│   └── pipeline-committer.md # Creates PR with generated files
│
├── skills/                    # User-level shared skills
│   ├── ci-monitor.md         # Polls CI checks
│   └── whatsapp-notifier.md  # Sends notifications
│
├── templates/
│   ├── agents/              # Universal + conditional agent templates
│   │   ├── ticket-planner.md
│   │   ├── code-implementer.md
│   │   ├── tester.md
│   │   ├── pr-reviewer.md
│   │   ├── ticket-manager.md
│   │   ├── android-implementer.md
│   │   ├── android-tester.md
│   │   ├── ios-implementer.md
│   │   ├── ios-tester.md
│   │   ├── smoke-tester.md
│   │   └── python-tester.md
│   │
│   └── skills/              # Universal + conditional skill templates
│       ├── env-setup.md
│       ├── ci-monitor.md
│       ├── whatsapp-notifier.md
│       ├── build-check.md
│       ├── docker-build-check.md
│       └── playwright-smoke.md
│
└── automations/
    └── pipeline-generator.md # Main automation definition
```

## Universal Components (All Repos)

These are always generated regardless of tech stack:

| Component | Type | Purpose |
|-----------|------|---------|
| `ticket-planner` | Agent | Reads GitHub Issue → implementation plan |
| `code-implementer` | Agent | Creates branch, writes code |
| `tester` | Agent | Writes missing tests |
| `pr-reviewer` | Agent | Self-reviews, posts comments |
| `ticket-manager` | Agent | Creates PR linked to issue |
| `env-setup` | Skill | Configures environment from secrets |
| `ci-monitor` | Skill | Polls CI checks, retries on failure |
| `whatsapp-notifier` | Skill | Sends review notifications |

## Conditional Components (Audit-Revealed)

Based on repository audit, these are added as needed:

| Detection | Components Generated |
|-----------|---------------------|
| `build.gradle` | `android-implementer`, `android-tester` |
| `*.xcodeproj` | `ios-implementer`, `ios-tester` |
| `playwright.config.js` | `smoke-tester`, `playwright-smoke` skill |
| `Dockerfile` | `docker-build-check` skill |
| React/Vue/Angular | `build-check` skill |
| `pytest.ini` | `python-tester` agent |

## Example Audit Output

```json
{
  "repo_url": "https://github.com/myorg/android-app",
  "repo_name": "android-app",
  "tech_stack": {
    "language": "kotlin",
    "framework": "android",
    "package_manager": "gradle"
  },
  "conditional_components": {
    "has_android": true,
    "has_docker": true
  }
}
```

**Generated pipeline:** ticket-planner, android-implementer, android-tester, pr-reviewer, ticket-manager, env-setup, ci-monitor, whatsapp-notifier, docker-build-check

## Setup

### Prerequisites

1. OpenHands account with API key
2. GitHub token with repo access

### Register Secrets

```bash
# In OpenHands → Settings → Secrets
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
```

### Register Automation

```bash
curl -X POST "https://app.all-hands.dev/api/automation/v1/preset/prompt" \
  -H "Authorization: Bearer ${OPENHANDS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @.agents/automations/pipeline-generator.md
```

## Triggering Pipeline Generation

```bash
# Create issue with repo URL
gh issue create --repo HeyItsChloe/pipeline-generator \
  --title "Setup pipeline for my-repo" \
  --body "https://github.com/owner/my-repo"

# Label to trigger
gh issue edit <NUMBER> --add-label "setup-pipeline"
```

## What Gets Generated

For each repository, the generator creates:

```
{REPO}/
├── .agents/
│   ├── agents/
│   │   ├── ticket-planner.md
│   │   ├── code-implementer.md    # (parameterized for detected stack)
│   │   ├── tester.md              # (parameterized for test framework)
│   │   ├── pr-reviewer.md
│   │   ├── ticket-manager.md
│   │   └── {conditional agents}.md
│   │
│   ├── skills/
│   │   ├── env-setup.md           # (parameterized for config file)
│   │   ├── ci-monitor.md
│   │   ├── whatsapp-notifier.md
│   │   └── {conditional skills}.md
│   │
│   └── automations/
│       └── autonomous-dev-pipeline.md
```

## Pipeline Flow

```
Issue labeled "ready-to-implement"
        ↓
  ticket-planner              reads issue, maps to codebase
        ↓
  code-implementer            creates branch, writes code
        ↓
  tester                      writes missing tests
        ↓
  build-check (if applicable) frontend build verification
        ↓
  smoke-tester (if applicable) E2E tests
        ↓
  ticket-manager              creates PR
        ↓
  pr-reviewer                 self-review, comments
        ↓
  ci-monitor                  waits for CI green
        ↓
  whatsapp-notifier           sends review request
```

## Contributing

To add support for a new tech stack:

1. Create agent template in `.agents/templates/agents/{stack}-implementer.md`
2. Create skill template in `.agents/templates/skills/{stack}-*.md`
3. Add detection logic to `repo-auditor.md`
4. Add template mapping to `template-resolver.md`

## License

MIT