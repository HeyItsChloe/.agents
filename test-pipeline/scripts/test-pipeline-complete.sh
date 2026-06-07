#!/bin/bash
# test-pipeline-complete.sh
# Test the full pipeline from issue to PR

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <REPO> <ISSUE_NUMBER>"
  echo "Example: $0 11thandOrange/BusyBuddy_v2 42"
  exit 1
fi

REPO="$1"
ISSUE_NUMBER="$2"

echo "=== Testing Complete Pipeline ==="
echo "Repo: $REPO"
echo "Issue: #$ISSUE_NUMBER"
echo ""

# Check prerequisites
echo "Checking prerequisites..."
if ! command -v gh &> /dev/null; then
  echo "❌ gh CLI not installed"
  exit 1
fi

# Get issue details
echo "Fetching issue details..."
ISSUE_JSON=$(gh issue view "$ISSUE_NUMBER" --repo "$REPO" --json number,title,body,labels,state --jq '{number,title,body,labels:[.labels[].name],state}')
ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
ISSUE_STATE=$(echo "$ISSUE_JSON" | jq -r '.state')

echo "Issue: #$ISSUE_NUMBER - $ISSUE_TITLE"
echo "State: $ISSUE_STATE"
echo ""

# Check if already processed
EXISTING_PR=$(gh pr list --repo "$REPO" --state all --json number,title,body --jq ".[] | select(.body | contains(\"#${ISSUE_NUMBER}\")) | \"PR #\(.number): \(.title)\"" | head -1)

if [ -n "$EXISTING_PR" ]; then
  echo "⚠️  Issue already has a PR:"
  echo "   $EXISTING_PR"
  echo ""
  echo "Skipping pipeline test (already complete)"
  exit 0
fi

# Add label to trigger pipeline
echo "Adding 'ready-to-implement' label to trigger pipeline..."
gh issue edit "$ISSUE_NUMBER" --repo "$REPO" --add-label "ready-to-implement"
echo "✅ Label added"
echo ""

# Monitor pipeline progress
echo "=== Monitoring Pipeline ==="
echo "Waiting for pipeline to start (30 seconds)..."
sleep 30

# Check for automation run in OpenHands
echo "Checking OpenHands for automation runs..."
echo "URL: https://app.all-hands.dev/automations"
echo ""

# Check for new branch
echo "Checking for new branch..."
BRANCH=$(git branch -a --list "*/feat/issue-${ISSUE_NUMBER}-*" 2>/dev/null | head -1 | tr -d ' ')
if [ -n "$BRANCH" ]; then
  echo "✅ Branch created: $BRANCH"
else
  echo "⏳ No branch yet (may take time)"
fi

# Check for PR
echo ""
echo "Checking for PR..."
PR_JSON=$(gh pr list --repo "$REPO" --state open --json number,title,body,createdAt --jq '.[] | select(.body | contains("'"#"${ISSUE_NUMBER}"'")) | {number,title,createdAt}')

if [ -n "$PR_JSON" ]; then
  PR_NUMBER=$(echo "$PR_JSON" | jq -r '.number')
  PR_TITLE=$(echo "$PR_JSON" | jq -r '.title')
  echo "✅ PR created: #$PR_NUMBER - $PR_TITLE"
  echo "   URL: https://github.com/$REPO/pull/$PR_NUMBER"
else
  echo "⏳ PR not yet created (pipeline still running)"
fi

echo ""
echo "=== Pipeline Test Initiated ==="
echo "Monitor progress at: https://app.all-hands.dev/automations"
echo ""
echo "Expected timeline:"
echo "  - Immediate: Pipeline starts"
echo "  - 5-15 min: Branch created, code committed"
echo "  - 15-30 min: PR created"
echo "  - 30-45 min: CI checks, review posted"
echo "  - 45-60 min: Ready for manual review"