# iOS Tester — {{REPO_NAME}}

Writes XCTest unit tests and/or UI tests for iOS app.

## Test Framework Detected

- **Framework:** XCTest (built-in)
- **UI Testing:** XCUITest

## Test Commands

- **Unit Tests:** `xcodebuild test -workspace {{WORKSPACE}} -scheme {{SCHEME}}`
- **UI Tests:** `xcodebuild test -workspace {{WORKSPACE}} -scheme {{SCHEME}} -only-testing:UI`

## Paths

- **Unit Tests:** `{{PROJECT}}Tests/`
- **UI Tests:** `{{PROJECT}}UITests/`

## Process

### Step 1: Identify Files Needing Tests

```bash
# Find recently modified Swift files
git diff --name-only HEAD~1..HEAD | grep "\.swift$"

# Find source files without tests
find . -name "*.swift" -path "*/Sources/*" | while read f; do
  test_file=$(echo "$f" | sed 's|Sources|Tests|')
  test_file="${test_file%.swift}Tests.swift"
  [ ! -f "$test_file" ] && echo "Missing test: $test_file"
done | head -10
```

### Step 2: Check Existing Test Patterns

```bash
# List existing test files
find . -name "*Tests.swift" -o -name "*Test.swift" | head -10

# Read existing test patterns
cat {{PROJECT}}Tests/*.swift 2>/dev/null | head -80
```

### Step 3: Write Unit Tests

```bash
# Create unit tests following existing patterns
cat > {{PROJECT}}Tests/ExampleTests.swift << 'EOF'
import XCTest
@testable import {{PROJECT_NAME}}

class ExampleTests: XCTestCase {
    
    func testExample() {
        // Arrange
        let instance = Example()
        
        // Act
        let result = instance.method()
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "expected")
    }
    
    func testErrorHandling() {
        // Test error conditions
        let instance = Example()
        XCTAssertThrowsError(try instance.failingMethod())
    }
}
EOF
```

### Step 4: Write UI Tests (if needed)

```bash
cat > {{PROJECT}}UITests/ExampleUITests.swift << 'EOF'
import XCTest

class ExampleUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testExampleScreen() {
        let app = XCUIApplication()
        app.launch()
        
        // Test UI elements
        XCTAssertTrue(app.buttons["buttonName"].exists)
        XCTAssertTrue(app.textFields["textFieldName"].exists)
    }
}
EOF
```

### Step 5: Run Tests

```bash
xcodebuild test -workspace {{WORKSPACE}} -scheme {{SCHEME}} CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO 2>&1 | tail -50
```

### Step 6: Fix Any Test Failures

```bash
# Fix test failures and re-run
xcodebuild test -workspace {{WORKSPACE}} -scheme {{SCHEME}} CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

### Step 7: Commit Test Files

```bash
git add {{PROJECT}}Tests/ {{PROJECT}}UITests/
git commit -m "test(ios): add unit and UI tests

- Added XCTest unit tests for ViewModels
- Added XCUITest UI tests for main screens
- All tests passing
"
```

## Output

- Unit tests created in `{{PROJECT}}Tests/`
- UI tests created in `{{PROJECT}}UITests/`
- All tests passing
- Test files committed

## Next Step

Continue to `build-check` skill or `ci-monitor` skill.