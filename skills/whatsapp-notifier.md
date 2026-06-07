# WhatsApp Notifier Skill

Send a WhatsApp message from any pipeline — PR review requests, failure alerts,
deployment notifications. Works for any project.

## Required Secrets

Register in OpenHands → Settings → Secrets:

| Secret | Description |
|--------|-------------|
| `WHATSAPP_PHONE` | Your WhatsApp number, international format, no `+` (e.g. `447911123456`) |
| `WHATSAPP_API_KEY` | callmebot API key (see One-Time Setup) |

## One-Time Setup (callmebot — free, no SDK)

1. Open WhatsApp and message **+34 644 76 60 71**:
   ```
   I allow callmebot to send me messages
   ```
2. You'll receive your personal API key by reply.
3. Save it as `WHATSAPP_API_KEY` in OpenHands Secrets.

## Send a Message

```bash
send_whatsapp() {
  local message="$1"
  local encoded
  encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$message")
  curl -s "https://api.callmebot.com/whatsapp.php?phone=${WHATSAPP_PHONE}&text=${encoded}&apikey=${WHATSAPP_API_KEY}"
}

# Examples
send_whatsapp "✅ PR #${PR_NUMBER} is ready for your review. All checks passed.
Link: ${PR_URL}"

send_whatsapp "❌ PR #${PR_NUMBER} has failing CI checks after 3 retries.
Link: ${PR_URL}"

send_whatsapp "⚠️ Autonomous pipeline failed at Step ${N} for issue #${ISSUE}.
Manual action required."
```

## Test Your Setup

```bash
curl -s "https://api.callmebot.com/whatsapp.php?phone=${WHATSAPP_PHONE}&text=OpenHands+test+ping&apikey=${WHATSAPP_API_KEY}"
# Should return: {"status":"Message sent",...}
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Message not delivered | Re-send the activation message to callmebot |
| `Wrong API key` | Check `WHATSAPP_API_KEY` has no extra spaces |
| Phone format error | Ensure `WHATSAPP_PHONE` has no `+`, spaces, or dashes |

## Alternative: Twilio

If you prefer Twilio, register these additional secrets:
`TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_FROM_NUMBER`

```bash
curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json" \
  --data-urlencode "From=whatsapp:${TWILIO_FROM_NUMBER}" \
  --data-urlencode "To=whatsapp:+${WHATSAPP_PHONE}" \
  --data-urlencode "Body=${message}" \
  -u "${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}"
```
