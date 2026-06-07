# Build Check — {{REPO_NAME}}

Verifies frontend build succeeds.

## Detected

- **Frontend Dir:** `{{FRONTEND_DIR}}`
- **Build Tool:** `{{BUILD_TOOL}}` (Vite, Webpack, Next.js, CRA)
- **CI Flag:** `{{CI_FLAG}}`

## Process

### Step 1: Navigate to Frontend Directory

```bash
cd {{FRONTEND_DIR}}
ls -la
```

### Step 2: Run Build Command

```bash
# Run build with CI flag to bypass prompts
{{BUILD_CMD}} {{CI_FLAG}}
```

### Step 3: Check Build Output

```bash
# Check for build errors
if [ -d "dist" ] || [ -d "build" ] || [ -d ".next" ]; then
  echo "✅ Build successful"
  ls -la dist/ build/ .next/ 2>/dev/null | head -10
else
  echo "❌ Build may have failed - no output directory found"
fi

# Check for any error logs
find . -name "*.log" -path "*/npm*" 2>/dev/null | xargs tail -20 2>/dev/null || true
```

### Step 4: Fix Build Errors (if any)

```bash
# If build failed, analyze errors and fix
# Common fixes:
# - npm install (dependencies may be missing)
# - Clear cache: rm -rf node_modules/.cache
# - Update dependencies: npm update

# Re-run build after fixes
{{BUILD_CMD}} {{CI_FLAG}}
```

## Build Tools Reference

| Tool | Build Command | Output Directory |
|------|---------------|------------------|
| Vite | `npm run build` | `dist/` |
| Webpack | `npm run build` | `build/` |
| Next.js | `npm run build` | `.next/` |
| CRA | `npm run build` | `build/` |
| Nuxt | `npm run build` | `.output/` |
| SvelteKit | `npm run build` | `build/` |

## Error Handling

If build fails:
1. Log errors to `/tmp/build-check-error.log`
2. Attempt common fixes
3. If still failing, document in PR comment
4. Continue pipeline (build issues can be addressed in review)

## Next Step

After build check, continue to `smoke-tester` or `ci-monitor`.