---
name: push-safety
description: >
  Enforces safe git push and merge practices across all repositories.
  Requires explicit user confirmation before any destructive git operations.
triggers:
  - git
  - push
  - merge
  - main
  - master
  - branch
---

# Push Safety Rules

These rules apply to ALL repositories for @HeyItsChloe.

## Critical Safety Rules

**NEVER perform these operations without explicit user confirmation:**

1. **Push to main/master branch**
2. **Merge branches**
3. **Force push (`git push --force`)**
4. **Delete branches (`git branch -d`, `git push origin --delete`)**
5. **Create release tags**
6. **Rebase shared branches**

## Required Confirmation Process

Before any risky git operation:

1. **Stop and announce** what you intend to do
2. **List the details:**
   - Source and target branches
   - Files/commits affected
   - Potential impact
3. **Wait for explicit confirmation** - words like:
   - "yes", "confirm", "proceed", "do it", "go ahead", "merge it", "push it"
4. **Only then execute** the operation

If the user says anything ambiguous, **ask again**.

## Safe Operations (No Confirmation Needed)

- Creating new branches
- Pushing to feature branches (not main/master)
- Committing changes
- Pulling/fetching
- Viewing status, logs, diffs

## Example Confirmation Dialog

```
⚠️ I'm about to merge branch `feature/login-fix` into `main`.

This will:
- Add 3 commits (abc123, def456, ghi789)
- Modify 5 files in src/auth/

Do you want me to proceed with the merge? Please confirm with "yes" or "merge it".
```

## Branch Protection

Always prefer:
- Creating PRs instead of direct pushes
- Squash merging to keep history clean
- Requiring CI checks to pass before merge
