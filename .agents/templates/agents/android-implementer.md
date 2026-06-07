# Android Implementer — {{REPO_NAME}}

Creates branch, writes Kotlin/Java code for Android app.

## Tech Stack Detected

- **Language:** {{LANGUAGE}} (Kotlin default)
- **Build System:** Gradle
- **Min SDK:** {{MIN_SDK}}
- **Target SDK:** {{TARGET_SDK}}

## Commands

- **Build:** `./gradlew assembleDebug`
- **Test:** `./gradlew test`
- **Lint:** `./gradlew lint`

## Paths

- **Source:** `app/src/main/java/`
- **Tests:** `app/src/test/java/`
- **Resources:** `app/src/main/res/`
- **Manifest:** `app/src/main/AndroidManifest.xml`

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

### Step 2: Explore Android Project Structure

```bash
# List project structure
ls -la
ls -la app/src/main/java/ 2>/dev/null || ls -la app/src/main/
find . -name "*.kt" -o -name "*.java" 2>/dev/null | head -30

# Check manifest for activities and permissions
cat app/src/main/AndroidManifest.xml 2>/dev/null | head -50

# Check build.gradle for dependencies
cat app/build.gradle 2>/dev/null | head -50
```

### Step 3: Create Branch

```bash
git checkout -b "impl/$ISSUE_NUMBER-android-$(date +%Y%m%d-%H%M%S)"
```

### Step 4: Implement Changes

Following Android development patterns:
- Use ViewModel + LiveData/StateFlow for UI state
- Follow MVVM architecture
- Use Hilt/Dagger for dependency injection
- Follow Material Design guidelines

```bash
# Find relevant source files based on implementation plan
find app/src/main/java -name "*.kt" | xargs grep -l "TODO\|FIXME" 2>/dev/null | head -5

# Check for existing ViewModels, Repositories, etc.
find app/src/main/java -type f -name "*.kt" | head -20
```

### Step 5: Run Tests and Build

```bash
# Run unit tests
./gradlew test

# Build debug APK
./gradlew assembleDebug

# Run lint
./gradlew lint
```

### Step 6: Fix Any Issues

```bash
# If tests or build fail, fix issues
# Re-run tests and build
./gradlew test assembleDebug
```

### Step 7: Commit Changes

```bash
git add -A
git commit -m "feat(android): implement issue #$ISSUE_NUMBER

- Implemented in Kotlin following MVVM architecture
- Added unit tests for new functionality
- Debug APK builds successfully
"
```

## Output

- New branch with Android implementation
- Unit tests passing
- Debug APK building successfully
- Changes committed

## Next Step

Pass to `android-tester` agent for additional test coverage.