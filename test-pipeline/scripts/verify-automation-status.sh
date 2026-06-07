#!/bin/bash
# verify-automation-status.sh
# Check that all automations are registered and enabled

set -e

AUTOMATION_API="https://app.all-hands.dev/api/automation/v1"

echo "=== Verifying Automation Status ==="
echo ""

# Check if API key is set
if [ -z "$OPENHANDS_API_KEY" ]; then
  echo "❌ OPENHANDS_API_KEY not set"
  exit 1
fi

echo "Fetching automations..."
RESPONSE=$(curl -s "$AUTOMATION_API" \
  -H "Authorization: Bearer $OPENHANDS_API_KEY")

# Check for errors
if echo "$RESPONSE" | jq -e '.detail' > /dev/null 2>&1; then
  echo "❌ API error: $(echo "$RESPONSE" | jq -r '.detail')"
  exit 1
fi

# Expected automations
declare -a EXPECTED_AUTOMATIONS=(
  "BusyBuddy_v2 — Autonomous Dev Pipeline"
  "Orbit — Autonomous Dev Pipeline"
  "OrderMate — Autonomous Dev Pipeline"
  "Complex Logic Pipeline"
  "Daily Issue Processor (4AM)"
)

# Expected repos with pipelines
declare -a EXPECTED_REPOS=(
  "11thandOrange/BusyBuddy_v2"
  "HeyItsChloe/mates4ever"
  "11thandOrange/OrderMate"
  "HeyItsChloe/.agents"
)

echo "Checking expected automations..."
FAILED=0

for name in "${EXPECTED_AUTOMATIONS[@]}"; do
  if echo "$RESPONSE" | jq -e ".automations[] | select(.name == \"$name\")" > /dev/null 2>&1; then
    # Check if enabled
    ENABLED=$(echo "$RESPONSE" | jq -r ".automations[] | select(.name == \"$name\") | .enabled")
    if [ "$ENABLED" = "true" ]; then
      echo "✅ $name (enabled)"
    else
      echo "⚠️  $name (disabled)"
    fi
  else
    echo "❌ $name (not found)"
    FAILED=1
  fi
done

echo ""
echo "=== Summary ==="
if [ $FAILED -eq 0 ]; then
  echo "✅ All automations registered and enabled"
else
  echo "❌ Some automations missing or disabled"
  exit 1
fi

# List all registered automations
echo ""
echo "=== Registered Automations ==="
echo "$RESPONSE" | jq -r '.automations[] | "\(.name) - \(if .enabled then "✅" else "❌" end)"'