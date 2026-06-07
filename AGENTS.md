# Pipeline Generator — OpenHands AI Agents

This repository contains AI agents for generating autonomous development pipelines for any GitHub repository.

## Agents

### Pipeline Generator Agents

| Agent | Purpose |
|-------|---------|
| `repo-auditor` | Clones repo, analyzes structure, outputs audit JSON |
| `template-resolver` | Matches audit findings to templates |
| `agent-generator` | Creates .agents/agents/*.md from templates |
| `skill-generator` | Creates .agents/skills/*.md from templates |
| `automation-registrar` | Registers OpenHands automation |
| `pipeline-committer` | Commits changes, creates PR |

### Generated Pipeline Agents

After generation, each repo gets:

| Agent | Purpose |
|-------|---------|
| `ticket-planner` | Reads issues, writes implementation plans |
| `code-implementer` | Creates branches, writes code |
| `tester` | Writes missing tests |
| `pr-reviewer` | Self-reviews, posts comments |
| `ticket-manager` | Creates PRs linked to issues |

## Skills

### Universal Skills (All Repos)

| Skill | Purpose |
|-------|---------|
| `env-setup` | Configures environment from secrets |
| `ci-monitor` | Polls CI checks, retries on failure |
| `whatsapp-notifier` | Sends review notifications |

### Conditional Skills (Audit-Revealed)

| Skill | Trigger |
|-------|---------|
| `build-check` | React/Vue/Angular frontend detected |
| `docker-build-check` | Dockerfile detected |
| `playwright-smoke` | playwright.config.js detected |

## Automation

The pipeline generator automation is defined in `.agents/automations/pipeline-generator.md`.

Trigger: Label an issue `setup-pipeline` on any repository.

## Tech Stack Detection

The `repo-auditor` agent detects:

- Languages: JavaScript, Python, Ruby, Go, Kotlin, Swift, Java
- Frameworks: React, Vue, Angular, Django, Rails, Express, Android, iOS
- Test frameworks: Jest, Vitest, pytest, RSpec, XCTest, JUnit
- CI systems: GitHub Actions, CircleCI, Jenkins
- Build systems: Gradle, Maven, Webpack, Vite, Make

## Triggering the Generator

```bash
# Create issue with repo URL in body
gh issue create --repo HeyItsChloe/pipeline-generator \
  --title "Setup pipeline" \
  --body "https://github.com/owner/repo"

# Label to trigger
gh issue edit <NUMBER> --add-label "setup-pipeline"
```

## Generated Output

For each repo, the generator creates:

```
{REPO}/
├── .agents/
│   ├── agents/
│   │   ├── ticket-planner.md
│   │   ├── code-implementer.md
│   │   ├── tester.md
│   │   ├── pr-reviewer.md
│   │   ├── ticket-manager.md
│   │   └── {conditional agents}.md
│   ├── skills/
│   │   ├── env-setup.md
│   │   ├── ci-monitor.md
│   │   ├── whatsapp-notifier.md
│   │   └── {conditional skills}.md
│   └── automations/
│       └── autonomous-dev-pipeline.md
```

## Next Steps

After generation:
1. Review the PR with generated files
2. Register secrets in OpenHands
3. Label an issue `ready-to-implement` to start the autonomous pipeline