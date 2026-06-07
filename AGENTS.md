# OpenHands Agent Library — HeyItsChloe

## Architecture

```
HeyItsChloe/.agents (THIS REPO) — User-Level (Canonical)
├── agents/           # User-level agents (generic, context-aware)
├── skills/           # User-level skills (generic, shared)
├── checklists/       # Project-specific review checklists
└── automations/      # Automation configurations

.REPO/.agents/ — Repo-Level (Project-Specific)
├── agents/           # Repo-level agents (project-specific)
├── skills/           # Repo-level skills (project-specific)
└── automations/      # Pipeline definitions
```

## User-Level Agents (Generic)

These agents work with any project by accepting context parameters from pipelines.

| Agent | Purpose | Context Params |
|-------|---------|----------------|
| `ticket-planner` | Reads issue → implementation plan | REPO_URL, SOURCE_DIR, TEST_DIR, BUILD_CMD, TEST_CMD, LANGUAGE, FRAMEWORK |
| `ticket-manager` | Manages issues and PRs | REPO_URL |
| `pr-reviewer` | Self-reviews PRs | REPO_URL, REPO_NAME, LANGUAGE, FRAMEWORK, CHECKLIST_FILE |
| `tester` | Writes missing tests | REPO_URL, TEST_DIR, TEST_CMD |
| `approach-planner` | Posts 3 approach options | REPO_URL |
| `approach-implementer` | Implements approach | REPO_URL |
| `approach-reviewer` | Scores approaches | REPO_URL |
| `code-implementer` | Generic code implementation | REPO_URL, SOURCE_DIR |

## User-Level Skills (Generic)

These skills work with any project.

| Skill | Purpose |
|-------|---------|
| `ci-monitor` | Poll GitHub Actions until pass/fail |
| `mark-pr-ready` | Remove draft status from PR |
| `whatsapp-notifier` | Send WhatsApp messages |
| `env-setup` | Configure environment from secrets |
| `submit-winning-approach` | Open PR from winning branch |

## Project Checklists

Located in `checklists/` — project-specific PR review criteria.

| Checklist | Project |
|-----------|---------|
| `busybuddy-review.md` | BusyBuddy_v2 (Shopify/React) |
| `orbit-review.md` | mates4ever (React/TypeScript) |
| `ordermate-review.md` | OrderMate (Android/Kotlin) |
| `agents-library-review.md` | .agents library itself |

## Pipelines

### Autonomous Dev Pipeline

**Trigger:** Label `ready-to-implement` OR Cron @ 4AM (Mon-Fri)
**Filter:** `project != "admin"`

**Steps:**
1. ticket-planner (user-level) → reads issue, creates plan
2. [repo]-implementer (repo-level) → implements code
3. tester (user-level) → writes tests
4. build-check (repo-level) → verifies build
5. ticket-manager (user-level) → creates PR
6. pr-reviewer (user-level) → self-reviews
7. ci-monitor (user-level) → waits for CI
8. mark-pr-ready (user-level) → removes draft
9. whatsapp-notifier (user-level) → sends notification

### Complex Logic Pipeline

**Trigger:** Label `complex-logic`
**Filter:** `project != "admin"`

**Steps:**
1. approach-planner → posts 3 approaches
2. approach-implementer (x3) → implements each approach
3. approach-reviewer → scores and picks winner
4. submit-winning-approach → opens PR
5. mark-pr-ready → removes draft
6. whatsapp-notifier → sends notification

## Context Parameters

When calling user-level agents, pipelines pass these at runtime:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `{{REPO_URL}}` | GitHub repo URL | `11thandOrange/BusyBuddy_v2` |
| `{{REPO_NAME}}` | Short repo name | `busybuddy`, `orbit`, `ordermate` |
| `{{SOURCE_DIR}}` | Source code directory | `web/frontend/src/`, `src/` |
| `{{TEST_DIR}}` | Test directory | `src/__tests__/`, `web/test/` |
| `{{BUILD_CMD}}` | Build command | `npm run build`, `./gradlew assembleDebug` |
| `{{TEST_CMD}}` | Test command | `npm test`, `./gradlew test` |
| `{{LANGUAGE}}` | Primary language | `TypeScript`, `Kotlin`, `Python` |
| `{{FRAMEWORK}}` | Framework | `React`, `Android`, `FastAPI` |
| `{{CHECKLIST_FILE}}` | Path to project checklist | `.agents/checklists/busybuddy-review.md` |

## Safety Rules

All agents must follow:
- **NEVER** merge to main without explicit confirmation
- **NEVER** approve PRs without explicit confirmation
- **NEVER** delete branches without explicit confirmation
- **NEVER** force push

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| User-level agents | Generic names | `ticket-planner`, `pr-reviewer` |
| Repo-level agents | Project-prefixed | `busybuddy-implementer`, `orbit-tester` |
| User-level skills | Descriptive | `ci-monitor`, `whatsapp-notifier` |
| Repo-level skills | Project-prefixed | `busybuddy-build-check`, `orbit-dev-server` |
| Checklists | Project-prefixed | `busybuddy-review.md` |

## GitHub Labels

| Label | Pipeline | Description |
|-------|----------|-------------|
| `ready-to-implement` | autonomous-dev-pipeline | Issue queued for autonomous implementation |
| `complex-logic` | complex-logic-pipeline | Issue requires 3 approach comparison |
| `admin` | All cron triggers | Excluded from scheduled processing |
