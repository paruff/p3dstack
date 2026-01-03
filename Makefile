.PHONY: help validate test lint clean install setup start stop restart logs status

# Colors for output
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m

help: ## Show this help message
	@echo "P3DStack - Development Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

install: ## Install required development tools
	@echo "Installing development tools..."
	pip install yamllint
	npm install -g markdownlint-cli
	@echo "$(GREEN)✓ Tools installed$(NC)"

setup: install ## Setup development environment (install tools + pre-commit hook)
	@echo "Setting up development environment..."
	cp pre-commit.sh .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
	chmod +x verify-production.sh
	chmod +x cleanup.sh
	@echo "$(GREEN)✓ Development environment ready$(NC)"

validate: ## Run all validation checks
	@echo "Running validation checks..."
	@make validate-yaml
	@make validate-compose
	@make validate-production
	@echo "$(GREEN)✓ All validations passed$(NC)"

validate-yaml: ## Validate YAML syntax
	@echo "Validating YAML files..."
	@yamllint services/*.yml configs/*.yaml docker-compose.yml 2>/dev/null || (echo "$(YELLOW)⚠ Install yamllint: pip install yamllint$(NC)" && exit 1)

validate-compose: ## Validate docker-compose configuration
	@echo "Validating docker-compose..."
	@docker-compose config > /dev/null && echo "$(GREEN)✓ docker-compose valid$(NC)"

validate-production: ## Run production configuration checks
	@echo "Running production checks..."
	@./verify-production.sh

lint: ## Lint markdown files
	@echo "Linting markdown files..."
	@markdownlint '**/*.md' --config .markdownlint.json || echo "$(YELLOW)⚠ Install markdownlint: npm install -g markdownlint-cli$(NC)"

test: validate lint ## Run all tests (validate + lint)
	@echo "$(GREEN)✓ All tests passed$(NC)"

start: ## Start all services
	@echo "Starting all services..."
	docker-compose up -d
	@echo "$(GREEN)✓ Services started$(NC)"
	@make status

stop: ## Stop all services
	@echo "Stopping all services..."
	docker-compose stop
	@echo "$(GREEN)✓ Services stopped$(NC)"

restart: stop start ## Restart all services

down: ## Stop and remove all services
	@echo "Removing all services..."
	docker-compose down
	@echo "$(GREEN)✓ Services removed$(NC)"

logs: ## Show logs for all services
	docker-compose logs -f

logs-service: ## Show logs for specific service (usage: make logs-service SERVICE=jenkins)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(YELLOW)Usage: make logs-service SERVICE=<service-name>$(NC)"; \
		exit 1; \
	fi
	docker-compose logs -f $(SERVICE)

status: ## Show status of all services
	@docker-compose ps

health: ## Check health of all services
	@echo "Service Health Status:"
	@docker-compose ps --format json | jq -r '.[] | "\(.Name): \(.Health)"' 2>/dev/null || docker-compose ps

pull: ## Pull latest images
	@echo "Pulling latest images..."
	docker-compose pull
	@echo "$(GREEN)✓ Images updated$(NC)"

update: pull restart ## Update and restart services

clean: ## Remove all containers, volumes, and orphans
	@echo "$(YELLOW)WARNING: This will remove all data!$(NC)"
	@read -p "Are you sure? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "$(GREEN)✓ Cleanup complete$(NC)"; \
	fi

backup: ## Backup all volumes (creates backups/ directory)
	@echo "Backing up volumes..."
	@mkdir -p backups
	@docker run --rm -v jenkins_data:/data -v $(PWD)/backups:/backup \
		alpine tar czf /backup/jenkins-$(shell date +%Y%m%d).tar.gz /data
	@docker run --rm -v sonarqube_data:/data -v $(PWD)/backups:/backup \
		alpine tar czf /backup/sonarqube-$(shell date +%Y%m%d).tar.gz /data
	@docker run --rm -v opensearch_data:/data -v $(PWD)/backups:/backup \
		alpine tar czf /backup/opensearch-$(shell date +%Y%m%d).tar.gz /data
	@echo "$(GREEN)✓ Backups created in backups/ directory$(NC)"

stats: ## Show resource usage statistics
	@docker stats --no-stream

network: ## Show network information
	@docker network inspect p3dstack_dev-net

volumes: ## List all volumes
	@docker volume ls | grep p3dstack

inspect: ## Inspect a specific service (usage: make inspect SERVICE=jenkins)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(YELLOW)Usage: make inspect SERVICE=<service-name>$(NC)"; \
		exit 1; \
	fi
	@docker inspect $(SERVICE)

shell: ## Open shell in a service container (usage: make shell SERVICE=jenkins)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(YELLOW)Usage: make shell SERVICE=<service-name>$(NC)"; \
		exit 1; \
	fi
	@docker-compose exec $(SERVICE) /bin/sh || docker-compose exec $(SERVICE) /bin/bash

dev: ## Start services in development mode (attached logs)
	docker-compose up

prod: validate ## Start services in production mode
	@echo "Starting in production mode..."
	@docker-compose up -d
	@echo "$(GREEN)✓ Services started in production mode$(NC)"
	@make health

ci: ## Run CI checks locally (simulates GitHub Actions)
	@echo "Running CI checks..."
	@make validate
	@make lint
	@echo "$(GREEN)✓ CI checks passed$(NC)"

docs: ## Open documentation in browser
	@echo "Documentation files:"
	@echo "  - README.md"
	@echo "  - PRODUCTION.md"
	@echo "  - CI_CD.md"
	@echo "  - CONTRIBUTING.md"

list-services: ## List all available services
	@echo "Available services:"
	@ls -1 services/*.yml | sed 's/services\//  - /' | sed 's/.yml//'

ports: ## Show all exposed ports
	@echo "Exposed ports:"
	@grep -r '- "' services/ | grep -E '[0-9]+:[0-9]+' | sort -u

info: ## Show system information
	@echo "System Information:"
	@echo "  Docker Version: $(shell docker --version)"
	@echo "  Docker Compose Version: $(shell docker-compose --version)"
	@echo "  Services: $(shell ls -1 services/*.yml | wc -l)"
	@echo "  Running Containers: $(shell docker-compose ps -q | wc -l)"

default: help
