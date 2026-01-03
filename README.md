# p3dstack (Fawkes Dev Platform)
A production-ready product discovery, design and delivery stack in docker compose with comprehensive observability.

> 🚀 **Production Ready**: All services include health checks, restart policies, resource limits, and proper dependency management.

## Quick Links
- 📘 [Production Deployment Guide](PRODUCTION.md) - Detailed production setup and operations
- 🔄 [CI/CD Quality Checks](CI_CD.md) - Automated configuration validation
- 🔧 [Service Configurations](services/) - Individual service definitions
- ⚙️ [Configuration Files](configs/) - OTEL, Prometheus, Tempo, etc.

## Architecture

This platform provides a complete development environment with integrated observability using OpenTelemetry (OTEL).

### Directory Structure

```
p3dstack/
├── docker-compose.yml              # Main orchestrator with service imports
├── services/                       # Individual service definitions
│   ├── jenkins.yml                 # CI/CD automation
│   ├── sonarqube.yml              # Code quality analysis
│   ├── focalboard.yml             # Project management
│   ├── prometheus.yml             # Metrics storage
│   ├── opensearch.yml             # Log storage and search
│   ├── mattermost.yml             # Team collaboration
│   ├── eclipse-che.yml            # Cloud IDE
│   ├── backstage.yml              # Developer portal
│   ├── telemetry.yml              # OTEL Collector
│   ├── tempo.yml                  # Trace storage
│   ├── grafana.yml                # Visualization
│   ├── harbor.yml                 # Container registry
│   ├── vault.yml                  # Secrets management
│   ├── alertmanager.yml           # Alert routing
│   └── selenium-grid.yml          # Browser automation
├── configs/                        # Configuration files
│   ├── otel-config.yaml           # OTEL Collector configuration
│   ├── tempo.yaml                 # Tempo configuration
│   ├── prometheus.yml             # Prometheus scrape config
│   ├── alertmanager.yml           # Alert routing rules
│   └── grafana-dashboard.json     # Grafana dashboards
├── .env                            # Environment variables
└── README.md                       # This file
```

## Observability Stack (OTEL Integration)

All services are configured to send telemetry data through the OpenTelemetry Collector:

- **Logs** → OpenSearch (via OTEL Collector)
- **Metrics** → Prometheus (via OTEL Collector)
- **Traces** → Tempo (via OTEL Collector)

### OTEL Environment Variables

Each service is configured with:
```yaml
environment:
  - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
  - OTEL_SERVICE_NAME=<service-name>
  - OTEL_EXPORTER_OTLP_PROTOCOL=grpc
  - OTEL_METRICS_EXPORTER=otlp
  - OTEL_LOGS_EXPORTER=otlp
  - OTEL_TRACES_EXPORTER=otlp
```

## Production Features ✨

All services are configured with production-ready features:

- ✅ **Health Checks**: Automatic service health monitoring with retries
- ✅ **Restart Policies**: `unless-stopped` for automatic recovery
- ✅ **Resource Limits**: CPU and memory constraints for stability
- ✅ **Dependency Management**: Services start in correct order with health checks
- ✅ **Logging**: Structured JSON logs with rotation (10MB, 3 files)
- ✅ **Container Names**: Explicit naming for easy management
- ✅ **Security**: Database isolation, read-only volumes where appropriate

See [PRODUCTION.md](PRODUCTION.md) for complete deployment guide.

## Quick Start

### Using Make (Recommended)
```bash
# Setup development environment
make setup

# Validate configuration
make validate

# Start services
make start

# Check status
make status
```

### Using Docker Compose
1. **Start all services:**
   ```bash
   docker-compose up -d
   ```

2. **Verify all services are healthy:**
   ```bash
   docker-compose ps
   ```

3. **Access services:**
   - Grafana: http://localhost:3000 (admin/admin)
   - OpenSearch Dashboards: http://localhost:5601
   - Prometheus: http://localhost:9090
   - Tempo: http://localhost:3200
   - Jenkins: http://localhost:8081
   - SonarQube: http://localhost:9000
   - Mattermost: http://localhost:8065
   - Focalboard: http://localhost:8082
   - Eclipse Che: http://localhost:8083
   - Harbor: http://localhost:8084
   - Backstage: http://localhost:7007
   - Vault: http://localhost:8200
   - Traefik Dashboard: http://localhost:8080

3. **View telemetry:**
   - Logs: OpenSearch Dashboards → Discover (index: otel-logs)
   - Metrics: Grafana → Explore → Prometheus datasource
   - Traces: Grafana → Explore → Tempo datasource

## Service Details

### Development Tools
- **Jenkins**: CI/CD automation with OTEL instrumentation
- **SonarQube**: Code quality and security analysis
- **Eclipse Che**: Browser-based IDE
- **Selenium Grid**: Automated browser testing

### Collaboration
- **Mattermost**: Team chat and collaboration
- **Focalboard**: Project and task management
- **Backstage**: Developer portal and service catalog

### Infrastructure
- **Harbor**: Private container registry
- **Vault**: Secrets and credentials management

### Observability
- **OTEL Collector**: Central telemetry collection and routing
- **Prometheus**: Metrics storage and alerting
- **Tempo**: Distributed tracing backend
- **OpenSearch**: Log aggregation and search
- **Grafana**: Unified visualization dashboard
- **Alertmanager**: Alert notification routing

## Maintenance

### Stop all services:
```bash
docker-compose down
```

### Stop and remove volumes:
```bash
docker-compose down -v
```

### View logs:
```bash
docker-compose logs -f <service-name>
```

### Restart a specific service:
```bash
docker-compose restart <service-name>
```
