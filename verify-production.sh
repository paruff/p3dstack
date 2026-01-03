#!/bin/bash
# Verification script to check production-ready configurations

echo "=== P3DStack Production Configuration Verification ==="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if file has a pattern
check_pattern() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if grep -q "$pattern" "$file"; then
        echo -e "${GREEN}✓${NC} $description in $(basename $file)"
        return 0
    else
        echo -e "${RED}✗${NC} Missing $description in $(basename $file)"
        return 1
    fi
}

echo "Checking service configurations..."
echo ""

services=(
    "jenkins"
    "sonarqube"
    "grafana"
    "prometheus"
    "opensearch"
    "tempo"
    "telemetry"
    "harbor"
    "vault"
    "alertmanager"
    "selenium-grid"
    "backstage"
    "eclipse-che"
    "mattermost"
    "focalboard"
)

total_checks=0
passed_checks=0

for service in "${services[@]}"; do
    service_file="services/${service}.yml"
    
    if [ ! -f "$service_file" ]; then
        echo -e "${RED}✗${NC} Service file not found: $service_file"
        continue
    fi
    
    echo "--- Checking $service ---"
    
    # Check for health check
    if check_pattern "$service_file" "healthcheck:" "Health check"; then
        ((passed_checks++))
    fi
    ((total_checks++))
    
    # Check for restart policy
    if check_pattern "$service_file" "restart:" "Restart policy"; then
        ((passed_checks++))
    fi
    ((total_checks++))
    
    # Check for container name
    if check_pattern "$service_file" "container_name:" "Container name"; then
        ((passed_checks++))
    fi
    ((total_checks++))
    
    # Check for resource limits
    if check_pattern "$service_file" "resources:" "Resource limits"; then
        ((passed_checks++))
    fi
    ((total_checks++))
    
    # Check for logging
    if check_pattern "$service_file" "logging:" "Logging config"; then
        ((passed_checks++))
    fi
    ((total_checks++))
    
    # Check for OTEL config
    if check_pattern "$service_file" "OTEL_EXPORTER_OTLP_ENDPOINT" "OTEL config"; then
        ((passed_checks++))
    fi
    ((total_checks++))
    
    echo ""
done

echo "=== Summary ==="
echo ""
echo "Total checks: $total_checks"
echo -e "Passed: ${GREEN}$passed_checks${NC}"
echo -e "Failed: ${RED}$((total_checks - passed_checks))${NC}"
echo ""

percentage=$((passed_checks * 100 / total_checks))
if [ $percentage -ge 90 ]; then
    echo -e "${GREEN}✓ Configuration is production-ready! ($percentage%)${NC}"
    exit 0
elif [ $percentage -ge 70 ]; then
    echo -e "${YELLOW}⚠ Configuration needs improvement ($percentage%)${NC}"
    exit 1
else
    echo -e "${RED}✗ Configuration is not production-ready ($percentage%)${NC}"
    exit 1
fi
