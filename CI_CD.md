# CI/CD Quality Checks Documentation

## Overview

The P3DStack project includes comprehensive automated quality checks that run on every push and pull request to ensure configuration quality, security, and documentation standards.

## GitHub Actions Workflow

### Workflow File
- **Location**: `.github/workflows/quality-check.yml`
- **Triggers**: Push and PR to `main` and `develop` branches
- **Jobs**: 6 parallel jobs with a final summary report

### Jobs Description

#### 1. YAML Validation (`yaml-validation`)
**Purpose**: Ensures all YAML files are syntactically correct and follow best practices.

**Checks**:
- ✅ YAML syntax validation using `yamllint`
- ✅ Docker Compose configuration validation
- ✅ Line length limits (120 chars)
- ✅ Proper formatting and indentation

**Tools**: 
- `yamllint` - YAML linter
- `docker-compose config` - Docker Compose validator

#### 2. Production Config Check (`production-config-check`)
**Purpose**: Verifies all services meet production-ready standards.

**Checks**:
- ✅ All services have health checks
- ✅ All services have restart policies
- ✅ Resource limits are defined
- ✅ OTEL configuration is present
- ✅ Production verification script passes

**Script**: Uses `verify-production.sh`

**Exit Conditions**:
- ❌ **FAIL**: Missing health checks or restart policies
- ⚠️ **WARN**: Missing resource limits or OTEL config (non-blocking)

#### 3. Documentation Check (`documentation-check`)
**Purpose**: Ensures documentation is complete, well-formatted, and up-to-date.

**Checks**:
- ✅ Markdown syntax validation
- ✅ Broken link detection
- ✅ Required documentation files exist
- ✅ Documentation completeness

**Tools**:
- `markdownlint-cli` - Markdown linter
- `github-action-markdown-link-check` - Link checker

**Required Files**:
- `README.md`
- `PRODUCTION.md`

**Required Sections** (in README.md):
- Quick Start
- Architecture
- Observability

#### 4. Security Scan (`security-scan`)
**Purpose**: Identifies security issues and configuration vulnerabilities.

**Checks**:
- ✅ Configuration security scan (Trivy)
- ✅ Hardcoded password detection
- ✅ API key detection
- ✅ Token detection
- ✅ Latest tag usage warning

**Tools**:
- `Trivy` - Security scanner
- Custom regex patterns for secrets

**Security Concerns Detected**:
- Hardcoded passwords in configuration
- Hardcoded API keys
- Hardcoded tokens
- Use of `:latest` image tags

#### 5. Docker Compose Test (`docker-compose-test`)
**Purpose**: Validates Docker Compose configuration integrity.

**Checks**:
- ✅ Valid docker-compose.yml syntax
- ✅ No port conflicts between services
- ✅ All volumes are declared
- ✅ Service definitions are valid

**Validations**:
- Port uniqueness across all services
- Volume declarations match usage
- Service configuration completeness

#### 6. Report Summary (`report-summary`)
**Purpose**: Generates a comprehensive quality report.

**Output**:
- Summary of all job results
- Total service count
- Overall pass/fail status
- Available in GitHub Actions Summary

## Configuration Files

### `.markdownlint.json`
Markdown linting rules:
```json
{
  "MD013": { "line_length": 120 },  // Max line length
  "MD033": false,                    // Allow HTML
  "MD041": false,                    // No title requirement
  "MD024": { "siblings_only": true } // Allow duplicate headers
}
```

### `.markdown-link-check.json`
Link checking configuration:
```json
{
  "ignorePatterns": ["localhost", "127.0.0.1"],
  "timeout": "20s",
  "retryCount": 3
}
```

## Local Development

### Pre-commit Hook

Install the pre-commit hook for local validation:

```bash
cp pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**Features**:
- Runs before each commit
- Validates only staged files
- Provides immediate feedback
- Prevents bad commits

**Checks Performed**:
- YAML syntax validation
- Docker Compose validation
- Markdown linting
- Service configuration checks
- Production readiness verification

### Manual Validation

Run checks manually:

```bash
# YAML validation
yamllint services/*.yml configs/*.yaml

# Docker Compose validation
docker-compose config

# Production verification
./verify-production.sh

# Markdown linting
markdownlint '**/*.md'
```

## Required Tools Installation

### For Developers

```bash
# Python tools
pip install yamllint

# Node.js tools
npm install -g markdownlint-cli

# Docker (should already be installed)
docker --version
docker-compose --version
```

### For CI/CD
All tools are automatically installed in GitHub Actions runners.

## Bypassing Checks (Not Recommended)

### Skip Pre-commit Hook
```bash
git commit --no-verify
```

### Skip CI Checks
Not possible - CI must pass for PR approval.

## Troubleshooting

### Common Issues

#### YAML Validation Fails
```bash
# Check specific file
yamllint services/your-service.yml

# Common issues:
# - Incorrect indentation
# - Missing spaces after colons
# - Lines too long (>120 chars)
```

#### Docker Compose Validation Fails
```bash
# Validate configuration
docker-compose config

# Common issues:
# - Invalid service references
# - Missing volume declarations
# - Port conflicts
```

#### Markdown Linting Fails
```bash
# Check specific file
markdownlint README.md

# Common issues:
# - Missing blank lines
# - Inconsistent list formatting
# - Lines too long
```

#### Health Check Missing
Add health check to service:
```yaml
healthcheck:
  test: ["CMD-SHELL", "your-health-check-command"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 30s
```

#### Resource Limits Missing
Add resource limits to service:
```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 1G
    reservations:
      cpus: '0.25'
      memory: 256M
```

## Best Practices

### Configuration Management
1. ✅ Always add health checks to new services
2. ✅ Define resource limits for all services
3. ✅ Use specific image tags, not `:latest`
4. ✅ Document configuration changes in PRODUCTION.md
5. ✅ Test locally before pushing

### Documentation
1. ✅ Keep README.md up-to-date
2. ✅ Document breaking changes
3. ✅ Include examples for complex configurations
4. ✅ Check for broken links regularly
5. ✅ Use consistent formatting

### Security
1. ✅ Never commit secrets or passwords
2. ✅ Use environment variables for sensitive data
3. ✅ Reference Vault for production secrets
4. ✅ Review security scan results
5. ✅ Update images regularly

## Monitoring CI/CD Status

### GitHub Actions Dashboard
1. Navigate to repository
2. Click "Actions" tab
3. View workflow runs
4. Check job details and logs

### Pull Request Checks
- All checks must pass before merge
- Review comments and warnings
- Address failures promptly

### Status Badges
Add to README.md:
```markdown
[![Quality Check](https://github.com/paruff/p3dstack/actions/workflows/quality-check.yml/badge.svg)](https://github.com/paruff/p3dstack/actions/workflows/quality-check.yml)
```

## Extending the Workflow

### Adding New Checks

1. Edit `.github/workflows/quality-check.yml`
2. Add new job or step
3. Test in a branch first
4. Document the new check here

### Example: Adding a Custom Check
```yaml
custom-check:
  name: My Custom Check
  runs-on: ubuntu-latest
  steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Run custom validation
      run: |
        echo "Running custom check..."
        # Your validation logic here
```

## Performance Optimization

### Job Parallelization
- All validation jobs run in parallel
- Total workflow time: ~3-5 minutes
- Independent job failures don't block others

### Caching
Consider adding caching for:
- Python packages
- Node.js packages
- Docker layers

Example:
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
```

## Support

### Questions or Issues?
1. Check this documentation
2. Review GitHub Actions logs
3. Check [PRODUCTION.md](PRODUCTION.md) for configuration help
4. Review service-specific documentation in `services/`

### Contributing
When adding new services:
1. Follow existing patterns
2. Include all production-ready features
3. Update documentation
4. Ensure all CI checks pass
