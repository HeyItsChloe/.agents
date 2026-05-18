# .agents - User-Level Skills

This repository contains user-level skills that apply to **all repositories** owned by [@HeyItsChloe](https://github.com/HeyItsChloe).

## How It Works

When you select any repo you own in OpenHands, it automatically loads skills from this `.agents` repository.

This tests [PR #14440](https://github.com/OpenHands/OpenHands/pull/14440) which adds support for `.agents` org/user skill repos.

## Skills Included

| Skill | Triggers | Description |
|-------|----------|-------------|
| `my-standards` | "my standards", "my rules", "how I code" | Personal coding preferences |
| `python-helper` | "python", "pip", "venv" | Python development assistance |

## Testing

1. Run OpenHands with PR #14440
2. Select **any** repo owned by HeyItsChloe (e.g., `skills_test`)
3. Say: "What are my standards?" or "Help me with Python"
4. Verify the skill loads from this `.agents` repo

## Expected Log Output

```
Found org skill repo at HeyItsChloe/.agents
```
