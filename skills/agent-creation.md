# Agent Creation

This skill defines the standards for creating new file-based agents.

## Agent File Location

```
~/.openhands/agents/{agent-name}.md
```

## File Format

File-based agents use Markdown with YAML frontmatter:

```markdown
---
name: agent-name
description: >
  What this agent does.
  <example>Example task 1</example>
  <example>Example task 2</example>
tools:
  - tool_name_1
  - tool_name_2
model: inherit
skills:
  - skill-name-1
  - skill-name-2
permission_mode: never_confirm
---

# Agent Name

You are a [role description]. Your purpose is to [main function].

## Capabilities

1. First capability
2. Second capability

## Instructions

[Detailed instructions for the agent]

## Constraints

- What the agent should NOT do
- Limitations to respect
```

## Frontmatter Fields

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| name | Yes | - | Agent identifier (lowercase, hyphens) |
| description | Yes | - | What the agent does + `<example>` tags |
| tools | No | [] | List of tools the agent can use |
| model | No | "inherit" | LLM model or "inherit" from parent |
| skills | No | [] | Skills to load for this agent |
| permission_mode | No | inherit | never_confirm, always_confirm, confirm_risky |
| max_iteration_per_run | No | None | Max iterations per run |

## Available Tools

| Tool | Use For |
|------|---------|
| file_editor | Reading/writing files |
| terminal | Running shell commands |
| browser_tool_set | Web browsing and interaction |
| DelegateTool | Delegating to other agents |

## Required `<example>` Tags

Always include at least 2 `<example>` tags in the description. These help the orchestrator know when to delegate:

```yaml
description: >
  Manages calendar events and scheduling.
  <example>Schedule a meeting for tomorrow at 3pm</example>
  <example>What's on my calendar today?</example>
  <example>Find a free slot next week</example>
```

## System Prompt Guidelines

1. **Start with role:** "You are a [specific role]..."
2. **State purpose:** Clear primary function
3. **List capabilities:** What can this agent do?
4. **Provide instructions:** Step-by-step when needed
5. **Define constraints:** What NOT to do
6. **Include examples:** Show expected behavior

## Naming Convention

- Use lowercase
- Use hyphens for spaces
- Be descriptive but concise
- Match filename to `name` field exactly

Examples:
- `email-agent.md` → name: email-agent
- `schedule-agent.md` → name: schedule-agent
- `code-reviewer.md` → name: code-reviewer

## Validation Checklist

Before saving a new agent:
- [ ] name field matches filename
- [ ] At least 2 `<example>` tags in description
- [ ] Tools list only includes tools the agent needs
- [ ] System prompt is clear and actionable
- [ ] No conflicting instructions
- [ ] Skills listed exist in ~/.openhands/skills/
