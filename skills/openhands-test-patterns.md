---
triggers:
  - test
  - testing
  - unit test
  - pytest
  - vitest
  - jest
  - test coverage
  - write tests
description: Unit testing patterns and conventions based on the OpenHands repository
---

# OpenHands Test Patterns

Testing conventions, patterns, and best practices derived from the OpenHands repository.

## Test Organization

### Directory Structure

```
tests/
├── unit/                    # Unit tests (mirrors source)
│   ├── app_server/
│   ├── frontend/
│   ├── integrations/
│   ├── server/
│   ├── storage/
│   └── utils/
├── integration/             # Integration tests
└── conftest.py              # Shared fixtures

frontend/
├── __tests__/               # Frontend unit tests
├── tests/                   # E2E tests (Playwright)
└── vitest.setup.ts          # Test setup
```

### File Naming

```
# Python: test_ prefix
tests/unit/services/test_user_service.py

# TypeScript: .test.ts suffix
src/utils/format.test.ts
__tests__/UserProfile.test.tsx
```

## Python Testing (pytest)

### Basic Test Structure

```python
import pytest
from openhands.services.user_service import UserService


class TestUserService:
    """Tests for UserService."""

    def test_get_user_with_valid_id_returns_user(self):
        """Should return user when ID exists."""
        service = UserService(db=mock_db)
        user = service.get_user("user-123")
        
        assert user is not None
        assert user.id == "user-123"

    def test_get_user_with_invalid_id_returns_none(self):
        """Should return None when ID doesn't exist."""
        service = UserService(db=mock_db)
        user = service.get_user("nonexistent")
        
        assert user is None

    def test_create_user_with_valid_data_creates_user(self):
        """Should create and return new user."""
        service = UserService(db=mock_db)
        user = service.create_user(name="Test", email="test@example.com")
        
        assert user.name == "Test"
        assert user.email == "test@example.com"
```

### Test Naming Convention

```
test_<function>_<scenario>_<expected_result>

Examples:
- test_validate_email_with_valid_email_returns_true
- test_parse_config_with_missing_key_raises_key_error
- test_calculate_total_with_empty_list_returns_zero
- test_authenticate_with_expired_token_raises_auth_error
```

### Fixtures (conftest.py)

```python
# tests/conftest.py
import pytest
from openhands.models import User


@pytest.fixture
def sample_user() -> User:
    """Create a sample user for testing."""
    return User(
        id="user-123",
        name="Test User",
        email="test@example.com"
    )


@pytest.fixture
def db_session():
    """Create a test database session."""
    session = create_test_session()
    yield session
    session.rollback()
    session.close()


@pytest.fixture
def api_client(db_session):
    """Create a test API client."""
    app.dependency_overrides[get_db] = lambda: db_session
    with TestClient(app) as client:
        yield client
```

### Parametrized Tests

```python
import pytest


@pytest.mark.parametrize("input_value,expected", [
    ("hello", 5),
    ("", 0),
    ("hello world", 11),
    ("  spaces  ", 10),
])
def test_string_length(input_value: str, expected: int):
    """Should correctly calculate string length."""
    assert len(input_value) == expected


@pytest.mark.parametrize("email,is_valid", [
    ("user@example.com", True),
    ("user@domain.co.uk", True),
    ("invalid-email", False),
    ("@nodomain.com", False),
    ("", False),
])
def test_validate_email(email: str, is_valid: bool):
    """Should validate email formats correctly."""
    assert validate_email(email) == is_valid
```

### Testing Exceptions

```python
import pytest
from openhands.exceptions import ValidationError


def test_validate_config_with_invalid_data_raises_error():
    """Should raise ValidationError for invalid config."""
    with pytest.raises(ValidationError) as exc_info:
        validate_config({"invalid": "data"})
    
    assert "missing required field" in str(exc_info.value)


def test_divide_by_zero_raises_error():
    """Should raise ZeroDivisionError."""
    with pytest.raises(ZeroDivisionError):
        divide(10, 0)
```

### Async Tests

```python
import pytest


@pytest.mark.asyncio
async def test_fetch_user_returns_user():
    """Should fetch user asynchronously."""
    user = await fetch_user("user-123")
    assert user.id == "user-123"


@pytest.mark.asyncio
async def test_fetch_user_with_timeout_raises_error():
    """Should raise TimeoutError when request times out."""
    with pytest.raises(TimeoutError):
        await fetch_user("user-123", timeout=0.001)
```

## TypeScript Testing (Vitest)

### Basic Test Structure

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { formatDate, parseDate } from './date-utils';

describe('formatDate', () => {
  it('formats date in default format', () => {
    const date = new Date('2024-01-15');
    expect(formatDate(date)).toBe('Jan 15, 2024');
  });

  it('handles custom format', () => {
    const date = new Date('2024-01-15');
    expect(formatDate(date, 'YYYY-MM-DD')).toBe('2024-01-15');
  });

  it('returns empty string for invalid date', () => {
    expect(formatDate(new Date('invalid'))).toBe('');
  });
});

describe('parseDate', () => {
  it('parses valid date string', () => {
    const result = parseDate('2024-01-15');
    expect(result).toBeInstanceOf(Date);
    expect(result?.getFullYear()).toBe(2024);
  });

  it('returns null for invalid string', () => {
    expect(parseDate('not-a-date')).toBeNull();
  });
});
```

### React Component Tests

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  it('renders children correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click</Button>);
    
    fireEvent.click(screen.getByText('Click'));
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Disabled</Button>);
    expect(screen.getByText('Disabled')).toBeDisabled();
  });

  it('applies variant styles correctly', () => {
    render(<Button variant="primary">Primary</Button>);
    const button = screen.getByText('Primary');
    expect(button).toHaveClass('bg-primary');
  });
});
```

### Hook Tests

```typescript
import { renderHook, act, waitFor } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });

  it('initializes with provided value', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  it('increments count', () => {
    const { result } = renderHook(() => useCounter());
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });
});
```

## When to Mock (and When NOT to)

### ✅ DO Mock

```python
# External HTTP APIs
@pytest.fixture
def mock_http_client(mocker):
    return mocker.patch('httpx.AsyncClient.get')

# Time-dependent code
@pytest.fixture
def frozen_time(mocker):
    return mocker.patch('time.time', return_value=1234567890)

# File system operations in unit tests
@pytest.fixture
def mock_fs(tmp_path):
    return tmp_path
```

### ❌ DON'T Mock

```python
# Your own code - test the real implementation
def test_user_service():
    # ❌ Don't mock your own classes
    # service = Mock(spec=UserService)
    
    # ✅ Use the real implementation
    service = UserService(db=test_db)

# Database in integration tests
def test_user_crud(db_session):
    # ✅ Use real database with test session
    user = UserService(db_session).create_user(...)
```

## Running Tests

### Python

```bash
# Run all tests
pytest

# Run with verbose output
pytest -xvs

# Run specific file
pytest tests/unit/test_user_service.py

# Run specific test
pytest -k "test_get_user_with_valid_id"

# Run with coverage
pytest --cov=openhands --cov-report=term-missing

# Run only failed tests from last run
pytest --lf
```

### TypeScript

```bash
# Run all tests
npm test

# Run in watch mode
npm test -- --watch

# Run specific file
npm test -- src/utils/format.test.ts

# Run with coverage
npm run test:coverage

# Run E2E tests (Playwright)
npx playwright test
```

## Coverage Goals

| Code Type | Target |
|-----------|--------|
| New features | 80%+ |
| Critical paths (auth, payments) | 100% |
| Utilities | 90%+ |
| Edge cases | At least 1 test each |

## Test Principles

### 1. Test Behavior, Not Implementation

```python
# ❌ Testing implementation details
def test_user_service_calls_db_get():
    mock_db.get.assert_called_once()

# ✅ Testing behavior
def test_user_service_returns_user_for_valid_id():
    user = service.get_user("user-123")
    assert user.name == "Expected Name"
```

### 2. One Concept Per Test

```python
# ❌ Testing multiple concepts
def test_user_operations():
    user = service.create_user("Test", "test@example.com")
    assert user.name == "Test"
    
    updated = service.update_user(user.id, name="New")
    assert updated.name == "New"
    
    service.delete_user(user.id)
    assert service.get_user(user.id) is None

# ✅ Separate tests
def test_create_user():
    user = service.create_user("Test", "test@example.com")
    assert user.name == "Test"

def test_update_user():
    # ...

def test_delete_user():
    # ...
```

### 3. Arrange-Act-Assert Pattern

```python
def test_calculate_discount():
    # Arrange
    cart = Cart(items=[Item(price=100), Item(price=50)])
    discount = Discount(percentage=10)
    
    # Act
    total = calculate_total(cart, discount)
    
    # Assert
    assert total == 135.0  # 150 - 10%
```

### 4. Use Descriptive Assertions

```python
# ❌ Unclear failure message
assert result == expected

# ✅ Clear failure message
assert result == expected, f"Expected {expected}, got {result}"

# ✅ Or use pytest's rich assertions
assert user.name == "Expected"  # pytest shows diff on failure
```

## Common Test Utilities

### Python (conftest.py)

```python
@pytest.fixture
def capture_logs(caplog):
    """Capture log output for assertions."""
    caplog.set_level(logging.INFO)
    return caplog


@pytest.fixture
def env_vars(monkeypatch):
    """Set environment variables for test."""
    def _set(**kwargs):
        for key, value in kwargs.items():
            monkeypatch.setenv(key, value)
    return _set
```

### TypeScript (test-utils.tsx)

```typescript
import { render } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

export function renderWithProviders(ui: React.ReactElement) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  
  return render(
    <QueryClientProvider client={queryClient}>
      {ui}
    </QueryClientProvider>
  );
}
```
