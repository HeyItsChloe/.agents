# Cross-Repo Pipeline Test Suite

Automated tests to verify all autonomous pipelines are working correctly.

## Structure

```
test-pipeline/
├── README.md           # This file
├── scripts/
│   ├── test-label-trigger.sh      # Test label-based triggers
│   ├── test-cron-trigger.sh        # Test cron-based triggers
│   ├── test-pipeline-complete.sh   # Test full pipeline end-to-end
│   └── verify-automation-status.sh # Check all automations enabled
├── fixtures/
│   └── test-issue-template.md      # Test issue template
└── expected/
    └── pipeline-outputs.md         # Expected outputs
```

## Scripts

### test-label-trigger.sh

Tests that labeling an issue triggers the pipeline.

```bash
./test-label-trigger.sh <REPO> <ISSUE_NUMBER>
```

### test-cron-trigger.sh

Tests that cron triggers work (simulated).

```bash
./test-cron-trigger.sh <REPO>
```

### test-pipeline-complete.sh

Tests the full pipeline from issue to PR.

```bash
./test-pipeline-complete.sh <REPO> <ISSUE_NUMBER>
```

### verify-automation-status.sh

Checks that all automations are registered and enabled.

```bash
./verify-automation-status.sh
```

## Running Tests

### Run All Tests

```bash
cd test-pipeline
bash scripts/run-all-tests.sh
```

### Run Individual Test

```bash
bash scripts/verify-automation-status.sh
```

## CI Integration

Add to `.github/workflows/pipeline-test.yml`:

```yaml
name: Pipeline Tests
on:
  schedule:
    - cron: '0 8 * * *'  # Daily at 8AM
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify automations
        run: bash test-pipeline/scripts/verify-automation-status.sh
```

## Expected Results

| Test | Pass | Fail |
|------|------|------|
| Label trigger | Pipeline starts | No action |
| Cron trigger | Batch processes | Nothing happens |
| Pipeline complete | PR created | Stalls at step |
| Automation status | All enabled | Some disabled |