# OrderMate (Android) — PR Review Checklist

Review criteria for Android/Kotlin Clover POS app PRs.

## Tech Stack
- **Language:** Kotlin
- **Platform:** Android (Clover devices)
- **Build:** Gradle (Kotlin DSL)
- **Backend:** Firebase Realtime Database
- **POS Integration:** Clover SDK v3

## Kotlin Conventions

- [ ] No `var` — use `val` unless mutability required
- [ ] Proper null safety (no `!!` without comment)
- [ ] Extension functions used appropriately
- [ ] Sealed classes for UI states
- [ ] Data classes for models
- [ ] Coroutines for async operations

## Android Patterns

- [ ] ViewModels for UI state management
- [ ] LiveData or StateFlow for reactive UI
- [ ] Proper lifecycle handling
- [ ] Fragments properly managed
- [ ] Activities handle config changes

## Architecture

```
app/src/main/java/com/orderMate/
├── activities/       # MainActivity, OverlayActivity
├── adapters/         # RecyclerView adapters
├── broadcast/        # Broadcast receivers
├── fragment/         # UI fragments by feature
├── modals/           # Data models
├── networkManager/   # API and Retrofit setup
├── repository/       # CloverRepository
├── services/         # Background services
├── utils/            # Utility classes
└── viewmodel/        # ViewModels
```

- [ ] Clean separation of concerns
- [ ] Repository pattern for data access
- [ ] ViewModels for business logic

## UI Components

- [ ] Material Design compliance
- [ ] Proper theming (light/dark)
- [ ] Glass morphism UI where applicable
- [ ] Responsive layouts

## Widget System (V2)

- [ ] WidgetConfig follows V2 schema
- [ ] PopupSettings properly configured
- [ ] DefaultWidgetFactory creates correct defaults

## Color System

Colors from `res/values/colors.xml`:
- [ ] Glass morphism colors used
- [ ] Tag/pill colors consistent
- [ ] Status colors (OPEN, PAID, etc.) applied
- [ ] No inline color values

## Testing

- [ ] Unit tests in `app/src/test/java/com/orderMate/`
- [ ] UI tests for critical flows
- [ ] Clover API mocking in tests

## Security

- [ ] No hardcoded credentials
- [ ] Firebase config from secure source
- [ ] API keys not in git

## Build & Release

```bash
# Build commands
./gradlew assembleDebug        # Debug APK
./gradlew test                 # Run tests
./gradlew assembleRelease      # Release APK
```

- [ ] Debug APK builds successfully
- [ ] Tests pass
- [ ] ProGuard/R8 rules applied (release)

## Clover Integration

- [ ] API calls use CloverRepository
- [ ] Proper error handling for offline
- [ ] Payment states mapped correctly:
  - `OPEN`, `PAID`, `PARTIALLY_PAID`
  - `PARTIALLY_REFUNDED`, `REFUNDED`, `LOCKED`

## Documentation

- [ ] KDoc comments on public functions
- [ ] README updated if needed
- [ ] Changelog entry added

## Checklist Command

```bash
# Run checklist verification
./gradlew assembleDebug
./gradlew test
```