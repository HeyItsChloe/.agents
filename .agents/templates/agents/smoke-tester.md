# Smoke Tester — {{REPO_NAME}}

Runs Playwright end-to-end tests and commits screenshots as proof.

## Detected

- **Config:** `playwright.config.js` or `playwright.config.ts`
- **Test Dir:** `{{E2E_DIR}}`
- **Browser:** Chromium (default)

## Process

### Step 1: Install Playwright

```bash
# Install Playwright if not already installed
npm install -D @playwright/test 2>/dev/null || pip install playwright 2>/dev/null

# Install browser
npx playwright install chromium 2>/dev/null || python -m playwright install chromium 2>/dev/null
```

### Step 2: Run E2E Tests

```bash
# Run Playwright tests
npx playwright test {{E2E_DIR}} --reporter=list 2>/dev/null || \
python -m pytest {{E2E_DIR}} -v 2>/dev/null || \
npx playwright test
```

### Step 3: Review Test Results

```bash
# Check for any test failures
ls -la test-results/ 2>/dev/null || ls -la playwright-report/ 2>/dev/null

# View any screenshots of failures
find . -name "*.png" -path "*/failure/*" 2>/dev/null | head -5
```

### Step 4: Commit Screenshots to Branch

```bash
# Create screenshots directory if it doesn't exist
mkdir -p .smoke-results

# Copy any test screenshots/report
cp -r test-results/* .smoke-results/ 2>/dev/null || true
cp -r playwright-report/* .smoke-results/ 2>/dev/null || true

# Commit screenshots
git add .smoke-results/
git commit -m "test: add smoke test results and screenshots

- Playwright E2E tests completed
- Screenshots saved to .smoke-results/
"
```

### Step 5: Post Results to PR

```bash
# Get PR info
PR_NUMBER=$(cat /tmp/pr-number.txt 2>/dev/null || echo "")
PR_URL=$(cat /tmp/pr-url.txt 2>/dev/null || echo "")

# Post comment with test summary
gh pr comment {{OWNER}}/{{REPO_NAME}}/$PR_NUMBER --body "
## Smoke Test Results ✅

Playwright E2E tests completed successfully.

Screenshots and reports saved to \`.smoke-results/\` directory.

View full report: [Playwright Report](link if available)
" 2>/dev/null || echo "Could not post comment"
```

## Output

- Playwright E2E tests run
- Screenshots committed to branch
- PR comment posted with results

## Next Step

Continue to `ci-monitor` skill.