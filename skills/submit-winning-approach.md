# Submit Winning Approach Skill

Open a PR from the winning branch. The PR body documents which approach won,
why it was chosen, and links to the other two branches for reference.
Repo-agnostic — works for any GitHub repository.

## Problem

After the approach-reviewer picks the winner, the winning branch needs a PR
opened with the decision context included so the human reviewer understands
why this implementation was chosen over the alternatives.

## Prerequisites

```bash
[ -n "$GITHUB_TOKEN" ] && echo "set" || echo "GITHUB_TOKEN missing"
WINNING_BRANCH=<branch name from approach-reviewer>
ISSUE_NUMBER=<issue number>
```

## Commands

### Read the decision comment

```bash
# Fetch the reviewer's decision comment from the issue
DECISION=$(gh issue view "${ISSUE_NUMBER}" --json comments \
  --jq '[.comments[].body | select(startswith("## Approach Review"))] | last')

echo "$DECISION"
```

### Open the PR

```bash
ISSUE_TITLE=$(gh issue view "${ISSUE_NUMBER}" --json title -q '.title')

gh pr create \
  --head "${WINNING_BRANCH}" \
  --base main \
  --title "${ISSUE_TITLE}" \
  --body "Closes #${ISSUE_NUMBER}

## Why This Approach

${DECISION}

## Alternative Branches

The two other approaches remain on their branches for reference:
- \`feat/issue-${ISSUE_NUMBER}-approach-1\`
- \`feat/issue-${ISSUE_NUMBER}-approach-2\`
- \`feat/issue-${ISSUE_NUMBER}-approach-3\`

(The winning branch is excluded from the list above.)"
```

### Record the PR URL on the issue

```bash
PR_URL=$(gh pr view --json url -q '.url')

gh issue comment "${ISSUE_NUMBER}" --body "## PR Opened

**PR:** ${PR_URL}
**Branch:** \`${WINNING_BRANCH}\`

Pipeline complete. Awaiting review."
```

## Success Output

```
https://github.com/<owner>/<repo>/pull/<N>
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `already exists` error on PR create | A PR for this branch already exists — use `gh pr view` to get the URL instead |
| Branch not found | Ensure approach-implementer pushed the branch: `git ls-remote --heads origin` |
| `GITHUB_TOKEN` lacks write access | Check token scopes include `repo` |

## Never Do

- Merge the PR — human decision only
- Delete the losing approach branches — leave them for reference
- Push directly to `main`
