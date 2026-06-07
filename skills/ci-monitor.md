# CI Monitor — pipeline-generator

Polls PR checks, surfaces failure logs, retries on failure (max 3 retries).

## CI System Detected

- **Type:** GitHub Actions
- **Config:** `.github/workflows/`

## Process

### Step 1: Get PR Number

```bash
PR_NUMBER=$(cat /tmp/pr-number.txt 2>/dev/null || echo "")
echo "Monitoring CI for PR #$PR_NUMBER"
```

### Step 2: Poll CI Status

```bash
gh pr checks $PR_NUMBER --repo HeyItsChloe/pipeline-generator --watch --interval 30
```

### Step 3: Wait for CI Completion

```bash
MAX_WAIT=600
START_TIME=$(date +%s)
RETRIES=0

while [ $RETRIES -lt 3 ]; do
  STATUS=$(gh pr view $PR_NUMBER --repo HeyItsChloe/pipeline-generator --json statusCheckRollup --jq '.[0].statusCheckRollup[] | select(.state != "SUCCESS") | .state' 2>/dev/null | head -1)
  
  if [ -z "$STATUS" ]; then
    echo "All checks passed!"
    break
  fi
  
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - START_TIME))
  
  if [ $ELAPSED -gt $MAX_WAIT ]; then
    echo "Timeout reached after ${ELAPSED}s"
    break
  fi
  
  echo "Waiting for checks... (${ELAPSED}s elapsed)"
  sleep 30
done
```

### Step 4: Handle Failures

```bash
FAILURES=$(gh pr view $PR_NUMBER --repo HeyItsChloe/pipeline-generator --json statusCheckRollup --jq '.[0].statusCheckRollup[] | select(.state == "FAILURE") | .name' 2>/dev/null)

if [ -n "$FAILURES" ]; then
  echo "Failed checks: $FAILURES"
  FAILED_RUN_ID=$(gh run list --repo HeyItsChloe/pipeline-generator --limit 5 --json id,conclusion --jq '.[] | select(.conclusion == "failure") | .id' | head -1)
  
  if [ -n "$FAILED_RUN_ID" ]; then
    echo "Re-running failed job: $FAILED_RUN_ID"
    gh run rerun $FAILED_RUN_ID --repo HeyItsChloe/pipeline-generator
    RETRIES=$((RETRIES + 1))
  fi
fi
```

### Step 5: Report Final Status

```bash
FINAL_STATUS=$(gh pr view $PR_NUMBER --repo HeyItsChloe/pipeline-generator --json mergeable --jq '.mergeable')

if [ "$FINAL_STATUS" == "true" ]; then
  echo "✅ CI passed - PR is mergeable"
else
  echo "❌ CI failed - manual intervention required"
fi
```

## Error Handling

If polling fails:
1. Log error to `/tmp/ci-monitor-error.log`
2. Continue to notification step with "unknown" status

## Next Step

After CI monitoring, pass to notification skill.
