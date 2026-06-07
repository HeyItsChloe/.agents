---
triggers:
  - code patterns
  - openhands patterns
  - architecture
  - project structure
  - coding conventions
  - how to structure
description: Code patterns and conventions based on the OpenHands repository
---

# OpenHands Code Patterns

Coding patterns, conventions, and best practices derived from the OpenHands repository.

## Project Structure

```
repository/
├── .agents/              # Agent definitions
├── .github/              # GitHub Actions, templates
├── frontend/             # React frontend (TypeScript)
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── hooks/        # Custom React hooks
│   │   ├── contexts/     # React contexts
│   │   ├── services/     # API services
│   │   ├── stores/       # State management
│   │   ├── types/        # TypeScript types
│   │   ├── utils/        # Utility functions
│   │   └── ui/           # Base UI components
│   ├── tests/            # Frontend tests
│   └── package.json
├── openhands/            # Python backend
│   ├── core/             # Core functionality
│   ├── server/           # API server
│   └── utils/            # Utilities
├── tests/                # Python tests
│   └── unit/             # Unit tests (mirrors source)
├── skills/               # Skill definitions
├── AGENTS.md             # Repository-level agent instructions
├── pyproject.toml        # Python dependencies
└── Makefile              # Build commands
```

## Frontend Patterns

### Component Organization

```
components/
├── features/       # Feature-specific components
├── shared/         # Shared across features
├── ui/             # Base UI primitives
└── v1/             # Version-specific components
```

### Component File Structure

```tsx
// components/features/UserProfile.tsx

import { useState } from 'react';
import { Card } from '@/ui/card';
import type { User } from '@/types';

interface UserProfileProps {
  user: User;
  onUpdate?: (user: User) => void;
}

export function UserProfile({ user, onUpdate }: UserProfileProps) {
  const [isEditing, setIsEditing] = useState(false);
  
  return (
    <Card>
      {/* Component content */}
    </Card>
  );
}
```

### UI Primitives (src/ui/)

Keep base components minimal and composable:

```tsx
// ui/card.tsx
interface CardProps {
  children: React.ReactNode;
  className?: string;
}

export function Card({ children, className }: CardProps) {
  return (
    <div className={`bg-surface rounded-lg border ${className}`}>
      {children}
    </div>
  );
}
```

### Hooks Pattern

```tsx
// hooks/useUser.ts
export function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setIsLoading(false));
  }, [userId]);

  return { user, isLoading, error };
}
```

## Backend Patterns (Python)

### Module Structure

```python
# openhands/services/user_service.py

from typing import Optional
from pydantic import BaseModel

from openhands.core.database import Database
from openhands.models.user import User


class UserService:
    """Service for user operations."""

    def __init__(self, db: Database) -> None:
        self.db = db

    def get_user(self, user_id: str) -> Optional[User]:
        """Retrieve a user by ID."""
        return self.db.get(User, user_id)

    def create_user(self, name: str, email: str) -> User:
        """Create a new user."""
        user = User(name=name, email=email)
        self.db.save(user)
        return user
```

### Type Hints

Always use type hints:

```python
from typing import Optional, List, Dict, Any

def process_items(
    items: List[str],
    config: Optional[Dict[str, Any]] = None
) -> Dict[str, int]:
    """Process items and return counts."""
    config = config or {}
    return {item: len(item) for item in items}
```

### Pydantic Models

```python
from pydantic import BaseModel, Field


class UserConfig(BaseModel):
    """Configuration for a user."""

    name: str = Field(..., description="User's display name")
    email: str = Field(..., description="User's email address")
    settings: Dict[str, Any] = Field(default_factory=dict)

    class Config:
        extra = "forbid"
```

## Git Practices

### Commit Messages

Use imperative mood:
```
✅ Add user authentication endpoint
✅ Fix validation error in form submission
✅ Update dependencies to latest versions

❌ Added user authentication
❌ Fixes validation error
❌ Updating dependencies
```

### Branch Naming

```
feature/add-user-auth
fix/login-validation-error
refactor/simplify-api-client
docs/update-readme
```

### Pre-commit Hooks

Always run before pushing:

```bash
# Python changes
pre-commit run --config ./dev_config/python/.pre-commit-config.yaml

# Frontend changes
cd frontend && npm run lint:fix && npm run build
```

## GitHub Actions

### Pin Third-Party Actions

```yaml
# ✅ Correct: Full SHA with version comment
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

# ❌ Wrong: Mutable tag
- uses: actions/checkout@v4
```

### Exception

GitHub-authored (`actions/*`) and first-party (`OpenHands/*`) actions are exempt.

## Build Commands

```bash
# Full build
make build

# Install pre-commit hooks (required before making changes)
make install-pre-commit-hooks

# Run locally
make run FRONTEND_PORT=12000

# Python linting
ruff check .
ruff format .
mypy openhands/

# Frontend linting
cd frontend && npm run lint:fix
```

## Code Quality Standards

### Python (Ruff + MyPy)

```toml
# pyproject.toml
[tool.ruff]
line-length = 88
select = ["E", "F", "I", "W"]

[tool.mypy]
strict = true
```

### TypeScript (ESLint + Prettier)

```json
// .eslintrc
{
  "extends": ["react-app", "prettier"],
  "rules": {
    "no-unused-vars": "error"
  }
}
```

## Import Organization

### Python

```python
# Standard library
import os
from typing import Optional

# Third-party
import httpx
from pydantic import BaseModel

# Local
from openhands.core import config
from openhands.utils.helpers import format_date
```

### TypeScript

```typescript
// React/external
import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';

// Internal - absolute imports
import { Card } from '@/ui/card';
import { useUser } from '@/hooks/useUser';
import type { User } from '@/types';

// Relative imports (same feature)
import { UserAvatar } from './UserAvatar';
```

## Error Handling

### Python

```python
from openhands.exceptions import UserNotFoundError

def get_user(user_id: str) -> User:
    user = db.get(User, user_id)
    if not user:
        raise UserNotFoundError(f"User {user_id} not found")
    return user
```

### TypeScript

```typescript
async function fetchUser(userId: string): Promise<User> {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch user: ${response.statusText}`);
  }
  return response.json();
}
```

## PR-Specific Artifacts

Store temporary PR artifacts in `.pr/` directory:

```
.pr/
├── design.md       # Design decisions
├── analysis.md     # Investigation notes
└── notes.md        # Any PR-specific content
```

These are NOT merged to main.

## Documentation

### Docstrings (Python)

```python
def process_request(
    request: Request,
    validate: bool = True
) -> Response:
    """Process an incoming request.

    Args:
        request: The incoming request object.
        validate: Whether to validate the request. Defaults to True.

    Returns:
        The processed response.

    Raises:
        ValidationError: If validation fails and validate is True.
    """
```

### JSDoc (TypeScript)

```typescript
/**
 * Fetches user data from the API.
 * @param userId - The unique identifier of the user
 * @returns Promise resolving to the user object
 * @throws Error if the fetch fails
 */
async function fetchUser(userId: string): Promise<User> {
```
