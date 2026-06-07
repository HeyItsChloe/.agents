# Weekly Report

This skill defines the format and content for the weekly progress summary.

## Schedule

- **When:** Every Saturday at 6:00 AM Pacific (America/Los_Angeles)
- **Delivery:** Email to user

## Report Sections

### 1. Header
```
📊 WEEKLY PROGRESS SUMMARY
Week of [Start Date] - [End Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 2. GitHub Projects Progress
Show all active GitHub Projects with:
- Project name
- Visual progress bar
- Items by status (Done / In Progress / Todo)

### 3. GitHub Milestones
Show active milestones with:
- Milestone name and due date
- Issue counts (open/closed)

### 4. Manual Goals
From ~/.openhands/goals.yaml:
- Goal title
- Progress percentage
- Visual progress bar

### 5. Issues/Tickets Summary
- Closed this week
- Opened this week
- Still open (assigned to user)

### 6. Pull Requests Summary
- Merged this week
- Currently open
- Reviews completed

### 7. Merge Conflicts (⚠️ Action Required)
List all open PRs with merge conflicts:
- Branch name
- Target branch
- Conflicting files

### 8. Attention Needed
Flag items requiring action:
- Stale PRs (no activity > 3 days)
- Unassigned issues in user's repos
- Goals with no progress > 2 weeks
- Overdue milestones

### 9. Suggested Priorities
AI-generated list of top 3-5 priorities based on:
- Urgency (conflicts, overdue items)
- Impact (blocked PRs, release milestones)
- Momentum (goals close to completion)

## Report Template

```
📊 WEEKLY PROGRESS SUMMARY
Week of {start_date} - {end_date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 GITHUB PROJECTS
┌──────────────────────────────────────────────┐
│ {project_name}    {progress_bar}  {pct}%     │
│   ✓ {done} done │ → {in_prog} in progress │ ○ {todo} todo │
└──────────────────────────────────────────────┘

🏁 GITHUB MILESTONES
┌──────────────────────────────────────────────┐
│ {milestone} (due {date})   {closed}/{total}  │
└──────────────────────────────────────────────┘

📌 MANUAL GOALS
┌──────────────────────────────────────────────┐
│ {goal_title}           {progress_bar}  {pct}%│
└──────────────────────────────────────────────┘

📝 ISSUES THIS WEEK
│ Closed: {n}  │  Opened: {n}  │  Open: {n}   │

🔀 PULL REQUESTS THIS WEEK
│ Merged: {n}  │  Open: {n}    │  Reviewed: {n}│

⚠️ MERGE CONFLICTS ({count} branches)
│ {branch} ← conflicts with {target} ({n} files)│

🚨 ATTENTION NEEDED
• {item requiring attention}

📋 SUGGESTED PRIORITIES
1. {priority_1}
2. {priority_2}
3. {priority_3}
```

## Data Sources

1. **GitHub API** (via GITHUB_TOKEN):
   - Projects: GraphQL API
   - Milestones: REST API per repo
   - PRs: Search API
   - Issues: Search API

2. **Local file**:
   - Manual goals: ~/.openhands/goals.yaml
