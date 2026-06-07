# GitHub Context

This skill provides GitHub account context for the Progress Agent and any agent needing GitHub data.

## Account Details

- **Username:** HeyItsChloe
- **Profile URL:** https://github.com/HeyItsChloe
- **Scope:** All repositories (public and private via GITHUB_TOKEN)
- **Organizations:** None (personal repos only)

## Repositories to Track

Track ALL repositories under the HeyItsChloe account, including:
- Personal projects
- Forks
- Private repositories (when GITHUB_TOKEN has access)

## GitHub API Patterns

### List all repos
```bash
gh api users/HeyItsChloe/repos --paginate --jq '.[].full_name'
```

### Get open PRs across all repos
```bash
gh api search/issues --method GET -f q='author:HeyItsChloe is:pr is:open' --jq '.items[] | {repo: .repository_url, title: .title, number: .number}'
```

### Get PRs with merge conflicts
```bash
gh pr list --author HeyItsChloe --state open --json number,title,mergeable --jq '.[] | select(.mergeable == "CONFLICTING")'
```

### Get GitHub Projects
```bash
gh api graphql -f query='{ user(login: "HeyItsChloe") { projectsV2(first: 10) { nodes { id title } } } }'
```

### Get milestones
```bash
gh api repos/HeyItsChloe/{repo}/milestones --jq '.[] | {title, open_issues, closed_issues, due_on}'
```

## Data Freshness

Always fetch live data from GitHub API. Do not cache or assume state.
