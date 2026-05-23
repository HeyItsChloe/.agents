# Goals Management

This skill defines how to manage the manual goals file at ~/.openhands/goals.yaml.

## File Location

```
~/.openhands/goals.yaml
```

## File Format

```yaml
goals:
  - id: goal-001
    title: "Goal title here"
    description: "Optional longer description"
    target_date: "2024-06-01"  # Optional, YYYY-MM-DD format
    progress: 60               # 0-100 percentage
    status: active             # active | completed | paused | cancelled
    linked_items:              # Optional GitHub links
      - "github:HeyItsChloe/repo#123"
      - "github:HeyItsChloe/repo#124"
    notes: "Any additional notes"
    created_at: "2024-05-01"
    updated_at: "2024-05-20"
```

## Field Definitions

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| id | Yes | string | Unique identifier (goal-001, goal-002, etc.) |
| title | Yes | string | Short goal title |
| description | No | string | Longer description if needed |
| target_date | No | date | Target completion date (YYYY-MM-DD) |
| progress | Yes | int | 0-100 percentage complete |
| status | Yes | enum | active, completed, paused, cancelled |
| linked_items | No | list | GitHub issues/PRs linked to this goal |
| notes | No | string | Freeform notes |
| created_at | Yes | date | When goal was created |
| updated_at | Yes | date | Last modification date |

## Linked Items Format

Link to GitHub issues or PRs:
```
github:{owner}/{repo}#{number}
```

Examples:
- `github:HeyItsChloe/agent_iOS#42`
- `github:HeyItsChloe/OpenHands#15`

## Operations

### Add a new goal
1. Generate next ID (goal-XXX)
2. Set created_at and updated_at to current date
3. Default status to "active"
4. Default progress to 0

### Update progress
1. Update progress field (0-100)
2. Update updated_at timestamp
3. If progress = 100, suggest changing status to "completed"

### Complete a goal
1. Set status to "completed"
2. Set progress to 100
3. Update updated_at

### Link GitHub items
1. Add to linked_items list
2. Format: github:owner/repo#number

## Progress Calculation

If a goal has linked GitHub items, calculate progress:
```
progress = (closed_linked_items / total_linked_items) * 100
```

For manual goals without links, user sets progress manually.

## Example Goals File

```yaml
goals:
  - id: goal-001
    title: "Build Personal Assistant Agent System"
    description: "Create a multi-agent system for personal task management"
    target_date: "2024-06-15"
    progress: 40
    status: active
    linked_items:
      - "github:HeyItsChloe/agents_test#1"
    notes: "Phase 1 complete, working on Phase 2"
    created_at: "2024-05-20"
    updated_at: "2024-05-23"

  - id: goal-002
    title: "Learn Swift for iOS development"
    progress: 15
    status: active
    linked_items: []
    notes: "Completed intro tutorials"
    created_at: "2024-05-01"
    updated_at: "2024-05-15"
```
