# Developer Setup Guide

## Quick Start for Contributors

### 1. Prerequisites

Install required tools for local validation:

```bash
# Python tools
pip install yamllint

# Node.js tools (if you have npm)
npm install -g markdownlint-cli

# Docker
docker --version
docker-compose --version
```

### 2. Clone and Setup

```bash
# Clone repository
git clone https://github.com/paruff/p3dstack.git
cd p3dstack

# Install pre-commit hook (recommended)
cp pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Make scripts executable
chmod +x verify-production.sh cleanup.sh
```

### 3. Local Validation

Before committing changes, run these checks:

```bash
# Validate all YAML files
yamllint services/*.yml configs/*.yaml docker-compose.yml

# Validate docker-compose
docker-compose config

# Check production readiness
./verify-production.sh

# Lint markdown files
markdownlint '**/*.md' --config .markdownlint.json
```

### 4. Making Changes

#### Adding a New Service

1. Create service file in `services/your-service.yml`
2. Include production-ready features:
   ```yaml
   services:
     your-service:
       image: your/image:version
       container_name: your-service
       restart: unless-stopped
       ports:
         - "PORT:PORT"
       environment:
         - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
         - OTEL_SERVICE_NAME=your-service
         - OTEL_EXPORTER_OTLP_PROTOCOL=grpc
       healthcheck:
         test: ["CMD-SHELL", "your-health-check"]
         interval: 30s
         timeout: 10s
         retries: 3
         start_period: 30s
       deploy:
         resources:
           limits:
             cpus: '1.0'
             memory: 1G
           reservations:
             cpus: '0.25'
             memory: 256M
       depends_on:
         otel-collector:
           condition: service_healthy
       networks:
         - dev-net
       logging:
         driver: "json-file"
         options:
           max-size: "10m"
           max-file: "3"
   ```

3. Add volume declarations to `docker-compose.yml`:
   ```yaml
   volumes:
     your_service_data:
   ```

4. Add include statement to `docker-compose.yml`:
   ```yaml
   include:
     - services/your-service.yml
   ```

5. Update documentation in README.md and PRODUCTION.md

#### Modifying Configuration

1. Edit the relevant config file in `configs/`
2. Validate YAML syntax
3. Test with `docker-compose config`
4. Document changes in PRODUCTION.md

#### Updating Documentation

1. Edit markdown files
2. Run markdown linter: `markdownlint filename.md`
3. Check for broken links
4. Ensure all required sections are present

### 5. Committing Changes

```bash
# Stage your changes
git add .

# Commit (pre-commit hook will run automatically)
git commit -m "Your commit message"

# If pre-commit hook fails, fix issues and try again
```

### 6. Creating Pull Requests

1. Push your branch: `git push origin your-branch`
2. Create PR on GitHub
3. Wait for CI checks to complete
4. All checks must pass:
   - ✅ YAML Validation
   - ✅ Production Config Check
   - ✅ Documentation Check
   - ✅ Security Scan
   - ✅ Docker Compose Test
5. Address any failures or warnings
6. Request review

## CI/CD Pipeline

The GitHub Actions workflow runs automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`

View results: Repository → Actions tab

## Common Tasks

### Testing Locally

```bash
# Start all services
docker-compose up -d

# Check service health
docker-compose ps

# View logs
docker-compose logs -f service-name

# Stop all services
docker-compose down
```

### Updating Dependencies

```bash
# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d
```

### Debugging Issues

```bash
# Check service logs
docker-compose logs service-name

# Inspect container
docker inspect container-name

# Check resource usage
docker stats

# Validate configuration
docker-compose config
```

## Troubleshooting

### Pre-commit Hook Issues

If pre-commit hook fails:
```bash
# Check what failed
git commit -m "test"

# Fix issues, then commit again
```

To temporarily bypass (not recommended):
```bash
git commit --no-verify
```

### CI/CD Failures

1. Check GitHub Actions logs
2. Reproduce locally with same commands
3. Fix issues
4. Push again

### YAML Validation Errors

Common issues:
- Indentation (use 2 spaces)
- Missing colons or spaces
- Lines too long (max 120 chars)
- Invalid YAML syntax

Fix:
```bash
yamllint problematic-file.yml
# Review errors and fix
```

### Docker Compose Errors

Common issues:
- Undefined volumes
- Port conflicts
- Invalid service references
- Missing dependencies

Fix:
```bash
docker-compose config
# Review errors and fix
```

## Best Practices

### Configuration
- ✅ Always include health checks
- ✅ Set resource limits
- ✅ Use explicit container names
- ✅ Configure logging
- ✅ Add OTEL instrumentation
- ✅ Use restart policies
- ✅ Declare all volumes

### Documentation
- ✅ Update README.md for user-facing changes
- ✅ Update PRODUCTION.md for operational changes
- ✅ Include examples
- ✅ Document breaking changes
- ✅ Keep CI_CD.md updated

### Security
- ✅ Never commit secrets
- ✅ Use environment variables
- ✅ Review security scan results
- ✅ Pin image versions
- ✅ Use read-only volumes where possible

### Git Workflow
- ✅ Create feature branches
- ✅ Write descriptive commit messages
- ✅ Keep commits focused
- ✅ Run local checks before pushing
- ✅ Respond to review feedback

## Getting Help

- 📘 [Production Guide](PRODUCTION.md) - Operations and deployment
- 🔄 [CI/CD Documentation](CI_CD.md) - Automated checks
- 🐛 Issues - Report bugs or request features
- 💬 Discussions - Ask questions

## Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [YAML Specification](https://yaml.org/spec/)
- [Markdown Guide](https://www.markdownguide.org/)
