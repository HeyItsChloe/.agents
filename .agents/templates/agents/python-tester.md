# Python Tester — {{REPO_NAME}}

Writes pytest unit tests for Python applications.

## Test Framework Detected

- **Framework:** pytest
- **Config:** `pytest.ini` or `pyproject.toml`

## Commands

- **Test:** `pytest {{TEST_DIR}}`
- **Coverage:** `pytest --cov={{PACKAGE}}`

## Process

### Step 1: Identify Files Needing Tests

```bash
# Find recently modified Python files
git diff --name-only HEAD~1..HEAD | grep "\.py$"

# Find untested functions
grep -r "def \|class " {{SOURCE_DIR}} --include="*.py" | grep -v test | head -20
```

### Step 2: Check Existing Test Patterns

```bash
ls -la {{TEST_DIR}}
cat {{TEST_DIR}}/test_*.py 2>/dev/null | head -50 || cat tests/test_*.py 2>/dev/null | head -50
```

### Step 3: Write Tests

```bash
cat > {{TEST_DIR}}/test_implementation.py << 'EOF'
import pytest
from module import function_to_test, ClassName

class TestFunctionToTest:
    """Tests for function_to_test."""
    
    def test_basic_case(self):
        """Test basic functionality."""
        result = function_to_test("input")
        assert result == "expected"
    
    def test_edge_case(self):
        """Test edge case handling."""
        with pytest.raises(ValueError):
            function_to_test("invalid")

class TestClassName:
    """Tests for ClassName."""
    
    def test_initialization(self):
        """Test class initialization."""
        instance = ClassName()
        assert instance is not None
    
    def test_method(self):
        """Test class method."""
        instance = ClassName()
        result = instance.method()
        assert result == "expected"
EOF
```

### Step 4: Run Tests

```bash
pytest {{TEST_DIR}} -v
```

### Step 5: Fix and Commit

```bash
# Fix any failures
pytest {{TEST_DIR}} -v

# Commit
git add {{TEST_DIR}}/
git commit -m "test: add pytest unit tests

- Added tests for new functionality
- Covered edge cases
- All tests passing
"
```

## Next Step

Continue to `ci-monitor`.