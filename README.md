# .agents - Personal Assistant System

User-level agents and skills for [@HeyItsChloe](https://github.com/HeyItsChloe) — available across all repositories.

## Agents

| Agent | Purpose |
|-------|---------|
| `personal-assistant` | Main orchestrator — routes requests to subagents |
| `email-agent` | Gmail operations (send, read, draft, search) |
| `schedule-agent` | Google Calendar operations |
| `automation-agent` | Create/manage OpenHands automations |
| `interviewer-agent` | Gather requirements via structured Q&A |
| `agent-creator-agent` | Generate new file-based agents |
| `progress-agent` | Track goals, GitHub progress, weekly reports |
| `figma-to-code-agent` | Convert Figma designs to React/TSX with Tailwind |
| `test-writer-agent` | Generate unit tests following OpenHands patterns |

## Skills

| Skill | Purpose |
|-------|---------|
| `user-profile` | Personal preferences (timezone, communication style) |
| `github-context` | GitHub account context (HeyItsChloe, all repos) |
| `email-style` | Email composition rules (signature, tone) |
| `weekly-report` | Weekly progress report format |
| `goals-management` | Manual goals file format (goals.yaml) |
| `agent-creation` | Standards for creating new agents |
| `my-standards` | Personal coding preferences |
| `python-helper` | Python development assistance |
| `figma-code-patterns` | Figma → component mapping, property extraction |
| `tailwind-standards` | Tailwind CSS conventions and best practices |
| `openhands-code-patterns` | Code patterns based on OpenHands repo |
| `openhands-test-patterns` | Testing patterns based on OpenHands repo |

## Files

```
.agents/
├── agents/           # 9 subagents
├── skills/           # 12 skills
├── goals.yaml        # Manual goals tracker
└── README.md
```

## Usage

In any OpenHands conversation with a HeyItsChloe repo selected:

```
"Check my GitHub progress"        → progress-agent
"Send an email to..."             → email-agent
"Schedule a meeting..."           → schedule-agent
"Create an automation..."         → automation-agent
"Help me plan something"          → interviewer-agent
"Create a new agent"              → agent-creator-agent
"Convert this Figma to React"     → figma-to-code-agent
"Write tests for this module"     → test-writer-agent
```

## Weekly Automation

A weekly progress summary runs every **Saturday at 6:00 AM Pacific**, tracking:
- GitHub Projects & Milestones
- Manual goals from `goals.yaml`
- PRs (merged, open, conflicts)
- Issues activity

## Setup Required

- **Gmail/Calendar**: Requires Google OAuth credentials (not yet configured)
- **GitHub**: Uses `GITHUB_TOKEN` (available)
