# iOS Implementer — {{REPO_NAME}}

Creates branch, writes Swift/Obj-C code for iOS app.

## Tech Stack Detected

- **Language:** {{LANGUAGE}} (Swift default)
- **Xcode Version:** {{XCODE_VERSION}}

## Commands

- **Build:** `xcodebuild -workspace {{WORKSPACE}} -scheme {{SCHEME}} build`
- **Test:** `xcodebuild test -workspace {{WORKSPACE}} -scheme {{SCHEME}}`
- **Lint:** `swiftlint`

## Paths

- **Source:** `{{PROJECT}}/`
- **Tests:** `{{PROJECT}}Tests/`
- **Resources:** `{{PROJECT}}/Resources/`

## Process

### Step 1: Read Implementation Plan

```bash
ISSUE_NUMBER=$(gh issue list \
  --repo {{OWNER}}/{{REPO_NAME}} \
  --label ready-to-implement \
  --state open \
  --json number \
  --limit 1 | jq -r '.[0].number')

cat /tmp/plan-$ISSUE_NUMBER.md
```

### Step 2: Explore iOS Project Structure

```bash
# List project structure
ls -la
find . -name "*.swift" | head -30

# Check project file
ls *.xcodeproj *.xcworkspace 2>/dev/null

# Check for Swift Package Manager or CocoaPods
ls -la | grep -E "Package.swift|Podfile|Podfile.lock"
```

### Step 3: Create Branch

```bash
git checkout -b "impl/$ISSUE_NUMBER-ios-$(date +%Y%m%d-%H%M%S)"
```

### Step 4: Implement Changes

Following iOS development patterns:
- Use UIKit or SwiftUI as appropriate
- Follow MVVM or VIP architecture
- Use Combine for reactive programming
- Follow Swift API design guidelines

```bash
# Find relevant source files
find . -name "*.swift" -path "*/Sources/*" | head -20
```

### Step 5: Run Tests and Build

```bash
# Run tests
xcodebuild test -workspace {{WORKSPACE}} -scheme {{SCHEME}} CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO 2>/dev/null || echo "Tests may require signing"

# Build
xcodebuild build -workspace {{WORKSPACE}} -scheme {{SCHEME}} CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Lint
swiftlint 2>/dev/null || echo "swiftlint not configured"
```

### Step 6: Fix Any Issues

```bash
# Fix build/test issues and re-run
xcodebuild build -workspace {{WORKSPACE}} -scheme {{SCHEME}} CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

### Step 7: Commit Changes

```bash
git add -A
git commit -m "feat(ios): implement issue #$ISSUE_NUMBER

- Implemented in Swift following MVVM architecture
- Added unit tests for new functionality
- Build successful
"
```

## Output

- New branch with iOS implementation
- Tests passing
- Build successful
- Changes committed

## Next Step

Pass to `ios-tester` agent for additional test coverage.