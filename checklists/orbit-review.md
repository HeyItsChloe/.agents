# Orbit (mates4ever) — PR Review Checklist

Review criteria for React/TypeScript dating app PRs.

## Tech Stack
- **Frontend:** React 18, TypeScript (strict mode)
- **Build:** Vite
- **Tests:** Vitest + @testing-library/react
- **Styling:** Inline styles with design tokens

## TypeScript (Strict Mode)

- [ ] No `any` types — define proper interfaces
- [ ] All component props typed with an interface
- [ ] Return types on exported functions
- [ ] No non-null assertions without a comment
- [ ] Use `import.meta.env.VITE_*` — never `process.env.*`
- [ ] tsconfig strict: true compliance

## Design Tokens

All colours must come from `src/theme.ts`. Never use inline hex values.

- [ ] Uses `PURPLE` family for human UI
- [ ] Uses `BLUE` family for AI/bot UI
- [ ] No hardcoded hex colours in components

## React Patterns

- [ ] Functional components only
- [ ] Props interface defined at top of file
- [ ] useState/useReducer for local state
- [ ] Custom hooks extracted for reusable logic
- [ ] No class components

## Component Structure

```
src/
├── screens/     # Route-level components
├── components/  # Reusable UI components
├── hooks/       # Custom hooks
└── services/    # API services (mocked in tests)
```

- [ ] Components are in correct directories
- [ ] Tests are in `src/__tests__/<category>/`
- [ ] Barrel exports from `index.ts` files

## Testing

- [ ] Test files: `*.test.tsx` or `*.test.ts`
- [ ] Mock AI service: `vi.mock('../../services/aiService', ...)`
- [ ] No real API calls in tests
- [ ] Test bot vs human rendering separately
- [ ] Test empty/loading/error states

## Bot Personas

- [ ] Bot profiles have `isBot: true`
- [ ] Bot profiles have `age: null`
- [ ] Bot profiles have `dist: undefined`
- [ ] Bot UI uses `BLUE` accent family
- [ ] Human UI uses `PURPLE` accent family

## Security

- [ ] No hardcoded secrets
- [ ] API keys from `.env` (VITE_*)
- [ ] No eval() or similar patterns
- [ ] Input validation on user inputs

## Build Verification

```bash
# Run these checks
npm run dev          # Dev server starts
npm test -- --run    # All tests pass
npx tsc --noEmit     # No type errors
npm run build        # Production build succeeds
```

## UI/UX

- [ ] Swipe gestures work on mobile
- [ ] Chat screen handles AI responses
- [ ] Profile screen displays correctly
- [ ] Filter drawer works for Human/AI/All

## Checklist Command

```bash
# Run checklist verification
npm test -- --run
npx tsc --noEmit
npm run build
```