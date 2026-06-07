# .agents (HeyItsChloe) — PR Review Checklist

Review criteria for the agent library repository.

## Tech Stack
- **Agents:** Markdown-based agent definitions
- **Skills:** Markdown-based skill definitions
- **Automations:** OpenHands automation configurations

## Agent Files

### Structure
```
agents/           # User-level agents (generic)
.agents/agents/   # Repo-level agents (project-specific)
skills/           # User-level skills (generic)
.agents/skills/   # Repo-level skills (project-specific)
automations/      # Automation configurations
checklists/       # Project-specific review checklists
templates/        # Agent and skill templates
```

### Agent Definition
- [ ] Front matter with: name, description, tools, model, permission_mode
- [ ] Description includes examples
- [ ] All tools listed (file_editor, terminal, etc.)
- [ ] permission_mode set appropriately

### Skill Definition
- [ ] Clear purpose statement
- [ ] Step-by-step instructions
- [ ] Error handling documented
- [ ] Prerequisites listed

## Automation Files

- [ ] Trigger type defined (cron or event)
- [ ] Filter conditions specified
- [ ] Repos array includes all needed
- [ ] Timeout set appropriately
- [ ] Prompt includes all steps

## Context Parameters

User-level agents must accept these parameters:

| Parameter | Used By |
|-----------|---------|
| `{{REPO_URL}}` | ticket-planner, pr-reviewer, ticket-manager |
| `{{REPO_NAME}}` | pr-reviewer |
| `{{SOURCE_DIR}}` | ticket-planner |
| `{{TEST_DIR}}` | ticket-planner |
| `{{BUILD_CMD}}` | ticket-planner |
| `{{TEST_CMD}}` | ticket-planner |
| `{{LANGUAGE}}` | pr-reviewer |
| `{{FRAMEWORK}}` | pr-reviewer |
| `{{CHECKLIST_FILE}}` | pr-reviewer |

- [ ] All context parameters documented
- [ ] Parameters match pipeline usage

## Pipelines

### Autonomous Dev Pipeline
- [ ] Label trigger: `ready-to-implement`
- [ ] All steps documented
- [ ] Error handling for each step
- [ ] Max iterations specified

### Complex Logic Pipeline
- [ ] Label trigger: `complex-logic`
- [ ] Three approach pattern
- [ ] Scoring criteria defined
- [ ] Winner selection logic

### Cron Trigger (4AM)
- [ ] Schedule: `0 4 * * 1-5`
- [ ] Filter: `project != "admin"`
- [ ] Batch processing logic

## Naming Conventions

- [ ] User-level agents: generic names (ticket-planner, pr-reviewer)
- [ ] Repo-level agents: project-prefixed (busybuddy-implementer, orbit-tester)
- [ ] Skills: descriptive (ci-monitor, whatsapp-notifier)
- [ ] Checklists: project-prefixed (busybuddy-review.md, orbit-review.md)

## Documentation

- [ ] README updated with new agents
- [ ] AGENTS.md reflects current structure
- [ ] Examples in agent descriptions

## Safety Rules

All agents must follow:
- [ ] Never merge to main without confirmation
- [ ] Never approve PRs without confirmation
- [ ] Never delete branches without confirmation
- [ ] Never force push

## Checklist Command

```bash
# Run checklist verification
ls agents/
ls skills/
ls automations/
ls checklists/
```