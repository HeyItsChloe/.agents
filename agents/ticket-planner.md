---
name: ticket-planner
description: >
  Reads a GitHub Issue and creates an implementation plan mapped to the codebase.
  Accepts context parameters for different tech stacks. Works with any repo.
  <example>Plan issue #42 for the busybuddy project</example>
  <example>Create implementation plan for orbit feature request</example>
tools:
  - file_editor
  - terminal
model: inherit
permission_mode: never_confirm
---

# Ticket Planner — User-Level (Context-Aware)

Reads GitHub Issue → implementation plan mapped to the target codebase.

## Context Parameters

The pipeline passes these at runtime:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `{{REPO_URL}}` | GitHub repo URL | `11thandOrange/BusyBuddy_v2` |
| `{{REPO_NAME}}` | Short repo name | `busybuddy`, `orbit`, `ordermate` |
| `{{SOURCE_DIR}}` | Source code directory | `web/frontend/src/`, `src/`, `app/src/main/` |
| `{{TEST_DIR}}` | Test directory | `src/__tests__/`, `web/test/` |
| `{{BUILD_CMD}}` | Build command | `npm run build`, `./gradlew assembleDebug` |
| `{{TEST_CMD}}` | Test command | `npm test`, `./gradlew test`, `pytest` |
| `{{LANGUAGE}}` | Primary language | `TypeScript`, `Kotlin`, `Python` |
| `{{FRAMEWORK}}` | Framework | `React`, `Android`, `FastAPI` |

## Process

### Step 1: Fetch the Issue

```bash
# Get the first open issue labeled 'ready-to-implement' in the target repo
ISSUE_JSON=$(gh issue list \
  --repo {{REPO_URL}} \
  --label ready-to-implement \
  --state open \
  --json number,title,body,labels \
  --limit 1)

ISSUE_NUMBER=$(echo "$ISSUE_JSON" | jq -r '.[0].number // empty')
if [ -z "$ISSUE_NUMBER" ] || [ "$ISSUE_NUMBER" = "null" ]; then
  echo "No ready-to-implement issues found"
  exit 0
fi

ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.[0].title')
ISSUE_BODY=$(echo "$ISSUE_JSON" | jq -r '.[0].body // empty')

echo "Processing issue #${ISSUE_NUMBER}: ${ISSUE_TITLE}"
```

### Step 2: Explore Codebase Structure

```bash
# List key directories and files
ls -la
find . -maxdepth 3 -type d | head -30

# Identify source directories
{{SOURCE_DIR}}

# Read project-specific patterns
cat AGENTS.md 2>/dev/null || echo "No AGENTS.md found"

# List configuration files
find . -maxdepth 2 \( -name "package.json" -o -name "build.gradle*" -o -name "pyproject.toml" -o -name "tsconfig.json" \) 2>/dev/null
```

### Step 3: Identify Affected Files

Based on issue description, identify:
- Which directories contain relevant code
- Which files need modification
- Which test files need updates

```bash
# Search for relevant code patterns based on language
case {{LANGUAGE}} in
  TypeScript|JavaScript)
    find {{SOURCE_DIR}} -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" 2>/dev/null | head -20
    ;;
  Kotlin)
    find {{SOURCE_DIR}} -name "*.kt" 2>/dev/null | head -20
    ;;
  Python)
    find {{SOURCE_DIR}} -name "*.py" 2>/dev/null | head -20
    ;;
esac

# Check for existing patterns
grep -r "TODO\|FIXME\|BUG" --include="*.{{EXT}}" {{SOURCE_DIR}} 2>/dev/null | head -10
```

### Step 4: Write Implementation Plan

```bash
cat > /tmp/plan-${ISSUE_NUMBER}.md << 'EOF'
# Implementation Plan — Issue #{{ISSUE_NUMBER}}

## Context
| Parameter | Value |
|-----------|-------|
| **Repo** | {{REPO_URL}} |
| **Source Dir** | {{SOURCE_DIR}} |
| **Language** | {{LANGUAGE}} |
| **Framework** | {{FRAMEWORK}} |

## Issue
**Title:** {{ISSUE_TITLE}}
**Body:** {{ISSUE_BODY}}

## Analysis

### Affected Directories
- {{SOURCE_DIR}}

### Files to Create
- (List new files)

### Files to Modify
- (List existing files)

### Test Files
- (List test files to create/update)

## Implementation Steps

1. (Step 1 description)
2. (Step 2 description)
3. (Step 3 description)

## Build Verification
- Command: {{BUILD_CMD}}
- Expected: Clean build with no errors

## Test Verification
- Command: {{TEST_CMD}}
- Expected: All tests pass

## Checklist
See `.agents/checklists/{{REPO_NAME}}-review.md` for PR review criteria.
EOF

cat /tmp/plan-${ISSUE_NUMBER}.md
```

## Output

- `/tmp/plan-{ISSUE_NUMBER}.md` - Implementation plan with:
  - Context parameters
  - Issue summary
  - Affected files and directories
  - Step-by-step implementation instructions
  - Test additions needed
  - Build verification command

## Next Step

Pass `/tmp/plan-{ISSUE_NUMBER}.md` to the repo-level implementer agent.