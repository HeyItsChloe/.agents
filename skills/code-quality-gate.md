# Code Quality Gate Skill

Run linter and formatter checks before opening a PR. Ensures code quality
standards are met across all projects.

## Supported Tools

| Type | Tool | Command |
|------|------|---------|
| JavaScript/TypeScript | ESLint | `npx eslint .` |
| Prettier (format check) | Prettier | `npx prettier --check .` |
| Python | Ruff | `ruff check .` |
| Python | Black (format check) | `black --check .` |
| Kotlin | ktlint | `./gradlew ktlintCheck` |
| Go | golangci-lint | `golangci-lint run` |

## Process

### Step 1: Detect Linter/Formatter

```bash
# Check for linting tools
if [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ] || [ -f "eslint.config.js" ]; then
  LINTER="eslint"
  LINT_CMD="npx eslint ."
elif [ -f "ruff.toml" ]; then
  LINTER="ruff"
  LINT_CMD="ruff check ."
elif [ -f "pyproject.toml" ] && grep -q "black" pyproject.toml; then
  LINTER="black"
  LINT_CMD="black --check ."
elif [ -f "ktlint.gradle.kts" ] || grep -q "ktlint" build.gradle.kts 2>/dev/null; then
  LINTER="ktlint"
  LINT_CMD="./gradlew ktlintCheck"
fi

# Check for formatters
if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
  FORMATTER="prettier"
  FORMAT_CMD="npx prettier --check ."
elif [ -f "pyproject.toml" ] && grep -q "black" pyproject.toml; then
  FORMATTER="black"
  FORMAT_CMD="black --check ."
fi

echo "Linter: ${LINTER:-none}"
echo "Formatter: ${FORMATTER:-none}"
```

### Step 2: Run Linter

```bash
if [ -n "$LINTER" ]; then
  echo "Running linter: $LINT_CMD"
  $LINT_CMD
  LINT_RESULT=$?
  
  if [ $LINT_RESULT -ne 0 ]; then
    echo "Linter errors found"
    exit 1
  fi
  
  echo "Linter passed"
else
  echo "No linter configured"
fi
```

### Step 3: Run Formatter Check

```bash
if [ -n "$FORMATTER" ]; then
  echo "Running formatter check: $FORMAT_CMD"
  $FORMAT_CMD
  FORMAT_RESULT=$?
  
  if [ $FORMAT_RESULT -ne 0 ]; then
    echo "Formatter issues found"
    echo "Run formatter to fix: $FIX_CMD"
    exit 1
  fi
  
  echo "Formatter check passed"
else
  echo "No formatter configured"
fi
```

### Step 4: Auto-Fix (if supported)

```bash
# If linter/formatter has auto-fix capability
if [ "$LINTER" = "eslint" ]; then
  echo "Running ESLint auto-fix..."
  npx eslint . --fix
elif [ "$LINTER" = "ruff" ]; then
  echo "Running Ruff auto-fix..."
  ruff check . --fix
elif [ "$FORMATTER" = "prettier" ]; then
  echo "Running Prettier auto-fix..."
  npx prettier --write .
elif [ "$FORMATTER" = "black" ]; then
  echo "Running Black auto-fix..."
  black .
fi
```

### Step 5: Commit Auto-Fixes (if any)

```bash
# Check if any files were auto-fixed
if git diff --quiet; then
  echo "No auto-fixes needed"
else
  echo "Auto-fixes applied, committing..."
  git add -A
  git commit -m "style: auto-fix linter/formatter issues

Automated code quality fixes"
  git push
fi
```

## Verification Checklist

- [ ] Linter passed (or auto-fixed)
- [ ] Formatter check passed (or auto-fixed)
- [ ] Auto-fixes committed (if any)

## Common Issues

| Issue | Solution |
|-------|----------|
| ESLint not installed | `npm install --save-dev eslint` |
| Prettier not installed | `npm install --save-dev prettier` |
| Ruff not installed | `pip install ruff` |
| ktlint not configured | Add to `build.gradle.kts` |

## Output

- All linting errors fixed
- All formatting issues resolved
- Auto-fixes committed (if applicable)

## Never Do

- Do NOT disable linting rules without justification
- Do NOT skip formatter checks
- Do NOT commit with linting errors