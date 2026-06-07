# BusyBuddy_v2 — PR Review Checklist

Review criteria for Shopify/React/Node.js PRs.

## Tech Stack
- **Frontend:** React, TypeScript, Vite
- **Backend:** Node.js, Express, MongoDB
- **Extensions:** Shopify Cart Transformer

## Code Quality

### TypeScript
- [ ] No `any` types — use proper interfaces
- [ ] All component props typed
- [ ] Return types on exported functions
- [ ] No non-null assertions without comment

### React
- [ ] Components are functional (not class)
- [ ] Hooks properly used (useState, useEffect, etc.)
- [ ] No inline styles — use shared styles or theme
- [ ] Props destructured

### Node.js/Express
- [ ] Async/await used (no callbacks)
- [ ] Error handling with try/catch
- [ ] Middleware properly chained
- [ ] Environment variables from process.env

## Security

- [ ] No hardcoded secrets (passwords, API keys)
- [ ] Input validation on API routes
- [ ] MongoDB queries use proper sanitization
- [ ] No eval() or similar dangerous patterns

## Testing

- [ ] Unit tests for new logic
- [ ] Integration tests for API routes
- [ ] Tests use mocking (no real API calls in tests)

## Shopify-Specific

- [ ] Extension code follows Shopify guidelines
- [ ] App handles Shopify webhook events properly
- [ ] GraphQL queries are optimized

## Build & Deploy

- [ ] `npm run build` succeeds
- [ ] No TypeScript errors
- [ ] ESLint passes (if configured)

## UI/UX

- [ ] Responsive design works on mobile
- [ ] Loading states for async operations
- [ ] Error states for failed API calls
- [ ] Accessibility (alt text, aria labels where needed)

## Checklist Command

```bash
# Run checklist verification
cd web/frontend && npx tsc --noEmit
cd web && npm test
npm run build
```