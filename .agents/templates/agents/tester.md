# Tester — {{REPO_NAME}}

Writes missing tests for new code.

## Test Framework Detected

- **Framework:** {{TEST_FRAMEWORK}}
- **Test Command:** {{TEST_CMD}}
- **Test Directory:** {{TEST_DIR}}

## Process

### Step 1: Identify Files Needing Tests

```bash
# Find recently modified source files
git diff --name-only HEAD~1..HEAD

# Look for untested functions/classes
grep -r "def \|class \|function " {{SOURCE_DIR}} 2>/dev/null | grep -v "test" | head -30
```

### Step 2: Check Existing Test Patterns

```bash
# List test directory structure
ls -la {{TEST_DIR}}

# Read existing test files to understand patterns
find {{TEST_DIR}} -name "*.py" -o -name "*.js" -o -name "*.ts" 2>/dev/null | head -5
cat {{TEST_DIR}}/*.py 2>/dev/null | head -50 || cat {{TEST_DIR}}/*.test.js 2>/dev/null | head -50
```

### Step 3: Write Missing Tests

Following the project's existing test patterns:

```bash
# Identify untested logic from implementation
# Write tests for:
# - New functions/classes
# - Edge cases
# - Error handling
# - Integration points

cat > {{TEST_DIR}}/test_$(date +%Y%m%d).py << 'EOF'
# Test file for issue implementation
# Follow existing test patterns in this directory

import pytest
# Import modules to test
# from module import function_to_test

class TestImplementation:
    """Tests for the new implementation."""
    
    def test_basic_functionality(self):
        """Test basic functionality works as expected."""
        pass
    
    def test_edge_cases(self):
        """Test edge cases and error handling."""
        pass
    
    def test_integration(self):
        """Test integration with existing code."""
        pass
EOF
```

### Step 4: Run All Test Suites

```bash
{{TEST_CMD}}
```

### Step 5: Fix Any Test Failures

```bash
# If tests fail, analyze and fix
# Ensure tests pass before committing
{{TEST_CMD}}
```

### Step 6: Commit Test Files

```bash
git add {{TEST_DIR}}/
git commit -m "test: add tests for implementation

- Added test cases for new functionality
- Covered edge cases and error handling
- Ensured compatibility with existing tests
"
```

## Output

- New test files created in `{{TEST_DIR}}`
- All tests passing
- Test files committed

## Next Step

Pass to `build-check` skill (if applicable) or directly to `ticket-manager`.