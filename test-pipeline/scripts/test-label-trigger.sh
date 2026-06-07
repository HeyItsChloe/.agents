#!/bin/bash
# test-label-trigger.sh
# Test that labeling an issue triggers the pipeline

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <REPO> <ISSUE_NUMBER>"
  echo "Example: $0 11thandOrange/BusyBuddy_v2 42"
  exit 1
fi

REPO="$1"
ISSUE_NUMBER="$2"

echo "=== Testing Label Trigger ==="
echo "Repo: $REPO"
echo "Issue: #$ISSUE_NUMBER"
echo ""

# Check prerequisites
echo "Checking prerequisites..."
if ! command -v gh &> /dev/null; then
  echo "❌ gh CLI not installed"
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "❌ Not authenticated with GitHub"
  exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Check current labels on issue
echo "Current labels on issue #$ISSUE_NUMBER:"
gh issue view "$ISSUE_NUMBER" --repo "$REPO" --json labels --jq '.labels[].name'
echo ""

# Add ready-to-implement label
echo "Adding 'ready-to-implement' label..."
gh issue edit "$ISSUE_NUMBER" --repo "$REPO" --add-label "ready-to-implement"
echo "✅ Label added"
echo ""

# Wait a moment for automation to potentially start
echo "Waiting 10 seconds for automation to trigger..."
sleep 10

# Check recent workflow runs
echo "Checking recent workflow runs..."
gh run list --repo "$REPO" --limit 5 --json name,status,conclusion,createdAt --jq '.[] | "\(.name) - \(.status) - \(.conclusion // "pending") - \(.createdAt)"'
echo ""

# Check for new PR (pipeline should create one)
echo "Checking for new PRs..."
PR=$(gh pr list --repo "$REPO" --state open --json number,title,headRefName --jq '.[] | "PR #\(.number): \(.title) (branch: \(.headRefName))"' | head -3)
if [ -n "$PR" ]; then
  echo "✅ PRs found:"
  echo "$PR"
else
  echo "⏳ No PRs yet (pipeline may still be running)"
fi

echo ""
echo "=== Test Complete ==="
echo "Check OpenHands dashboard for automation run status"
echo "URL: https://app.all-hands.dev/automations"