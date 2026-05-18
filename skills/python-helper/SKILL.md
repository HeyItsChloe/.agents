---
triggers:
  - python
  - pip
  - venv
  - virtualenv
  - pytest
  - poetry
description: Python development assistance and best practices
---

# Python Helper

Guidance for Python development across all my projects.

## Environment Setup

Always use virtual environments:

```bash
# Using venv
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows

# Using poetry (preferred)
poetry install
poetry shell
```

## Package Management

```bash
# Install dependencies
pip install -r requirements.txt
poetry install

# Add new package
pip install package-name && pip freeze > requirements.txt
poetry add package-name

# Dev dependencies
poetry add --group dev pytest ruff mypy
```

## Running Tests

```bash
# pytest
pytest -xvs tests/
pytest -k "test_specific" --tb=short

# With coverage
pytest --cov=src --cov-report=term-missing
```

## Linting & Formatting

```bash
# Ruff (fast, replaces flake8/black/isort)
ruff check .
ruff format .

# Type checking
mypy src/
```

## Common Patterns

### Entry point
```python
if __name__ == "__main__":
    main()
```

### Type hints
```python
def process_items(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}
```

## This Skill is Working!

If you see this, user-level skills from `.agents` are loading! 🐍
