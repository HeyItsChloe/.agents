# OpenHands Autonomous Development Pipeline

This directory contains the autonomous development pipeline for the OpenHands project.

## Overview

The pipeline automatically:
1. Reads GitHub Issues labeled `ready-to-implement`
2. Creates an implementation plan
3. Writes code on a dedicated branch
4. Adds tests
5. Self-reviews the changes
6. Creates a PR linked to the issue
7. Monitors CI and notifies when ready for review

## Quick Start

```bash
# Label an issue to trigger the pipeline
gh issue edit <ISSUE_NUMBER> --repo HeyItsChloe/.agents --add-label "ready-to-implement"
```

## Tech Stack

- **Language:** Python 3.12-3.13
- **Package Manager:** Poetry
- **Test Framework:** pytest, pytest-asyncio
- **E2E Testing:** Playwright
- **Frontend:** TypeScript/Vite
- **Containerization:** Docker

## Agents

| Agent | Purpose |
|-------|---------|
| `ticket-planner` | Reads issues, creates implementation plans |
| `code-implementer` | Creates branches, writes code |
| `tester` | Writes missing tests |
| `pr-reviewer` | Self-reviews, posts comments |
| `ticket-manager` | Creates PRs linked to issues |

## Skills

| Skill | Purpose |
|-------|---------|
| `env-setup` | Configures environment from secrets |
| `ci-monitor` | Polls CI checks, retries on failure |
| `whatsapp-notifier` | Sends review notifications |

## Automation

The automation is defined in `.agents/automations/autonomous-dev-pipeline.md`.

Trigger: Label an issue `ready-to-implement` on `HeyItsChloe/.agents`.
