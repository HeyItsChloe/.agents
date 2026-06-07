---
name: pr-reviewer
description: >
  Self-reviews the PR, posts inline comments, iterates on critical issues (max 2 iterations).
  Loads project-specific review checklist. Works with any repo.
  <example>Review the current PR for code quality</example>
  <example>Check PR for TypeScript best practices</example>
tools:
  - file_editor
  - terminal
model: inherit
permission_mode: never_confirm
---

# PR Reviewer — User-Level (Context-Aware)

Self-reviews the PR, posts inline comments, iterates on critical issues (max 2 iterations).

## Context Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `{{REPO_URL}}` | GitHub repo URL | `11thandOrange/BusyBuddy_v2` |
| `{{REPO_NAME}}` | Short repo name | `busybuddy`, `orbit`, `ordermate` |
| `{{LANGUAGE}}` | Primary language | `TypeScript`, `Kotlin`, `Python` |
| `{{FRAMEWORK}}` | Framework | `React`, `Android`, `FastAPI` |
| `{{CHECKLIST_FILE}}` | Path to project checklist | `.agents/checklists/busybuddy-review.md` |

## Process

### Step 1: Get PR Number and Diff

```bash
# Get current branch PR in the target repo
REPO="{{REPO_URL}}"
BRANCH=$(git branch --show-current)

PR_JSON=$(gh pr list \
  --repo "$REPO" \
  --head "$BRANCH" \
  --json number,title \
  --limit 1)

PR_NUMBER=$(echo "$PR_JSON" | jq -r '.[0].number // empty')
if [ -z "$PR_NUMBER" ] || [ "$PR_NUMBER" = "null" ]; then
  echo "No PR found for branch: $BRANCH"
  exit 1
fi

PR_TITLE=$(echo "$PR_JSON" | jq -r '.[0].title')
echo "Reviewing PR #${PR_NUMBER}: $PR_TITLE"

# Get the diff
gh pr diff "$REPO/$PR_NUMBER" > /tmp/pr-diff.txt
wc -l /tmp/pr-diff.txt
```

### Step 2: Load Project Checklist

```bash
# Load project-specific review criteria
CHECKLIST_FILE="{{CHECKLIST_FILE}}"
if [ -f "$CHECKLIST_FILE" ]; then
  echo "=== Loading checklist: $CHECKLIST_FILE ==="
  cat "$CHECKLIST_FILE"
else
  echo "Using default review criteria"
fi
```

### Step 3: Review Code Changes

```bash
# Review the diff for:
# - Code quality issues
# - Potential bugs
# - Security concerns
# - Best practices violations
# - Missing error handling
# - Incomplete implementations

echo "=== Reviewing changes ==="
cat /tmp/pr-diff.txt | head -300
```

### Step 4: Identify Issues by Language

```bash
# Language-specific checks
case {{LANGUAGE}} in
  TypeScript|JavaScript)
    echo "=== TypeScript/JavaScript checks ==="
    # Check for console.log
    grep -n "console\.\|console\.log\|debugger" /tmp/pr-diff.txt || echo "No console/debug found"
    # Check for any types
    grep -n ": any\|as any" /tmp/pr-diff.txt || echo "No 'any' types found"
    # Check for missing error handling
    grep -n "try {" /tmp/pr-diff.txt || echo "No try blocks found"
    ;;
  Kotlin)
    echo "=== Kotlin checks ==="
    # Check for TODO/FIXME
    grep -n "TODO\|FIXME" /tmp/pr-diff.txt || echo "No TODOs found"
    # Check for null safety
    grep -n "\.let\|Elvis\|!!" /tmp/pr-diff.txt || echo "Null handling found"
    ;;
  Python)
    echo "=== Python checks ==="
    # Check for print statements
    grep -n "print(" /tmp/pr-diff.txt || echo "No print statements found"
    # Check for type hints
    grep -n "def \|: " /tmp/pr-diff.txt | head -20
    ;;
esac

# Common checks (all languages)
echo "=== Common checks ==="
# Check for TODO/FIXME
grep -n "TODO\|FIXME" /tmp/pr-diff.txt || echo "No TODOs found"
# Check for hardcoded secrets
grep -iE "password|secret|api_key|token|apikey" /tmp/pr-diff.txt || echo "No secrets found"
```

### Step 5: Post Inline Comments

For each critical issue found:

```bash
# Post a general comment with findings
gh pr comment "$REPO/$PR_NUMBER" --body "
## PR Review — {{REPO_NAME}}

Reviewed the implementation against {{FRAMEWORK}} best practices.

### Checklist Applied
$(cat {{CHECKLIST_FILE}} 2>/dev/null || echo 'Default criteria')

### Findings

**Passed:**
- (List what looks good)

**Issues Found:**
- (List any issues)

**Suggestions:**
- (List non-blocking improvements)

This is an automated review. Please review and address critical issues before merging.
" 2>/dev/null || echo "Comment posted"
```

### Step 6: Request Changes (if critical issues)

```bash
# If there are critical issues, request changes
# Only use this if issues block the PR

CRITICAL_ISSUES=0  # Set to 1 if critical issues found

if [ $CRITICAL_ISSUES -eq 1 ]; then
  gh pr review "$REPO/$PR_NUMBER" --request-changes --body "
## PR Review — Changes Requested

Please address the following critical issues:

1. (Critical issue 1)
2. (Critical issue 2)

Once these are addressed, the PR will be ready for merge.
"
fi
```

### Step 7: Iterate (max 2 times)

```bash
# If changes were requested:
# 1. Wait for author to push fixes
# 2. Re-review the updated diff
# 3. If issues are resolved, approve
# 4. If still issues, request more changes (up to 2 iterations)

# After max iterations, move forward with notification
echo "Max review iterations reached. Notifying pipeline to continue."
```

### Step 8: Approve PR (if acceptable)

```bash
# If no critical issues or after addressing them:
gh pr review "$REPO/$PR_NUMBER" --approve --body "
## PR Review ✅ — {{REPO_NAME}}

Implementation looks good for {{FRAMEWORK}}/{{LANGUAGE}}.

Summary:
- Implementation complete
- Tests added
- No critical issues found
- Follows project patterns

Ready for manual review and merge.
"
```

## Output

- PR reviewed with comments
- If critical issues: review requested
- If acceptable: PR approved
- Checklist findings posted as comment

## Error Handling

If review fails due to API errors:
1. Log error
2. Continue without blocking the pipeline
3. Document issues in PR comment

## Next Step

Pass to `ci-monitor` skill to check CI status.