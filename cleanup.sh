#!/bin/bash
# Cleanup script to remove duplicate files after restructuring

echo "=== P3DStack Restructuring Cleanup ==="
echo ""
echo "Removing duplicate files..."
echo ""

echo "1. Removing old configs/services directory (all service files)..."
rm -rf configs/services

echo "2. Removing old configs/otel-.yaml..."
rm -f configs/otel-.yaml

echo "3. Removing old configs/grafana.json..."
rm -f configs/grafana.json

echo ""
echo "✓ Cleanup complete!"
echo ""
echo "Files removed:"
echo "  - configs/services/ (entire directory with subdirectories)"
echo "    • jenkins.yml, sonarqube.yml, grafana.yml, harbor.yml"
echo "    • vault.yml, alertmanager.yml, selenium-grid.yml, another.yml"
echo "    • docker-compose.yml"
echo "    • tempo.yml/ subdirectory with:"
echo "      - backstage.yml, che.yml, mattermost.yml, opensearch.yml"
echo "      - prometheus.yml, telemetry.yml, tempo.yml, tempo.yaml"
echo "      - otel-config.yml"
echo "      - focalboard.yml/focalboard.yml (nested directory)"
echo ""
echo "  - configs/otel-.yaml → replaced by configs/otel-config.yaml"
echo "  - configs/grafana.json → replaced by configs/grafana-dashboard.json"
echo ""
echo "All configurations preserved and enhanced in:"
echo "  • services/ (with full OTEL support)"
echo "  • configs/ (improved configuration files)"
