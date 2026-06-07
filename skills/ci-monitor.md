# CI Monitor Skill

Poll GitHub Actions checks on a PR until all pass or a failure is detected.
Works for any repository. Surfaces failure logs so the implementer can fix and retry.

## Prerequisites

```bash
[ -n "$GITHUB_TOKEN" ] && echo "set" || echo "GITHUB_TOKEN missing"
gh auth status
```

## Core Monitor Loop

```bash
#!/bin/bash
# Usage: bash ci-monitor.sh <PR_NUMBER> [MAX_WAIT_MINUTES]

PR_NUMBER="${1}"
MAX_WAIT_MINUTES="${2:-20}"
POLL_INTERVAL=30
MAX_POLLS=$(( MAX_WAIT_MINUTES * 60 / POLL_INTERVAL ))
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')

echo "Monitoring CI for PR #${PR_NUMBER} on ${REPO}"

for i in $(seq 1 $MAX_POLLS); do
  STATUS=$(gh pr checks "${PR_NUMBER}" --json name,state,conclusion 2>/dev/null)

  if [ -z "$STATUS" ]; then
    echo "[${i}/${MAX_POLLS}] No checks yet — waiting..."
    sleep $POLL_INTERVAL
    continue
  fi

  PENDING=$(echo "$STATUS" | jq '[.[] | select(.state == "pending" or .state == "queued" or .conclusion == null)] | length')
  FAILED=$(echo "$STATUS"  | jq '[.[] | select(.conclusion == "failure" or .conclusion == "cancelled" or .conclusion == "timed_out")] | length')
  PASSED=$(echo "$STATUS"  | jq '[.[] | select(.conclusion == "success" or .conclusion == "skipped")] | length')
  TOTAL=$(echo "$STATUS"   | jq 'length')

  echo "[${i}/${MAX_POLLS}] Total: ${TOTAL} | Passed: ${PASSED} | Pending: ${PENDING} | Failed: ${FAILED}"

  if [ "$FAILED" -gt 0 ]; then
    echo "❌ CI FAILED"
    echo "$STATUS" | jq '[.[] | select(.conclusion == "failure" or .conclusion == "cancelled") | {name,conclusion}]'
    exit 1
  fi

  if [ "$PENDING" -eq 0 ] && [ "$TOTAL" -gt 0 ]; then
    echo "✅ All CI checks passed"
    exit 0
  fi

  sleep $POLL_INTERVAL
done

echo "⏰ Timeout: CI did not complete within ${MAX_WAIT_MINUTES} minutes"
exit 2
```

## Fetch Failure Logs (on exit code 1)

```bash
FAILED_RUN=$(gh run list \
  --branch "$(git branch --show-current)" \
  --json databaseId,conclusion \
  --jq '[.[] | select(.conclusion == "failure")] | first | .databaseId')

gh run view "$FAILED_RUN" --log-failed 2>&1 | tail -100
```

## Pipeline Usage

```bash
PR_NUMBER=$(gh pr view --json number -q '.number')

# Run monitor (20 min timeout)
bash ci-monitor.sh "${PR_NUMBER}" 20
CI_EXIT=$?

if   [ $CI_EXIT -eq 0 ]; then echo "Green — proceed to whatsapp-notifier"
elif [ $CI_EXIT -eq 1 ]; then echo "Failed — feed logs to implementer and fix"
elif [ $CI_EXIT -eq 2 ]; then echo "Timed out — notify human"
fi
```

## Retry Cap (use in pipeline)

```bash
MAX_RETRIES=3; ATTEMPT=0
while [ $ATTEMPT -lt $MAX_RETRIES ]; do
  ATTEMPT=$((ATTEMPT+1))
  bash ci-monitor.sh "${PR_NUMBER}" 20 && break
  [ $ATTEMPT -eq $MAX_RETRIES ] && echo "Retries exhausted" && exit 1
  # feed logs to implementer → fix → push
done
```

## Check Conclusions

| Conclusion | Action |
|------------|--------|
| `success` / `skipped` | Continue |
| `failure` | Fetch logs → fix → re-push |
| `cancelled` | Re-trigger or alert human |
| `timed_out` | Check for hanging tests |
| `null` | Still running — keep polling |
