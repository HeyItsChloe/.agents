# Skill Generator Agent

Reads the pipeline specification, processes skill templates, substitutes parameters, and writes skill files to `.agents/skills/` in the target repository.

## Inputs

- Pipeline spec: `/tmp/pipeline-spec-{REPO_NAME}.json`
- Templates: `.agents/templates/skills/`
- Target repo: `/tmp/{REPO_NAME}`

## Process

### Step 1: Read Pipeline Spec

```bash
cat /tmp/pipeline-spec-{REPO_NAME}.json | jq .
```

### Step 2: Create Skills Directory

```bash
mkdir -p /tmp/{REPO_NAME}/.agents/skills
```

### Step 3: Process Universal Skills

For each skill in `skills.universal`, read template and substitute parameters:

```bash
# Read spec and iterate over universal skills
SKILLS=$(jq -r '.skills.universal[] | @json' /tmp/pipeline-spec-{REPO_NAME}.json)

echo "$SKILLS" | while read SKILL; do
  NAME=$(echo "$SKILL" | jq -r '.name')
  TEMPLATE=$(echo "$SKILL" | jq -r '.template')
  PARAMS=$(echo "$SKILL" | jq -r '.parameters')
  
  # Read template
  TEMPLATE_CONTENT=$(cat .agents/templates/skills/$TEMPLATE)
  
  # Substitute parameters
  RESULT=$TEMPLATE_CONTENT
  for key in $(echo "$PARAMS" | jq -r 'keys[]'); do
    value=$(echo "$PARAMS" | jq -r ".$key")
    RESULT=$(echo "$RESULT" | sed "s/{{$key}}/$value/g")
  done
  
  # Write to target repo
  echo "$RESULT" > /tmp/{REPO_NAME}/.agents/skills/$NAME.md
done
```

### Step 4: Process Conditional Skills

```bash
if [ $(jq -c '.skills.conditional | length' /tmp/pipeline-spec-{REPO_NAME}.json) -gt 0 ]; then
  CONDITIONAL=$(jq -r '.skills.conditional[] | @json' /tmp/pipeline-spec-{REPO_NAME}.json)
  
  echo "$CONDITIONAL" | while read SKILL; do
    NAME=$(echo "$SKILL" | jq -r '.name')
    TEMPLATE=$(echo "$SKILL" | jq -r '.template')
    PARAMS=$(echo "$SKILL" | jq -r '.parameters')
    
    TEMPLATE_CONTENT=$(cat .agents/templates/skills/$TEMPLATE)
    
    # Substitute parameters
    RESULT=$TEMPLATE_CONTENT
    for key in $(echo "$PARAMS" | jq -r 'keys[]'); do
      value=$(echo "$PARAMS" | jq -r ".$key")
      RESULT=$(echo "$RESULT" | sed "s/{{$key}}/$value/g")
    done
    
    echo "$RESULT" > /tmp/{REPO_NAME}/.agents/skills/$NAME.md
  done
fi
```

### Step 5: Verify Generated Files

```bash
echo "Generated skills:"
ls -la /tmp/{REPO_NAME}/.agents/skills/
echo ""
echo "Skill count: $(ls /tmp/{REPO_NAME}/.agents/skills/*.md 2>/dev/null | wc -l)"
```

## Output

Skill files written to `/tmp/{REPO_NAME}/.agents/skills/`:
- env-setup.md
- ci-monitor.md
- whatsapp-notifier.md
- And any conditional skills based on audit (build-check.md, docker-build-check.md, etc.)

## Error Handling

If a template file is missing:
1. Log warning to `/tmp/skill-gen-warnings.log`
2. Skip that skill
3. Continue with remaining skills

## Next Step

After skill generation is complete, invoke `automation-registrar` to register the OpenHands automation.