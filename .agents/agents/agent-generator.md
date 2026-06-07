# Agent Generator Agent

Reads the pipeline specification, processes agent templates, substitutes parameters, and writes agent files to `.agents/agents/` in the target repository.

## Inputs

- Pipeline spec: `/tmp/pipeline-spec-{REPO_NAME}.json`
- Templates: `.agents/templates/agents/`
- Target repo: `/tmp/{REPO_NAME}`

## Process

### Step 1: Read Pipeline Spec

```bash
cat /tmp/pipeline-spec-{REPO_NAME}.json | jq .
```

### Step 2: Create Agents Directory

```bash
mkdir -p /tmp/{REPO_NAME}/.agents/agents
```

### Step 3: Process Universal Agents

For each agent in `agents.universal`, read template and substitute parameters:

```bash
# Read spec and iterate over universal agents
AGENTS=$(jq -r '.agents.universal[] | @json' /tmp/pipeline-spec-{REPO_NAME}.json)

echo "$AGENTS" | while read AGENT; do
  NAME=$(echo "$AGENT" | jq -r '.name')
  TEMPLATE=$(echo "$AGENT" | jq -r '.template')
  PARAMS=$(echo "$AGENT" | jq -r '.parameters')
  
  # Read template
  TEMPLATE_CONTENT=$(cat .agents/templates/agents/$TEMPLATE)
  
  # Substitute parameters
  # For each key in PARAMS, replace {KEY} with value
  RESULT=$TEMPLATE_CONTENT
  for key in $(echo "$PARAMS" | jq -r 'keys[]'); do
    value=$(echo "$PARAMS" | jq -r ".$key")
    RESULT=$(echo "$RESULT" | sed "s/{{$key}}/$value/g")
  done
  
  # Write to target repo
  echo "$RESULT" > /tmp/{REPO_NAME}/.agents/agents/$NAME.md
done
```

### Step 4: Process Conditional Agents

```bash
if [ $(jq -c '.agents.conditional | length' /tmp/pipeline-spec-{REPO_NAME}.json) -gt 0 ]; then
  CONDITIONAL=$(jq -r '.agents.conditional[] | @json' /tmp/pipeline-spec-{REPO_NAME}.json)
  
  echo "$CONDITIONAL" | while read AGENT; do
    NAME=$(echo "$AGENT" | jq -r '.name')
    TEMPLATE=$(echo "$AGENT" | jq -r '.template')
    PARAMS=$(echo "$AGENT" | jq -r '.parameters')
    
    TEMPLATE_CONTENT=$(cat .agents/templates/agents/$TEMPLATE)
    
    # Substitute parameters
    RESULT=$TEMPLATE_CONTENT
    for key in $(echo "$PARAMS" | jq -r 'keys[]'); do
      value=$(echo "$PARAMS" | jq -r ".$key")
      RESULT=$(echo "$RESULT" | sed "s/{{$key}}/$value/g")
    done
    
    echo "$RESULT" > /tmp/{REPO_NAME}/.agents/agents/$NAME.md
  done
fi
```

### Step 5: Verify Generated Files

```bash
echo "Generated agents:"
ls -la /tmp/{REPO_NAME}/.agents/agents/
echo ""
echo "Agent count: $(ls /tmp/{REPO_NAME}/.agents/agents/*.md 2>/dev/null | wc -l)"
```

## Output

Agent files written to `/tmp/{REPO_NAME}/.agents/agents/`:
- ticket-planner.md
- code-implementer.md
- tester.md
- pr-reviewer.md
- ticket-manager.md
- And any conditional agents based on audit (android-implementer.md, etc.)

## Error Handling

If a template file is missing:
1. Log warning to `/tmp/agent-gen-warnings.log`
2. Skip that agent
3. Continue with remaining agents

## Next Step

After agent generation is complete, invoke `skill-generator` to generate skill files.