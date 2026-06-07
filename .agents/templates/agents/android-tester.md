# Android Tester — {{REPO_NAME}}

Writes Espresso UI tests and/or Robolectric unit tests for Android app.

## Test Framework Detected

- **Unit Framework:** {{UNIT_TEST_FRAMEWORK}} (JUnit4, Robolectric)
- **UI Framework:** {{UI_TEST_FRAMEWORK}} (Espresso)
- **Mock Framework:** Mockito

## Test Commands

- **Unit Tests:** `./gradlew test`
- **UI Tests:** `./gradlew connectedAndroidTest` (requires emulator/device)

## Paths

- **Unit Tests:** `app/src/test/java/`
- **UI Tests:** `app/src/androidTest/java/`

## Process

### Step 1: Identify Files Needing Tests

```bash
# Find recently modified files
git diff --name-only HEAD~1..HEAD

# Find untested ViewModels, UseCases, Repositories
find app/src/main/java -name "*.kt" | while read f; do
  test_file=$(echo "$f" | sed 's|/main/|/test/|' | sed 's/\.kt$/Test.kt/')
  [ ! -f "$test_file" ] && echo "Missing: $test_file"
done | head -10
```

### Step 2: Check Existing Test Patterns

```bash
# List existing test structure
ls -la app/src/test/java/
find app/src/test -name "*.kt" | head -5

# Read existing Robolectric tests
find app/src/test -name "*Test.kt" | head -3 | xargs cat 2>/dev/null | head -50
```

### Step 3: Write Unit Tests (Robolectric)

```bash
# Create unit tests following existing patterns
cat > app/src/test/java/com/example/TestClassTest.kt << 'EOF'
package com.example

import org.junit.Test
import org.junit.Assert.*
import org.robolectric.annotation.Config

@Config(manifest = Config.NONE)
class TestClassTest {

    @Test
    fun `test basic functionality`() {
        // Arrange
        val instance = TestClass()
        
        // Act
        val result = instance.method()
        
        // Assert
        assertNotNull(result)
        assertEquals("expected", result)
    }
    
    @Test
    fun `test error handling`() {
        // Test edge cases and error conditions
    }
}
EOF
```

### Step 4: Write UI Tests (Espresso)

```bash
# Create UI tests if needed
cat > app/src/androidTest/java/com/example/ExampleUITest.kt << 'EOF'
package com.example

import androidx.test.core.app.ActivityScenario
import androidx.test.espresso.Espresso.*
import androidx.test.espresso.assertion.ViewAssertions.*
import androidx.test.ext.junit.rules.ActivityScenarioRule
import org.junit.Rule
import org.junit.Test

class ExampleUITest {
    
    @Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)
    
    @Test
    fun testDisplayContent() {
        onView(withId(R.id.text_view))
            .check(matches(withText("Expected Text")))
    }
}
EOF
```

### Step 5: Run Unit Tests

```bash
./gradlew test
```

### Step 6: Fix Any Test Failures

```bash
# Fix test failures and re-run
./gradlew test
```

### Step 7: Commit Test Files

```bash
git add app/src/test/ app/src/androidTest/
git commit -m "test(android): add unit and UI tests

- Added Robolectric unit tests for ViewModels
- Added Espresso UI tests for main screens
- All tests passing
"
```

## Output

- Unit tests created in `app/src/test/java/`
- UI tests created in `app/src/androidTest/java/`
- All tests passing
- Test files committed

## Next Step

Continue to `build-check` skill or `ci-monitor` skill.