---
name: security-rules
description: >
  Security best practices and checks for all repositories.
  Enforces secure coding, secret management, and vulnerability awareness.
triggers:
  - security
  - password
  - secret
  - token
  - api_key
  - credential
  - auth
  - login
---

# Security Rules

These security rules apply to ALL repositories for @HeyItsChloe.

## Core Principles

1. **Never commit secrets** - No passwords, API keys, tokens, or credentials in code
2. **Use secure protocols** - HTTPS, SSH, TLS for all communications
3. **Least privilege** - Request minimum permissions needed
4. **Validate all input** - Never trust user input
5. **Fail securely** - Don't expose sensitive info in errors

## Secret Detection Checklist

Before committing, scan for:

```bash
# Common secret patterns to avoid
grep -rn "password\s*=\|api_key\s*=\|secret\s*=\|token\s*=" --include="*.kt" --include="*.java" --include="*.py" --include="*.js" .
grep -rn "BEGIN RSA PRIVATE KEY\|BEGIN OPENSSH PRIVATE KEY" .
grep -rn "AKIA[0-9A-Z]{16}" .  # AWS Access Keys
```

## What to Flag

### 🔴 Critical (Must Fix)
- Hardcoded credentials or API keys
- Exposed private keys or certificates
- SQL injection vulnerabilities
- Unencrypted sensitive data storage
- Disabled SSL/TLS verification

### 🟠 Important (Should Fix)
- Missing input validation
- Overly permissive CORS settings
- Debug mode enabled in production
- Verbose error messages exposing internals
- Missing authentication on sensitive endpoints

### 🟡 Suggestions
- Consider using environment variables
- Add rate limiting
- Implement request logging
- Use parameterized queries

## Safe Alternatives

| Don't Do | Do Instead |
|----------|------------|
| `api_key = "abc123"` | `api_key = System.getenv("API_KEY")` |
| `password = "secret"` | Use secure credential storage |
| Commit `.env` files | Add `.env` to `.gitignore` |
| Log sensitive data | Mask or omit sensitive fields in logs |

## Platform-Specific Security

### Android (Kotlin/Java)
- Use **EncryptedSharedPreferences** for sensitive local storage
- Use **Android Keystore** for cryptographic keys
- Enable **ProGuard/R8** for release builds
- Set `android:allowBackup="false"` for sensitive apps
- Use **Certificate Pinning** for API calls
- Check **network_security_config.xml** for cleartext traffic

### Web (JavaScript/TypeScript)
- Sanitize all user input before rendering (XSS prevention)
- Use Content Security Policy (CSP) headers
- Enable HTTPS-only cookies with `Secure` and `HttpOnly` flags
- Validate and sanitize on both client and server

### Python
- Use `secrets` module for cryptographic randomness
- Never use `pickle` with untrusted data
- Use parameterized queries with SQLAlchemy/psycopg2
- Keep dependencies updated (`pip-audit`)

## Error Handling

```kotlin
// ❌ Bad - exposes internal details
catch (e: Exception) {
    Log.e("AUTH", "Login failed: ${e.message} for user $email with password $password")
}

// ✅ Good - safe error logging
catch (e: Exception) {
    Log.e("AUTH", "Login failed for user: [REDACTED]")
    // Report to crash analytics without sensitive data
}
```

## When to Alert User

If you discover a security issue:

1. **Stop and report** the finding immediately
2. **Classify severity** (Critical/Important/Suggestion)
3. **Recommend fix** with code example
4. **Don't commit** until the issue is resolved
