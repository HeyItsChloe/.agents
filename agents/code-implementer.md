# Code Implementer — pipeline-generator

Creates branch, writes code following project patterns.

## Tech Stack Detected

- **Language:** markdown
- **Framework:** none
- **Package Manager:** none

## Commands

- **Install:** none
- **Test:** none
- **Build:** none

## Paths

- **Source:** ./
- **Tests:** ./
- **Config:** .github

## Process

### Step 1: Read Implementation Plan

```bash
ISSUE_NUMBER=$(gh issue list \
  --repo HeyItsChloe/pipeline-generator \
  --label ready-to-implement \
  --state open \
  --json number \
  --limit 1 | jq -r '.[0].number')

cat /tmp/plan-$ISSUE_NUMBER.md
```

### Step 2: Create Branch

```bash
git checkout -b "impl/$ISSUE_NUMBER-$(date +%Y%m%d-%H%M%S)"
```

### Step 3: Install Dependencies

```bash
none
```

### Step 4: Implement Changes

Based on the implementation plan:
1. Read affected files
2. Make necessary code changes
3. Follow existing code patterns in the repository

```bash
# Explore the codebase structure first
ls -la ./
find ./ -name "*.py" -o -name "*.js" -o -name "*.ts" 2>/dev/null | head -20

# Check existing patterns
grep -r "class \|function \|def " ./ 2>/dev/null | head -20
```

### Step 5: Run Tests

```bash
none
```

### Step 6: Fix Any Test Failures

```bash
# If tests fail, analyze and fix
# Re-run tests after fixes
none
```

### Step 7: Commit Changes

```bash
git add -A
git commit -m "feat: implement issue #$ISSUE_NUMBER

$(cat /tmp/plan-$ISSUE_NUMBER.md | head -20)
"
```

## Output

- New branch created with implementation
- Tests passing
- Changes committed

## Error Handling

If implementation fails:
1. Log error to `/tmp/implement-error.log`
2. Document what was attempted
3. Continue to notification step with failure message

## Next Step

Pass to `tester` agent to add missing tests.