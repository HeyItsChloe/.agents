# Mark PR Ready Skill

Remove draft status from a pull request, making it ready for review.
This triggers any smoke CI jobs gated on `ready_for_review` events.
Repo-agnostic — detects the current repository at runtime.

## Prerequisites

```bash
[ -n "$GITHUB_TOKEN" ] && echo "set" || echo "GITHUB_TOKEN missing"
```

## Commands

```bash
# Detect current repo (works from any cloned repository)
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
echo "Marking PR ready in: $REPO"

# Remove draft status
gh pr ready "${PR_NUMBER}" --repo "${REPO}"
```

## Verify

```bash
gh pr view "${PR_NUMBER}" --repo "${REPO}" --json isDraft -q '.isDraft'
# Must return: false
```

## Full Usage in a Pipeline

```bash
PR_NUMBER=<PR_NUMBER>
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')

gh pr ready "${PR_NUMBER}" --repo "${REPO}"

# Confirm
IS_DRAFT=$(gh pr view "${PR_NUMBER}" --repo "${REPO}" --json isDraft -q '.isDraft')
if [ "$IS_DRAFT" = "false" ]; then
  echo "✅ PR #${PR_NUMBER} is now ready for review"
else
  echo "❌ PR #${PR_NUMBER} is still a draft — check permissions"
  exit 1
fi
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `GraphQL: Must have push access to change draft status` | Token lacks `repo` write scope |
| `Could not resolve to a PullRequest` | Wrong PR number or branch mismatch |
| `REPO` is empty | Run from inside a cloned git repo, or set `REPO=owner/repo` manually |

## Never Do

- Mark a PR ready without CI passing (use ci-monitor first)
- Merge — human decision only
