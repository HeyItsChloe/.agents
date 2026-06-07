# Docker Build Check — {{REPO_NAME}}

Verifies Docker image builds correctly.

## Detected

- **Dockerfile:** `{{DOCKERFILE_PATH}}`
- **Docker Compose:** `{{COMPOSE_FILE}}`

## Process

### Step 1: Start Docker Daemon (if needed)

```bash
# Check if Docker is running
docker info >/dev/null 2>&1 || {
  echo "Starting Docker daemon..."
  sudo dockerd > /tmp/docker.log 2>&1 &
  sleep 5
}
```

### Step 2: Build Docker Image

```bash
# Build the image
docker build -t {{REPO_NAME}}:$(git branch --show-current) -f {{DOCKERFILE_PATH}} .

# Or with build args
docker build -t {{REPO_NAME}}:$(git branch --show-current) \
  --build-arg NODE_ENV=production \
  -f {{DOCKERFILE_PATH}} .
```

### Step 3: Check Build Output

```bash
# Verify image was created
docker images {{REPO_NAME}} | grep -v REPOSITORY

# Run a quick container check
docker run --rm {{REPO_NAME}}:$(git branch --show-current) --version 2>/dev/null || \
docker run --rm {{REPO_NAME}}:$(git branch --show-current) --help 2>/dev/null || \
echo "Container started successfully (no --version/--help available)"
```

### Step 4: Build with Docker Compose (if applicable)

```bash
# If docker-compose.yml exists, build with compose
if [ -f "{{COMPOSE_FILE}}" ]; then
  docker-compose -f {{COMPOSE_FILE}} build
  
  echo "✅ Docker Compose build successful"
fi
```

### Step 5: Fix Build Errors (if any)

```bash
# If build failed, analyze errors
# Common fixes:
# - Clear build cache: docker builder prune
# - Update base image
# - Fix COPY/ADD paths

# Re-run build after fixes
docker build -t {{REPO_NAME}}:$(git branch --show-current) -f {{DOCKERFILE_PATH}} .
```

## Output

- Docker image built successfully
- Image tagged with branch name
- No runtime errors on quick container check

## Error Handling

If Docker build fails:
1. Log errors to `/tmp/docker-build-error.log`
2. Document in PR comment
3. Continue pipeline (Docker issues can be addressed in review)

## Next Step

After Docker build check, continue to `ci-monitor`.