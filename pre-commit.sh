#!/bin/bash
# Pre-commit hook for local quality checks
# Install: cp pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

set -e

echo "🔍 Running pre-commit quality checks..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# Function to run check
run_check() {
    local name=$1
    local command=$2
    
    echo -n "Checking $name... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        ((ERRORS++))
        return 1
    fi
}

# Check if staged files include yml/yaml files
YAML_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(yml|yaml)$' || true)

if [ -n "$YAML_FILES" ]; then
    echo "📝 YAML files detected, running validations..."
    
    # Check if yamllint is installed
    if command -v yamllint &> /dev/null; then
        for file in $YAML_FILES; do
            run_check "YAML syntax in $file" "yamllint '$file'"
        done
    else
        echo -e "${YELLOW}⚠️  yamllint not installed, skipping YAML validation${NC}"
        echo "   Install: pip install yamllint"
    fi
    
    # Validate docker-compose if changed
    if echo "$YAML_FILES" | grep -q "docker-compose.yml"; then
        run_check "docker-compose configuration" "docker-compose config > /dev/null"
    fi
fi

# Check if staged files include markdown files
MD_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.md$' || true)

if [ -n "$MD_FILES" ]; then
    echo "📄 Markdown files detected, running checks..."
    
    # Check if markdownlint is installed
    if command -v markdownlint &> /dev/null; then
        for file in $MD_FILES; do
            run_check "Markdown syntax in $file" "markdownlint '$file' --config .markdownlint.json"
        done
    else
        echo -e "${YELLOW}⚠️  markdownlint not installed, skipping markdown validation${NC}"
        echo "   Install: npm install -g markdownlint-cli"
    fi
fi

# Check if service files were modified
SERVICE_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^services/.*\.yml$' || true)

if [ -n "$SERVICE_FILES" ]; then
    echo "⚙️  Service files detected, running production checks..."
    
    for file in $SERVICE_FILES; do
        # Check for health check
        if ! grep -q "healthcheck:" "$file"; then
            echo -e "${YELLOW}⚠️  $file is missing healthcheck configuration${NC}"
        fi
        
        # Check for restart policy
        if ! grep -q "restart:" "$file"; then
            echo -e "${YELLOW}⚠️  $file is missing restart policy${NC}"
        fi
        
        # Check for resource limits
        if ! grep -q "resources:" "$file"; then
            echo -e "${YELLOW}⚠️  $file is missing resource limits${NC}"
        fi
    done
fi

# Run production verification if script exists
if [ -f "verify-production.sh" ] && [ -n "$SERVICE_FILES" ]; then
    echo "🔬 Running production configuration verification..."
    if ./verify-production.sh > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Production configuration verified"
    else
        echo -e "${YELLOW}⚠️  Production configuration verification has warnings${NC}"
    fi
fi

echo ""
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Pre-commit checks failed with $ERRORS error(s)${NC}"
    echo "Please fix the issues and try again."
    exit 1
else
    echo -e "${GREEN}✅ All pre-commit checks passed!${NC}"
    exit 0
fi
