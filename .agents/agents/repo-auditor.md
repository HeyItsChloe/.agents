# Repo Auditor Agent

Clones a repository, analyzes its structure, tech stack, test frameworks, and CI/CD configuration. Outputs a comprehensive audit JSON that drives the pipeline generation.

## Inputs

- `REPO_URL`: The repository URL from the GitHub issue (parsed from issue body)
- `REPO_NAME`: Derived from URL (e.g., "my-repo" from "github.com/owner/my-repo")

## Process

### Step 1: Clone the Repository

```bash
# Clone to /tmp/{REPO_NAME}
git clone --depth 1 {REPO_URL} /tmp/{REPO_NAME}
cd /tmp/{REPO_NAME}
```

### Step 2: Detect Tech Stack

#### Languages & Package Managers
```bash
# Detect files and infer languages
ls -la | grep -E "package\.json|requirements\.txt|Gemfile|go\.mod|Cargo\.toml|pom\.xml|build\.gradle|\.xcodeproj|composer\.json"

# For Node.js
if [ -f "package.json" ]; then
  cat package.json | jq -r '.engines // .packageManager // "npm"' 
  cat package.json | jq -r '.scripts.test // "npm test"'
fi

# For Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo "python"
  grep -E "pytest|unittest|pytest" requirements.txt pyproject.toml 2>/dev/null || echo "pytest"
fi

# For Ruby
if [ -f "Gemfile" ]; then
  echo "ruby"
  grep -E "rspec|minitest" Gemfile || echo "rspec"
fi

# For Go
if [ -f "go.mod" ]; then
  echo "go"
fi

# For Rust
if [ -f "Cargo.toml" ]; then
  echo "rust"
fi
```

#### Framework Detection
```bash
# Node.js frameworks
grep -E "express|koa|hapi|fastify|nestjs|next\.js|react|vue|angular" package.json 2>/dev/null

# Python frameworks
ls *.py 2>/dev/null && grep -lE "flask|django|fastapi|bottle|pyramid" *.py 2>/dev/null

# Check for Shopify
if [ -d "extensions" ] || [ -d "shopify" ]; then
  echo "shopify-detected"
fi

# Check for Shopify Functions
find . -name "*.toml" -path "*/shopify.extension*" 2>/dev/null && echo "shopify-functions"
```

### Step 3: Detect Project Structure

```bash
# Source directories
find . -maxdepth 2 -type d \( -name "src" -o -name "lib" -o -name "app" -o -name "web" -o -name "frontend" -o -name "client" -o -name "main" \) 2>/dev/null | head -10

# Test directories
find . -maxdepth 2 -type d \( -name "test" -o -name "tests" -o -name "__tests__" -o -name "spec" -o -name "specs" -o -name "androidTest" -o -name "androidTest" \) 2>/dev/null | head -10

# Config files
ls -la | grep -E "\.env|\.env\.example|config|settings|application\.yml"

# Entry points
find . -maxdepth 2 \( -name "index.js" -o -name "index.ts" -o -name "main.py" -o -name "main.go" -o -name "App.tsx" -o -name "index.html" \) 2>/dev/null
```

### Step 4: Detect Build System

```bash
# Check for various build systems
if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  echo "gradle"
  grep -E "minSdk|compileSdk" build.gradle 2>/dev/null | head -2
fi

if [ -f "pom.xml" ]; then
  echo "maven"
fi

if [ -f "*.xcodeproj" ] || [ -f "*.xcworkspace" ]; then
  echo "xcode"
  ls *.xcodeproj *.xcworkspace 2>/dev/null
fi

if [ -f "Makefile" ]; then
  echo "make"
  grep -E "test|build" Makefile | head -5
fi
```

### Step 5: Detect CI/CD

```bash
# GitHub Actions
if [ -d ".github/workflows" ]; then
  ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null
  for wf in .github/workflows/*.yml .github/workflows/*.yaml; do
    [ -f "$wf" ] && grep -E "test|build|lint" "$wf" | head -3
  done
fi

# Other CI
ls -la | grep -E "circleci|\.travis\.yml|Jenkinsfile|bitbucket-pipelines\.yml"
```

### Step 6: Detect Test Frameworks

```bash
# Read package.json scripts for test commands
if [ -f "package.json" ]; then
  cat package.json | jq -r '.scripts | to_entries[] | select(.key | contains("test")) | "\(.key): \(.value)"' 2>/dev/null
fi

# Check test frameworks in package.json
if [ -f "package.json" ]; then
  cat package.json | jq -r '.devDependencies, .dependencies | keys[]' 2>/dev/null | grep -E "vitest|jest|mocha|chai|playwright|cypress|eslint"
fi

# Check for test config files
ls -la | grep -E "vitest\.config|jest\.config|playwright\.config|mocha\.opts|\.mocharc"
```

### Step 7: Detect Docker

```bash
if [ -f "Dockerfile" ]; then
  echo "dockerfile-detected"
  head -5 Dockerfile
fi

if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
  echo "docker-compose-detected"
fi
```

### Step 8: Detect Monorepo

```bash
# Count package.json files (monorepo indicator)
PKG_COUNT=$(find . -name "package.json" -not -path "*/node_modules/*" | wc -l)
if [ "$PKG_COUNT" -gt 1 ]; then
  echo "monorepo-detected"
  find . -name "package.json" -not -path "*/node_modules/*" | head -10
fi
```

## Output: Audit JSON

Save to `/tmp/audit-{REPO_NAME}.json`:

```json
{
  "repo_url": "{REPO_URL}",
  "repo_name": "{REPO_NAME}",
  "owner": "{OWNER}",
  
  "tech_stack": {
    "language": "{LANGUAGE}",
    "framework": "{FRAMEWORK}",
    "package_manager": "{PACKAGE_MANAGER}"
  },
  
  "project_structure": {
    "source_dirs": ["{SRC_DIR_1}", "{SRC_DIR_2}"],
    "test_dirs": ["{TEST_DIR_1}", "{TEST_DIR_2}"],
    "config_files": ["{CONFIG_1}", "{CONFIG_2}"],
    "entry_points": ["{ENTRY_1}", "{ENTRY_2}"]
  },
  
  "commands": {
    "install": "{INSTALL_CMD}",
    "test": "{TEST_CMD}",
    "build": "{BUILD_CMD}",
    "lint": "{LINT_CMD}"
  },
  
  "ci_system": {
    "type": "{GITHUB_ACTIONS|CIRCLECI|JENKINS|NONE}",
    "config_path": "{CI_CONFIG_PATH}",
    "workflows": ["{WF_1}", "{WF_2}"]
  },
  
  "test_framework": {
    "framework": "{JEST|VITEST|PYTEST|RSPEC|XCTest|JUnit}",
    "config_file": "{TEST_CONFIG}",
    "test_dirs": ["{TEST_DIR_1}"]
  },
  
  "build_system": {
    "type": "{GRADLE|MAVEN|WEBPACK|VITE|NEXUS|MAKE}",
    "config_file": "{BUILD_CONFIG}"
  },
  
  "conditional_components": {
    "has_shopify": {BOOLEAN},
    "has_android": {BOOLEAN},
    "has_ios": {BOOLEAN},
    "has_docker": {BOOLEAN},
    "has_frontend": {BOOLEAN},
    "has_playwright": {BOOLEAN},
    "has_monorepo": {BOOLEAN},
    "has_extensions": {BOOLEAN}
  },
  
  "existing_agents": [],
  "existing_skills": []
}
```

## Conditional Detection Rules

| Detection | File/Directory | Triggers |
|-----------|---------------|----------|
| Shopify | `extensions/`, `shopify.extension.toml` | shopify-extension-implementer |
| Android | `build.gradle`, `settings.gradle` | android-implementer, android-tester |
| iOS | `*.xcodeproj`, `*.xcworkspace` | ios-implementer, ios-tester |
| Docker | `Dockerfile` | docker-build-check |
| Frontend | `frontend/`, `client/`, `web/` with React/Vue | build-check (frontend) |
| Playwright | `playwright.config.js`, `e2e/` | smoke-tester, playwright-smoke |
| Python | `requirements.txt`, `pyproject.toml` | python-tester |
| Ruby/Rails | `Gemfile`, `config/application.rb` | ruby-tester, rails-assets |
| Go | `go.mod` | go-implementer, go-tester |
| Monorepo | Multiple `package.json` | monorepo-module-detector |

## Error Handling

If repository cannot be cloned or analyzed:
1. Log the error to `/tmp/audit-error.log`
2. Output minimal audit JSON with `error` field
3. Pipeline should skip to completion with error message

## Next Step

After audit JSON is saved, invoke `template-resolver` to match findings against templates.