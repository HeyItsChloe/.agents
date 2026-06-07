# Template Resolver Agent

Reads the audit JSON from `repo-auditor`, matches findings against available templates, and outputs a pipeline specification that drives agent and skill generation.

## Inputs

- Audit JSON: `/tmp/audit-{REPO_NAME}.json`
- Available templates: `.agents/templates/agents/` and `.agents/templates/skills/`

## Process

### Step 1: Read Audit JSON

```bash
cat /tmp/audit-{REPO_NAME}.json | jq .
```

### Step 2: Identify Universal Components

Universal agents (always generated):
- ticket-planner
- code-implementer
- tester
- pr-reviewer
- ticket-manager

Universal skills (always generated):
- env-setup
- ci-monitor
- whatsapp-notifier

### Step 3: Identify Conditional Components

Based on `conditional_components` in audit JSON:

```bash
# Check each conditional
jq -r '.conditional_components | to_entries[] | select(.value == true) | .key' /tmp/audit-{REPO_NAME}.json
```

| Condition | Agents to Generate | Skills to Generate |
|-----------|-------------------|-------------------|
| has_shopify | shopify-extension-implementer | - |
| has_android | android-implementer, android-tester | - |
| has_ios | ios-implementer, ios-tester | - |
| has_docker | - | docker-build-check |
| has_frontend | - | build-check |
| has_playwright | smoke-tester | playwright-smoke |
| has_monorepo | monorepo-module-detector | - |
| has_extensions | extension-implementer | - |

### Step 4: Map Parameters to Templates

For each component, map audit values to template placeholders:

```bash
# Example: Extract parameters for android-implementer template
if jq -e '.conditional_components.has_android' /tmp/audit-{REPO_NAME}.json; then
  echo "Language: $(jq -r '.tech_stack.language' /tmp/audit-{REPO_NAME}.json)"
  echo "Build System: $(jq -r '.build_system.type' /tmp/audit-{REPO_NAME}.json)"
  echo "Test Command: $(jq -r '.commands.test' /tmp/audit-{REPO_NAME}.json)"
  echo "Source Dirs: $(jq -r '.project_structure.source_dirs' /tmp/audit-{REPO_NAME}.json)"
fi
```

### Step 5: Build Pipeline Specification

Create `/tmp/pipeline-spec-{REPO_NAME}.json`:

```json
{
  "repo_url": "{REPO_URL}",
  "repo_name": "{REPO_NAME}",
  "owner": "{OWNER}",
  
  "agents": {
    "universal": [
      {
        "name": "ticket-planner",
        "template": "ticket-planner.md",
        "parameters": {
          "REPO_NAME": "{REPO_NAME}",
          "OWNER": "{OWNER}",
          "SOURCE_DIRS": "{SOURCE_DIRS}",
          "TEST_DIRS": "{TEST_DIRS}"
        }
      },
      {
        "name": "code-implementer",
        "template": "code-implementer.md",
        "parameters": {
          "REPO_NAME": "{REPO_NAME}",
          "LANGUAGE": "{LANGUAGE}",
          "FRAMEWORK": "{FRAMEWORK}",
          "INSTALL_CMD": "{INSTALL_CMD}",
          "TEST_CMD": "{TEST_CMD}",
          "BUILD_CMD": "{BUILD_CMD}",
          "SOURCE_DIR": "{SOURCE_DIR}",
          "TEST_DIR": "{TEST_DIR}"
        }
      },
      {
        "name": "tester",
        "template": "tester.md",
        "parameters": {
          "REPO_NAME": "{REPO_NAME}",
          "TEST_FRAMEWORK": "{TEST_FRAMEWORK}",
          "TEST_CMD": "{TEST_CMD}",
          "TEST_DIR": "{TEST_DIR}"
        }
      },
      {
        "name": "pr-reviewer",
        "template": "pr-reviewer.md",
        "parameters": {
          "REPO_NAME": "{REPO_NAME}"
        }
      },
      {
        "name": "ticket-manager",
        "template": "ticket-manager.md",
        "parameters": {
          "REPO_NAME": "{REPO_NAME}",
          "OWNER": "{OWNER}"
        }
      }
    ],
    "conditional": []
  },
  
  "skills": {
    "universal": [
      {
        "name": "env-setup",
        "template": "env-setup.md",
        "parameters": {
          "REPO_NAME": "{REPO_NAME}",
          "CONFIG_FILE": "{CONFIG_FILE}",
          "REQUIRED_ENV_VARS": "{REQUIRED_ENV_VARS}"
        }
      },
      {
        "name": "ci-monitor",
        "template": "ci-monitor.md",
        "parameters": {
          "REPO_NAME": "{REPO_NAME}",
          "CI_TYPE": "{CI_TYPE}",
          "CI_CONFIG_PATH": "{CI_CONFIG_PATH}"
        }
      },
      {
        "name": "whatsapp-notifier",
        "template": "whatsapp-notifier.md",
        "parameters": {
          "REPO_NAME": "{REPO_NAME}"
        }
      }
    ],
    "conditional": []
  },
  
  "automation": {
    "trigger_label": "ready-to-implement",
    "trigger_filter": "event.label.name == 'ready-to-implement' && glob(repository.full_name, '{OWNER}/{REPO_NAME}')",
    "timeout": 3600
  },
  
  "audit_summary": {
    "tech_stack": "{LANGUAGE} + {FRAMEWORK}",
    "total_agents": {COUNT},
    "total_skills": {COUNT},
    "conditional_added": ["{LIST}"]
  }
}
```

### Step 6: Add Conditional Components

Based on audit findings, append to `conditional` arrays:

```bash
# Shopify extensions
if jq -e '.conditional_components.has_shopify' /tmp/audit-{REPO_NAME}.json; then
  jq ".skills.conditional += [{
    \"name\": \"shopify-extension-implementer\",
    \"template\": \"shopify-extension-implementer.md\",
    \"parameters\": {
      \"REPO_NAME\": \"{REPO_NAME}\",
      \"EXTENSIONS_DIR\": \"extensions/\"
    }
  }]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi

# Android
if jq -e '.conditional_components.has_android' /tmp/audit-{REPO_NAME}.json; then
  jq ".agents.conditional += [
    {\"name\": \"android-implementer\", \"template\": \"android-implementer.md\", \"parameters\": {...}},
    {\"name\": \"android-tester\", \"template\": \"android-tester.md\", \"parameters\": {...}}
  ]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi

# iOS
if jq -e '.conditional_components.has_ios' /tmp/audit-{REPO_NAME}.json; then
  jq ".agents.conditional += [
    {\"name\": \"ios-implementer\", \"template\": \"ios-implementer.md\", \"parameters\": {...}},
    {\"name\": \"ios-tester\", \"template\": \"ios-tester.md\", \"parameters\": {...}}
  ]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi

# Docker build check
if jq -e '.conditional_components.has_docker' /tmp/audit-{REPO_NAME}.json; then
  jq ".skills.conditional += [{
    \"name\": \"docker-build-check\",
    \"template\": \"docker-build-check.md\",
    \"parameters\": {
      \"REPO_NAME\": \"{REPO_NAME}\",
      \"DOCKERFILE_PATH\": \"Dockerfile\",
      \"COMPOSE_FILE\": \"docker-compose.yml\"
    }
  }]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi

# Frontend build check
if jq -e '.conditional_components.has_frontend' /tmp/audit-{REPO_NAME}.json; then
  jq ".skills.conditional += [{
    \"name\": \"build-check\",
    \"template\": \"build-check.md\",
    \"parameters\": {
      \"REPO_NAME\": \"{REPO_NAME}\",
      \"FRONTEND_DIR\": \"{FRONTEND_DIR}\",
      \"BUILD_CMD\": \"{BUILD_CMD}\",
      \"CI_FLAG\": \"CI=true\"
    }
  }]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi

# Playwright smoke tests
if jq -e '.conditional_components.has_playwright' /tmp/audit-{REPO_NAME}.json; then
  jq ".agents.conditional += [{
    \"name\": \"smoke-tester\",
    \"template\": \"smoke-tester.md\",
    \"parameters\": {...}
  }]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
  
  jq ".skills.conditional += [{
    \"name\": \"playwright-smoke\",
    \"template\": \"playwright-smoke.md\",
    \"parameters\": {...}
  }]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi

# Python
if jq -e '.tech_stack.language == \"python\"' /tmp/audit-{REPO_NAME}.json; then
  jq ".agents.conditional += [{
    \"name\": \"python-tester\",
    \"template\": \"python-tester.md\",
    \"parameters\": {...}
  }]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi

# Go
if jq -e '.tech_stack.language == \"go\"' /tmp/audit-{REPO_NAME}.json; then
  jq ".agents.conditional += [
    {\"name\": \"go-implementer\", \"template\": \"go-implementer.md\", \"parameters\": {...}},
    {\"name\": \"go-tester\", \"template\": \"go-tester.md\", \"parameters\": {...}}
  ]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi

# Ruby/Rails
if jq -e '.tech_stack.framework | contains(\"rails\")' /tmp/audit-{REPO_NAME}.json; then
  jq ".agents.conditional += [{\"name\": \"ruby-tester\", \"template\": \"ruby-tester.md\", \"parameters\": {...}}]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
  jq ".skills.conditional += [{\"name\": \"rails-assets\", \"template\": \"rails-assets.md\", \"parameters\": {...}}]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi

# Monorepo
if jq -e '.conditional_components.has_monorepo' /tmp/audit-{REPO_NAME}.json; then
  jq ".agents.conditional += [{
    \"name\": \"monorepo-module-detector\",
    \"template\": \"monorepo-module-detector.md\",
    \"parameters\": {...}
  }]" /tmp/pipeline-spec-{REPO_NAME}.json > /tmp/spec.tmp && mv /tmp/spec.tmp /tmp/pipeline-spec-{REPO_NAME}.json
fi
```

## Output: Pipeline Specification

Save to `/tmp/pipeline-spec-{REPO_NAME}.json` with structure:

```json
{
  "repo_url": "https://github.com/owner/repo",
  "repo_name": "repo",
  "owner": "owner",
  "agents": {
    "universal": [...],
    "conditional": [...]
  },
  "skills": {
    "universal": [...],
    "conditional": [...]
  },
  "automation": {
    "trigger_label": "ready-to-implement",
    "timeout": 3600
  },
  "audit_summary": {
    "tech_stack": "Kotlin + Android",
    "total_agents": 7,
    "total_skills": 4,
    "conditional_added": ["android-implementer", "android-tester"]
  }
}
```

## Next Step

After pipeline spec is saved, invoke:
1. `agent-generator` to create agent files from templates
2. `skill-generator` to create skill files from templates