# Build Check Skill — Generic (Auto-Detect)

Verify the project builds correctly for production. Auto-detects project type
and runs the appropriate build command.

## Supported Project Types

| Type | Detection | Build Command |
|------|-----------|---------------|
| npm/Node.js | `package.json` | `npm run build` |
| Gradle/Android | `build.gradle*` | `./gradlew assembleDebug` |
| Poetry/Python | `pyproject.toml` | `poetry build` |
| Cargo/Rust | `Cargo.toml` | `cargo build --release` |
| Make | `Makefile` | `make` |

## Process

### Step 1: Detect Project Type

```bash
# Check for project type indicators
if [ -f "package.json" ]; then
  PROJECT_TYPE="npm"
  BUILD_CMD="npm run build"
  TEST_CMD="npm test"
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  PROJECT_TYPE="gradle"
  BUILD_CMD="./gradlew assembleDebug"
  TEST_CMD="./gradlew test"
elif [ -f "pyproject.toml" ]; then
  PROJECT_TYPE="poetry"
  BUILD_CMD="poetry build"
  TEST_CMD="poetry run pytest"
elif [ -f "Cargo.toml" ]; then
  PROJECT_TYPE="cargo"
  BUILD_CMD="cargo build --release"
  TEST_CMD="cargo test"
elif [ -f "Makefile" ]; then
  PROJECT_TYPE="make"
  BUILD_CMD="make"
  TEST_CMD="make test"
else
  echo "Unknown project type"
  exit 1
fi

echo "Detected project type: $PROJECT_TYPE"
echo "Build command: $BUILD_CMD"
```

### Step 2: Run Tests

```bash
# Run tests first (faster than build, catches issues early)
echo "Running tests..."
$TEST_CMD
TEST_RESULT=$?

if [ $TEST_RESULT -ne 0 ]; then
  echo "Tests failed"
  exit 1
fi

echo "Tests passed"
```

### Step 3: Run Build

```bash
# Run build
echo "Building..."
$BUILD_CMD
BUILD_RESULT=$?

if [ $BUILD_RESULT -ne 0 ]; then
  echo "Build failed"
  exit 1
fi

echo "Build successful"
```

### Step 4: Verify Output

```bash
# Check for expected output artifacts
case $PROJECT_TYPE in
  npm)
    [ -d "dist" ] || [ -d "build" ] && echo "Output directory found"
    ;;
  gradle)
    ls app/build/outputs/apk/debug/*.apk 2>/dev/null && echo "APK found"
    ;;
  poetry)
    [ -d "dist" ] && echo "Package directory found"
    ;;
  cargo)
    [ -d "target/release" ] && echo "Binary found"
    ;;
esac
```

## Verification Checklist

- [ ] Project type detected
- [ ] Tests passed
- [ ] Build succeeded
- [ ] Output artifacts created

## Error Handling

| Error | Solution |
|-------|----------|
| `package.json not found` | Check if in correct directory |
| `node_modules not found` | Run `npm install` first |
| `gradlew not found` | Check if in Android project root |
| `poetry not found` | Install poetry: `curl -sSL https://install.python-poetry.org | python3 -` |

## Output

- Build artifacts in expected locations
- All tests passing
- Clean build with no errors

## Next Step

Pass to `ticket-manager` agent to create PR.