# Docs Deploy Skill

Build and deploy a documentation site to GitHub Pages.
Repo-agnostic — all repo-specific values are passed as parameters at runtime.

## Required Parameters

| Parameter | Example | Description |
|-----------|---------|-------------|
| `REPO` | `11thandOrange/BusyBuddy_v2` | Full GitHub repo identifier |
| `BASE_PATH` | `/BusyBuddy_v2/` | GitHub Pages base path (must match `vite.config.ts` `base`) |
| `DOCS_DIR` | `docs/frontend` | Path to the Vite frontend relative to repo root |

Detect at runtime:
```bash
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
# BASE_PATH and DOCS_DIR are set per-repo in the calling agent or automation
```

## Quick Commands

### Build
```bash
cd ${DOCS_DIR}
npm ci
npm run build
```

### Deploy via gh-pages
```bash
cd ${DOCS_DIR}
npx gh-pages -d dist -m "docs: deploy site [skip ci]"
```

### Trigger GitHub Actions workflow (if configured)
```bash
gh workflow run deploy-docs.yml --repo "${REPO}"
```

### Check Deployment Status
```bash
gh api "repos/${REPO}/pages" --jq '.status'
```

## Step-by-Step

### Step 1 — Verify vite.config.ts base matches BASE_PATH

```bash
grep "base:" ${DOCS_DIR}/vite.config.ts
# Must match BASE_PATH exactly, e.g. base: '/BusyBuddy_v2/'
```

### Step 2 — Build

```bash
cd ${DOCS_DIR} && npm ci && npm run build
test -f dist/index.html && echo "✅ Build OK" || echo "❌ Build failed — stop here"
```

### Step 3 — Deploy

```bash
cd ${DOCS_DIR}
npx gh-pages -d dist -m "docs: deploy site [skip ci]"
```

### Step 4 — Verify

```bash
sleep 30  # GitHub Pages propagation delay
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  "https://$(echo ${REPO} | cut -d/ -f1 | tr '[:upper:]' '[:lower:]').github.io${BASE_PATH}")
echo "HTTP ${HTTP_CODE}"
# Expected: 200
```

## Repo Values Reference

| Repo | REPO | BASE_PATH | DOCS_DIR |
|------|------|-----------|----------|
| BusyBuddy_v2 | `11thandOrange/BusyBuddy_v2` | `/BusyBuddy_v2/` | `docs/frontend` |
| OrderMate | `11thandOrange/OrderMate` | `/OrderMate/` | `docs/frontend` |

## Troubleshooting

**404 on routes after deploy:** `base` in `vite.config.ts` doesn't match `BASE_PATH`
**npm ci fails:** Delete `node_modules/` and retry; check Node.js >= 18
**gh-pages permission error:** Ensure `GITHUB_TOKEN` has `pages:write` scope
**Stale content:** GitHub Pages CDN can take 5–10 min; hard-refresh browser

## Environment Requirements

| Requirement | Version |
|-------------|---------|
| Node.js | >= 18 |
| npm | >= 9 |
| `GITHUB_TOKEN` | write access to target repo |
